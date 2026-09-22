import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:gap/gap.dart';
import '../../theme/app_theme.dart';
import '../../models/lead.dart';
import '../../widgets/auth_widgets.dart';
import 'filter_panel.dart';

class SearchScreen extends StatefulWidget {
  final void Function(SearchFilters filters) onSearch;

  const SearchScreen({super.key, required this.onSearch});

  @override
  State<SearchScreen> createState() => _SearchScreenState();
}

class _SearchScreenState extends State<SearchScreen> {
  final _locationCtrl = TextEditingController();
  final _queryCtrl = TextEditingController();
  SearchFilters _filters = SearchFilters(noWebsiteOnly: true);
  FreelancerPreset? _activePreset;

  @override
  void dispose() {
    _locationCtrl.dispose();
    _queryCtrl.dispose();
    super.dispose();
  }

  void _applyPreset(FreelancerPreset preset) {
    setState(() {
      _activePreset = preset;
      _filters = _filters.copyWith(preset: preset);
      // Auto-fill first suggested query
      if (_queryCtrl.text.isEmpty) {
        _queryCtrl.text = preset.suggestedQueries.first;
        _filters =
            _filters.copyWith(businessQuery: preset.suggestedQueries.first);
      }
    });
  }

  void _openFilters() async {
    final updated = await showModalBottomSheet<SearchFilters>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => FilterPanel(filters: _filters),
    );
    if (updated != null) setState(() => _filters = updated);
  }

  void _handleSearch() {
    final loc = _locationCtrl.text.trim();
    final query = _queryCtrl.text.trim();
    if (loc.isEmpty || query.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            'Enter a location and business type to search.',
            style: GoogleFonts.dmSans(color: AppTheme.textPrimary),
          ),
          backgroundColor: AppTheme.bgCard,
          behavior: SnackBarBehavior.floating,
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
        ),
      );
      return;
    }
    widget.onSearch(_filters.copyWith(location: loc, businessQuery: query));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.bg,
      body: Stack(
        children: [
          const GridBackground(),
          const GlowAccent(),
          SafeArea(
            child: SingleChildScrollView(
              padding: const EdgeInsets.symmetric(horizontal: 24),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Gap(32),

                  // Header row
                  FadeSlideIn(
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Find Leads',
                              style: GoogleFonts.spaceMono(
                                fontSize: 24,
                                fontWeight: FontWeight.w700,
                                color: AppTheme.textPrimary,
                              ),
                            ),
                            Text(
                              'Businesses without a website',
                              style: GoogleFonts.dmSans(
                                fontSize: 13,
                                color: AppTheme.textSecondary,
                              ),
                            ),
                          ],
                        ),
                        const AppLogo(size: 40),
                      ],
                    ),
                  ),

                  const Gap(32),

                  // ── Preset pills ───────────────────────────────
                  FadeSlideIn(
                    delay: const Duration(milliseconds: 80),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        _SectionLabel('Your field'),
                        const Gap(10),
                        Wrap(
                          spacing: 8,
                          runSpacing: 8,
                          children: FreelancerPreset.values.map((p) {
                            final active = _activePreset == p;
                            return GestureDetector(
                              onTap: () => _applyPreset(p),
                              child: AnimatedContainer(
                                duration: const Duration(milliseconds: 200),
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 14,
                                  vertical: 8,
                                ),
                                decoration: BoxDecoration(
                                  color: active
                                      ? AppTheme.greenGlow
                                      : AppTheme.bgInput,
                                  borderRadius: BorderRadius.circular(32),
                                  border: Border.all(
                                    color: active
                                        ? AppTheme.green
                                        : AppTheme.borderDim,
                                    width: active ? 1.5 : 1,
                                  ),
                                ),
                                child: Text(
                                  '${p.icon} ${p.label}',
                                  style: GoogleFonts.dmSans(
                                    fontSize: 13,
                                    fontWeight: active
                                        ? FontWeight.w600
                                        : FontWeight.w400,
                                    color: active
                                        ? AppTheme.green
                                        : AppTheme.textSecondary,
                                  ),
                                ),
                              ),
                            );
                          }).toList(),
                        ),
                      ],
                    ),
                  ),

                  const Gap(28),

                  // ── Location field ─────────────────────────────
                  FadeSlideIn(
                    delay: const Duration(milliseconds: 140),
                    child: _FormField(
                      label: 'Location',
                      child: TextFormField(
                        controller: _locationCtrl,
                        textInputAction: TextInputAction.next,
                        style: GoogleFonts.dmSans(
                          color: AppTheme.textPrimary,
                          fontSize: 15,
                        ),
                        decoration: InputDecoration(
                          hintText: 'City, suburb or address',
                          prefixIcon: const Icon(
                            Icons.location_on_outlined,
                            color: AppTheme.textSecondary,
                            size: 20,
                          ),
                          suffixIcon: _locationCtrl.text.isNotEmpty
                              ? IconButton(
                                  icon: const Icon(Icons.close_rounded,
                                      size: 18, color: AppTheme.textSecondary),
                                  onPressed: () =>
                                      setState(() => _locationCtrl.clear()),
                                )
                              : null,
                        ),
                        onChanged: (_) => setState(() {}),
                      ),
                    ),
                  ),

                  const Gap(16),

                  // ── Business type field ────────────────────────
                  FadeSlideIn(
                    delay: const Duration(milliseconds: 180),
                    child: _FormField(
                      label: 'Business type',
                      child: TextFormField(
                        controller: _queryCtrl,
                        textInputAction: TextInputAction.search,
                        style: GoogleFonts.dmSans(
                          color: AppTheme.textPrimary,
                          fontSize: 15,
                        ),
                        decoration: InputDecoration(
                          hintText: 'e.g. restaurant, plumber, hair salon',
                          prefixIcon: const Icon(
                            Icons.search_rounded,
                            color: AppTheme.textSecondary,
                            size: 20,
                          ),
                          suffixIcon: _queryCtrl.text.isNotEmpty
                              ? IconButton(
                                  icon: const Icon(Icons.close_rounded,
                                      size: 18, color: AppTheme.textSecondary),
                                  onPressed: () =>
                                      setState(() => _queryCtrl.clear()),
                                )
                              : null,
                        ),
                        onChanged: (_) => setState(() {}),
                        onFieldSubmitted: (_) => _handleSearch(),
                      ),
                    ),
                  ),

                  // Suggested queries (when preset is active)
                  if (_activePreset != null) ...[
                    const Gap(10),
                    FadeSlideIn(
                      child: Wrap(
                        spacing: 6,
                        children: _activePreset!.suggestedQueries.map((q) {
                          return GestureDetector(
                            onTap: () => setState(() {
                              _queryCtrl.text = q;
                              _filters = _filters.copyWith(businessQuery: q);
                            }),
                            child: Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 10,
                                vertical: 5,
                              ),
                              decoration: BoxDecoration(
                                color: AppTheme.bgCard,
                                borderRadius: BorderRadius.circular(6),
                                border: Border.all(color: AppTheme.borderDim),
                              ),
                              child: Text(
                                q,
                                style: GoogleFonts.dmSans(
                                  fontSize: 12,
                                  color: AppTheme.textSecondary,
                                ),
                              ),
                            ),
                          );
                        }).toList(),
                      ),
                    ),
                  ],

                  const Gap(24),

                  // ── Radius slider ──────────────────────────────
                  FadeSlideIn(
                    delay: const Duration(milliseconds: 220),
                    child: Container(
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: AppTheme.bgCard,
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(color: AppTheme.borderDim),
                      ),
                      child: Column(
                        children: [
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text(
                                'Search radius',
                                style: GoogleFonts.dmSans(
                                  fontSize: 13,
                                  fontWeight: FontWeight.w500,
                                  color: AppTheme.textSecondary,
                                ),
                              ),
                              Container(
                                padding: const EdgeInsets.symmetric(
                                    horizontal: 10, vertical: 4),
                                decoration: BoxDecoration(
                                  color: AppTheme.greenGlow,
                                  borderRadius: BorderRadius.circular(6),
                                ),
                                child: Text(
                                  '${_filters.radiusKm.round()} km',
                                  style: GoogleFonts.spaceMono(
                                    fontSize: 12,
                                    fontWeight: FontWeight.w700,
                                    color: AppTheme.green,
                                  ),
                                ),
                              ),
                            ],
                          ),
                          SliderTheme(
                            data: SliderTheme.of(context).copyWith(
                              activeTrackColor: AppTheme.green,
                              inactiveTrackColor: AppTheme.borderDim,
                              thumbColor: AppTheme.green,
                              overlayColor: AppTheme.greenGlow,
                              trackHeight: 2,
                            ),
                            child: Slider(
                              value: _filters.radiusKm,
                              min: 1,
                              max: 50,
                              divisions: 49,
                              onChanged: (v) => setState(
                                () => _filters = _filters.copyWith(radiusKm: v),
                              ),
                            ),
                          ),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text('1 km',
                                  style: GoogleFonts.dmSans(
                                      fontSize: 11, color: AppTheme.textHint)),
                              Text('50 km',
                                  style: GoogleFonts.dmSans(
                                      fontSize: 11, color: AppTheme.textHint)),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ),

                  const Gap(20),

                  // ── Quick toggle chips ─────────────────────────
                  FadeSlideIn(
                    delay: const Duration(milliseconds: 260),
                    child: Row(
                      children: [
                        _ToggleChip(
                          label: 'No website',
                          active: _filters.noWebsiteOnly,
                          onTap: () => setState(() => _filters =
                              _filters.copyWith(
                                  noWebsiteOnly: !_filters.noWebsiteOnly)),
                        ),
                        const Gap(8),
                        _ToggleChip(
                          label: 'No phone',
                          active: _filters.noPhoneOnly,
                          onTap: () => setState(() => _filters = _filters
                              .copyWith(noPhoneOnly: !_filters.noPhoneOnly)),
                        ),
                        const Gap(8),
                        _ToggleChip(
                          label: 'Open only',
                          active: _filters.operationalOnly,
                          onTap: () => setState(() => _filters =
                              _filters.copyWith(
                                  operationalOnly: !_filters.operationalOnly)),
                        ),
                      ],
                    ),
                  ),

                  const Gap(16),

                  // ── Advanced filters button ────────────────────
                  FadeSlideIn(
                    delay: const Duration(milliseconds: 290),
                    child: GestureDetector(
                      onTap: _openFilters,
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 16, vertical: 12),
                        decoration: BoxDecoration(
                          color: AppTheme.bgCard,
                          borderRadius: BorderRadius.circular(10),
                          border: Border.all(color: AppTheme.borderDim),
                        ),
                        child: Row(
                          children: [
                            const Icon(Icons.tune_rounded,
                                color: AppTheme.textSecondary, size: 18),
                            const Gap(10),
                            Text('Advanced filters',
                                style: GoogleFonts.dmSans(
                                    fontSize: 14,
                                    color: AppTheme.textSecondary)),
                            const Spacer(),
                            if (_filters.activeCount > 0)
                              Container(
                                padding: const EdgeInsets.symmetric(
                                    horizontal: 8, vertical: 3),
                                decoration: BoxDecoration(
                                  color: AppTheme.green,
                                  borderRadius: BorderRadius.circular(12),
                                ),
                                child: Text('${_filters.activeCount}',
                                    style: GoogleFonts.spaceMono(
                                        fontSize: 11,
                                        fontWeight: FontWeight.w700,
                                        color: AppTheme.bg)),
                              ),
                            const Gap(6),
                            const Icon(Icons.chevron_right_rounded,
                                color: AppTheme.textSecondary, size: 18),
                          ],
                        ),
                      ),
                    ),
                  ),

                  const Gap(32),

                  // ── Search CTA ─────────────────────────────────
                  FadeSlideIn(
                    delay: const Duration(milliseconds: 320),
                    child: ElevatedButton.icon(
                      onPressed: _handleSearch,
                      icon: const Icon(Icons.search_rounded, size: 20),
                      label: const Text('Hunt for leads'),
                    ),
                  ),

                  const Gap(40),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// ── Helper widgets ────────────────────────────────────────

