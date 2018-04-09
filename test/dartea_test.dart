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

}




