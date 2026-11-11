# OpenPro Autonomous Engineering Backlog

This document establishes the continuous autonomous execution roadmap for OpenPro. Each daily engineering sprint is designed to be executed sequentially, end-to-end, with full unit and widget test verification, zero static analysis warnings, and zero emojis.

---

## Autonomous Sprint Execution Protocol

When instructed with the prompt:
```text
run daily sprint
```

The engineering assistant shall:
1. Identify the first unchecked sprint (`- [ ]`) in this document.
2. Formulate an implementation plan covering domain logic, data models, UI components, and unit/widget tests.
3. Implement the feature according to the acceptance criteria, strictly adhering to Clean Architecture, Provider MVVM, Zero Hardcoded Colors, and the Zero Emojis rule.
4. Execute `flutter analyze` to ensure zero warnings or errors.
5. Execute `flutter test` to ensure 100% pass rate across all automated tests.
6. Mark the sprint checkbox as completed (`- [x]`).
7. Create a Git commit following Conventional Commits (e.g., `feat(sprint-01): implement salary band percentile calculator`).
8. Push the commit to `origin main`.

---

## 25-Day Autonomous Engineering Sprints

### Sprint 01: Salary Band Percentile Calculator
- [x] **Task Definition:** Implement an interactive salary compensation percentile estimator that compares a candidate's target compensation against market percentiles (25th, 50th, 75th, 90th) based on role, seniority, and location.
- **Scope:** `lib/domain/calculators/salary_percentile_calculator.dart`, `lib/presentation/jobs/widgets/salary_distribution_card.dart`.
- **Acceptance Criteria:**
  - Computes 25th, 50th, 75th, and 90th percentile salary benchmarks for Junior, Mid, Senior, Lead, and Principal tiers.
  - Renders a custom horizontal percentile bar indicator showing where the current job or user expectation lands.
  - Full unit test coverage in `test/unit/salary_percentile_calculator_test.dart`.

### Sprint 02: Interactive Skill Endorsement Graph
- [x] **Task Definition:** Build a peer skill endorsement system where connections can endorse specific skills, incrementing endorsement counts and displaying avatar clusters of top endorsers.
- **Scope:** `lib/domain/entities/skill_endorsement.dart`, `lib/data/repositories/skill_repository.dart`, `lib/presentation/profile/widgets/endorsed_skills_section.dart`.
- **Acceptance Criteria:**
  - Persists endorsements to SQLite `skill_endorsements` table with user foreign keys.
  - Displays avatar stacks for endorsements with count badges.
  - Toggling an endorsement updates UI instantaneously via `notifyListeners()`.
  - Comprehensive unit test in `test/unit/skill_endorsement_test.dart`.

### Sprint 03: Interview Availability Calendar Picker
- [x] **Task Definition:** Construct a multi-slot calendar scheduling interface allowing candidates to select preferred 30-minute interview time slots when accepting an interview invitation.
- **Scope:** `lib/presentation/jobs/widgets/interview_scheduler_modal.dart`, `lib/presentation/jobs/viewmodels/interview_scheduler_viewmodel.dart`.
- **Acceptance Criteria:**
  - Allows selecting up to three time slots from a 7-day rolling window.
  - Enforces minimum 24-hour advance scheduling window.
  - Persists scheduled slots to SQLite `applications` table.
  - Widget test covering slot selection in `test/widget/interview_scheduler_test.dart`.

### Sprint 04: Markdown Technical Post Editor
- [x] **Task Definition:** Enhance the post creation modal with a live preview Markdown editor supporting fenced code blocks, bullet points, headers, and hyperlinks.
- **Scope:** `lib/presentation/feed/widgets/markdown_post_editor.dart`, `lib/presentation/feed/widgets/markdown_post_body.dart`.
- **Acceptance Criteria:**
  - Dual-mode editor: Edit tab and Preview tab with instant toggle.
  - Renders monospaced syntax blocks with background containers resolved from `Theme.of(context).colorScheme.surfaceContainerHighest`.
  - Character counter with warning boundary at 2,000 characters.
  - Unit and widget tests in `test/widget/markdown_post_editor_test.dart`.

### Sprint 05: Recruiter Direct InMail Simulator
- [x] **Task Definition:** Implement an InMail communication channel allowing users to receive, inspect, and reply to inbound recruiter outreach messages.
- **Scope:** `lib/domain/entities/inmail_message.dart`, `lib/presentation/messages/inmail_inbox_view.dart`, `lib/presentation/messages/inmail_detail_view.dart`.
- **Acceptance Criteria:**
  - Tabular or list inbox separating "Recruiter Outreach" from "General Messages".
  - Quick-reply action templates: "Interested, let us connect", "Not looking, but keep in touch", "Decline politely".
  - Reply updates message status in SQLite to "Replied".
  - Unit tests verifying message state transitions in `test/unit/inmail_viewmodel_test.dart`.

