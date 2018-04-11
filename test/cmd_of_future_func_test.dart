import 'dart:async';

import 'package:flutter_test/flutter_test.dart';

import 'package:dartea/dartea.dart';

import 'testable_program.dart';
import 'counter_app.dart';

void main() {
  group('cmd of future functions', () {
    testWidgets('0 args success', (WidgetTester tester) async {
      var initArg = 0;
      var sideEffect = "side effect!";
      Future<String> func() => Future.sync(() => sideEffect);

      var effect = Cmd.ofFutureFunc<String, Message>(func,
          onSuccess: (x) => OnSuccessEffectWithResult(x));
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
            predicate((Message m) =>
                m is OnSuccessEffectWithResult && m.result == sideEffect),
          ]));
    });

    testWidgets('1 arg success', (WidgetTester tester) async {
      var initArg = 0;
      var sideEffect = "side effect!";
      Future<String> func(String arg) => Future.sync(() => arg);

      var effect = Cmd.ofFutureFunc1<String, Message, String>(func, sideEffect,
          onSuccess: (x) => OnSuccessEffectWithResult(x));
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
            predicate((Message m) =>
                m is OnSuccessEffectWithResult && m.result == sideEffect),
          ]));
    });

    testWidgets('2 args success', (WidgetTester tester) async {
      var initArg = 0;
      var arg1 = "side ";
      var arg2 = "effect!";
      Future<String> func(String arg1, String arg2) =>
          Future.sync(() => arg1 + arg2);

      var effect = Cmd.ofFutureFunc2<String, Message, String, String>(
          func, arg1, arg2,
          onSuccess: (x) => OnSuccessEffectWithResult(x));
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
            predicate((Message m) =>
                m is OnSuccessEffectWithResult && m.result == arg1 + arg2),
          ]));
    });

    testWidgets('3 args success', (WidgetTester tester) async {
      var initArg = 0;
      var arg1 = "side ";
      var arg2 = "effect";
      var arg3 = "!";
      Future<String> func(String arg1, String arg2, String arg3) =>
          Future.sync(() => arg1 + arg2 + arg3);

      var effect = Cmd.ofFutureFunc3<String, Message, String, String, String>(
          func, arg1, arg2, arg3,
          onSuccess: (x) => OnSuccessEffectWithResult(x));
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
            predicate((Message m) =>
                m is OnSuccessEffectWithResult &&
                m.result == arg1 + arg2 + arg3),
          ]));
    });

    testWidgets('error', (WidgetTester tester) async {
      var initArg = 0;
      var sideEffect = "side effect!";
      var error = new Exception(sideEffect);
      Future<String> func() => Future.sync(() => throw error);

      var effect = Cmd.ofFutureFunc<String, Message>(func,
          onSuccess: (_) => OnSuccessEffectWithResult(_),
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
            predicate((Message m) =>
                m is ErrorMessage && m.message == error.toString())
          ]));
    });
  });
}
