import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:gap/gap.dart';
import 'package:url_launcher/url_launcher.dart';
import '../../theme/app_theme.dart';
import '../../models/lead.dart';
import '../../services/places_service.dart';
import '../../widgets/auth_widgets.dart';

class ResultsScreen extends StatefulWidget {
  final SearchFilters filters;
  final VoidCallback onBack;

  const ResultsScreen({
    super.key,
    required this.filters,
    required this.onBack,
  });

  @override
  State<ResultsScreen> createState() => _ResultsScreenState();
}

class _ResultsScreenState extends State<ResultsScreen> {
  final _service = PlacesService();

  List<Lead> _leads = [];
  bool _isLoading = true;
  String? _error;
  int _fetched = 0;
  int _total = 0;
  String _sortBy = 'rating'; // rating | reviews | name

  @override
  void initState() {
    super.initState();
    _runSearch();
  }

  Future<void> _runSearch() async {
    setState(() {
      _isLoading = true;
      _error = null;
      _leads = [];
    });

    try {
      final leads = await _service.searchLeads(
        filters: widget.filters,
        maxResults: 60,
        onProgress: (f, t) => setState(() {
          _fetched = f;
          _total = t;
        }),
      );
      setState(() {
        _leads = leads;
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _error = e.toString().replaceFirst('Exception: ', '');
        _isLoading = false;
      });
    }
  }

