import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:gap/gap.dart';
import '../../theme/app_theme.dart';
import '../../models/lead.dart';

class FilterPanel extends StatefulWidget {
  final SearchFilters filters;
  const FilterPanel({super.key, required this.filters});

  @override
  State<FilterPanel> createState() => _FilterPanelState();
}

class _FilterPanelState extends State<FilterPanel> {
  late SearchFilters _f;

  final _minReviewCtrl = TextEditingController();
  final _maxReviewCtrl = TextEditingController();

  @override
  void initState() {
    super.initState();
    _f = widget.filters;
    _minReviewCtrl.text = _f.minReviews?.toString() ?? '';
    _maxReviewCtrl.text = _f.maxReviews?.toString() ?? '';
  }

  @override
  void dispose() {
    _minReviewCtrl.dispose();
    _maxReviewCtrl.dispose();
    super.dispose();
  }

  void _apply() {
    final minR = int.tryParse(_minReviewCtrl.text);
    final maxR = int.tryParse(_maxReviewCtrl.text);
    Navigator.pop(
        context,
        _f.copyWith(
          minReviews: minR,
          maxReviews: maxR,
        ));
  }

  void _reset() {
    setState(() {
      _f = SearchFilters(noWebsiteOnly: true);
      _minReviewCtrl.clear();
      _maxReviewCtrl.clear();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(
        color: AppTheme.bgCard,
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      padding: EdgeInsets.only(
        bottom: MediaQuery.of(context).viewInsets.bottom,
      ),
      child: SingleChildScrollView(
        padding: const EdgeInsets.fromLTRB(24, 0, 24, 32),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Handle bar
            Center(
              child: Container(
                margin: const EdgeInsets.symmetric(vertical: 14),
                width: 36,
                height: 4,
                decoration: BoxDecoration(
                  color: AppTheme.borderDim,
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
            ),

            // Header
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Advanced filters',
                  style: GoogleFonts.spaceMono(
                    fontSize: 18,
                    fontWeight: FontWeight.w700,
                    color: AppTheme.textPrimary,
                  ),
                ),
                TextButton(
                  onPressed: _reset,
                  child: Text('Reset all',
                      style: GoogleFonts.dmSans(
                          fontSize: 13, color: AppTheme.textSecondary)),
                ),
              ],
            ),

            const Gap(24),
            _Divider(),

            // ── Presence filters ───────────────────────────
            const Gap(20),
            _SectionTitle('Business presence'),
            const Gap(14),

            _SwitchRow(
              label: 'No website only',
              subtitle: 'Only show businesses without a website',
              value: _f.noWebsiteOnly,
              onChanged: (v) =>
                  setState(() => _f = _f.copyWith(noWebsiteOnly: v)),
            ),
            const Gap(12),
            _SwitchRow(
              label: 'No phone only',
              subtitle: 'Only show businesses with no phone listed',
              value: _f.noPhoneOnly,
              onChanged: (v) =>
                  setState(() => _f = _f.copyWith(noPhoneOnly: v)),
            ),
            const Gap(12),
            _SwitchRow(
              label: 'Operational only',
              subtitle: 'Exclude permanently or temporarily closed',
              value: _f.operationalOnly,
              onChanged: (v) =>
                  setState(() => _f = _f.copyWith(operationalOnly: v)),
            ),

            const Gap(20),
            _Divider(),

            // ── Rating filter ──────────────────────────────
            const Gap(20),
            _SectionTitle('Google rating'),
            const Gap(6),
            Text(
              _f.minRating == null
                  ? 'Any rating'
                  : 'Between ${_f.minRating!.toStringAsFixed(1)} and ${_f.maxRating?.toStringAsFixed(1) ?? '5.0'}',
              style: GoogleFonts.spaceMono(
                fontSize: 13,
                color: AppTheme.green,
                fontWeight: FontWeight.w700,
              ),
            ),
            const Gap(12),
            // Min rating slider
            _SliderRow(
              label: 'Min rating',
              value: _f.minRating ?? 0,
              min: 0,
              max: 5,
              divisions: 50,
              onChanged: (v) => setState(
                  () => _f = _f.copyWith(minRating: v == 0 ? null : v)),
            ),
            const Gap(8),
            _SliderRow(
              label: 'Max rating',
              value: _f.maxRating ?? 5,
              min: 0,
              max: 5,
              divisions: 50,
              onChanged: (v) => setState(
                  () => _f = _f.copyWith(maxRating: v == 5 ? null : v)),
            ),

            const Gap(20),
            _Divider(),

            // ── Review count ───────────────────────────────
            const Gap(20),
            _SectionTitle('Review count'),
            const Gap(14),
            Row(
              children: [
                Expanded(
                  child: _NumberInput(
                    controller: _minReviewCtrl,
                    label: 'Min reviews',
                    hint: '0',
                  ),
                ),
                const Gap(12),
                Expanded(
                  child: _NumberInput(
                    controller: _maxReviewCtrl,
                    label: 'Max reviews',
                    hint: 'Any',
                  ),
                ),
              ],
            ),

            const Gap(32),

            // ── Apply button ───────────────────────────────
            ElevatedButton(
              onPressed: _apply,
              child: const Text('Apply filters'),
            ),
          ],
        ),
      ),
    );
  }
}

