import 'dart:async';

import 'package:open_pro/core/database/app_database.dart';
import 'package:open_pro/data/repositories/ai_assistant_repository.dart';
import 'package:open_pro/data/repositories/community_repository.dart';
import 'package:open_pro/data/repositories/job_repository.dart';
import 'package:open_pro/data/repositories/profile_repository.dart';
import 'package:open_pro/data/repositories/skill_repository.dart';
import 'package:open_pro/data/repositories/social_repository.dart';
import 'package:open_pro/domain/entities/chat_message_entity.dart';
import 'package:open_pro/domain/entities/comment_entity.dart';
import 'package:open_pro/domain/entities/event_entity.dart';
import 'package:open_pro/domain/entities/group_entity.dart';
import 'package:open_pro/domain/entities/inmail_message.dart';
import 'package:open_pro/domain/entities/job_entity.dart';
import 'package:open_pro/domain/entities/post_entity.dart';
import 'package:open_pro/domain/entities/skill_endorsement.dart';
import 'package:open_pro/domain/entities/story_entity.dart';
import 'package:open_pro/domain/entities/user_profile_entity.dart';
import 'package:open_pro/domain/repositories/inmail_repository_interface.dart';

class MockJobRepository extends JobRepository {
  List<JobEntity> inMemoryJobs;

  MockJobRepository({List<JobEntity>? jobs})
    : inMemoryJobs =
          jobs ??
          [
            const JobEntity(
              id: 'job_1',
              title: 'Principal Flutter Architect',
              company: 'CloudScale Global',
              companyLogo: 'assets/images/cloudscale.png',
              location: 'San Francisco, CA (Remote)',
              workplaceType: 'Remote',
              employmentType: 'Full-time',
              salaryMin: 195000,
              salaryMax: 245000,
              salaryCurrency: 'USD',
              equity: '0.15% - 0.35%',
              description: 'Design enterprise Flutter platforms.',
              requirements: ['7+ years experience'],
              skills: ['Flutter', 'Dart', 'Provider', 'SQLite'],
              postedDate: '2 hours ago',
              isBookmarked: false,
              applicationStatus: 'none',
              matchScore: 96,
              recruiterName: 'Sarah Vance',
              recruiterTitle: 'VP Talent',
            ),
            const JobEntity(
              id: 'job_2',
              title: 'Staff AI Mobile Systems Engineer',
              company: 'QuantumAI Labs',
              companyLogo: 'assets/images/quantum_ai.png',
              location: 'New York, NY (Hybrid)',
              workplaceType: 'Hybrid',
              employmentType: 'Full-time',
              salaryMin: 210000,
              salaryMax: 260000,
              salaryCurrency: 'USD',
              equity: '0.2%',
              description: 'On-device AI integration.',
              requirements: ['AI background'],
              skills: ['Flutter', 'AI Recruiter Matching', 'Dart'],
              postedDate: '5 hours ago',
              isBookmarked: true,
              applicationStatus: 'none',
              matchScore: 92,
              recruiterName: 'Marcus Thorne',
              recruiterTitle: 'Director',
            ),
          ],
      super(database: AppDatabase.instance);

  @override
  Future<List<JobEntity>> getJobs() async => List.from(inMemoryJobs);

  @override
  Future<JobEntity?> toggleBookmark(String jobId) async {
    final idx = inMemoryJobs.indexWhere((j) => j.id == jobId);
    if (idx == -1) return null;
    final updated = inMemoryJobs[idx].copyWith(
      isBookmarked: !inMemoryJobs[idx].isBookmarked,
    );
    inMemoryJobs[idx] = updated;
    return updated;
  }

  @override
  Future<JobEntity?> submitApplication({
    required String jobId,
    required String coverNote,
    String? portfolioUrl,
  }) async {
    final idx = inMemoryJobs.indexWhere((j) => j.id == jobId);
    if (idx == -1) return null;
    final updated = inMemoryJobs[idx].copyWith(applicationStatus: 'applied');
    inMemoryJobs[idx] = updated;
    return updated;
  }

