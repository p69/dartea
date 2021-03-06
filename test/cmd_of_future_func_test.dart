import 'dart:async';

import 'package:flutter_test/flutter_test.dart';

import 'package:dartea/dartea.dart';

import 'testable_program.dart';
import 'counter_app.dart';

void main() {
  group('cmd of future functions', () {
    const initArg = 0;
    const sideEffect = "side effect!";
    Cmd<Message> successEffect;
    Cmd<Message> errorEffect;
    Exception error = new Exception(sideEffect);

    setUp(() {
      Future<String> successFunc() => Future.sync(() => sideEffect);
      Future<String> errorFunc() => Future.sync(() => throw error);
      successEffect = Cmd.ofAsyncFunc<String, Message>(successFunc,
          onSuccess: (x) => OnSuccessEffectWithResult(x));
      errorEffect = Cmd.ofAsyncFunc<String, Message>(errorFunc,
          onSuccess: (x) => OnSuccessEffectWithResult(x),
          onError: (Exception e) => ErrorMessage(e.toString()));
    });

    testWidgets('success', (WidgetTester tester) async {
      var program =
          TestProgram(() => init(initArg, effect: successEffect), update, view);
      program.run();

      await tester.pumpWidget(program.frame);
      await tester.tap(find.byKey(effectBtnKey));
      await tester.pumpWidget(program.frame);

      expect(
          program.updates,
          emitsInOrder([
            predicate((Message m) => m is DoSideEffect),
            predicate((Message m) =>
                m is OnSuccessEffectWithResult && m.result == sideEffect),
          ]));
    });

    testWidgets('error', (WidgetTester tester) async {
      var program =
          TestProgram(() => init(initArg, effect: errorEffect), update, view);
      program.run();

      await tester.pumpWidget(program.frame);
      await tester.tap(find.byKey(effectBtnKey));
      await tester.pumpWidget(program.frame);

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
