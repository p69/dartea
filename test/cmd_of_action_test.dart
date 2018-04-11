import 'dart:async';

import 'package:flutter_test/flutter_test.dart';

import 'package:dartea/dartea.dart';

import 'testable_program.dart';
import 'counter_app.dart';

void main() {
  group('cmd of actions', () {
    StreamController<String> effectsController;

    setUp(() {
      effectsController = new StreamController<String>();
    });

    testWidgets('0 args success', (WidgetTester tester) async {
      var initArg = 0;
      var sideEffect = "side effect!";
      var effect = Cmd.ofAction<Message>(
          () => effectsController.add(sideEffect),
          onSuccess: () => OnSuccessEffect());
      var program =
          TestProgram((start) => init(start, effect: effect), update, view);
      program.runWith(initArg);

      await tester.pumpWidget(program.frames.removeLast());
      await tester.tap(find.byKey(incrementBtnKey));
      await tester.tap(find.byKey(effectBtnKey));
      await tester.tap(find.byKey(effectBtnKey));
      await tester.pumpWidget(program.frames.removeLast());

      expect(
          program.updates,
          emitsInOrder([
            predicate((Message m) => m is Increment),
            predicate((Message m) => m is DoSideEffect),
            predicate((Message m) => m is OnSuccessEffect),
            predicate((Message m) => m is DoSideEffect),
            predicate((Message m) => m is OnSuccessEffect)
          ]));
      expect(effectsController.stream, emitsInOrder([sideEffect, sideEffect]));
      expect(find.text((initArg + 1).toString()), findsOneWidget);
    });

    testWidgets('1 arg success', (WidgetTester tester) async {
      var initArg = 0;
      var sideEffect = "side effect!";
      var effect = Cmd.ofAction1<Message, String>(
          (arg) => effectsController.add(arg), sideEffect,
          onSuccess: () => OnSuccessEffect());
      var program =
          TestProgram((start) => init(start, effect: effect), update, view);
      program.runWith(initArg);

      await tester.pumpWidget(program.frames.removeLast());
      await tester.tap(find.byKey(incrementBtnKey));
      await tester.tap(find.byKey(effectBtnKey));
      await tester.pumpWidget(program.frames.removeLast());

      expect(
          program.updates,
          emitsInOrder([
            predicate((Message m) => m is Increment),
            predicate((Message m) => m is DoSideEffect),
            predicate((Message m) => m is OnSuccessEffect)
          ]));
      expect(effectsController.stream, emitsInOrder([sideEffect]));
      expect(find.text((initArg + 1).toString()), findsOneWidget);
    });

    testWidgets('2 args success', (WidgetTester tester) async {
      var initArg = 0;
      var arg1 = "side ";
      var arg2 = "effect!";
      var effect = Cmd.ofAction2<Message, String, String>(
          (arg1, arg2) => effectsController.add(arg1 + arg2), arg1, arg2,
          onSuccess: () => OnSuccessEffect());
      var program =
          TestProgram((start) => init(start, effect: effect), update, view);
      program.runWith(initArg);

      await tester.pumpWidget(program.frames.removeLast());
      await tester.tap(find.byKey(incrementBtnKey));
      await tester.tap(find.byKey(effectBtnKey));
      await tester.pumpWidget(program.frames.removeLast());

      expect(
          program.updates,
          emitsInOrder([
            predicate((Message m) => m is Increment),
            predicate((Message m) => m is DoSideEffect),
            predicate((Message m) => m is OnSuccessEffect)
          ]));
      expect(effectsController.stream, emitsInOrder([arg1 + arg2]));
      expect(find.text((initArg + 1).toString()), findsOneWidget);
    });

    testWidgets('3 args success', (WidgetTester tester) async {
      var initArg = 0;
      var arg1 = "side ";
      var arg2 = "effect";
      var arg3 = "!";
      var effect = Cmd.ofAction3<Message, String, String, String>(
          (arg1, arg2, arg3) => effectsController.add(arg1 + arg2 + arg3),
          arg1,
          arg2,
          arg3,
          onSuccess: () => OnSuccessEffect());
      var program =
          TestProgram((start) => init(start, effect: effect), update, view);
      program.runWith(initArg);

      await tester.pumpWidget(program.frames.removeLast());
      await tester.tap(find.byKey(incrementBtnKey));
      await tester.tap(find.byKey(effectBtnKey));
      await tester.pumpWidget(program.frames.removeLast());

      expect(
          program.updates,
          emitsInOrder([
            predicate((Message m) => m is Increment),
            predicate((Message m) => m is DoSideEffect),
            predicate((Message m) => m is OnSuccessEffect)
          ]));
      expect(effectsController.stream, emitsInOrder([arg1 + arg2 + arg3]));
      expect(find.text((initArg + 1).toString()), findsOneWidget);
    });

    testWidgets('error', (WidgetTester tester) async {
      var initArg = 0;
      var sideEffect = "side effect!";
      var error = new Exception(sideEffect);
      var effect = Cmd.ofAction<Message>(() => throw error,
          onError: (Exception e) => ErrorMessage(e.toString()));
      var program =
          TestProgram((start) => init(start, effect: effect), update, view);
      program.runWith(initArg);

      await tester.pumpWidget(program.frames.removeLast());
      await tester.tap(find.byKey(effectBtnKey));
      await tester.pumpWidget(program.frames.removeLast());

      expect(
          program.updates,
          emitsInOrder([
            predicate((Message m) => m is DoSideEffect),
            predicate((Message m) {
              if (m is ErrorMessage) {
                return m.message == error.toString();
              }
              return false;
            })
          ]));
      expect(find.text((initArg).toString()), findsOneWidget);
    });
  });
}