  @override
  Future<JobEntity?> updateApplicationStatus({
    required String jobId,
    required String status,
  }) async {
    final idx = inMemoryJobs.indexWhere((j) => j.id == jobId);
    if (idx == -1) return null;
    final updated = inMemoryJobs[idx].copyWith(applicationStatus: status);
    inMemoryJobs[idx] = updated;
    return updated;
  }

  final Map<String, List<DateTime>> inMemoryScheduledSlots = {};

  @override
  Future<bool> scheduleInterviewSlots({
    required String jobId,
    required String userId,
    required List<DateTime> slots,
  }) async {
    inMemoryScheduledSlots['${jobId}_$userId'] = List.from(slots);
    final idx = inMemoryJobs.indexWhere((j) => j.id == jobId);
    if (idx != -1) {
      inMemoryJobs[idx] = inMemoryJobs[idx].copyWith(
        applicationStatus: 'interviewScheduled',
      );
    }
    return true;
  }

  @override
  Future<List<DateTime>> getScheduledSlots({
    required String jobId,
    required String userId,
  }) async {
    return List.from(inMemoryScheduledSlots['${jobId}_$userId'] ?? []);
  }
}

class MockSocialRepository extends SocialRepository {
  List<PostEntity> inMemoryPosts;
  List<StoryEntity> inMemoryStories;
  List<CommentEntity> inMemoryComments;

  MockSocialRepository({
    List<PostEntity>? posts,
    List<StoryEntity>? stories,
    List<CommentEntity>? comments,
  }) : inMemoryPosts =
           posts ??
           [
             const PostEntity(
               id: 'post_1',
               authorName: 'Safeer Hussain',
               authorRole: 'Senior Flutter Architect',
               authorAvatar: 'assets/images/safeer_avatar.png',
               authorCompany: 'OpenPro Labs',
               content: 'Eliminating widget rebuilds using Selector.',
               codeSnippet: 'Selector<Feed, bool>(...)',
               codeLanguage: 'dart',
               timestamp: '18m ago',
               likesCount: 42,
               commentsCount: 2,
               sharesCount: 11,
               isLiked: false,
               isBookmarked: false,
               tags: ['#Flutter', '#Architecture'],
             ),
           ],
       inMemoryStories =
           stories ??
           [
             const StoryEntity(
               id: 'story_1',
               authorName: 'Safeer Hussain',
               authorAvatar: 'assets/images/safeer_avatar.png',
               title: 'Flutter 3.47 Architecture',
               subtitle: 'Zero-jank 120 FPS loops',
               mediaUrl: 'assets/images/story_flutter.png',
               durationSeconds: 6,
               postedAt: '1h ago',
               isViewed: false,
               reactionCount: 28,
             ),
           ],
       inMemoryComments =
           comments ??
           [
             const CommentEntity(
               id: 'com_1',
               postId: 'post_1',
               authorName: 'Elena Rostova',
               authorAvatar: 'assets/images/fintech_prime.png',
               authorRole: 'Principal Mobile Lead',
               content: 'Great architectural pattern!',
               timestamp: '10m ago',
             ),
           ],
       super(database: AppDatabase.instance);

  @override
  Future<List<PostEntity>> getPosts() async => List.from(inMemoryPosts);

  @override
  Future<List<StoryEntity>> getStories() async => List.from(inMemoryStories);

  @override
  Future<void> createPost(PostEntity post) async {
    inMemoryPosts.insert(0, post);
  }

  @override
  Future<PostEntity?> toggleLike(String postId) async {
    final idx = inMemoryPosts.indexWhere((p) => p.id == postId);
    if (idx == -1) return null;
    final curr = inMemoryPosts[idx];
    final willLike = !curr.isLiked;
    final updated = curr.copyWith(
      isLiked: willLike,
      likesCount: willLike ? curr.likesCount + 1 : curr.likesCount - 1,
    );
    inMemoryPosts[idx] = updated;
    return updated;
  }

