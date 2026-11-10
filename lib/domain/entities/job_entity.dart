class JobEntity {
  final String id;
  final String title;
  final String company;
  final String companyLogo;
  final String location;
  final String workplaceType; // Remote, Hybrid, On-Site
  final String employmentType; // Full-time, Contract, etc.
  final int salaryMin;
  final int salaryMax;
  final String salaryCurrency;
  final String equity;
  final String description;
  final List<String> requirements;
  final List<String> skills;
  final String postedDate;
  final bool isBookmarked;
  final String applicationStatus; // none, applied, inReview, interviewScheduled
  final int matchScore;
  final String recruiterName;
  final String recruiterTitle;

  const JobEntity({
    required this.id,
    required this.title,
    required this.company,
    required this.companyLogo,
    required this.location,
    required this.workplaceType,
    required this.employmentType,
    required this.salaryMin,
    required this.salaryMax,
    required this.salaryCurrency,
    required this.equity,
    required this.description,
    required this.requirements,
    required this.skills,
    required this.postedDate,
    required this.isBookmarked,
    required this.applicationStatus,
    required this.matchScore,
    required this.recruiterName,
    required this.recruiterTitle,
  });

  bool get isApplied => applicationStatus != 'none';

  String get salaryBand =>
      '\$${(salaryMin / 1000).toInt()}k - \$${(salaryMax / 1000).toInt()}k';

  double get salaryMedian => (salaryMin + salaryMax) / 2.0;

  JobEntity copyWith({
    String? id,
    String? title,
    String? company,
    String? companyLogo,
    String? location,
    String? workplaceType,
    String? employmentType,
    int? salaryMin,
    int? salaryMax,
    String? salaryCurrency,
    String? equity,
    String? description,
    List<String>? requirements,
    List<String>? skills,
    String? postedDate,
    bool? isBookmarked,
    String? applicationStatus,
    int? matchScore,
    String? recruiterName,
    String? recruiterTitle,
  }) {
    return JobEntity(
      id: id ?? this.id,
      title: title ?? this.title,
      company: company ?? this.company,
      companyLogo: companyLogo ?? this.companyLogo,
      location: location ?? this.location,
      workplaceType: workplaceType ?? this.workplaceType,
      employmentType: employmentType ?? this.employmentType,
      salaryMin: salaryMin ?? this.salaryMin,
      salaryMax: salaryMax ?? this.salaryMax,
      salaryCurrency: salaryCurrency ?? this.salaryCurrency,
      equity: equity ?? this.equity,
      description: description ?? this.description,
      requirements: requirements ?? this.requirements,
      skills: skills ?? this.skills,
      postedDate: postedDate ?? this.postedDate,
      isBookmarked: isBookmarked ?? this.isBookmarked,
      applicationStatus: applicationStatus ?? this.applicationStatus,
      matchScore: matchScore ?? this.matchScore,
      recruiterName: recruiterName ?? this.recruiterName,
      recruiterTitle: recruiterTitle ?? this.recruiterTitle,
    );
  }
}
