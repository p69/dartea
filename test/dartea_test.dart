import 'dart:async';

import 'package:flutter_test/flutter_test.dart';

import 'package:dartea/dartea.dart';

import 'testable_program.dart';
import 'counter_app.dart';

void main() {
  group('main functions', () {
    int startVal = 0;
    TestProgram<Model, Message> program;

    setUp(() {
      program = new TestProgram(() => init(startVal), update, view);
    });

    testWidgets('init', (WidgetTester tester) async {
      startVal = 42;
      program.run();

      var lastFrame = program.frame;
      await tester.pumpWidget(lastFrame);

      expect(program.views,
          emitsInOrder([predicate((Model m) => m.counter == startVal)]));
      expect(find.text(startVal.toString()), findsOneWidget);
    });

    testWidgets('update', (WidgetTester tester) async {
      program.run();

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
          find.text((startVal + incrementsCount - decrementsCount).toString()),
          findsOneWidget);
    });

    testWidgets('subscribe', (WidgetTester tester) async {
      final externalSource = new StreamController<Message>();

      StreamSubscription<Message> subscribe(
          StreamSubscription<Message> currentSub,
          Dispatch<Message> dispatch,
          Model model) {
        if (currentSub != null) {
          return currentSub;
        }
        return externalSource.stream.listen((m) => dispatch(m));
      }

      program.withSubscription(subscribe);
      program.run();

      await tester.pumpWidget(program.frame);
      int incrementsCount = 5;
      var updateMatchers = new List<Matcher>();
      for (var i = 0; i < incrementsCount; i++) {
        externalSource.add(Increment());
        updateMatchers.add(predicate((Message m) => m is Increment));
      }

      expect(program.updates, emitsInOrder(updateMatchers));
      externalSource.close();
    });
  });
}
