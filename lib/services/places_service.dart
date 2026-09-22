import 'dart:convert';
import 'dart:developer' as dev;
import 'package:http/http.dart' as http;
import '../models/lead.dart';

class PlacesService {
  // TODO: Move to remote config — never hardcode in production
  static const String _apiKey = 'AIzaSyBdBN_lnSqQnhEJ1TvckhPaKRLbId1imTY';

  static const String _geocodeUrl =
      'https://maps.googleapis.com/maps/api/geocode/json';
  static const String _searchUrl =
      'https://maps.googleapis.com/maps/api/place/textsearch/json';
  static const String _detailUrl =
      'https://maps.googleapis.com/maps/api/place/details/json';

  /// Convert a city/address string to lat/lng
  Future<({double lat, double lng})> geocode(String location) async {
    final uri = Uri.parse(_geocodeUrl).replace(
      queryParameters: {'address': location, 'key': _apiKey},
    );

    dev.log('[LeadHunter] Geocoding: $location', name: 'PlacesService');
    final res = await http.get(uri);
    final data = jsonDecode(res.body) as Map<String, dynamic>;
    final status = data['status'] as String? ?? 'UNKNOWN';
    dev.log('[LeadHunter] Geocode status: $status', name: 'PlacesService');

    if (status != 'OK') {
      final msg = data['error_message'] as String? ?? '';
      throw Exception(
        'Could not find "$location". ($status${msg.isNotEmpty ? ': $msg' : ''})',
      );
    }

    final loc = data['results'][0]['geometry']['location'];
    final lat = (loc['lat'] as num).toDouble();
    final lng = (loc['lng'] as num).toDouble();
    dev.log('[LeadHunter] Coordinates: $lat, $lng', name: 'PlacesService');
    return (lat: lat, lng: lng);
  }

  /// Search for places matching query near location, returns list of place IDs
  Future<List<String>> searchPlaceIds({
    required String query,
    required double lat,
    required double lng,
    required int radiusMeters,
    int maxResults = 60,
  }) async {
    final placeIds = <String>[];
    String? pageToken;

    while (placeIds.length < maxResults) {
      Map<String, String> params;

      if (pageToken != null) {
        params = {'pagetoken': pageToken, 'key': _apiKey};
        await Future.delayed(const Duration(seconds: 2));
      } else {
        final latStr = lat.toStringAsFixed(6);
        final lngStr = lng.toStringAsFixed(6);
        final radius = radiusMeters.clamp(1, 50000);
        params = {
          'query': query,
          'location': '$latStr,$lngStr',
          'radius': '$radius',
          'key': _apiKey,
        };
      }

      // Log the full URL (key redacted) for debugging
      final debugUri = Uri.parse(_searchUrl).replace(queryParameters: {
        ...params,
        'key': '***REDACTED***',
      });
      dev.log('[LeadHunter] Search URL: $debugUri', name: 'PlacesService');

      final uri = Uri.parse(_searchUrl).replace(queryParameters: params);
      final res = await http.get(uri);

      dev.log('[LeadHunter] HTTP status: ${res.statusCode}',
          name: 'PlacesService');
      dev.log(
          '[LeadHunter] Response body: ${res.body.substring(0, res.body.length.clamp(0, 400))}',
          name: 'PlacesService');

      if (res.statusCode != 200) {
        throw Exception('HTTP ${res.statusCode} from Places API');
      }

      final data = jsonDecode(res.body) as Map<String, dynamic>;
      final status = data['status'] as String? ?? 'UNKNOWN';
      final errMsg = data['error_message'] as String? ?? '';

      dev.log('[LeadHunter] Places status: $status  errMsg: $errMsg',
          name: 'PlacesService');

      if (status == 'ZERO_RESULTS') break;
      if (status != 'OK' && status != 'NEXT_PAGE_TOKEN') {
        throw Exception(_friendlyError(status, errMsg));
      }

      for (final place in (data['results'] as List? ?? [])) {
        if (placeIds.length >= maxResults) break;
        final id = place['place_id'] as String?;
        if (id != null) placeIds.add(id);
      }

      pageToken = data['next_page_token'] as String?;
      if (pageToken == null) break;
    }

    dev.log('[LeadHunter] Found ${placeIds.length} place IDs',
        name: 'PlacesService');
    return placeIds;
  }

  /// Fetch full details for a single place
  Future<Lead> getPlaceDetails(String placeId) async {
    final uri = Uri.parse(_detailUrl).replace(queryParameters: {
      'place_id': placeId,
      'fields': [
        'place_id',
        'name',
        'formatted_address',
        'formatted_phone_number',
        'website',
        'rating',
        'user_ratings_total',
        'business_status',
        'url',
        'types',
      ].join(','),
      'key': _apiKey,
    });

    final res = await http.get(uri);
    final data = jsonDecode(res.body) as Map<String, dynamic>;

    if (data['status'] != 'OK') {
      throw Exception('Place detail lookup failed: ${data['status']}');
    }

    return Lead.fromPlacesApi(data['result'] as Map<String, dynamic>);
  }

  /// Full search + filter pipeline
  Future<List<Lead>> searchLeads({
    required SearchFilters filters,
    int maxResults = 60,
    void Function(int fetched, int total)? onProgress,
  }) async {
    final coords = await geocode(filters.location);

    final ids = await searchPlaceIds(
      query: filters.businessQuery,
      lat: coords.lat,
      lng: coords.lng,
      radiusMeters: (filters.radiusKm * 1000).round(),
      maxResults: maxResults,
    );

    final leads = <Lead>[];
    for (int i = 0; i < ids.length; i++) {
      try {
        final lead = await getPlaceDetails(ids[i]);
        onProgress?.call(i + 1, ids.length);
        await Future.delayed(const Duration(milliseconds: 100));

        if (filters.noWebsiteOnly && lead.hasWebsite) continue;
        if (filters.noPhoneOnly && lead.hasPhone) continue;
        if (filters.operationalOnly && !lead.isOperational) continue;
        if (filters.minRating != null &&
            (lead.rating ?? 0) < filters.minRating!) continue;
        if (filters.maxRating != null &&
            (lead.rating ?? 5) > filters.maxRating!) continue;
        if (filters.minReviews != null &&
            (lead.reviewCount ?? 0) < filters.minReviews!) continue;
        if (filters.maxReviews != null &&
            (lead.reviewCount ?? 0) > filters.maxReviews!) continue;

        leads.add(lead);
      } catch (_) {
        continue;
      }
    }

    return leads;
  }

  String _friendlyError(String status, String apiMsg) {
    switch (status) {
      case 'INVALID_REQUEST':
        return 'Invalid search request — check the debug log in your terminal for the exact URL and response.';
      case 'REQUEST_DENIED':
        return 'API key rejected. Make sure the Places API is enabled and your key has no HTTP referrer restrictions set.';
      case 'OVER_QUERY_LIMIT':
        return 'API quota exceeded. Check your billing settings in Google Cloud Console.';
      default:
        return 'Places API error: $status${apiMsg.isNotEmpty ? ' — $apiMsg' : ''}';
    }
  }
}
