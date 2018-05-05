import 'dart:async';

import 'package:flutter_test/flutter_test.dart';

import 'package:dartea/dartea.dart';

import 'testable_program.dart';
import 'counter_app.dart';

void main() {
  group('main functions', () {
    TestProgram<int, Model, Message> program;

    setUp(() {
      program = new TestProgram(init, update, view);
    });

    testWidgets('init', (WidgetTester tester) async {
      final initArg = 42;
      program.runWith(initArg);

      var lastFrame = program.frame;
      await tester.pumpWidget(lastFrame);

      expect(program.views,
          emitsInOrder([predicate((Model m) => m.counter == initArg)]));
      expect(find.text(initArg.toString()), findsOneWidget);
    });

    testWidgets('update', (WidgetTester tester) async {
      final initArg = 0;
      program.runWith(initArg);

      await tester.pumpWidget(program.frame);

      var incrementsCount = 10;
      var decrementsCount = 4;

      for (int i = 0; i < incrementsCount; i++) {
        await tester.tap(find.byKey(incrementBtnKey));
      }
      for (int i = 0; i < decrementsCount; i++) {
        await tester.tap(find.byKey(decrementBtnKey));
      }

      await tester.pumpWidget(program.frame);

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

    testWidgets('subscribe', (WidgetTester tester) async {
      final initArg = 0;
      var externalSource = new StreamController<Message>();
      Cmd<Message> subscribe(Model model) =>
          Cmd.ofEffect((Dispatch<Message> dispatch) {
            externalSource.stream.listen((m) => dispatch(m));
          });
      program.withSubscription(subscribe);
      program.runWith(initArg);

      await tester.pumpWidget(program.frame);
      int incrementsCount = 5;
      var updateMatchers = new List<Matcher>();
      for (var i = 0; i < incrementsCount; i++) {
        externalSource.add(Increment());
        updateMatchers.add(predicate((Message m) => m is Increment));
      }

      expect(program.updates, emitsInOrder(updateMatchers));
    });
  });
}
