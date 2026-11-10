import 'dart:convert';

import '../../domain/entities/job_entity.dart';

class JobModel extends JobEntity {
  const JobModel({
    required super.id,
    required super.title,
    required super.company,
    required super.companyLogo,
    required super.location,
    required super.workplaceType,
    required super.employmentType,
    required super.salaryMin,
    required super.salaryMax,
    required super.salaryCurrency,
    required super.equity,
    required super.description,
    required super.requirements,
    required super.skills,
    required super.postedDate,
    required super.isBookmarked,
    required super.applicationStatus,
    required super.matchScore,
    required super.recruiterName,
    required super.recruiterTitle,
  });

  factory JobModel.fromMap(Map<String, dynamic> map) {
    List<String> parseList(dynamic val) {
      if (val == null) return [];
      if (val is List) return val.map((e) => e.toString()).toList();
      try {
        final decoded = jsonDecode(val.toString());
        if (decoded is List) return decoded.map((e) => e.toString()).toList();
      } catch (_) {}
      return [];
    }

    return JobModel(
      id: map['id'] as String,
      title: map['title'] as String,
      company: map['company'] as String,
      companyLogo: map['company_logo'] as String,
      location: map['location'] as String,
      workplaceType: map['workplace_type'] as String,
      employmentType: map['employment_type'] as String,
      salaryMin: (map['salary_min'] as num).toInt(),
      salaryMax: (map['salary_max'] as num).toInt(),
      salaryCurrency: map['salary_currency'] as String,
      equity: map['equity'] as String,
      description: map['description'] as String,
      requirements: parseList(map['requirements']),
      skills: parseList(map['skills']),
      postedDate: map['posted_date'] as String,
      isBookmarked: (map['is_bookmarked'] as num?)?.toInt() == 1,
      applicationStatus: map['application_status'] as String? ?? 'none',
      matchScore: (map['match_score'] as num?)?.toInt() ?? 80,
      recruiterName: map['recruiter_name'] as String? ?? 'Lead Talent Partner',
      recruiterTitle:
          map['recruiter_title'] as String? ?? 'Technical Recruiter',
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'title': title,
      'company': company,
      'company_logo': companyLogo,
      'location': location,
      'workplace_type': workplaceType,
      'employment_type': employmentType,
      'salary_min': salaryMin,
      'salary_max': salaryMax,
      'salary_currency': salaryCurrency,
      'equity': equity,
      'description': description,
      'requirements': jsonEncode(requirements),
      'skills': jsonEncode(skills),
      'posted_date': postedDate,
      'is_bookmarked': isBookmarked ? 1 : 0,
      'application_status': applicationStatus,
      'match_score': matchScore,
      'recruiter_name': recruiterName,
      'recruiter_title': recruiterTitle,
    };
  }
}
