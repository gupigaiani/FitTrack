import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class WorkoutHistoryPage extends StatefulWidget {
  const WorkoutHistoryPage({super.key, this.erroFirebase});
  final String? erroFirebase;
  @override
  State<WorkoutHistoryPage> createState() => _WorkoutHistoryPageState();
}

class _WorkoutHistoryPageState extends State<WorkoutHistoryPage> {
  late final Stream<QuerySnapshot<Map<String, dynamic>>>? treinos =
      widget.erroFirebase == null
      ? FirebaseFirestore.instance
            .collection('treinos')
            .orderBy('dataRegistro', descending: true)
            .snapshots()
      : null;

  String dataFormatada(Timestamp data) {
    final d = data.toDate();
    String dois(int n) => n.toString().padLeft(2, '0');
    return '${dois(d.day)}/${dois(d.month)}/${d.year} às ${dois(d.hour)}:${dois(d.minute)}';
  }

  @override
  Widget build(BuildContext context) => Scaffold(
    appBar: AppBar(
      title: const Text('Histórico de treinos'),
      centerTitle: true,
      backgroundColor: const Color(0xFF1E1E1E),
    ),
    body: widget.erroFirebase != null
        ? Center(
            child: Padding(
              padding: const EdgeInsets.all(24),
              child: Text(widget.erroFirebase!),
            ),
          )
        : StreamBuilder<QuerySnapshot<Map<String, dynamic>>>(
            stream: treinos,
            builder: (context, snapshot) {
              if (snapshot.hasError) {
                return const Center(
                  child: Text(
                    'Não foi possível carregar os treinos. Confira a conexão e as regras.',
                  ),
                );
              }
              if (!snapshot.hasData) {
                return const Center(child: CircularProgressIndicator());
              }
              final documentos = snapshot.data!.docs;
              if (documentos.isEmpty) {
                return const Center(
                  child: Text('Nenhum treino registrado ainda.'),
                );
              }
              return Center(
                child: ConstrainedBox(
                  constraints: const BoxConstraints(maxWidth: 800),
                  child: ListView.builder(
                    padding: const EdgeInsets.all(20),
                    itemCount: documentos.length,
                    itemBuilder: (context, i) {
                      final d = documentos[i].data();
                      final concluido = d['concluido'] == true;
                      return Card(
                        child: Padding(
                          padding: const EdgeInsets.all(16),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                children: [
                                  const Icon(
                                    Icons.fitness_center,
                                    color: Color(0xFF00E676),
                                  ),
                                  const SizedBox(width: 12),
                                  Expanded(
                                    child: Text(
                                      d['exercicio'] as String,
                                      style: const TextStyle(
                                        fontSize: 20,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 12),
                              Text(
                                '${d['grupoMuscular']} • ${d['series']} séries • ${d['repeticoes']} repetições',
                              ),
                              Text(
                                '${d['carga']} kg',
                                style: const TextStyle(
                                  fontSize: 18,
                                  color: Color(0xFF00E676),
                                ),
                              ),
                              Text(
                                dataFormatada(d['dataRegistro'] as Timestamp),
                              ),
                              const SizedBox(height: 8),
                              Row(
                                children: [
                                  Icon(
                                    concluido
                                        ? Icons.check_circle
                                        : Icons.radio_button_unchecked,
                                    color: concluido
                                        ? const Color(0xFF00E676)
                                        : Colors.grey,
                                  ),
                                  const SizedBox(width: 8),
                                  Text(
                                    concluido ? 'Concluído' : 'Não concluído',
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ),
                      );
                    },
                  ),
                ),
              );
            },
          ),
  );
}
