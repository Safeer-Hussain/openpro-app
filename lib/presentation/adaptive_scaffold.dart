import 'dart:async';

import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:flutter/material.dart';

import '../core/constants/asset_paths.dart';
import '../core/notifications/local_notification_service.dart';
import '../core/services/service_locator.dart';
import 'ai_assistant/views/ai_career_assistant_view.dart';
import 'community/views/community_hub_view.dart';
import 'job_feed/views/job_feed_view.dart';
import 'profile/views/profile_view.dart';
import 'social_feed/views/social_feed_view.dart';

class AdaptiveScaffold extends StatefulWidget {
  const AdaptiveScaffold({super.key});

  @override
  State<AdaptiveScaffold> createState() => _AdaptiveScaffoldState();
}

class _AdaptiveScaffoldState extends State<AdaptiveScaffold> {
  int _currentIndex = 0;
  bool _isOffline = false;
  StreamSubscription<List<ConnectivityResult>>? _connectivitySubscription;
  StreamSubscription<RecruiterNotification>? _notificationSubscription;
  RecruiterNotification? _activePushBanner;

  final List<Widget> _screens = const [
    JobFeedView(),
    SocialFeedView(),
    AiCareerAssistantView(),
    CommunityHubView(),
    ProfileView(),
  ];

  final List<String> _titles = const [
    'OpenPro • Opportunities',
    'OpenPro • Network Feed',
    'OpenPro • Career Assistant',
    'OpenPro • Guilds & Events',
    'OpenPro • Executive Profile',
  ];

  @override
  void initState() {
    super.initState();
    _initConnectivity();
    _initNotificationListener();
  }

  void _initConnectivity() {
    _connectivitySubscription = Connectivity().onConnectivityChanged.listen((
      results,
    ) {
      final isNone = results.contains(ConnectivityResult.none);
      if (mounted && isNone != _isOffline) {
        setState(() => _isOffline = isNone);
      }
    });
  }

  void _initNotificationListener() {
    final service = sl<LocalNotificationService>();
    _notificationSubscription = service.notificationStream.listen((notif) {
      if (mounted) {
        setState(() => _activePushBanner = notif);
        Future.delayed(const Duration(seconds: 4), () {
          if (mounted && _activePushBanner?.id == notif.id) {
            setState(() => _activePushBanner = null);
          }
        });
      }
    });
  }

