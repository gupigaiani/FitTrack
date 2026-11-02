import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

enum GrupoMuscular { peito, costas, pernas, bracos, ombros }

const nomesGrupos = ['Peito', 'Costas', 'Pernas', 'Braços', 'Ombros'];

class RegisterWorkoutPage extends StatefulWidget {
  const RegisterWorkoutPage({
    super.key,
    required this.orientacao,
    this.erroFirebase,
  });
  final String orientacao;
  final String? erroFirebase;
  @override
  State<RegisterWorkoutPage> createState() => _RegisterWorkoutPageState();
}

class _RegisterWorkoutPageState extends State<RegisterWorkoutPage> {
  final exercicio = TextEditingController();
  final series = TextEditingController();
  final repeticoes = TextEditingController();
  final carga = TextEditingController();
  GrupoMuscular? grupo;
  bool concluido = false;
  bool salvando = false;
  String nomeDigitado = '';
  String mensagem = '';

  @override
  void dispose() {
    exercicio.dispose();
    series.dispose();
    repeticoes.dispose();
    carga.dispose();
    super.dispose();
  }

  Future<void> salvar() async {
    final nome = exercicio.text.trim().replaceAll(RegExp(r'\s+'), ' ');
    final s = int.tryParse(series.text.trim());
    final r = int.tryParse(repeticoes.text.trim());
    final c = double.tryParse(carga.text.trim().replaceAll(',', '.'));
    if (nome.isEmpty ||
        s == null ||
        s <= 0 ||
        r == null ||
        r <= 0 ||
        c == null ||
        !c.isFinite ||
        c < 0 ||
        grupo == null) {
      setState(
        () => mensagem =
            'Informe o exercício, séries e repetições maiores '
            'que zero, carga válida a partir de zero e grupo muscular.',
      );
      return;
    }
    if (widget.erroFirebase != null) {
      setState(() => mensagem = widget.erroFirebase!);
      return;
    }
    setState(() {
      salvando = true;
      mensagem = '';
    });
    try {
      await FirebaseFirestore.instance.collection('treinos').add({
        'exercicio': nome,
        'series': s,
        'repeticoes': r,
        'carga': c,
        'grupoMuscular': nomesGrupos[grupo!.index],
        'concluido': concluido,
        'dataRegistro': Timestamp.now(),
      });
      if (!mounted) return;
      exercicio.clear();
      series.clear();
      repeticoes.clear();
      carga.clear();
      setState(() {
        nomeDigitado = '';
        grupo = null;
        concluido = false;
        mensagem = 'Treino salvo com sucesso!';
      });
    } catch (_) {
      if (!mounted) return;
      setState(
        () => mensagem = 'Não foi possível salvar. Confira a conexão e as regras do Firestore.',
      );
    } finally {
      if (mounted) setState(() => salvando = false);
    }
  }

  @override
  Widget build(BuildContext context) => Scaffold(
    appBar: AppBar(
      title: const Text('Registrar treino'),
      centerTitle: true,
      backgroundColor: const Color(0xFF1E1E1E),
    ),
    body: SingleChildScrollView(
      child: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 680),
          child: Padding(
            padding: const EdgeInsets.all(24),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                ClipRRect(
                  borderRadius: BorderRadius.circular(16),
                  child: Image.asset(
                    'assets/images/treino_2.jpg',
                    height: 160,
                    fit: BoxFit.cover,
                  ),
                ),
                const SizedBox(height: 24),
                Text(
                  widget.orientacao,
                  style: const TextStyle(
                    fontSize: 22,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 16),
                TextField(
                  controller: exercicio,
                  enabled: !salvando,
                  onChanged: (v) => setState(() => nomeDigitado = v),
                  decoration: const InputDecoration(
                    labelText: 'Nome do exercício',
                    hintText: 'Supino reto',
                  ),
                ),
                const SizedBox(height: 16),
                TextField(
                  controller: series,
                  enabled: !salvando,
                  keyboardType: TextInputType.number,
                  decoration: const InputDecoration(
                    labelText: 'Quantidade de séries',
                    hintText: '4',
                  ),
                ),
                const SizedBox(height: 16),
                TextField(
                  controller: repeticoes,
                  enabled: !salvando,
                  keyboardType: TextInputType.number,
                  decoration: const InputDecoration(
                    labelText: 'Quantidade de repetições',
                    hintText: '12',
                  ),
                ),
                const SizedBox(height: 16),
                TextField(
                  controller: carga,
                  enabled: !salvando,
                  keyboardType: const TextInputType.numberWithOptions(
                    decimal: true,
                  ),
                  decoration: const InputDecoration(
                    labelText: 'Carga utilizada (kg)',
                    hintText: '50 ou 0 para peso corporal',
                  ),
                ),
                const SizedBox(height: 24),
                const Text('Grupo muscular', style: TextStyle(fontSize: 18)),
                RadioGroup<GrupoMuscular>(
                  groupValue: grupo,
                  onChanged: (v) {
                    if (!salvando) setState(() => grupo = v);
                  },
                  child: Column(
                    children: [
                      for (final g in GrupoMuscular.values)
                        RadioListTile<GrupoMuscular>(
                          value: g,
                          title: Text(nomesGrupos[g.index]),
                          enabled: !salvando,
                        ),
                    ],
                  ),
                ),
                CheckboxListTile(
                  value: concluido,
                  title: const Text('Treino concluído'),
                  onChanged: salvando
                      ? null
                      : (v) => setState(() => concluido = v ?? false),
                ),
                if (nomeDigitado.trim().isNotEmpty)
                  Text('Exercício: $nomeDigitado'),
                if (mensagem.isNotEmpty)
                  Padding(
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    child: Text(mensagem, semanticsLabel: mensagem),
                  ),
                const SizedBox(height: 16),
                ElevatedButton(
                  onPressed: salvando ? null : salvar,
                  child: Text(salvando ? 'Salvando...' : 'Salvar treino'),
                ),
              ],
            ),
          ),
        ),
      ),
    ),
  );
}
