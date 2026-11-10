import 'package:flutter_test/flutter_test.dart';
import 'package:open_pro/presentation/community/viewmodels/community_viewmodel.dart';

import '../helpers/mock_repositories.dart';

void main() {
  group('CommunityViewModel Unit Tests', () {
    late MockCommunityRepository mockRepo;
    late CommunityViewModel viewModel;

    setUp(() {
      mockRepo = MockCommunityRepository();
      viewModel = CommunityViewModel(repository: mockRepo);
    });

    test('Initializes with groups and events on tab 0', () async {
      await viewModel.loadData();
      expect(viewModel.groups.isNotEmpty, isTrue);
      expect(viewModel.events.isNotEmpty, isTrue);
      expect(viewModel.selectedTabIndex, equals(0));
    });

    test(
      'toggleJoinGroup mutates isJoined and increments memberCount reactively',
      () async {
        await viewModel.loadData();
        final group = viewModel.groups.first;
        final initialMembers = group.memberCount;
        expect(group.isJoined, isFalse);

        await viewModel.toggleJoinGroup(group.id);
        expect(viewModel.groups.first.isJoined, isTrue);
        expect(viewModel.groups.first.memberCount, equals(initialMembers + 1));

        // Toggle back
        await viewModel.toggleJoinGroup(group.id);
        expect(viewModel.groups.first.isJoined, isFalse);
        expect(viewModel.groups.first.memberCount, equals(initialMembers));
      },
    );

    test(
      'toggleRsvpEvent mutates isRsvp and increments attendeeCount reactively',
      () async {
        await viewModel.loadData();
        final event = viewModel.events.first;
        final initialAttendees = event.attendeeCount;
        expect(event.isRsvp, isFalse);

        await viewModel.toggleRsvpEvent(event.id);
        expect(viewModel.events.first.isRsvp, isTrue);
        expect(
          viewModel.events.first.attendeeCount,
          equals(initialAttendees + 1),
        );

        // Toggle back
        await viewModel.toggleRsvpEvent(event.id);
        expect(viewModel.events.first.isRsvp, isFalse);
        expect(viewModel.events.first.attendeeCount, equals(initialAttendees));
      },
    );

    test('createEvent adds new event to list at index 0', () async {
      await viewModel.loadData();
      final initialCount = viewModel.events.length;

      await viewModel.createEvent(
        title: 'Impeller Deep Dive Webinar',
        organizer: 'OpenPro Engineering Hub',
        dateDescription: 'Dec 15 • 2:00 PM EST',
        locationOrLink: 'Virtual Broadcast',
        isVirtual: true,
        speakers: ['Safeer Hussain'],
        tags: ['#Flutter', '#Impeller'],
      );

      expect(viewModel.events.length, equals(initialCount + 1));
      expect(
        viewModel.events.first.title,
        equals('Impeller Deep Dive Webinar'),
      );
      expect(viewModel.events.first.isRsvp, isTrue);
    });
  });
}
