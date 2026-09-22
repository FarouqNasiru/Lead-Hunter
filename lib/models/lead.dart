// ── Lead model ────────────────────────────────────────────
class Lead {
  final String placeId;
  final String name;
  final String address;
  final String? phone;
  final String? website;
  final double? rating;
  final int? reviewCount;
  final String? status; // OPERATIONAL | CLOSED_TEMPORARILY | CLOSED_PERMANENTLY
  final String? googleMapsUrl;
  final List<String> types;
  bool isSaved;
  String? notes;
  LeadStage stage;

  Lead({
    required this.placeId,
    required this.name,
    required this.address,
    this.phone,
    this.website,
    this.rating,
    this.reviewCount,
    this.status,
    this.googleMapsUrl,
    this.types = const [],
    this.isSaved = false,
    this.notes,
    this.stage = LeadStage.new_,
  });

  bool get hasWebsite => website != null && website!.isNotEmpty;
  bool get hasPhone => phone != null && phone!.isNotEmpty;
  bool get isOperational => status == 'OPERATIONAL' || status == null;

  factory Lead.fromPlacesApi(Map<String, dynamic> json) {
    return Lead(
      placeId: json['place_id'] ?? '',
      name: json['name'] ?? 'Unknown',
      address: json['formatted_address'] ?? json['vicinity'] ?? '',
      phone: json['formatted_phone_number'],
      website: json['website'],
      rating: (json['rating'] as num?)?.toDouble(),
      reviewCount: json['user_ratings_total'] as int?,
      status: json['business_status'],
      googleMapsUrl: json['url'],
      types: List<String>.from(json['types'] ?? []),
    );
  }

  Map<String, dynamic> toFirestore() => {
        'placeId': placeId,
        'name': name,
        'address': address,
        'phone': phone,
        'website': website,
        'rating': rating,
        'reviewCount': reviewCount,
        'status': status,
        'googleMapsUrl': googleMapsUrl,
        'types': types,
        'isSaved': isSaved,
        'notes': notes,
        'stage': stage.name,
      };
}

enum LeadStage { new_, contacted, interested, closed }

extension LeadStageLabel on LeadStage {
  String get label => switch (this) {
        LeadStage.new_ => 'New',
        LeadStage.contacted => 'Contacted',
        LeadStage.interested => 'Interested',
        LeadStage.closed => 'Closed',
      };
}

// ── Search filters model ──────────────────────────────────
class SearchFilters {
  // Location
  String location;
  double radiusKm;

  // Business type
  String businessQuery;

  // No-website / no-phone toggles
  bool noWebsiteOnly;
  bool noPhoneOnly;

  // Rating
  double? minRating;
  double? maxRating;

  // Review count
  int? minReviews;
  int? maxReviews;

  // Status
  bool operationalOnly;

  // Freelancer preset
  FreelancerPreset? preset;

  SearchFilters({
    this.location = '',
    this.radiusKm = 5,
    this.businessQuery = '',
    this.noWebsiteOnly = true,
    this.noPhoneOnly = false,
    this.minRating,
    this.maxRating,
    this.minReviews,
    this.maxReviews,
    this.operationalOnly = true,
    this.preset,
  });

  SearchFilters copyWith({
    String? location,
    double? radiusKm,
    String? businessQuery,
    bool? noWebsiteOnly,
    bool? noPhoneOnly,
    double? minRating,
    double? maxRating,
    int? minReviews,
    int? maxReviews,
    bool? operationalOnly,
    FreelancerPreset? preset,
  }) =>
      SearchFilters(
        location: location ?? this.location,
        radiusKm: radiusKm ?? this.radiusKm,
        businessQuery: businessQuery ?? this.businessQuery,
        noWebsiteOnly: noWebsiteOnly ?? this.noWebsiteOnly,
        noPhoneOnly: noPhoneOnly ?? this.noPhoneOnly,
        minRating: minRating ?? this.minRating,
        maxRating: maxRating ?? this.maxRating,
        minReviews: minReviews ?? this.minReviews,
        maxReviews: maxReviews ?? this.maxReviews,
        operationalOnly: operationalOnly ?? this.operationalOnly,
        preset: preset ?? this.preset,
      );

  // Count active filters (for badge)
  int get activeCount {
    int c = 0;
    if (noWebsiteOnly) c++;
    if (noPhoneOnly) c++;
    if (minRating != null) c++;
    if (maxRating != null) c++;
    if (minReviews != null) c++;
    if (maxReviews != null) c++;
    if (!operationalOnly) c++;
    return c;
  }
}

// ── Freelancer presets ────────────────────────────────────
enum FreelancerPreset {
  webDeveloper,
  graphicDesigner,
  copywriter,
  socialMediaManager,
  photographer,
  seoSpecialist,
  appDeveloper,
  translator,
  accountant,
  videoEditor,
}

extension FreelancerPresetInfo on FreelancerPreset {
  String get label => switch (this) {
        FreelancerPreset.webDeveloper => 'Web Developer',
        FreelancerPreset.graphicDesigner => 'Graphic Designer',
        FreelancerPreset.copywriter => 'Copywriter',
        FreelancerPreset.socialMediaManager => 'Social Media Manager',
        FreelancerPreset.photographer => 'Photographer',
        FreelancerPreset.seoSpecialist => 'SEO Specialist',
        FreelancerPreset.appDeveloper => 'App Developer',
        FreelancerPreset.translator => 'Translator',
        FreelancerPreset.accountant => 'Accountant',
        FreelancerPreset.videoEditor => 'Video Editor',
      };

  String get icon => switch (this) {
        FreelancerPreset.webDeveloper => '💻',
        FreelancerPreset.graphicDesigner => '🎨',
        FreelancerPreset.copywriter => '✍️',
        FreelancerPreset.socialMediaManager => '📱',
        FreelancerPreset.photographer => '📷',
        FreelancerPreset.seoSpecialist => '🔍',
        FreelancerPreset.appDeveloper => '📲',
        FreelancerPreset.translator => '🌐',
        FreelancerPreset.accountant => '📊',
        FreelancerPreset.videoEditor => '🎬',
      };

  // Default business types to search for this preset
  List<String> get suggestedQueries => switch (this) {
        FreelancerPreset.webDeveloper => [
            'restaurant',
            'plumber',
            'hair salon',
            'gym',
            'dentist',
            'law firm'
          ],
        FreelancerPreset.graphicDesigner => [
            'print shop',
            'bakery',
            'coffee shop',
            'boutique',
            'florist'
          ],
        FreelancerPreset.copywriter => [
            'real estate agency',
            'insurance agency',
            'consulting firm',
            'startup'
          ],
        FreelancerPreset.socialMediaManager => [
            'restaurant',
            'gym',
            'spa',
            'hotel',
            'retail store'
          ],
        FreelancerPreset.photographer => [
            'wedding venue',
            'restaurant',
            'hotel',
            'real estate agency',
            'gym'
          ],
        FreelancerPreset.seoSpecialist => [
            'plumber',
            'electrician',
            'dentist',
            'lawyer',
            'accountant'
          ],
        FreelancerPreset.appDeveloper => [
            'restaurant',
            'pharmacy',
            'clinic',
            'fitness center',
            'school'
          ],
        FreelancerPreset.translator => [
            'law firm',
            'medical clinic',
            'travel agency',
            'import export'
          ],
        FreelancerPreset.accountant => [
            'small business',
            'startup',
            'retail store',
            'contractor'
          ],
        FreelancerPreset.videoEditor => [
            'gym',
            'restaurant',
            'hotel',
            'real estate agency',
            'school'
          ],
      };
}
