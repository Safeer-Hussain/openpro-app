import 'package:flutter/foundation.dart';

import '../../../core/constants/app_constants.dart';
import '../../../data/repositories/job_repository.dart';
import '../../../domain/entities/job_entity.dart';

class InterviewSchedulerViewModel extends ChangeNotifier {
  final JobRepository repository;
  final JobEntity job;
  final String userId;
  final DateTime now;

  late final List<DateTime> availableDays;
  late DateTime selectedDay;
  final List<DateTime> selectedSlots = [];

  bool _isSubmitting = false;
  String? _errorMessage;

  InterviewSchedulerViewModel({
    required this.repository,
    required this.job,
    String? userId,
    DateTime? currentTime,
  }) : userId = userId ?? AppConstants.defaultUserId,
       now = currentTime ?? DateTime.now() {
    _initializeDays();
  }

  bool get isSubmitting => _isSubmitting;
  String? get errorMessage => _errorMessage;
  int get selectedCount => selectedSlots.length;
  bool get canConfirm =>
      selectedSlots.isNotEmpty && selectedSlots.length <= 3 && !_isSubmitting;

  void _initializeDays() {
    availableDays = List.generate(7, (index) {
      final target = now.add(Duration(days: index + 1));
      return DateTime(target.year, target.month, target.day);
    });
    selectedDay = availableDays.first;
  }

  void selectDay(DateTime day) {
    selectedDay = day;
    _errorMessage = null;
    notifyListeners();
  }

  List<DateTime> getSlotsForDay(DateTime day) {
    final standardHours = [
      const [9, 0],
      const [10, 0],
      const [11, 30],
      const [13, 30],
      const [15, 0],
      const [16, 30],
    ];

    return standardHours.map((pair) {
      return DateTime(day.year, day.month, day.day, pair[0], pair[1]);
    }).toList();
  }

  bool isSlotValid(DateTime slot) {
    final minAdvanceWindow = now.add(const Duration(hours: 24));
    return slot.isAfter(minAdvanceWindow);
  }

  bool isSlotSelected(DateTime slot) {
    return selectedSlots.any((s) => s.isAtSameMomentAs(slot));
  }

  bool toggleSlot(DateTime slot) {
    final existingIndex = selectedSlots.indexWhere(
      (s) => s.isAtSameMomentAs(slot),
    );

    if (existingIndex != -1) {
      selectedSlots.removeAt(existingIndex);
      _errorMessage = null;
      notifyListeners();
      return true;
    }

    if (!isSlotValid(slot)) {
      _errorMessage = 'Slots must be selected at least 24 hours in advance.';
      notifyListeners();
      return false;
    }

    if (selectedSlots.length >= 3) {
      _errorMessage = 'Maximum of 3 preferred interview slots can be selected.';
      notifyListeners();
      return false;
    }

    selectedSlots.add(slot);
    selectedSlots.sort((a, b) => a.compareTo(b));
    _errorMessage = null;
    notifyListeners();
    return true;
  }

  Future<bool> confirmInterview() async {
    if (!canConfirm) return false;

    _isSubmitting = true;
    _errorMessage = null;
    notifyListeners();

    try {
      final success = await repository.scheduleInterviewSlots(
        jobId: job.id,
        userId: userId,
        slots: selectedSlots,
      );
      _isSubmitting = false;
      notifyListeners();
      return success;
    } catch (e) {
      _isSubmitting = false;
      _errorMessage = 'Failed to confirm interview slots. Please retry.';
      notifyListeners();
      return false;
    }
  }
}