  @override
  Future<PostEntity?> toggleBookmark(String postId) async {
    final idx = inMemoryPosts.indexWhere((p) => p.id == postId);
    if (idx == -1) return null;
    final curr = inMemoryPosts[idx];
    final updated = curr.copyWith(isBookmarked: !curr.isBookmarked);
    inMemoryPosts[idx] = updated;
    return updated;
  }

  @override
  Future<PostEntity?> repost(String postId) async {
    final idx = inMemoryPosts.indexWhere((p) => p.id == postId);
    if (idx == -1) return null;
    final curr = inMemoryPosts[idx];
    final updated = curr.copyWith(sharesCount: curr.sharesCount + 1);
    inMemoryPosts[idx] = updated;
    return updated;
  }

  @override
  Future<List<CommentEntity>> getComments(String postId) async {
    return inMemoryComments.where((c) => c.postId == postId).toList();
  }

  @override
  Future<void> addComment(CommentEntity comment) async {
    inMemoryComments.add(comment);
    final idx = inMemoryPosts.indexWhere((p) => p.id == comment.postId);
    if (idx != -1) {
      inMemoryPosts[idx] = inMemoryPosts[idx].copyWith(
        commentsCount: inMemoryPosts[idx].commentsCount + 1,
      );
    }
  }

  @override
  Future<void> deleteComment(String commentId, String postId) async {
    inMemoryComments.removeWhere((c) => c.id == commentId);
    final idx = inMemoryPosts.indexWhere((p) => p.id == postId);
    if (idx != -1) {
      inMemoryPosts[idx] = inMemoryPosts[idx].copyWith(
        commentsCount: inMemoryPosts[idx].commentsCount - 1,
      );
    }
  }
}

class MockAiAssistantRepository extends AiAssistantRepository {
  List<ChatMessageEntity> inMemoryMessages;

  MockAiAssistantRepository({List<ChatMessageEntity>? messages})
    : inMemoryMessages = messages ?? [],
      super(
        database: AppDatabase.instance,
        profileRepository: MockProfileRepository(),
        jobRepository: MockJobRepository(),
      );

  @override
  Future<List<ChatMessageEntity>> getMessages() async =>
      List.from(inMemoryMessages);

  @override
  Future<void> saveMessage(ChatMessageEntity message) async {
    inMemoryMessages.add(message);
  }

  @override
  Future<void> clearMessages() async {
    inMemoryMessages.clear();
  }

  @override
  Stream<String> streamResponse(String userPrompt) async* {
    final tokens = ['Verified', ' match', ' analysis', ' completed.'];
    for (final token in tokens) {
      yield token;
    }
  }
}

class MockCommunityRepository extends CommunityRepository {
  List<GroupEntity> inMemoryGroups;
  List<EventEntity> inMemoryEvents;

  MockCommunityRepository({
    List<GroupEntity>? groups,
    List<EventEntity>? events,
  }) : inMemoryGroups =
           groups ??
           [
             const GroupEntity(
               id: 'grp_1',
               name: 'Flutter & Native SDK Architects',
               tagline: 'High-performance cross-platform system design',
               description: 'Enterprise Clean Architecture.',
               bannerUrl: 'assets/images/flutter_architects.png',
               memberCount: 12480,
               topic: 'Flutter',
               isJoined: false,
               recentPostsCount: 142,
             ),
           ],
       inMemoryEvents =
           events ??
           [
             const EventEntity(
               id: 'evt_1',
               title: 'Global Flutter Summit 2026',
               organizer: 'OpenPro Hub',
               organizerLogo: 'assets/images/techcorp.png',
               dateDescription: 'Nov 12 • 10:00 AM PST',
               dateTime: '2026-11-12T10:00:00Z',
               locationOrLink: 'Virtual Stream',
               isVirtual: true,
               attendeeCount: 1850,
               isRsvp: false,
               speakers: ['Safeer Hussain'],
               tags: ['#Flutter'],
             ),
           ],
       super(database: AppDatabase.instance);

  @override
  Future<List<GroupEntity>> getGroups() async => List.from(inMemoryGroups);

  @override
  Future<List<EventEntity>> getEvents() async => List.from(inMemoryEvents);

