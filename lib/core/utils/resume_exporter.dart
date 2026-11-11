import 'dart:io';

import 'package:flutter/services.dart';
import 'package:path_provider/path_provider.dart';

import '../../domain/entities/skill_endorsement.dart';
import '../../domain/entities/user_profile_entity.dart';

class ResumeExporter {
  const ResumeExporter();

  /// Formats the user profile into an Executive Markdown Curriculum Vitae document.
  String generateMarkdown(
    UserProfileEntity profile, {
    List<SkillEndorsement>? endorsements,
  }) {
    final buffer = StringBuffer();

    // Header
    buffer.writeln('# ${profile.name}');
    buffer.writeln('**${profile.title}** | ${profile.company}');
    buffer.writeln(
      '*${profile.location}* | Availability: ${profile.isOpenToWork ? "Actively Seeking Leadership Opportunities" : "Employed"}',
    );
    buffer.writeln();

    // Executive Summary
    buffer.writeln('## Executive Summary');
    buffer.writeln(profile.bio.trim());
    buffer.writeln();

    // Core Competencies & Skills
    buffer.writeln('## Core Competencies & Technical Skills');
    if (endorsements != null && endorsements.isNotEmpty) {
      for (final endorsement in endorsements) {
        buffer.writeln(
          '- **${endorsement.skillName}** (Verified: ${endorsement.count} peer endorsement${endorsement.count == 1 ? "" : "s"})',
        );
      }
    } else {
      for (final skill in profile.skills) {
        buffer.writeln('- $skill');
      }
    }
    buffer.writeln();

    // Professional Experience
    buffer.writeln('## Professional Experience');
    for (final exp in profile.experiences) {
      final period = exp.isCurrent
          ? '${exp.startDate} - Present'
          : '${exp.startDate} - ${exp.endDate}';
      buffer.writeln('### ${exp.role}');
      buffer.writeln('**${exp.company}** | *$period* | ${exp.location}');
      buffer.writeln();
      buffer.writeln(exp.description.trim());
      buffer.writeln();
    }

    // Key Engineering Platforms & Projects
    if (profile.projects.isNotEmpty) {
      buffer.writeln('## Engineering Platforms & Featured Projects');
      for (final proj in profile.projects) {
        buffer.writeln('### ${proj.title}');
        buffer.writeln('*Tech Stack: ${proj.techStack.join(", ")}*');
        buffer.writeln();
        buffer.writeln(proj.description.trim());
        if (proj.githubUrl.isNotEmpty || proj.liveUrl.isNotEmpty) {
          final links = <String>[];
          if (proj.githubUrl.isNotEmpty) {
            links.add('Repository: ${proj.githubUrl}');
          }
          if (proj.liveUrl.isNotEmpty) {
            links.add('Live Demo: ${proj.liveUrl}');
          }
          buffer.writeln();
          buffer.writeln('*Links: ${links.join(" | ")}*');
        }
        buffer.writeln();
      }
    }

    // Platform Verified Metrics
    buffer.writeln('## Verified OpenPro Metrics');
    buffer.writeln('- Profile Views: ${profile.profileViews}');
    buffer.writeln(
      '- Recruiter Search Appearances: ${profile.recruiterAppearances}',
    );
    buffer.writeln(
      '- Talent Match Rate Advantage: +${profile.aiMatchRateBoost}%',
    );
    buffer.writeln();

    return buffer.toString();
  }

  /// Formats the profile into clean, standardized ATS plain text format.
  String generatePlainText(
    UserProfileEntity profile, {
    List<SkillEndorsement>? endorsements,
  }) {
    final buffer = StringBuffer();
    final divider = '=' * 68;
    final subDivider = '-' * 68;

    buffer.writeln(divider);
    buffer.writeln(profile.name.toUpperCase());
    buffer.writeln('${profile.title} at ${profile.company}');
    buffer.writeln(
      '${profile.location} | Status: ${profile.isOpenToWork ? "Open to Work" : "Active"}',
    );
    buffer.writeln(divider);
    buffer.writeln();

    buffer.writeln('EXECUTIVE SUMMARY');
    buffer.writeln(subDivider);
    buffer.writeln(profile.bio.trim());
    buffer.writeln();

    buffer.writeln('CORE TECHNICAL SKILLS');
    buffer.writeln(subDivider);
    if (endorsements != null && endorsements.isNotEmpty) {
      for (final end in endorsements) {
        buffer.writeln(
          '• ${end.skillName.padRight(36)} [${end.count} Endorsement${end.count == 1 ? "" : "s"}]',
        );
      }
    } else {
      for (final skill in profile.skills) {
        buffer.writeln('• $skill');
      }
    }
    buffer.writeln();

    buffer.writeln('PROFESSIONAL EXPERIENCE');
    buffer.writeln(subDivider);
    for (final exp in profile.experiences) {
      final period = exp.isCurrent
          ? '${exp.startDate} - Present'
          : '${exp.startDate} - ${exp.endDate}';
      buffer.writeln(exp.role.toUpperCase());
      buffer.writeln('${exp.company} | ${exp.location} | $period');
      buffer.writeln(exp.description.trim());
      buffer.writeln();
    }

    if (profile.projects.isNotEmpty) {
      buffer.writeln('FEATURED ARCHITECTURAL PROJECTS');
      buffer.writeln(subDivider);
      for (final proj in profile.projects) {
        buffer.writeln(proj.title.toUpperCase());
        buffer.writeln('Stack: ${proj.techStack.join(", ")}');
        buffer.writeln(proj.description.trim());
        if (proj.githubUrl.isNotEmpty) {
          buffer.writeln('Code: ${proj.githubUrl}');
        }
        buffer.writeln();
      }
    }

    buffer.writeln('PLATFORM BENCHMARK METRICS');
    buffer.writeln(subDivider);
    buffer.writeln('• Profile Views: ${profile.profileViews}');
    buffer.writeln('• Recruiter Appearances: ${profile.recruiterAppearances}');
    buffer.writeln('• Talent Match Advantage: +${profile.aiMatchRateBoost}%');
    buffer.writeln();
    buffer.writeln(divider);

    return buffer.toString();
  }

  /// Exports the serialized resume content to a physical file in the target or temporary directory.
  Future<File> exportResumeFile(
    UserProfileEntity profile, {
    String format = 'md',
    List<SkillEndorsement>? endorsements,
    Directory? targetDirectory,
  }) async {
    final sanitizedName = profile.name.toLowerCase().replaceAll(
      RegExp(r'[^a-z0-9]'),
      '_',
    );
    final extension = format.toLowerCase() == 'txt' ? 'txt' : 'md';
    final timestamp = DateTime.now().millisecondsSinceEpoch;
    final filename = 'resume_${sanitizedName}_$timestamp.$extension';

    final Directory dir;
    if (targetDirectory != null) {
      dir = targetDirectory;
    } else {
      dir = await getTemporaryDirectory();
    }

    if (!dir.existsSync()) {
      dir.createSync(recursive: true);
    }

    final filePath = '${dir.path}${Platform.pathSeparator}$filename';
    final file = File(filePath);

    final content = extension == 'txt'
        ? generatePlainText(profile, endorsements: endorsements)
        : generateMarkdown(profile, endorsements: endorsements);

    file.writeAsStringSync(content);
    return file;
  }

  /// Copies the text to the system clipboard.
  Future<void> copyToClipboard(String content) async {
    await Clipboard.setData(ClipboardData(text: content));
  }
}
