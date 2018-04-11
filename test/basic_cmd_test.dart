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

      await tester.pumpWidget(program.frames.removeLast());
      await tester.tap(find.byKey(incrementBtnKey));
      await tester.tap(find.byKey(effectBtnKey));
      await tester.pumpWidget(program.frames.removeLast());

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

      await tester.pumpWidget(program.frames.removeLast());
      await tester.tap(find.byKey(incrementBtnKey));
      await tester.tap(find.byKey(effectBtnKey));
      await tester.pumpWidget(program.frames.removeLast());

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

      await tester.pumpWidget(program.frames.removeLast());
      await tester.tap(find.byKey(incrementBtnKey));
      await tester.tap(find.byKey(effectBtnKey));
      await tester.pumpWidget(program.frames.removeLast());

      expect(
          program.updates,
          emitsInOrder([
            predicate((Message m) => m is Increment),
            predicate((Message m) => m is DoSideEffect)
          ]));
      expect(find.text((initArg + 1).toString()), findsOneWidget);
    });
  });
}