  @override
  Future<GroupEntity?> toggleJoinGroup(String groupId) async {
    final idx = inMemoryGroups.indexWhere((g) => g.id == groupId);
    if (idx == -1) return null;
    final curr = inMemoryGroups[idx];
    final willJoin = !curr.isJoined;
    final updated = curr.copyWith(
      isJoined: willJoin,
      memberCount: willJoin ? curr.memberCount + 1 : curr.memberCount - 1,
    );
    inMemoryGroups[idx] = updated;
    return updated;
  }

  @override
  Future<EventEntity?> toggleRsvpEvent(String eventId) async {
    final idx = inMemoryEvents.indexWhere((e) => e.id == eventId);
    if (idx == -1) return null;
    final curr = inMemoryEvents[idx];
    final willRsvp = !curr.isRsvp;
    final updated = curr.copyWith(
      isRsvp: willRsvp,
      attendeeCount: willRsvp ? curr.attendeeCount + 1 : curr.attendeeCount - 1,
    );
    inMemoryEvents[idx] = updated;
    return updated;
  }
}

class MockProfileRepository extends ProfileRepository {
  UserProfileEntity inMemoryProfile;

  MockProfileRepository({UserProfileEntity? profile})
    : inMemoryProfile =
          profile ??
          const UserProfileEntity(
            id: 'usr_safeer_001',
            name: 'Safeer Hussain',
            title: 'Senior Flutter Architect & Mobile Team Lead',
            company: 'OpenPro Labs',
            location: 'San Francisco, CA (Remote)',
            bio: 'Principal Mobile Architect building resilient cross-platform systems.',
            avatarUrl: 'assets/images/safeer_avatar.png',
            isOpenToWork: true,
            isHiring: false,
            skills: [
              'Flutter',
              'Dart',
              'Clean Architecture',
              'Provider',
              'SQLite',
            ],
            experiences: [
              ExperienceEntity(
                id: 'exp_1',
                userId: 'usr_safeer_001',
                role: 'Senior Flutter Architect',
                company: 'OpenPro Labs',
                location: 'San Francisco, CA',
                startDate: '2023 - Present',
                endDate: 'Present',
                isCurrent: true,
                description: 'Architecture and 120 FPS render pipelines.',
              ),
            ],
            projects: [
              ProjectEntity(
                id: 'proj_1',
                userId: 'usr_safeer_001',
                title: 'OpenPro Mobile Network',
                description: 'AI-powered professional network.',
                techStack: ['Flutter', 'Dart', 'Provider', 'SQLite'],
                githubUrl: 'https://github.com/Safeer-Hussain/openpro',
                liveUrl: 'https://openpro.app',
              ),
            ],
            profileViews: 2840,
            recruiterAppearances: 612,
            aiMatchRateBoost: 30,
          ),
      super(database: AppDatabase.instance);

  @override
  Future<UserProfileEntity?> getUserProfile([
    String userId = 'usr_safeer_001',
  ]) async {
    return inMemoryProfile;
  }

  @override
  Future<void> updateProfile(UserProfileEntity profile) async {
    inMemoryProfile = profile;
  }

  @override
  Future<bool> toggleOpenToWork(String userId) async {
    final next = !inMemoryProfile.isOpenToWork;
    inMemoryProfile = inMemoryProfile.copyWith(isOpenToWork: next);
    return next;
  }

  @override
  Future<void> addExperience(ExperienceEntity experience) async {
    final updated = List<ExperienceEntity>.from(inMemoryProfile.experiences)
      ..insert(0, experience);
    inMemoryProfile = inMemoryProfile.copyWith(experiences: updated);
  }

  @override
  Future<void> addProject(ProjectEntity project) async {
    final updated = List<ProjectEntity>.from(inMemoryProfile.projects)
      ..insert(0, project);
    inMemoryProfile = inMemoryProfile.copyWith(projects: updated);
  }
}

class MockSkillRepository extends SkillRepository {
  List<SkillEndorsement> inMemoryEndorsements;