  @override
  void dispose() {
    _connectivitySubscription?.cancel();
    _notificationSubscription?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final orientation = MediaQuery.of(context).orientation;
    final isLandscape = orientation == Orientation.landscape;
    final colorScheme = Theme.of(context).colorScheme;

    return GestureDetector(
      behavior: HitTestBehavior.translucent,
      onTap: () => FocusManager.instance.primaryFocus?.unfocus(),
      child: Scaffold(
        appBar: AppBar(
          toolbarHeight: isLandscape ? 36 : 56,
          leading: Padding(
            padding: EdgeInsets.all(isLandscape ? 6 : 10),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(8),
              child: Image.asset(AssetPaths.appIcon, fit: BoxFit.contain),
            ),
          ),
          title: Text(
            _titles[_currentIndex],
            style: TextStyle(
              fontSize: isLandscape ? 13 : 17,
              fontWeight: FontWeight.w800,
              color: colorScheme.onSurface,
              letterSpacing: -0.3,
            ),
          ),
          actions: [
            if (_isOffline)
              Padding(
                padding: const EdgeInsets.only(right: 8),
                child: Chip(
                  avatar: const Icon(Icons.cloud_off_rounded, size: 14),
                  label: const Text(
                    'Offline Graph',
                    style: TextStyle(fontSize: 10, fontWeight: FontWeight.w700),
                  ),
                  backgroundColor: colorScheme.errorContainer,
                  side: BorderSide.none,
                  padding: EdgeInsets.zero,
                ),
              ),
          ],
        ),
        body: Stack(
          children: [
            Column(
              children: [
                if (_isOffline)
                  Container(
                    width: double.infinity,
                    color: colorScheme.errorContainer,
                    padding: const EdgeInsets.symmetric(
                      horizontal: 16,
                      vertical: 4,
                    ),
                    child: Text(
                      'Offline Mode - Serving Local SQL Career Graph',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontSize: 11,
                        fontWeight: FontWeight.w700,
                        color: colorScheme.onErrorContainer,
                      ),
                    ),
                  ),
                Expanded(
                  child: isLandscape
                      ? Row(
                          children: [
                            // Compact Left NavigationRail in landscape (Safe on 360dp phone height)
                            Container(
                              decoration: BoxDecoration(
                                border: Border(
                                  right: BorderSide(
                                    color: colorScheme.outlineVariant,
                                  ),
                                ),
                              ),
                              child: SingleChildScrollView(
                                physics: const ClampingScrollPhysics(),
                                child: IntrinsicHeight(
                                  child: NavigationRail(
                                    minWidth: 56,
                                    labelType: NavigationRailLabelType.none,
                                    selectedIndex: _currentIndex,
                                    onDestinationSelected: (val) =>
                                        setState(() => _currentIndex = val),
                                    destinations: const [
                                      NavigationRailDestination(
                                        icon: Icon(Icons.work_outline_rounded),
                                        selectedIcon: Icon(Icons.work_rounded),
                                        label: Text('Jobs'),
                                      ),
                                      NavigationRailDestination(
                                        icon: Icon(Icons.dynamic_feed_rounded),
                                        selectedIcon: Icon(Icons.feed_rounded),
                                        label: Text('Feed'),
                                      ),
                                      NavigationRailDestination(
                                        icon: Icon(Icons.auto_awesome_outlined),
                                        selectedIcon: Icon(
                                          Icons.auto_awesome_rounded,
                                        ),
                                        label: Text('AI'),
                                      ),
                                      NavigationRailDestination(
                                        icon: Icon(Icons.hub_outlined),
                                        selectedIcon: Icon(Icons.hub_rounded),
                                        label: Text('Guilds'),
                                      ),
                                      NavigationRailDestination(
                                        icon: Icon(
                                          Icons.person_outline_rounded,
                                        ),
                                        selectedIcon: Icon(
                                          Icons.person_rounded,
                                        ),
                                        label: Text('Profile'),
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                            ),
                            Expanded(child: _screens[_currentIndex]),
                          ],
                        )
                      : _screens[_currentIndex],
                ),
              ],
            ),

            // In-App Simulated Recruiter Push Banner
            if (_activePushBanner != null)
              Positioned(
                top: 8,
                left: 16,
                right: 16,
                child: Material(
                  elevation: 6,
                  borderRadius: BorderRadius.circular(16),
                  color: colorScheme.surfaceContainerHighest,
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 14,
                      vertical: 10,
                    ),
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(
                        color: colorScheme.primary,
                        width: 1.5,
                      ),
                    ),
                    child: Row(
                      children: [
                        CircleAvatar(
                          radius: 18,
                          backgroundColor: colorScheme.primaryContainer,
                          child: Icon(
                            Icons.flash_on_rounded,
                            size: 20,
                            color: colorScheme.primary,
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Text(
                                _activePushBanner!.title,
                                style: TextStyle(
                                  fontSize: 12.5,
                                  fontWeight: FontWeight.w800,
                                  color: colorScheme.onSurface,
                                ),
                              ),
                              Text(
                                _activePushBanner!.body,
                                style: TextStyle(
                                  fontSize: 11,
                                  color: colorScheme.onSurfaceVariant,
                                ),
                                maxLines: 2,
                                overflow: TextOverflow.ellipsis,
                              ),
                            ],
                          ),
                        ),
                        IconButton(
                          icon: const Icon(Icons.close_rounded, size: 16),
                          onPressed: () =>
                              setState(() => _activePushBanner = null),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
          ],
        ),
        bottomNavigationBar: isLandscape
            ? null
            : NavigationBar(
                selectedIndex: _currentIndex,
                onDestinationSelected: (val) =>
                    setState(() => _currentIndex = val),
                destinations: const [
                  NavigationDestination(
                    icon: Icon(Icons.work_outline_rounded),
                    selectedIcon: Icon(Icons.work_rounded),
                    label: 'Jobs',
                  ),
                  NavigationDestination(
                    icon: Icon(Icons.dynamic_feed_rounded),
                    selectedIcon: Icon(Icons.feed_rounded),
                    label: 'Feed',
                  ),
                  NavigationDestination(
                    icon: Icon(Icons.auto_awesome_outlined),
                    selectedIcon: Icon(Icons.auto_awesome_rounded),
                    label: 'AI Match',
                  ),
                  NavigationDestination(
                    icon: Icon(Icons.hub_outlined),
                    selectedIcon: Icon(Icons.hub_rounded),
                    label: 'Community',
                  ),
                  NavigationDestination(
                    icon: Icon(Icons.person_outline_rounded),
                    selectedIcon: Icon(Icons.person_rounded),
                    label: 'Profile',
                  ),
                ],
              ),
      ),
    );
  }
}
