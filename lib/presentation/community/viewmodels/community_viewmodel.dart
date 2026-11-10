import 'package:flutter/foundation.dart';

import '../../../data/repositories/community_repository.dart';
import '../../../domain/entities/event_entity.dart';
import '../../../domain/entities/group_entity.dart';

class CommunityViewModel extends ChangeNotifier {
  final CommunityRepository repository;

  int _selectedTabIndex = 0; // 0 = Groups, 1 = Events
  List<GroupEntity> _groups = [];
  List<EventEntity> _events = [];
  bool _isLoading = true;

  CommunityViewModel({required this.repository}) {
    loadData();
  }

  int get selectedTabIndex => _selectedTabIndex;
  List<GroupEntity> get groups => _groups;
  List<EventEntity> get events => _events;
  bool get isLoading => _isLoading;

  void setTabIndex(int index) {
    _selectedTabIndex = index;
    notifyListeners();
  }

  Future<void> loadData() async {
    _isLoading = true;
    notifyListeners();
    try {
      final results = await Future.wait([
        repository.getGroups(),
        repository.getEvents(),
      ]);
      _groups = results[0] as List<GroupEntity>;
      _events = results[1] as List<EventEntity>;
    } catch (_) {}
    _isLoading = false;
    notifyListeners();
  }

  Future<void> toggleJoinGroup(String groupId) async {
    final index = _groups.indexWhere((g) => g.id == groupId);
    if (index == -1) return;

    final current = _groups[index];
    final willJoin = !current.isJoined;
    final newMemberCount = willJoin
        ? current.memberCount + 1
        : (current.memberCount - 1).clamp(0, 999999);

    final updated = current.copyWith(
      isJoined: willJoin,
      memberCount: newMemberCount,
    );

    // Optimistic mutation
    _groups[index] = updated;
    notifyListeners();

    try {
      await repository.toggleJoinGroup(groupId);
    } catch (_) {
      _groups[index] = current;
      notifyListeners();
    }
  }

  Future<void> toggleRsvpEvent(String eventId) async {
    final index = _events.indexWhere((e) => e.id == eventId);
    if (index == -1) return;

    final current = _events[index];
    final willRsvp = !current.isRsvp;
    final newAttendeeCount = willRsvp
        ? current.attendeeCount + 1
        : (current.attendeeCount - 1).clamp(0, 999999);

    final updated = current.copyWith(
      isRsvp: willRsvp,
      attendeeCount: newAttendeeCount,
    );

    // Optimistic mutation
    _events[index] = updated;
    notifyListeners();

    try {
      await repository.toggleRsvpEvent(eventId);
    } catch (_) {
      _events[index] = current;
      notifyListeners();
    }
  }

  Future<void> createEvent({
    required String title,
    required String organizer,
    required String dateDescription,
    required String locationOrLink,
    required bool isVirtual,
    List<String> speakers = const [],
    List<String> tags = const [],
  }) async {
    final newEvent = EventEntity(
      id: 'evt_${DateTime.now().millisecondsSinceEpoch}',
      title: title,
      organizer: organizer,
      organizerLogo: 'assets/images/techcorp.png',
      dateDescription: dateDescription,
      dateTime: DateTime.now().toIso8601String(),
      locationOrLink: locationOrLink,
      isVirtual: isVirtual,
      attendeeCount: 1,
      isRsvp: true,
      speakers: speakers,
      tags: tags,
    );

    _events.insert(0, newEvent);
    notifyListeners();

    try {
      await repository.createEvent(newEvent);
    } catch (_) {}
  }
}