  MockSkillRepository({List<SkillEndorsement>? endorsements})
    : inMemoryEndorsements =
          endorsements ??
          [
            const SkillEndorsement(
              skillName: 'Flutter & Dart Architecture',
              count: 3,
              isEndorsedByMe: false,
              topEndorsers: [
                Endorser(
                  id: 'end_1',
                  name: 'Alex Rivera',
                  title: 'Staff Mobile Architect @ TechCorp Labs',
                  avatarUrl: 'assets/images/techcorp.png',
                ),
                Endorser(
                  id: 'end_2',
                  name: 'Sarah Chen',
                  title: 'Principal Systems Engineer @ CloudScale',
                  avatarUrl: 'assets/images/cloudscale.png',
                ),
                Endorser(
                  id: 'end_3',
                  name: 'Marcus Vance',
                  title: 'VP Engineering @ FinTech Prime',
                  avatarUrl: 'assets/images/fintech_prime.png',
                ),
              ],
            ),
            const SkillEndorsement(
              skillName: 'Clean Architecture & SOLID',
              count: 2,
              isEndorsedByMe: true,
              topEndorsers: [
                Endorser(
                  id: 'end_4',
                  name: 'Dr. Aris Thorne',
                  title: 'Chief AI Scientist @ QuantumAI Labs',
                  avatarUrl: 'assets/images/quantum_ai.png',
                ),
                Endorser(
                  id: 'end_me',
                  name: 'You',
                  title: 'Verified Peer',
                  avatarUrl: 'assets/images/safeer_avatar.png',
                ),
              ],
            ),
          ],
      super(database: AppDatabase.instance);

  @override
  Future<List<SkillEndorsement>> getEndorsementsForUser([
    String userId = 'usr_safeer_001',
  ]) async {
    return List.from(inMemoryEndorsements);
  }

  @override
  Future<SkillEndorsement> toggleEndorsement({
    required String userId,
    required String skillName,
    required String endorserName,
    required String endorserTitle,
    required String endorserAvatar,
  }) async {
    final idx = inMemoryEndorsements.indexWhere(
      (e) => e.skillName == skillName,
    );
    if (idx == -1) {
      final newEndorsement = SkillEndorsement(
        skillName: skillName,
        count: 1,
        isEndorsedByMe: true,
        topEndorsers: [
          Endorser(
            id: 'end_new',
            name: endorserName,
            title: endorserTitle,
            avatarUrl: endorserAvatar,
          ),
        ],
      );
      inMemoryEndorsements.add(newEndorsement);
      return newEndorsement;
    }

    final curr = inMemoryEndorsements[idx];
    final nextStatus = !curr.isEndorsedByMe;
    final nextCount = nextStatus ? curr.count + 1 : curr.count - 1;
    final endorsers = List<Endorser>.from(curr.topEndorsers);

    if (nextStatus) {
      endorsers.insert(
        0,
        Endorser(
          id: 'end_me',
          name: endorserName,
          title: endorserTitle,
          avatarUrl: endorserAvatar,
        ),
      );
    } else {
      endorsers.removeWhere((e) => e.id == 'end_me' || e.name == endorserName);
    }

    final updated = curr.copyWith(
      isEndorsedByMe: nextStatus,
      count: nextCount,
      topEndorsers: endorsers,
    );
    inMemoryEndorsements[idx] = updated;
    return updated;
  }
}

class MockInmailRepository implements InmailRepositoryInterface {
  List<InmailMessage> inMemoryMessages;

