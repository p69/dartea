import 'package:flutter_test/flutter_test.dart';

import 'package:dartea/dartea.dart';

import 'testable_program.dart';
import 'counter_app.dart';

void main() {
  group('basic cmd', () {
    testWidgets('message cmd', (WidgetTester tester) async {
      var initArg = 0;
      var effect = Cmd.ofMsg(Increment());
      var program =
          TestProgram((start) => init(start, effect: effect), update, view);
      program.runWith(initArg);

      await tester.pumpWidget(program.frame);
      await tester.tap(find.byKey(incrementBtnKey));
      await tester.tap(find.byKey(effectBtnKey));
      await tester.pumpWidget(program.frame);

      expect(
          program.updates,
          emitsInOrder([
            predicate((Message m) => m is Increment),
            predicate((Message m) => m is DoSideEffect),
            predicate((Message m) => m is Increment)
          ]));
      expect(find.text((initArg + 1 + 1).toString()), findsOneWidget);
    });

    testWidgets('cmd of sub', (WidgetTester tester) async {
      var initArg = 0;
      var effect =
          Cmd.ofSub((Dispatch<Message> dispatch) => dispatch(Increment()));
      var program =
          TestProgram((start) => init(start, effect: effect), update, view);
      program.runWith(initArg);

      await tester.pumpWidget(program.frame);
      await tester.tap(find.byKey(incrementBtnKey));
      await tester.tap(find.byKey(effectBtnKey));
      await tester.pumpWidget(program.frame);

      expect(
          program.updates,
          emitsInOrder([
            predicate((Message m) => m is Increment),
            predicate((Message m) => m is DoSideEffect),
            predicate((Message m) => m is Increment)
          ]));
      expect(find.text((initArg + 1 + 1).toString()), findsOneWidget);
    });

    testWidgets('none cmd', (WidgetTester tester) async {
      var initArg = 0;
      Cmd<Message> effect = Cmd.none();
      var program =
          TestProgram((start) => init(start, effect: effect), update, view);
      program.runWith(initArg);

      await tester.pumpWidget(program.frame);
      await tester.tap(find.byKey(incrementBtnKey));
      await tester.tap(find.byKey(effectBtnKey));
      await tester.pumpWidget(program.frame);

      expect(
          program.updates,
          emitsInOrder([
            predicate((Message m) => m is Increment),
            predicate((Message m) => m is DoSideEffect)
          ]));
      expect(find.text((initArg + 1).toString()), findsOneWidget);
    });

    testWidgets('batch cmd', (WidgetTester tester) async {
      var initArg = 0;
      var effect = Cmd.batch([
        Cmd.ofMsg(Increment()),
        Cmd.ofMsg(Increment()),
        Cmd.ofMsg(Increment()),
        Cmd.ofMsg(Decrement())
      ]);
      var program =
          TestProgram((start) => init(start, effect: effect), update, view);
      program.runWith(initArg);

      await tester.pumpWidget(program.frame);
      await tester.tap(find.byKey(effectBtnKey));
      await tester.pumpWidget(program.frame);

      expect(
          program.updates,
          emitsInOrder([
            predicate((Message m) => m is DoSideEffect),
            predicate((Message m) => m is Increment),
            predicate((Message m) => m is Increment),
            predicate((Message m) => m is Increment),
            predicate((Message m) => m is Decrement)
          ]));
      expect(find.text((initArg + 1 + 1 + 1 - 1).toString()), findsOneWidget);
    });

    testWidgets('map cmd', (WidgetTester tester) async {
      var initArg = 0;
      var effect = Cmd.fmap(_invert, Cmd.ofMsg(Increment()));
      var program =
          TestProgram((start) => init(start, effect: effect), update, view);
      program.runWith(initArg);

      await tester.pumpWidget(program.frame);
      await tester.tap(find.byKey(incrementBtnKey));
      await tester.tap(find.byKey(effectBtnKey));
      await tester.pumpWidget(program.frame);

      expect(
          program.updates,
          emitsInOrder([
            predicate((Message m) => m is Increment),
            predicate((Message m) => m is DoSideEffect),
            predicate((Message m) => m is Decrement)
          ]));
      expect(find.text((initArg + 1 - 1).toString()), findsOneWidget);
    });
  });
}

Message _invert(Message msg) {
  if (msg is Increment) {
    return Decrement();
  }
  if (msg is Decrement) {
    return Increment();
  }
  return msg;
}
