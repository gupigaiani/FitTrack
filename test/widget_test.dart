import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:fittrack/main.dart';
import 'package:fittrack/pages/register_workout_page.dart';

void main() {
  testWidgets('Navegação, parâmetro, validação, radio e checkbox', (
    tester,
  ) async {
    await tester.pumpWidget(
      const FitTrackApp(erroFirebase: 'Firebase não configurado.'),
    );
    await tester.tap(find.text('Registrar treino'));
    await tester.pumpAndSettle();
    expect(find.text('Registre o exercício realizado.'), findsOneWidget);
    await tester.ensureVisible(find.text('Salvar treino'));
    await tester.tap(find.text('Salvar treino'));
    await tester.pumpAndSettle();
    expect(find.textContaining('Informe o exercício'), findsOneWidget);
    await tester.ensureVisible(find.text('Peito'));
    await tester.tap(find.text('Peito'));
    await tester.pumpAndSettle();
    expect(
      tester
          .widget<RadioGroup<GrupoMuscular>>(
            find.byType(RadioGroup<GrupoMuscular>),
          )
          .groupValue,
      isNotNull,
    );
    await tester.ensureVisible(find.text('Treino concluído'));
    await tester.tap(find.text('Treino concluído'));
    await tester.pumpAndSettle();
    expect(
      tester.widget<CheckboxListTile>(find.byType(CheckboxListTile)).value,
      isTrue,
    );
    await tester.pageBack();
    await tester.pumpAndSettle();
    await tester.ensureVisible(find.text('Histórico de treinos'));
    await tester.tap(find.text('Histórico de treinos'));
    await tester.pumpAndSettle();
    expect(find.text('Firebase não configurado.'), findsOneWidget);
    expect(tester.takeException(), isNull);
  });
}