  MockInmailRepository({List<InmailMessage>? messages})
    : inMemoryMessages =
          messages ??
          [
            const InmailMessage(
              id: 'inmail_1',
              userId: 'user_safeer',
              senderName: 'Elena Rostova',
              senderRole: 'Director of Technical Talent',
              senderCompany: 'CloudScale Global',
              senderAvatar: 'assets/images/cloudscale.png',
              category: 'recruiter',
              subject: 'Executive Staff Mobile Architect - Cloud Infrastructure Platform',
              body: 'Hi Safeer, your architectural work on offline SQLite sync and high-concurrency systems came up in our engineering leadership search.',
              opportunityTitle: 'Executive Staff Mobile Architect',
              opportunitySalary: '\$210,000 - \$250,000 + Equity',
              status: 'unread',
              replyContent: null,
              sentAt: '2 hours ago',
              repliedAt: null,
            ),
            const InmailMessage(
              id: 'inmail_2',
              userId: 'user_safeer',
              senderName: 'Marcus Thorne',
              senderRole: 'VP Talent Science',
              senderCompany: 'QuantumAI Labs',
              senderAvatar: 'assets/images/quantum_ai.png',
              category: 'recruiter',
              subject: 'Lead AI & Mobile Systems Engineer',
              body: 'Safeer, our team is developing real-time on-device AI inference workflows.',
              opportunityTitle: 'Lead AI & Mobile Systems Engineer',
              opportunitySalary: '\$220,000 - \$260,000 + Stock',
              status: 'read',
              replyContent: null,
              sentAt: 'Yesterday',
              repliedAt: null,
            ),
            const InmailMessage(
              id: 'inmail_3',
              userId: 'user_safeer',
              senderName: 'Sarah Vance',
              senderRole: 'Head of Talent',
              senderCompany: 'FinTech Prime',
              senderAvatar: 'assets/images/fintech_prime.png',
              category: 'recruiter',
              subject: 'Principal Mobile Systems Lead',
              body: 'Hello Safeer, we are scaling our high-frequency payment terminal mobile clients.',
              opportunityTitle: 'Principal Mobile Systems Lead',
              opportunitySalary: '\$195,000 - \$240,000',
              status: 'replied',
              replyContent: 'Interested, let us connect. I would be happy to review the technical specifications.',
              sentAt: '3 days ago',
              repliedAt: '2 days ago',
            ),
            const InmailMessage(
              id: 'inmail_4',
              userId: 'user_safeer',
              senderName: 'Alex Chen',
              senderRole: 'Community Organizer',
              senderCompany: 'Flutter Architecture Guild',
              senderAvatar: 'assets/images/techcorp.png',
              category: 'general',
              subject:
                  'Invitation: Keynote Speaker for Architecture Roundtable',
              body: 'Hi Safeer, would you be interested in delivering a 20-minute keynote on offline-first state architecture at our upcoming virtual roundtable?',
              opportunityTitle: null,
              opportunitySalary: null,
              status: 'unread',
              replyContent: null,
              sentAt: '4 days ago',
              repliedAt: null,
            ),
          ];

  @override
  Future<List<InmailMessage>> getMessages({
    String? category,
    String? userId,
  }) async {
    var result = List<InmailMessage>.from(inMemoryMessages);
    if (category != null && category.isNotEmpty) {
      result = result.where((m) => m.category == category).toList();
    }
    if (userId != null && userId.isNotEmpty) {
      result = result.where((m) => m.userId == userId).toList();
    }
    return result;
  }

  @override
  Future<InmailMessage?> getMessageById(String id) async {
    final idx = inMemoryMessages.indexWhere((m) => m.id == id);
    if (idx != -1) return inMemoryMessages[idx];
    return null;
  }

  @override
  Future<void> markAsRead(String id) async {
    final idx = inMemoryMessages.indexWhere((m) => m.id == id);
    if (idx != -1 && inMemoryMessages[idx].status == 'unread') {
      inMemoryMessages[idx] = inMemoryMessages[idx].copyWith(status: 'read');
    }
  }

  @override
  Future<InmailMessage> sendReply({
    required String id,
    required String replyContent,
  }) async {
    final idx = inMemoryMessages.indexWhere((m) => m.id == id);
    if (idx == -1) {
      throw StateError('Message not found');
    }
    final updated = inMemoryMessages[idx].copyWith(
      status: 'replied',
      replyContent: replyContent,
      repliedAt: 'Just now',
    );
    inMemoryMessages[idx] = updated;
    return updated;
  }

  @override
  Future<int> getUnreadCount({String? category, String? userId}) async {
    final messages = await getMessages(category: category, userId: userId);
    return messages.where((m) => m.status == 'unread').length;
  }
}
