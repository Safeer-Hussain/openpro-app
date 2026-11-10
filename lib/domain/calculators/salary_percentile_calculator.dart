class SalaryBenchmark {
  final double p25;
  final double p50;
  final double p75;
  final double p90;
  final double percentile;
  final String tier;

  const SalaryBenchmark({
    required this.p25,
    required this.p50,
    required this.p75,
    required this.p90,
    required this.percentile,
    required this.tier,
  });

  String get formattedPercentile =>
      '${percentile.toStringAsFixed(0)}th Percentile';
}

class SalaryPercentileCalculator {
  static const Map<String, List<double>> _baseTiers = {
    'junior': [85000, 105000, 125000, 145000],
    'mid': [120000, 145000, 170000, 195000],
    'senior': [155000, 185000, 215000, 245000],
    'lead': [185000, 220000, 255000, 290000],
    'principal': [220000, 265000, 310000, 360000],
  };

  static double getRoleMultiplier(String role) {
    final lower = role.toLowerCase();
    if (lower.contains('ai') ||
        lower.contains('ml') ||
        lower.contains('machine learning')) {
      return 1.15;
    }
    if (lower.contains('lead') ||
        lower.contains('architect') ||
        lower.contains('principal')) {
      return 1.10;
    }
    if (lower.contains('mobile') ||
        lower.contains('flutter') ||
        lower.contains('backend') ||
        lower.contains('cloud')) {
      return 1.05;
    }
    return 1.0;
  }

  static double getLocationMultiplier(String location) {
    final lower = location.toLowerCase();
    if (lower.contains('san francisco') ||
        lower.contains('bay area') ||
        lower.contains('new york') ||
        lower.contains('nyc')) {
      return 1.20;
    }
    if (lower.contains('seattle') ||
        lower.contains('austin') ||
        lower.contains('boston')) {
      return 1.10;
    }
    if (lower.contains('london') ||
        lower.contains('uk') ||
        lower.contains('europe') ||
        lower.contains('germany')) {
      return 0.85;
    }
    return 1.0;
  }

  static SalaryBenchmark calculate({
    required String seniority,
    required String role,
    required String location,
    required double candidateSalary,
  }) {
    final normalizedSeniority = seniority.toLowerCase().trim();
    List<double> rawTier =
        _baseTiers[normalizedSeniority] ?? _baseTiers['senior']!;

    final roleMult = getRoleMultiplier(role);
    final locMult = getLocationMultiplier(location);
    final combinedMult = roleMult * locMult;

    final p25 = rawTier[0] * combinedMult;
    final p50 = rawTier[1] * combinedMult;
    final p75 = rawTier[2] * combinedMult;
    final p90 = rawTier[3] * combinedMult;

    double calculatedPercentile;
    if (candidateSalary <= p25) {
      final floor = p25 * 0.6;
      if (candidateSalary <= floor) {
        calculatedPercentile = 5.0;
      } else {
        calculatedPercentile =
            5.0 + ((candidateSalary - floor) / (p25 - floor)) * 20.0;
      }
    } else if (candidateSalary <= p50) {
      calculatedPercentile =
          25.0 + ((candidateSalary - p25) / (p50 - p25)) * 25.0;
    } else if (candidateSalary <= p75) {
      calculatedPercentile =
          50.0 + ((candidateSalary - p50) / (p75 - p50)) * 25.0;
    } else if (candidateSalary <= p90) {
      calculatedPercentile =
          75.0 + ((candidateSalary - p75) / (p90 - p75)) * 15.0;
    } else {
      final ceiling = p90 * 1.3;
      if (candidateSalary >= ceiling) {
        calculatedPercentile = 99.0;
      } else {
        calculatedPercentile =
            90.0 + ((candidateSalary - p90) / (ceiling - p90)) * 9.0;
      }
    }

    final clampedPercentile = calculatedPercentile.clamp(1.0, 99.0);

    String tierName;
    if (clampedPercentile >= 90) {
      tierName = 'Executive Tier';
    } else if (clampedPercentile >= 75) {
      tierName = 'Top Quartile';
    } else if (clampedPercentile >= 50) {
      tierName = 'Market Competitive';
    } else {
      tierName = 'Entry / Standard Tier';
    }

    return SalaryBenchmark(
      p25: p25,
      p50: p50,
      p75: p75,
      p90: p90,
      percentile: clampedPercentile,
      tier: tierName,
    );
  }
}