  List<Lead> get _sorted {
    final copy = List<Lead>.from(_leads);
    switch (_sortBy) {
      case 'rating':
        copy.sort((a, b) => (b.rating ?? 0).compareTo(a.rating ?? 0));
      case 'reviews':
        copy.sort((a, b) => (b.reviewCount ?? 0).compareTo(a.reviewCount ?? 0));
      case 'name':
        copy.sort((a, b) => a.name.compareTo(b.name));
    }
    return copy;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.bg,
      body: Stack(
        children: [
          const GridBackground(),
          SafeArea(
            child: Column(
              children: [
                _buildHeader(),
                if (_isLoading) _buildProgress(),
                if (_error != null) _buildError(),
                if (!_isLoading && _error == null) _buildSortBar(),
                Expanded(
                  child: _isLoading
                      ? const SizedBox()
                      : _error != null
                          ? const SizedBox()
                          : _leads.isEmpty
                              ? _buildEmpty()
                              : _buildList(),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildHeader() {
    return Container(
      padding: const EdgeInsets.fromLTRB(20, 16, 20, 16),
      decoration: const BoxDecoration(
        border: Border(bottom: BorderSide(color: AppTheme.borderDim)),
      ),
      child: Row(
        children: [
          GestureDetector(
            onTap: widget.onBack,
            child: Container(
              width: 38,
              height: 38,
              decoration: BoxDecoration(
                color: AppTheme.bgInput,
                borderRadius: BorderRadius.circular(10),
                border: Border.all(color: AppTheme.borderDim),
              ),
              child: const Icon(Icons.arrow_back_ios_new_rounded,
                  size: 15, color: AppTheme.textSecondary),
            ),
          ),
          const Gap(14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  widget.filters.businessQuery,
                  style: GoogleFonts.spaceMono(
                    fontSize: 16,
                    fontWeight: FontWeight.w700,
                    color: AppTheme.textPrimary,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                Text(
                  widget.filters.location,
                  style: GoogleFonts.dmSans(
                    fontSize: 12,
                    color: AppTheme.textSecondary,
                  ),
                ),
              ],
            ),
          ),
          if (!_isLoading && _leads.isNotEmpty)
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
              decoration: BoxDecoration(
                color: AppTheme.greenGlow,
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: AppTheme.greenDim),
              ),
              child: Text(
                '${_leads.length} leads',
                style: GoogleFonts.spaceMono(
                  fontSize: 12,
                  fontWeight: FontWeight.w700,
                  color: AppTheme.green,
                ),
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildProgress() {
    final pct = _total > 0 ? _fetched / _total : 0.0;
    return Expanded(
      child: Center(
        child: Padding(
          padding: const EdgeInsets.all(40),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              SizedBox(
                width: 64,
                height: 64,
                child: CircularProgressIndicator(
                  value: _total > 0 ? pct : null,
                  valueColor: const AlwaysStoppedAnimation(AppTheme.green),
                  strokeWidth: 2,
                  backgroundColor: AppTheme.borderDim,
                ),
              ),
              const Gap(24),
              Text(
                _total > 0 ? 'Scanning $_fetched of $_total' : 'Searching...',
                style: GoogleFonts.spaceMono(
                  fontSize: 14,
                  color: AppTheme.textPrimary,
                  fontWeight: FontWeight.w700,
                ),
              ),
              const Gap(8),
              Text(
                'Finding businesses without a website',
                style: GoogleFonts.dmSans(
                  fontSize: 13,
                  color: AppTheme.textSecondary,
                ),
              ),
              if (_total > 0) ...[
                const Gap(20),
                ClipRRect(
                  borderRadius: BorderRadius.circular(4),
                  child: LinearProgressIndicator(
                    value: pct,
                    backgroundColor: AppTheme.borderDim,
                    valueColor: const AlwaysStoppedAnimation(AppTheme.green),
                    minHeight: 3,
                  ),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildError() {
    return Expanded(
      child: Center(
        child: Padding(
          padding: const EdgeInsets.all(32),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: 60,
                height: 60,
                decoration: BoxDecoration(
                  color: AppTheme.error.withOpacity(0.1),
                  shape: BoxShape.circle,
                  border: Border.all(color: AppTheme.error.withOpacity(0.3)),
                ),
                child: const Icon(Icons.error_outline_rounded,
                    color: AppTheme.error, size: 28),
              ),
              const Gap(20),
              Text(
                'Search failed',
                style: GoogleFonts.spaceMono(
                  fontSize: 18,
                  fontWeight: FontWeight.w700,
                  color: AppTheme.textPrimary,
                ),
              ),
              const Gap(8),
              Text(
                _error!,
                style: GoogleFonts.dmSans(
                  fontSize: 13,
                  color: AppTheme.textSecondary,
                  height: 1.5,
                ),
                textAlign: TextAlign.center,
              ),
              const Gap(28),
              ElevatedButton.icon(
                onPressed: _runSearch,
                icon: const Icon(Icons.refresh_rounded, size: 18),
                label: const Text('Try again'),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildSortBar() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
      decoration: const BoxDecoration(
        border: Border(bottom: BorderSide(color: AppTheme.borderDim)),
      ),
      child: Row(
        children: [
          Text('Sort by',
              style: GoogleFonts.dmSans(
                  fontSize: 12, color: AppTheme.textSecondary)),
          const Gap(10),
          _SortChip(
              label: 'Rating',
              value: 'rating',
              active: _sortBy == 'rating',
              onTap: () => setState(() => _sortBy = 'rating')),
          const Gap(6),
          _SortChip(
              label: 'Reviews',
              value: 'reviews',
              active: _sortBy == 'reviews',
              onTap: () => setState(() => _sortBy = 'reviews')),
          const Gap(6),
          _SortChip(
              label: 'Name',
              value: 'name',
              active: _sortBy == 'name',
              onTap: () => setState(() => _sortBy = 'name')),
        ],
      ),
    );
  }

  Widget _buildEmpty() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(40),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text('🎯', style: TextStyle(fontSize: 48)),
            const Gap(20),
            Text(
              'No leads found',
              style: GoogleFonts.spaceMono(
                fontSize: 18,
                fontWeight: FontWeight.w700,
                color: AppTheme.textPrimary,
              ),
            ),
            const Gap(8),
            Text(
              'Try a different business type, location, or loosen your filters.',
              style: GoogleFonts.dmSans(
                fontSize: 13,
                color: AppTheme.textSecondary,
                height: 1.5,
              ),
              textAlign: TextAlign.center,
            ),
            const Gap(28),
            ElevatedButton(
              onPressed: widget.onBack,
              child: const Text('Adjust search'),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildList() {
    final leads = _sorted;
    return ListView.separated(
      padding: const EdgeInsets.all(16),
      itemCount: leads.length,
      separatorBuilder: (_, __) => const Gap(10),
      itemBuilder: (_, i) => LeadCard(
        lead: leads[i],
        onSaveToggle: () =>
            setState(() => leads[i].isSaved = !leads[i].isSaved),
      ),
    );
  }
}

// ── Lead card ─────────────────────────────────────────────
class LeadCard extends StatelessWidget {
  final Lead lead;
  final VoidCallback onSaveToggle;

  const LeadCard({super.key, required this.lead, required this.onSaveToggle});

  Future<void> _openMaps(String url) async {
    final uri = Uri.parse(url);
    if (await canLaunchUrl(uri)) await launchUrl(uri);
  }

  void _copyPhone(BuildContext context) {
    if (lead.phone == null) return;
    Clipboard.setData(ClipboardData(text: lead.phone!));
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Phone copied',
            style: GoogleFonts.dmSans(color: AppTheme.textPrimary)),
        backgroundColor: AppTheme.bgCard,
        behavior: SnackBarBehavior.floating,
        duration: const Duration(seconds: 1),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: AppTheme.bgCard,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(
          color: lead.isSaved ? AppTheme.greenDim : AppTheme.borderDim,
          width: lead.isSaved ? 1.5 : 1,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Top section
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 14, 12, 10),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        lead.name,
                        style: GoogleFonts.dmSans(
                          fontSize: 15,
                          fontWeight: FontWeight.w600,
                          color: AppTheme.textPrimary,
                        ),
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                      const Gap(4),
                      Row(
                        children: [
                          const Icon(Icons.location_on_outlined,
                              size: 12, color: AppTheme.textSecondary),
                          const Gap(3),
                          Expanded(
                            child: Text(
                              lead.address,
                              style: GoogleFonts.dmSans(
                                fontSize: 12,
                                color: AppTheme.textSecondary,
                              ),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
                const Gap(8),
                GestureDetector(
                  onTap: onSaveToggle,
                  child: AnimatedContainer(
                    duration: const Duration(milliseconds: 200),
                    width: 36,
                    height: 36,
                    decoration: BoxDecoration(
                      color:
                          lead.isSaved ? AppTheme.greenGlow : AppTheme.bgInput,
                      borderRadius: BorderRadius.circular(10),
                      border: Border.all(
                        color:
                            lead.isSaved ? AppTheme.green : AppTheme.borderDim,
                      ),
                    ),
                    child: Icon(
                      lead.isSaved
                          ? Icons.bookmark_rounded
                          : Icons.bookmark_outline_rounded,
                      size: 18,
                      color: lead.isSaved
                          ? AppTheme.green
                          : AppTheme.textSecondary,
                    ),
                  ),
                ),
              ],
            ),
          ),

          // Stats row
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Wrap(
              spacing: 6,
              runSpacing: 6,
              children: [
                if (lead.rating != null)
                  _StatChip(
                    icon: Icons.star_rounded,
                    label: lead.rating!.toStringAsFixed(1),
                    color: const Color(0xFFF59E0B),
                  ),
                if (lead.reviewCount != null)
                  _StatChip(
                    icon: Icons.rate_review_outlined,
                    label: '${lead.reviewCount} reviews',
                  ),
                if (!lead.hasWebsite)
                  _StatChip(
                    icon: Icons.language_outlined,
                    label: 'No website',
                    color: AppTheme.green,
                    highlight: true,
                  ),
                if (!lead.hasPhone)
                  _StatChip(
                    icon: Icons.phone_outlined,
                    label: 'No phone',
                    color: AppTheme.green,
                    highlight: true,
                  ),
              ],
            ),
          ),

          const Gap(12),
          const Divider(height: 1, color: AppTheme.borderDim),

          // Actions row
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 6),
            child: Row(
              children: [
                if (lead.phone != null)
                  _ActionBtn(
                    icon: Icons.copy_rounded,
                    label: 'Copy phone',
                    onTap: () => _copyPhone(context),
                  ),
                if (lead.googleMapsUrl != null)
                  _ActionBtn(
                    icon: Icons.map_outlined,
                    label: 'View on Maps',
                    onTap: () => _openMaps(lead.googleMapsUrl!),
                  ),
                _ActionBtn(
                  icon: Icons.message_outlined,
                  label: 'DM template',
                  onTap: () {
                    // TODO: open DM template bottom sheet
                  },
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _StatChip extends StatelessWidget {
  final IconData icon;
  final String label;
  final Color? color;
  final bool highlight;

  const _StatChip({
    required this.icon,
    required this.label,
    this.color,
    this.highlight = false,
  });

  @override
  Widget build(BuildContext context) {
    final c = color ?? AppTheme.textSecondary;
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: highlight ? AppTheme.greenGlow : AppTheme.bgInput,
        borderRadius: BorderRadius.circular(6),
        border: Border.all(
          color: highlight ? AppTheme.greenDim : AppTheme.borderDim,
        ),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 12, color: c),
          const Gap(4),
          Text(label,
              style: GoogleFonts.dmSans(
                fontSize: 11,
                color: c,
                fontWeight: FontWeight.w500,
              )),
        ],
      ),
    );
  }
}

class _ActionBtn extends StatelessWidget {
  final IconData icon;
  final String label;
  final VoidCallback onTap;

  const _ActionBtn({
    required this.icon,
    required this.label,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return TextButton.icon(
      onPressed: onTap,
      icon: Icon(icon, size: 14),
      label: Text(label),
      style: TextButton.styleFrom(
        foregroundColor: AppTheme.textSecondary,
        textStyle:
            GoogleFonts.dmSans(fontSize: 12, fontWeight: FontWeight.w500),
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 6),
        minimumSize: Size.zero,
        tapTargetSize: MaterialTapTargetSize.shrinkWrap,
      ),
    );
  }
}

class _SortChip extends StatelessWidget {
  final String label, value;
  final bool active;
  final VoidCallback onTap;

  const _SortChip({
    required this.label,
    required this.value,
    required this.active,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
        decoration: BoxDecoration(
          color: active ? AppTheme.greenGlow : AppTheme.bgInput,
          borderRadius: BorderRadius.circular(6),
          border: Border.all(
            color: active ? AppTheme.green : AppTheme.borderDim,
          ),
        ),
        child: Text(label,
            style: GoogleFonts.dmSans(
              fontSize: 12,
              color: active ? AppTheme.green : AppTheme.textSecondary,
              fontWeight: active ? FontWeight.w600 : FontWeight.w400,
            )),
      ),
    );
  }
}
