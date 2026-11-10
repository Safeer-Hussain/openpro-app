import 'package:flutter/material.dart';

import '../../../../domain/calculators/salary_percentile_calculator.dart';
import '../../../../domain/entities/job_entity.dart';

class SalaryDistributionCard extends StatefulWidget {
  final JobEntity? job;
  final double? candidateSalary;
  final String? role;
  final String? seniority;
  final String? location;

  const SalaryDistributionCard({
    super.key,
    this.job,
    this.candidateSalary,
    this.role,
    this.seniority,
    this.location,
  });

  @override
  State<SalaryDistributionCard> createState() => _SalaryDistributionCardState();
}

class _SalaryDistributionCardState extends State<SalaryDistributionCard> {
  late double _currentSalary;

  @override
  void initState() {
    super.initState();
    _currentSalary =
        widget.candidateSalary ??
        _parseSalary(widget.job?.salaryBand ?? '160000');
  }

  double _parseSalary(String raw) {
    final cleaned = raw.replaceAll(RegExp(r'[^0-9]'), '');
    if (cleaned.length >= 6) {
      return double.tryParse(cleaned.substring(0, 6)) ?? 160000;
    }
    final val = double.tryParse(cleaned) ?? 160;
    if (val < 1000) {
      return val * 1000;
    }
    return val;
  }

  String _formatCurrency(double amount) {
    if (amount >= 1000) {
      return '\$${(amount / 1000).toStringAsFixed(0)}k';
    }
    return '\$${amount.toStringAsFixed(0)}';
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final role = widget.role ?? widget.job?.title ?? 'Senior Mobile Engineer';
    final seniority = widget.seniority ?? 'Senior';
    final location = widget.location ?? widget.job?.location ?? 'Remote';

    final benchmark = SalaryPercentileCalculator.calculate(
      seniority: seniority,
      role: role,
      location: location,
      candidateSalary: _currentSalary,
    );

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: colorScheme.surfaceContainer,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: colorScheme.outlineVariant.withValues(alpha: 0.5),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Row(
            children: [
              Icon(
                Icons.analytics_outlined,
                size: 20,
                color: colorScheme.primary,
              ),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  'Market Compensation Benchmark',
                  style: Theme.of(context).textTheme.titleSmall?.copyWith(
                    fontWeight: FontWeight.bold,
                    color: colorScheme.onSurface,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: colorScheme.primaryContainer,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Text(
                  benchmark.tier,
                  style: Theme.of(context).textTheme.labelSmall?.copyWith(
                    color: colorScheme.onPrimaryContainer,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 6),
          Text(
            'Estimated for $role ($location)',
            style: Theme.of(context).textTheme.bodySmall
                ?.copyWith(color: colorScheme.onSurfaceVariant),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
          const SizedBox(height: 16),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Target: ${_formatCurrency(_currentSalary)}',
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  fontWeight: FontWeight.bold,
                  color: colorScheme.onSurface,
                ),
              ),
              Text(
                benchmark.formattedPercentile,
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  fontWeight: FontWeight.bold,
                  color: colorScheme.primary,
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),
          _buildPercentileBar(context, benchmark, colorScheme),
          const SizedBox(height: 14),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              _buildMarkerLabel(
                context,
                '25th',
                _formatCurrency(benchmark.p25),
                colorScheme,
              ),
              _buildMarkerLabel(
                context,
                '50th (Median)',
                _formatCurrency(benchmark.p50),
                colorScheme,
              ),
              _buildMarkerLabel(
                context,
                '75th',
                _formatCurrency(benchmark.p75),
                colorScheme,
              ),
              _buildMarkerLabel(
                context,
                '90th',
                _formatCurrency(benchmark.p90),
                colorScheme,
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildPercentileBar(
    BuildContext context,
    SalaryBenchmark benchmark,
    ColorScheme colorScheme,
  ) {
    final progress = (benchmark.percentile / 100.0).clamp(0.02, 0.98);

    return LayoutBuilder(
      builder: (context, constraints) {
        final barWidth = constraints.maxWidth;
        final pinPosition = barWidth * progress;

        return Column(
          children: [
            SizedBox(
              height: 24,
              child: Stack(
                clipBehavior: Clip.none,
                children: [
                  Positioned(
                    left: (pinPosition - 10).clamp(0.0, barWidth - 20),
                    top: 0,
                    child: Column(
                      children: [
                        Icon(
                          Icons.arrow_drop_down,
                          size: 20,
                          color: colorScheme.primary,
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            Container(
              height: 10,
              width: double.infinity,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(6),
                color: colorScheme.surfaceContainerHighest,
              ),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(6),
                child: Row(
                  children: [
                    Expanded(
                      flex: (benchmark.percentile * 10).toInt().clamp(1, 990),
                      child: Container(
                        decoration: BoxDecoration(
                          gradient: LinearGradient(
                            colors: [
                              colorScheme.primary.withValues(alpha: 0.6),
                              colorScheme.primary,
                            ],
                          ),
                        ),
                      ),
                    ),
                    Expanded(
                      flex: ((100 - benchmark.percentile) * 10).toInt().clamp(
                        1,
                        990,
                      ),
                      child: Container(color: Colors.transparent),
                    ),
                  ],
                ),
              ),
            ),
          ],
        );
      },
    );
  }

  Widget _buildMarkerLabel(
    BuildContext context,
    String title,
    String value,
    ColorScheme colorScheme,
  ) {
    return Column(
      children: [
        Text(
          title,
          style: Theme.of(context).textTheme.labelSmall
              ?.copyWith(color: colorScheme.onSurfaceVariant, fontSize: 10),
        ),
        const SizedBox(height: 2),
        Text(
          value,
          style: Theme.of(context).textTheme.labelSmall?.copyWith(
            fontWeight: FontWeight.bold,
            color: colorScheme.onSurface,
            fontSize: 11,
          ),
        ),
      ],
    );
  }
}