### Sprint 06: Resume PDF Generator and Exporter
- [ ] **Task Definition:** Build an on-device resume builder that serializes the user profile, work experience, education, and skills into a standardized executive text/PDF document layout.
- **Scope:** `lib/core/utils/resume_exporter.dart`, `lib/presentation/profile/widgets/export_resume_dialog.dart`.
- **Acceptance Criteria:**
  - Formats summary, timeline experience, skill cloud, and contact details into a clean markdown and printable document format.
  - Copies exported resume text to clipboard with `AppFeedback.showSuccess`.
  - Generates downloadable resume summary file in application cache directory.
  - Unit test in `test/unit/resume_exporter_test.dart`.

### Sprint 07: Application Stage Progression Pipeline
- [ ] **Task Definition:** Create an interactive Kanban-style visual pipeline tracker for submitted job applications (Applied -> Under Review -> Technical Screening -> Offer Received -> Archived).
- **Scope:** `lib/presentation/jobs/widgets/application_pipeline_view.dart`, `lib/presentation/jobs/viewmodels/application_pipeline_viewmodel.dart`.
- **Acceptance Criteria:**
  - Horizontal drag-and-drop or tap-to-advance stage progression.
  - Updates SQLite `applications` table stage column with timestamp tracking.
  - Displays elapsed days since application submission.
  - Unit and widget tests in `test/widget/application_pipeline_test.dart`.

### Sprint 08: Push Notification History Center
- [ ] **Task Definition:** Build a centralized Notification Center view that displays all historical simulated notifications (recruiter views, job alerts, application updates).
- **Scope:** `lib/presentation/notifications/notifications_center_view.dart`, `lib/presentation/notifications/notifications_viewmodel.dart`.
- **Acceptance Criteria:**
  - Filter by category: All, Recruiter Alerts, Job Updates, Community Activity.
  - Mark single notification as read or Mark all as read.
  - Persists read status to SQLite `notifications` table.
  - Unit tests in `test/unit/notifications_viewmodel_test.dart`.

### Sprint 09: Offline Queue and Sync Engine
- [ ] **Task Definition:** Implement an offline mutation queue that captures likes, comments, and applications when connectivity is lost and dispatches them in order upon reconnection.
- **Scope:** `lib/core/network/offline_sync_queue.dart`, `lib/core/network/sync_manager.dart`.
- **Acceptance Criteria:**
  - Enqueues mutation payloads into SQLite `sync_queue` table when offline.
  - Listens to `connectivity_plus` connectivity changes.
  - Automatically replays pending operations sequentially upon connection restore.
  - Unit tests simulating offline-to-online transition in `test/unit/offline_sync_queue_test.dart`.

### Sprint 10: Technical Portfolio Media Gallery
- [ ] **Task Definition:** Allow users to showcase visual portfolio items (architecture diagrams, system designs, GitHub repositories) on their profile.
- **Scope:** `lib/domain/entities/portfolio_project.dart`, `lib/presentation/profile/widgets/portfolio_gallery.dart`.
- **Acceptance Criteria:**
  - Grid view of project cards with title, description, tech stack tags, and repository link.
  - Modal viewer for inspecting project details and system architecture diagrams.
  - Add/Edit portfolio project form with validation.
  - Unit and widget tests in `test/widget/portfolio_gallery_test.dart`.

### Sprint 11: Company Culture and Review Scorecard
- [ ] **Task Definition:** Add an authentic company insights scorecard to job details showing verified employee ratings for engineering culture, work-life balance, and compensation.
- **Scope:** `lib/domain/entities/company_scorecard.dart`, `lib/presentation/jobs/widgets/company_scorecard_view.dart`.
- **Acceptance Criteria:**
  - Visual breakdown of 5 core dimensions: Engineering Velocity, Mentorship, Work-Life Balance, Tech Stack Modernity, Remote Flexibility.
  - Numerical 5-point rating scale rendered with linear progress indicators.
  - Unit test in `test/unit/company_scorecard_test.dart`.

