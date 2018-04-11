import 'dart:async';

import 'package:flutter_test/flutter_test.dart';

import 'package:dartea/dartea.dart';

import 'testable_program.dart';
import 'counter_app.dart';

void main() {
  group('cmd of future actions', () {
    StreamController<String> effectsController;

    setUp(() {
      effectsController = new StreamController<String>();
    });

    testWidgets('0 args success', (WidgetTester tester) async {
      var initArg = 0;
      var sideEffect = "side effect!";
      Future action() async {
        effectsController.add(sideEffect);
      }

      var effect = Cmd.ofFutureAction<Message>(action,
          onSuccess: () => OnSuccessEffect());
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
            predicate((Message m) => m is OnSuccessEffect),
          ]));
      expect(effectsController.stream, emitsInOrder([sideEffect]));
    });

    testWidgets('1 arg success', (WidgetTester tester) async {
      var initArg = 0;
      var sideEffect = "side effect!";
      Future action(String arg) async {
        effectsController.add(arg);
      }

      var effect = Cmd.ofFutureAction1<Message, String>(action, sideEffect,
          onSuccess: () => OnSuccessEffect());
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
            predicate((Message m) => m is OnSuccessEffect),
          ]));
      expect(effectsController.stream, emitsInOrder([sideEffect]));
    });

    testWidgets('2 args success', (WidgetTester tester) async {
      var initArg = 0;
      var arg1 = "side ";
      var arg2 = "effect!";
      Future action(String arg1, String arg2) async {
        effectsController.add(arg1);
        effectsController.add(arg2);
      }

      var effect = Cmd.ofFutureAction2<Message, String, String>(
          action, arg1, arg2,
          onSuccess: () => OnSuccessEffect());
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
            predicate((Message m) => m is OnSuccessEffect),
          ]));
      expect(effectsController.stream, emitsInOrder([arg1, arg2]));
    });

    testWidgets('3 args success', (WidgetTester tester) async {
      var initArg = 0;
      var arg1 = "side ";
      var arg2 = "effect";
      var arg3 = "!";
      Future action(String arg1, String arg2, String arg3) async {
        effectsController.add(arg1);
        effectsController.add(arg2);
        effectsController.add(arg3);
      }

      var effect = Cmd.ofFutureAction3<Message, String, String, String>(
          action, arg1, arg2, arg3,
          onSuccess: () => OnSuccessEffect());
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
            predicate((Message m) => m is OnSuccessEffect),
          ]));
      expect(effectsController.stream, emitsInOrder([arg1, arg2, arg3]));
    });

    testWidgets('error', (WidgetTester tester) async {
      var initArg = 0;
      var sideEffect = "side effect!";
      var error = new Exception(sideEffect);
      Future action() async {
        throw error;
      }

      var effect = Cmd.ofFutureAction<Message>(action,
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
    });
  });
}
