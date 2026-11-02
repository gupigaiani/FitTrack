import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:fl_chart/fl_chart.dart';

import 'register_workout_page.dart';
import 'workout_history_page.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key, this.erroFirebase});
  final String? erroFirebase;
  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  String? exercicioSelecionado;
  late final Stream<QuerySnapshot<Map<String, dynamic>>>? treinos =
      widget.erroFirebase == null
      ? FirebaseFirestore.instance
            .collection('treinos')
            .orderBy('dataRegistro')
            .snapshots()
      : null;

  Widget evolucao() {
    if (widget.erroFirebase != null) return Text(widget.erroFirebase!);
    return StreamBuilder<QuerySnapshot<Map<String, dynamic>>>(
      stream: treinos,
      builder: (context, snapshot) {
        if (snapshot.hasError) {
          return const Text(
            'Não foi possível carregar a evolução. Confira a conexão e as regras do Firestore.',
          );
        }
        if (!snapshot.hasData) {
          return const Center(child: CircularProgressIndicator());
        }
        final registros = snapshot.data!.docs.map((d) => d.data()).toList();
        final exercicios =
            registros
                .map(
                  (d) => (d['exercicio'] as String)
                      .trim()
                      .replaceAll(RegExp(r'\s+'), ' ')
                      .toLowerCase(),
                )
                .toSet()
                .toList()
              ..sort();
        if (exercicios.isEmpty) {
          return const Text(
            'Registre seus treinos para acompanhar a evolução.',
          );
        }
        final selecionado = exercicios.contains(exercicioSelecionado)
            ? exercicioSelecionado!
            : exercicios.first;
        final pontos = registros
            .where(
              (d) =>
                  (d['exercicio'] as String)
                      .trim()
                      .replaceAll(RegExp(r'\s+'), ' ')
                      .toLowerCase() ==
                  selecionado,
            )
            .toList();
        return Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            DropdownButton<String>(
              value: selecionado,
              isExpanded: true,
              items: exercicios
                  .map(
                    (e) => DropdownMenuItem(
                      value: e,
                      child: Text(
                        e.isEmpty ? e : e[0].toUpperCase() + e.substring(1),
                      ),
                    ),
                  )
                  .toList(),
              onChanged: (v) => setState(() => exercicioSelecionado = v),
            ),
            const SizedBox(height: 20),
            if (pontos.length < 2)
              const Text(
                'São necessários pelo menos dois registros deste exercício para visualizar a evolução.',
              )
            else ...[
              const Text(
                'Carga (kg)',
                style: TextStyle(color: Color(0xFFB0B0B0)),
              ),
              const SizedBox(height: 16),
              SizedBox(
                height: 260,
                child: Padding(
                  padding: const EdgeInsets.only(right: 16),
                  child: LineChart(
                    LineChartData(
                      minX: 1,
                      maxX: pontos.length.toDouble(),
                      minY: 0,
                      maxY:
                          pontos
                                  .map((d) => (d['carga'] as num).toDouble())
                                  .reduce((a, b) => a > b ? a : b) *
                              1.1 +
                          1,
                      titlesData: FlTitlesData(
                        topTitles: const AxisTitles(
                          sideTitles: SideTitles(showTitles: false),
                        ),
                        rightTitles: const AxisTitles(
                          sideTitles: SideTitles(showTitles: false),
                        ),
                        leftTitles: const AxisTitles(
                          sideTitles: SideTitles(
                            showTitles: true,
                            reservedSize: 48,
                          ),
                        ),
                        bottomTitles: AxisTitles(
                          sideTitles: SideTitles(
                            showTitles: true,
                            interval: pontos.length > 8
                                ? (pontos.length / 5).ceilToDouble()
                                : 1,
                            getTitlesWidget: (v, meta) =>
                                Text(v.toInt().toString()),
                          ),
                        ),
                      ),
                      lineBarsData: [
                        LineChartBarData(
                          spots: [
                            for (int i = 0; i < pontos.length; i++)
                              FlSpot(
                                (i + 1).toDouble(),
                                (pontos[i]['carga'] as num).toDouble(),
                              ),
                          ],
                          color: const Color(0xFF00E676),
                          barWidth: 3,
                          dotData: const FlDotData(show: true),
                          isCurved: false,
                        ),
                      ],
                    ),
                  ),
                ),
              ),
              const Text(
                'Sequência dos registros (do mais antigo ao mais recente)',
                style: TextStyle(color: Color(0xFFB0B0B0)),
              ),
            ],
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) => Scaffold(
    appBar: AppBar(
      title: const Text('FitTrack'),
      centerTitle: true,
      backgroundColor: const Color(0xFF1E1E1E),
    ),
    body: SingleChildScrollView(
      child: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 800),
          child: Padding(
            padding: const EdgeInsets.all(24),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                const Text(
                  'FitTrack',
                  style: TextStyle(
                    fontSize: 40,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF00E676),
                  ),
                ),
                const Text(
                  'Cada treino conta.',
                  style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 8),
                const Text(
                  'Registre seus exercícios, consulte seus treinos e acompanhe a evolução das cargas.',
                  style: TextStyle(color: Color(0xFFB0B0B0), fontSize: 16),
                ),
                const SizedBox(height: 24),
                ClipRRect(
                  borderRadius: BorderRadius.circular(20),
                  child: Stack(
                    children: [
                      Image.asset(
                        'assets/images/treino_1.jpg',
                        width: double.infinity,
                        height: 240,
                        fit: BoxFit.cover,
                      ),
                      const Positioned(
                        right: 16,
                        top: 16,
                        child: Card(
                          child: Padding(
                            padding: EdgeInsets.all(12),
                            child: Icon(
                              Icons.fitness_center,
                              color: Color(0xFF00E676),
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 20),
                const Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    Icon(Icons.fitness_center),
                    Icon(Icons.sports_gymnastics),
                    Icon(Icons.show_chart),
                  ],
                ),
                const SizedBox(height: 20),
                ElevatedButton(
                  onPressed: () => Navigator.push(
                    context,
                    MaterialPageRoute<void>(
                      builder: (_) => RegisterWorkoutPage(
                        orientacao: 'Registre o exercício realizado.',
                        erroFirebase: widget.erroFirebase,
                      ),
                    ),
                  ),
                  child: const Text('Registrar treino'),
                ),
                const SizedBox(height: 12),
                ElevatedButton(
                  onPressed: () => Navigator.push(
                    context,
                    MaterialPageRoute<void>(
                      builder: (_) =>
                          WorkoutHistoryPage(erroFirebase: widget.erroFirebase),
                    ),
                  ),
                  child: const Text('Histórico de treinos'),
                ),
                const SizedBox(height: 32),
                Card(
                  child: Padding(
                    padding: const EdgeInsets.all(20),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        const Text(
                          'Minha evolução',
                          style: TextStyle(
                            fontSize: 24,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 16),
                        evolucao(),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    ),
  );
}