class _SectionLabel extends StatelessWidget {
  final String text;
  const _SectionLabel(this.text);
  @override
  Widget build(BuildContext context) => Text(text,
      style: GoogleFonts.dmSans(
        fontSize: 13,
        fontWeight: FontWeight.w500,
        color: AppTheme.textSecondary,
        letterSpacing: 0.3,
      ));
}

class _FormField extends StatelessWidget {
  final String label;
  final Widget child;
  const _FormField({required this.label, required this.child});

  @override
  Widget build(BuildContext context) => Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [_SectionLabel(label), const Gap(8), child],
      );
}

class _ToggleChip extends StatelessWidget {
  final String label;
  final bool active;
  final VoidCallback onTap;

  const _ToggleChip({
    required this.label,
    required this.active,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 180),
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 9),
        decoration: BoxDecoration(
          color: active ? AppTheme.greenGlow : AppTheme.bgInput,
          borderRadius: BorderRadius.circular(8),
          border: Border.all(
            color: active ? AppTheme.green : AppTheme.borderDim,
            width: active ? 1.5 : 1,
          ),
        ),
        child: Text(
          label,
          style: GoogleFonts.dmSans(
            fontSize: 13,
            fontWeight: active ? FontWeight.w600 : FontWeight.w400,
            color: active ? AppTheme.green : AppTheme.textSecondary,
          ),
        ),
      ),
    );
  }
}
