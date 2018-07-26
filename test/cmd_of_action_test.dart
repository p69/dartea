import 'dart:async';

import 'package:flutter_test/flutter_test.dart';

import 'package:dartea/dartea.dart';

import 'testable_program.dart';
import 'counter_app.dart';

void main() {
  group('cmd of actions', () {
    const initArg = 0;
    const sideEffect = "side effect!";
    StreamController<String> effectsController;
    Cmd<Message> successEffect;
    Cmd<Message> errorEffect;
    Exception error = new Exception(sideEffect);

    setUp(() {
      effectsController = new StreamController<String>();
      successEffect = Cmd.ofAction<Message>(
          () => effectsController.add(sideEffect),
          onSuccess: () => OnSuccessEffect());
      errorEffect = Cmd.ofAction<Message>(() => throw error,
          onError: (Exception e) => ErrorMessage(e.toString()));
    });

    tearDown(() async {
      effectsController.close();
    });

    testWidgets('success', (WidgetTester tester) async {
      final program =
          TestProgram(() => init(initArg, effect: successEffect), update, view);
      program.run();

      await tester.pumpWidget(program.frame);
      await tester.tap(find.byKey(incrementBtnKey));
      await tester.tap(find.byKey(effectBtnKey));
      await tester.tap(find.byKey(effectBtnKey));
      await tester.pumpWidget(program.frame);

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

    testWidgets('error', (WidgetTester tester) async {
      final program =
          TestProgram(() => init(initArg, effect: errorEffect), update, view);
      program.run();

      await tester.pumpWidget(program.frame);
      await tester.tap(find.byKey(effectBtnKey));
      await tester.pumpWidget(program.frame);

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
