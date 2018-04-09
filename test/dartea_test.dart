import 'package:flutter_test/flutter_test.dart';

import 'testable_program.dart';
import 'counter_app.dart';

void main() {
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
      updateStreamMatchers
          .add(predicate((Message msg) => msg is Increment));
    }
    for (int i = 0; i < decrementsCount; i++) {
      updateStreamMatchers
          .add(predicate((Message msg) => msg is Decrement));
    }

    expect(program.updates, emitsInOrder(updateStreamMatchers));
    expect(find.text((initArg + incrementsCount - decrementsCount).toString()),
        findsOneWidget);
  });
}
