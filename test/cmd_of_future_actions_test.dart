import 'dart:async';

import 'package:flutter_test/flutter_test.dart';

import 'package:dartea/dartea.dart';

import 'testable_program.dart';
import 'counter_app.dart';

void main() {
  group('cmd of future actions', () {
    const initArg = 0;
    const sideEffect = "side effect!";
    StreamController<String> effectsController;
    Cmd<Message> successEffect;
    Cmd<Message> errorEffect;
    Exception error = new Exception(sideEffect);

    setUp(() {
      effectsController = new StreamController<String>();
      Future successAction() async {
        effectsController.add(sideEffect);
      }

      Future errorAction() async {
        throw error;
      }

      successEffect = Cmd.ofAsyncAction<Message>(successAction,
          onSuccess: () => OnSuccessEffect());
      errorEffect = Cmd.ofAsyncAction<Message>(errorAction,
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
            predicate((Message m) => m is OnSuccessEffect),
          ]));
      expect(effectsController.stream, emitsInOrder([sideEffect]));
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
