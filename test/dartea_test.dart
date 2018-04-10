import 'dart:async';

import 'package:flutter_test/flutter_test.dart';

import 'package:dartea/dartea.dart';

import 'testable_program.dart';
import 'counter_app.dart';

void main() {
  group('pure', () {
    TestProgram<int, Model, Message> program;

    setUp(() {
      program = new TestProgram(init, update, view);
    });

    testWidgets('init', (WidgetTester tester) async {
      final initArg = 42;
      program.runWith(initArg);

      var lastFrame = program.frames.removeLast();
      await tester.pumpWidget(lastFrame);

      expect(program.views,
          emitsInOrder([predicate((Model m) => m.counter == initArg)]));
      expect(find.text(initArg.toString()), findsOneWidget);
    });

    testWidgets('update', (WidgetTester tester) async {
      final initArg = 0;
      program.runWith(initArg);

      await tester.pumpWidget(program.frames.removeLast());

      var incrementsCount = 10;
      var decrementsCount = 4;

      for (int i = 0; i < incrementsCount; i++) {
        await tester.tap(find.byKey(incrementBtnKey));
      }
      for (int i = 0; i < decrementsCount; i++) {
        await tester.tap(find.byKey(decrementBtnKey));
      }

      await tester.pumpWidget(program.frames.removeLast());

      var updateStreamMatchers = new List<Matcher>();

      for (int i = 0; i < incrementsCount; i++) {
        updateStreamMatchers.add(predicate((Message msg) => msg is Increment));
      }
      for (int i = 0; i < decrementsCount; i++) {
        updateStreamMatchers.add(predicate((Message msg) => msg is Decrement));
      }

      expect(program.updates, emitsInOrder(updateStreamMatchers));
      expect(
          find.text((initArg + incrementsCount - decrementsCount).toString()),
          findsOneWidget);
    });
  });

  group('effects', () {
    StreamController<String> effectsController;

    setUp(() {
      effectsController = new StreamController<String>();
    });

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

    testWidgets('cmd of action (success)', (WidgetTester tester) async {
      var initArg = 0;
      var sideEffect = "side effect!";
      var effect =
          Cmd.ofAction<Message>(() => effectsController.add(sideEffect));
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
            predicate((Message m) => m is DoSideEffect)
          ]));
      expect(effectsController.stream, emitsInOrder([sideEffect]));
      expect(find.text((initArg + 1).toString()), findsOneWidget);
    });


  });
}