### Sprint 12: Skill Benchmark Assessment Quiz
- [ ] **Task Definition:** Build a timed technical evaluation quiz engine (e.g. Flutter Architecture, Dart Concurrency, Clean Architecture) that grants a "Verified Skill" badge upon achieving >= 80%.
- **Scope:** `lib/presentation/assessment/skill_quiz_view.dart`, `lib/presentation/assessment/skill_quiz_viewmodel.dart`.
- **Acceptance Criteria:**
  - 5-question multiple choice questionnaire with 60-second timer per question.
  - Evaluates score instantly and updates profile with a verified badge in SQLite.
  - Comprehensive unit test in `test/unit/skill_quiz_viewmodel_test.dart`.

### Sprint 13: Salary Negotiation Script Generator
- [ ] **Task Definition:** Add a specialized on-device tool in the AI Assistant module that generates structured counter-offer scripts and talking points based on target delta and competing offers.
- **Scope:** `lib/domain/usecases/generate_negotiation_script_usecase.dart`, `lib/presentation/ai_assistant/widgets/negotiation_helper_modal.dart`.
- **Acceptance Criteria:**
  - Form inputs: Current Offer, Target Compensation, Competing Leverage, Key Strengths.
  - Asynchronously generates executive-toned, professional email and verbal negotiation templates.
  - Unit tests in `test/unit/negotiation_script_test.dart`.

### Sprint 14: Job Alert Keyword Subscription Manager
- [ ] **Task Definition:** Build a keyword and criteria subscription manager where users save job search queries and configure daily or weekly simulation triggers.
- **Scope:** `lib/domain/entities/job_alert.dart`, `lib/presentation/jobs/widgets/job_alerts_manager_modal.dart`.
- **Acceptance Criteria:**
  - Create, toggle active/paused, and delete job alert filters.
  - Alerts persist to SQLite `job_alerts` table.
  - Notification service triggers matching job count upon alert evaluation.
  - Unit tests in `test/unit/job_alerts_test.dart`.

### Sprint 15: Recruiter Candidate Search and Filter Engine
- [ ] **Task Definition:** Build a dedicated Recruiter Mode search interface allowing technical hiring managers to search candidate profiles by required skills, experience level, and location.
- **Scope:** `lib/presentation/recruiter/candidate_search_view.dart`, `lib/presentation/recruiter/candidate_search_viewmodel.dart`.
- **Acceptance Criteria:**
  - Multi-select chip filter for skills (e.g. Flutter, Go, Kubernetes, System Design).
  - Minimum years of experience slider.
  - Instant list rendering with calculated match percentage against recruiter criteria.
  - Unit test in `test/unit/candidate_search_viewmodel_test.dart`.

### Sprint 16: Voice Note Comment and Pitch Recorder
- [ ] **Task Definition:** Implement an audio recording simulator that allows candidates to attach a 30-second audio elevator pitch to their job applications.
- **Scope:** `lib/presentation/jobs/widgets/audio_pitch_recorder.dart`, `lib/core/utils/audio_waveform_painter.dart`.
- **Acceptance Criteria:**
  - Simulated recording timer with pulsing visual waveform animation.
  - Play, pause, and delete controls.
  - Saves audio metadata record in SQLite `applications` table.
  - Widget test in `test/widget/audio_pitch_recorder_test.dart`.

### Sprint 17: Multi-Language Code Snippet Syntax Highlighter
- [ ] **Task Definition:** Implement high-contrast syntax highlighting for code snippets embedded within community posts and comments (Dart, Python, Go, TypeScript, SQL).
- **Scope:** `lib/core/utils/syntax_highlighter.dart`, `lib/presentation/feed/widgets/code_snippet_widget.dart`.
- **Acceptance Criteria:**
  - Tokenizes keywords, strings, comments, types, and numbers into distinct theme-aware text styles.
  - One-tap "Copy Code" button with clipboard feedback.
  - Unit tests verifying tokenization across Dart and SQL in `test/unit/syntax_highlighter_test.dart`.

### Sprint 18: Professional Connection Graph and 2nd-Degree Introductions
- [ ] **Task Definition:** Build a 1st and 2nd-degree connection network view displaying shared mutual connections and facilitating formal introduction requests.
- **Scope:** `lib/domain/entities/connection_node.dart`, `lib/presentation/network/connection_graph_view.dart`.
- **Acceptance Criteria:**
  - Visual listing of 1st-degree connections and "People You May Know".
  - Mutual connection count indicator (e.g. "5 mutual connections").
  - "Request Introduction" action modal with personal note input.
  - Unit tests in `test/unit/connection_graph_test.dart`.

