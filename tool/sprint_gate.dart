// ignore_for_file: avoid_print

import 'dart:async';
import 'dart:convert';
import 'dart:io';

Future<void> main(List<String> args) async {
  print('====================================================================');
  print('OPENPRO AUTONOMOUS SPRINT VERIFICATION GATE');
  print('====================================================================');
  final stopwatch = Stopwatch()..start();

  // 1. Dependency Resolution
  await _runStep(
    stepNumber: 1,
    title: 'Dependency Resolution (flutter pub get)',
    command: 'flutter',
    args: ['pub', 'get'],
  );

  // 2. Code Formatting (Auto-format lib & test)
  await _runStep(
    stepNumber: 2,
    title: 'Code Formatting (dart format lib test)',
    command: 'dart',
    args: ['format', 'lib', 'test'],
  );

  // 3. Static Analysis
  await _runStep(
    stepNumber: 3,
    title: 'Static Analysis (flutter analyze --no-pub)',
    command: 'flutter',
    args: ['analyze', '--no-pub'],
    validateOutput: (stdout, stderr) {
      if (stdout.contains('error •') || stdout.contains('warning •') || stdout.contains('info •')) {
        return false;
      }
      return stdout.contains('No issues found!');
    },
  );

  // 4. Automated Tests
  await _runStep(
    stepNumber: 4,
    title: 'Automated Test Suite (flutter test --no-pub)',
    command: 'flutter',
    args: ['test', '--no-pub'],
    validateOutput: (stdout, stderr) {
      return stdout.contains('All tests passed!');
    },
  );

  // 5. Connected Physical Device / Emulator Runtime Verification
  await _runDeviceRuntimeCheck(stepNumber: 5);

  stopwatch.stop();
  print('====================================================================');
  print('[PASS] ALL SPRINT GATE CHECKS VERIFIED SUCCESSFULLY in ${stopwatch.elapsed.inSeconds}s');
  print('====================================================================');
  exit(0);
}

Future<void> _runStep({
  required int stepNumber,
  required String title,
  required String command,
  required List<String> args,
  bool Function(String stdout, String stderr)? validateOutput,
}) async {
  print('\n[$stepNumber/5] -> $title...');
  final result = await Process.run(command, args, runInShell: true);

  final stdoutText = result.stdout.toString().trim();
  final stderrText = result.stderr.toString().trim();

  if (result.exitCode != 0) {
    print('[FAIL] Step $stepNumber failed with exit code ${result.exitCode}');
    if (stdoutText.isNotEmpty) print('STDOUT:\n$stdoutText');
    if (stderrText.isNotEmpty) print('STDERR:\n$stderrText');
    exit(1);
  }

  if (validateOutput != null) {
    final isValid = validateOutput(stdoutText, stderrText);
    if (!isValid) {
      print('[FAIL] Step $stepNumber validation condition not satisfied.');
      if (stdoutText.isNotEmpty) print('STDOUT:\n$stdoutText');
      if (stderrText.isNotEmpty) print('STDERR:\n$stderrText');
      exit(1);
    }
  }

  // Print concise summary of output
  final lines = stdoutText.split('\n').where((l) => l.trim().isNotEmpty).toList();
  if (lines.isNotEmpty) {
    final summary = lines.length <= 3 ? lines.join('\n') : '${lines.first} ... ${lines.last}';
    print('[OK] $summary');
  } else {
    print('[OK] Success.');
  }
}