// ── Small reusable widgets ────────────────────────────────

class _SectionTitle extends StatelessWidget {
  final String text;
  const _SectionTitle(this.text);
  @override
  Widget build(BuildContext context) => Text(text,
      style: GoogleFonts.dmSans(
        fontSize: 14,
        fontWeight: FontWeight.w600,
        color: AppTheme.textPrimary,
      ));
}

class _Divider extends StatelessWidget {
  @override
  Widget build(BuildContext context) =>
      const Divider(color: AppTheme.borderDim, height: 1);
}

class _SwitchRow extends StatelessWidget {
  final String label;
  final String subtitle;
  final bool value;
  final ValueChanged<bool> onChanged;

  const _SwitchRow({
    required this.label,
    required this.subtitle,
    required this.value,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(label,
                  style: GoogleFonts.dmSans(
                    fontSize: 14,
                    color: AppTheme.textPrimary,
                    fontWeight: FontWeight.w500,
                  )),
              Text(subtitle,
                  style: GoogleFonts.dmSans(
                    fontSize: 12,
                    color: AppTheme.textSecondary,
                  )),
            ],
          ),
        ),
        Switch(
          value: value,
          onChanged: onChanged,
          activeColor: AppTheme.green,
          activeTrackColor: AppTheme.greenGlow,
          inactiveThumbColor: AppTheme.textSecondary,
          inactiveTrackColor: AppTheme.bgInput,
        ),
      ],
    );
  }
}

class _SliderRow extends StatelessWidget {
  final String label;
  final double value, min, max;
  final int divisions;
  final ValueChanged<double> onChanged;

  const _SliderRow({
    required this.label,
    required this.value,
    required this.min,
    required this.max,
    required this.divisions,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        SizedBox(
          width: 80,
          child: Text(label,
              style: GoogleFonts.dmSans(
                fontSize: 12,
                color: AppTheme.textSecondary,
              )),
        ),
        Expanded(
          child: SliderTheme(
            data: SliderTheme.of(context).copyWith(
              activeTrackColor: AppTheme.green,
              inactiveTrackColor: AppTheme.borderDim,
              thumbColor: AppTheme.green,
              overlayColor: AppTheme.greenGlow,
              trackHeight: 2,
              thumbShape: const RoundSliderThumbShape(enabledThumbRadius: 7),
            ),
            child: Slider(
              value: value,
              min: min,
              max: max,
              divisions: divisions,
              onChanged: onChanged,
            ),
          ),
        ),
        SizedBox(
          width: 32,
          child: Text(
            value.toStringAsFixed(1),
            style: GoogleFonts.spaceMono(
              fontSize: 12,
              color: AppTheme.green,
              fontWeight: FontWeight.w700,
            ),
            textAlign: TextAlign.right,
          ),
        ),
      ],
    );
  }
}

class _NumberInput extends StatelessWidget {
  final TextEditingController controller;
  final String label;
  final String hint;

  const _NumberInput({
    required this.controller,
    required this.label,
    required this.hint,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label,
            style: GoogleFonts.dmSans(
              fontSize: 12,
              color: AppTheme.textSecondary,
              fontWeight: FontWeight.w500,
            )),
        const Gap(6),
        TextFormField(
          controller: controller,
          keyboardType: TextInputType.number,
          style: GoogleFonts.dmSans(
            color: AppTheme.textPrimary,
            fontSize: 15,
          ),
          decoration: InputDecoration(hintText: hint),
        ),
      ],
    );
  }
}