### Sprint 19: Career Path Trajectory Simulator
- [ ] **Task Definition:** Build a predictive career path visualizer showing step-by-step milestone progression from current role (e.g., Senior Mobile Engineer) to Staff, Principal, and VP of Engineering.
- **Scope:** `lib/domain/calculators/career_trajectory_calculator.dart`, `lib/presentation/profile/widgets/career_path_visualizer.dart`.
- **Acceptance Criteria:**
  - Graph-based node progression depicting typical timeline, required competency delta, and expected market compensation.
  - Interactive nodes expand with recommended reading and certification tracks.
  - Unit tests in `test/unit/career_trajectory_test.dart`.

### Sprint 20: Event Check-In and QR Code Pass Generator
- [ ] **Task Definition:** Provide an interactive event pass featuring a generated vector QR code for RSVP'd community events and conferences.
- **Scope:** `lib/presentation/community/widgets/event_ticket_modal.dart`, `lib/core/utils/qr_code_painter.dart`.
- **Acceptance Criteria:**
  - Generates custom vector QR code representation containing encrypted registration hash.
  - Ticket displays attendee name, event title, date, venue/link, and seat category.
  - Add to device calendar action integration.
  - Widget test in `test/widget/event_ticket_test.dart`.

### Sprint 21: Dark/Light Custom Accent Color Picker
- [ ] **Task Definition:** Allow users to customize the primary brand accent (Sapphire Blue, Emerald Green, Royal Violet, Cyber Teal, Amber Gold) while maintaining strict Material 3 contrast compliance.
- **Scope:** `lib/core/theme/accent_color_provider.dart`, `lib/presentation/settings/accent_picker_dialog.dart`.
- **Acceptance Criteria:**
  - Dynamic `ColorScheme` regeneration based on chosen seed color.
  - Persists selected seed color to `SharedPreferences`.
  - Re-renders all screens instantaneously without app restart.
  - Unit tests in `test/unit/accent_color_provider_test.dart`.

### Sprint 22: Profile Privacy and Recruiter Visibility Controls
- [ ] **Task Definition:** Implement fine-grained profile privacy settings ("Open to Work (All Recruiters)", "Confidential / Stealth Mode (Hide from current employer)", "Private Portfolio").
- **Scope:** `lib/presentation/profile/widgets/privacy_settings_modal.dart`, `lib/domain/entities/privacy_preferences.dart`.
- **Acceptance Criteria:**
  - Toggles for Stealth Mode, Profile Indexing, and Direct Messaging Permissions.
  - Persists settings to SQLite `user_preferences` table.
  - Recruiter view respects stealth settings.
  - Unit tests in `test/unit/privacy_preferences_test.dart`.

### Sprint 23: Direct Message Read Receipts and Typing Indicators
- [ ] **Task Definition:** Add animated typing indicators and sent/delivered/read status checkmarks to chat and message conversations.
- **Scope:** `lib/presentation/messages/widgets/typing_indicator_widget.dart`, `lib/presentation/messages/widgets/message_status_indicator.dart`.
- **Acceptance Criteria:**
  - Three-dot pulsing typing bubble with theme-compliant colors.
  - Status indicators: Single tick (Sent), Double tick (Delivered), Colored double tick (Read).
  - Zero timer leaks upon widget disposal.
  - Widget test in `test/widget/typing_indicator_test.dart`.

### Sprint 24: Weekly Recruiter Analytics PDF Digest
- [ ] **Task Definition:** Build a report generator that compiles profile view counts, top recruiter industries, and search keyword appearances into a summary document.
- **Scope:** `lib/core/utils/analytics_report_generator.dart`, `lib/presentation/profile/widgets/analytics_digest_modal.dart`.
- **Acceptance Criteria:**
  - Computes week-over-week view percentage change.
  - Displays top 3 searching company domains.
  - Formatted text export to clipboard and local file cache.
  - Unit test in `test/unit/analytics_report_test.dart`.

### Sprint 25: Comprehensive End-to-End Stress Test and Release Readiness Audit
- [ ] **Task Definition:** Execute a complete audit of all 5 core modules, landscape layouts, offline fallbacks, database migrations, and memory leak profiles to ensure production release readiness.
- **Scope:** `test/e2e/release_readiness_test.dart`, `lib/core/database/database_migrations.dart`.
- **Acceptance Criteria:**
  - Complete multi-step user journey test: Onboarding -> Job Swipe -> Smart Apply -> Post Publication -> AI Chat -> Event RSVP.
  - Zero memory leaks detected during repetitive screen pushes and pops.
  - 100% test pass rate across the complete automated test suite.
