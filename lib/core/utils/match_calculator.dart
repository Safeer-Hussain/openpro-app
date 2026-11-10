class MatchCalculator {
  static int calculateScore({
    required List<String> candidateSkills,
    required String candidateTitle,
    required List<String> jobSkills,
    required String jobTitle,
    required String workplaceType,
  }) {
    if (jobSkills.isEmpty) return 75;

    final normalizedCandidateSkills = candidateSkills
        .map((s) => s.trim().toLowerCase())
        .toSet();
    final normalizedJobSkills = jobSkills
        .map((s) => s.trim().toLowerCase())
        .toSet();

    // 1. Skill Match Weight: 60%
    int matchedSkillsCount = 0;
    for (final skill in normalizedJobSkills) {
      if (normalizedCandidateSkills.contains(skill) ||
          normalizedCandidateSkills.any(
            (cs) => cs.contains(skill) || skill.contains(cs),
          )) {
        matchedSkillsCount++;
      }
    }

    final double skillScore =
        (matchedSkillsCount / normalizedJobSkills.length) * 60.0;

    // 2. Role Title Overlap Weight: 25%
    final candidateTokens = candidateTitle
        .toLowerCase()
        .replaceAll(RegExp(r'[^a-z0-9 ]'), '')
        .split(' ')
        .where((t) => t.length > 2)
        .toSet();
    final jobTokens = jobTitle
        .toLowerCase()
        .replaceAll(RegExp(r'[^a-z0-9 ]'), '')
        .split(' ')
        .where((t) => t.length > 2)
        .toSet();

    int matchedTitleTokens = 0;
    for (final token in jobTokens) {
      if (candidateTokens.contains(token)) {
        matchedTitleTokens++;
      }
    }
    final double titleScore = jobTokens.isEmpty
        ? 15.0
        : (matchedTitleTokens / jobTokens.length).clamp(0.0, 1.0) * 25.0;

    // 3. Remote/Workplace Baseline Weight: 15%
    double workplaceScore = 15.0;
    if (workplaceType.toLowerCase() == 'on-site') {
      workplaceScore = 10.0;
    }

    final totalScore = (skillScore + titleScore + workplaceScore).round();
    return totalScore.clamp(45, 98);
  }
}
