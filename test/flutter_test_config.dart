import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';

Future<void> testExecutable(FutureOr<void> Function() testMain) async {
  WidgetController.hitTestWarningShouldBeFatal = true;

  // Prevent cursor blinking
  EditableText.debugDeterministicCursor = true;

  // Don't implicitly return `null` for non-mocked methods
  Mock.throwOnMissingStub();

  await testMain();
}
