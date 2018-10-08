import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:dartea/dartea.dart';

import 'testable_program.dart';
import 'counter_app.dart';

void main() {
  group('messages bus', () {
    int startVal1 = 0;
    int startVal2 = 100;
    Key incremntKey1 = Key("inc_1");
    TestProgram<Model, Message> program1;
    TestProgram<Model, Message> program2;

    setUp(() {
      program1 = new TestProgram(
          () => init(startVal1, incrementBtnKey: incremntKey1), (msg, model) {
        final upd = update(msg, model);
        final toBusMsgs = [Decrement()];
        return Upd(upd.model, effects: upd.effects, msgsToBus: toBusMsgs);
      }, view);
      program2 = TestProgram(() => init(startVal2), update, view);
    });

    testWidgets('update', (WidgetTester tester) async {
      program1.run();
      program2.run(enableMsgBus: true);

      await tester.pumpWidget(
          _twoProgramsFrame(program1.programWidget, program2.programWidget));

      var incrementsCount = 10;

      for (int i = 0; i < incrementsCount; i++) {
        await tester.tap(find.byKey(incremntKey1));
      }

      await tester.pumpWidget(
          _twoProgramsFrame(program1.programWidget, program2.programWidget));

      var p1StreamMatcher = new List<Matcher>();

      for (int i = 0; i < incrementsCount; i++) {
        p1StreamMatcher.add(predicate((Message msg) => msg is Increment));
      }

      var p2StreamMatcher = new List<Matcher>();

      for (int i = 0; i < incrementsCount; i++) {
        p2StreamMatcher.add(predicate((Message msg) => msg is Decrement));
      }

      expect(program1.updates, emitsInOrder(p1StreamMatcher));
      expect(program2.updates, emitsInOrder(p2StreamMatcher));
      expect(
          find.text((startVal1 + incrementsCount).toString()), findsOneWidget);
      expect(
          find.text((startVal2 - incrementsCount).toString()), findsOneWidget);
    });
  });
}

Widget _twoProgramsFrame(Widget p1, Widget p2) {
  return MaterialApp(
    home: DarteaMessagesBus(
        child: Column(
      children: <Widget>[p1, p2],
    )),
  );
}