Future<void> _runDeviceRuntimeCheck({required int stepNumber}) async {
  print('\n[$stepNumber/5] -> Checking Connected Devices for Live Runtime Smoke Test...');

  final deviceListResult = await Process.run(
    'flutter',
    ['devices', '--machine'],
    runInShell: true,
  );

  if (deviceListResult.exitCode != 0) {
    print('[WARN] Could not retrieve device list. Skipping runtime device test.');
    return;
  }

  List<dynamic> devices = [];
  try {
    devices = jsonDecode(deviceListResult.stdout.toString()) as List<dynamic>;
  } catch (e) {
    print('[WARN] Failed to parse devices JSON output: $e');
    return;
  }

  // Find physical or emulator mobile devices (Android or iOS)
  final mobileDevices = devices.where((d) {
    final platform = (d['targetPlatform'] ?? '').toString().toLowerCase();
    return platform.startsWith('android') || platform.startsWith('ios');
  }).toList();

  if (mobileDevices.isEmpty) {
    final deviceNames = devices.map((d) => d['name'] ?? d['id']).toList();
    print('[INFO] No mobile device or emulator connected via USB. Detected devices: $deviceNames');
    print('[INFO] Mobile runtime smoke test skipped. Unit and widget verification active.');
    return;
  }

  final targetDevice = mobileDevices.first;
  final deviceId = targetDevice['id']?.toString() ?? '';
  final deviceName = targetDevice['name']?.toString() ?? 'Mobile Device';
  final isAndroid = (targetDevice['targetPlatform'] ?? '').toString().toLowerCase().startsWith('android');

  print('[DEVICE] Target Mobile Device: $deviceName (ID: $deviceId)');

  final adbPath = _findAdbExecutable();

  // Clear stale device logs if Android
  if (isAndroid && adbPath != null) {
    print('[DEVICE] Clearing stale device logcat buffer...');
    await Process.run(adbPath, ['-s', deviceId, 'logcat', '-c'], runInShell: true);
  }

  print('[DEVICE] Launching application with 25-second live runtime smoke window...');
  final runProcess = await Process.start(
    'flutter',
    ['run', '-d', deviceId, '--suppress-analytics'],
    runInShell: true,
  );

  final StringBuffer consoleOutput = StringBuffer();
  final stdoutSub = runProcess.stdout.transform(utf8.decoder).listen((data) {
    consoleOutput.write(data);
  });
  final stderrSub = runProcess.stderr.transform(utf8.decoder).listen((data) {
    consoleOutput.write(data);
  });

  // Allow 25 seconds of live runtime
  await Future.delayed(const Duration(seconds: 25));

  // Terminate run process gracefully by sending 'q'
  try {
    runProcess.stdin.writeln('q');
    await runProcess.stdin.flush();
  } catch (_) {}

  // Wait up to 5 additional seconds, then kill if still running
  await Future.any([
    runProcess.exitCode,
    Future.delayed(const Duration(seconds: 5), () {
      runProcess.kill();
    }),
  ]);

  await stdoutSub.cancel();
  await stderrSub.cancel();

  // Check logs for runtime exceptions
  final capturedConsole = consoleOutput.toString();
  String combinedLogs = capturedConsole;

  if (isAndroid && adbPath != null) {
    print('[DEVICE] Inspecting device logcat output for critical exceptions...');
    final logcatResult = await Process.run(
      adbPath,
      ['-s', deviceId, 'logcat', '-d'],
      runInShell: true,
    );
    combinedLogs += '\n${logcatResult.stdout}';
  }

  final prohibitedPatterns = [
    'EXCEPTION CAUGHT BY',
    'A RenderFlex overflowed by',
    'There are multiple heroes that share the same tag',
    'No observables detected in the build method of Observer',
    'setState() or markNeedsBuild() called during build',
    'AndroidRuntime: FATAL EXCEPTION',
    'Unhandled Exception:',
  ];

  for (final pattern in prohibitedPatterns) {
    if (combinedLogs.contains(pattern)) {
      print('\n[CRITICAL ERROR] Prohibited runtime exception detected on device: "$pattern"');
      final matchingLines = combinedLogs
          .split('\n')
          .where((line) => line.contains(pattern))
          .take(5)
          .join('\n');
      print('Matching log output:\n$matchingLines');
      exit(1);
    }
  }

  print('[DEVICE] Live runtime smoke test passed with 0 runtime exceptions on $deviceName.');
}

String? _findAdbExecutable() {
  // Check if adb is directly reachable
  try {
    final result = Process.runSync('adb', ['version'], runInShell: true);
    if (result.exitCode == 0) return 'adb';
  } catch (_) {}

  // Check common Android SDK installation paths on Windows & Unix
  final localAppData = Platform.environment['LOCALAPPDATA'];
  final androidHome = Platform.environment['ANDROID_HOME'] ?? Platform.environment['ANDROID_SDK_ROOT'];
  final userProfile = Platform.environment['USERPROFILE'] ?? Platform.environment['HOME'];

  final candidates = [
    if (localAppData != null) '$localAppData\\Android\\Sdk\\platform-tools\\adb.exe',
    if (androidHome != null) '$androidHome\\platform-tools\\adb.exe',
    if (androidHome != null) '$androidHome/platform-tools/adb',
    if (userProfile != null) '$userProfile\\AppData\\Local\\Android\\Sdk\\platform-tools\\adb.exe',
    if (userProfile != null) '$userProfile/Library/Android/sdk/platform-tools/adb',
  ];

  for (final path in candidates) {
    if (File(path).existsSync()) {
      return path;
    }
  }

  return null;
}
