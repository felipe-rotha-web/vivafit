
import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../theme.dart';

class DesafiosPage extends StatefulWidget {
  const DesafiosPage({super.key});

  static const String pontosTotalKey = 'desafios_pontos_total';
  static const int pontosDefault = 5000;
  static const String metaSemanalKey = 'desafios_meta_semanal';
  static const String pontosSemanaAtualKey = 'desafios_pontos_semana_atual';
  static const String metasKey = 'desafios_metas';
  static const String desafiosKey = 'desafios_itens';
  static const String historicoKey = 'desafios_historico';

  @override
  State<DesafiosPage> createState() => _DesafiosPageState();
}

class _DesafiosPageState extends State<DesafiosPage> {
  int _pontuacaoTotal = 5000;
  int _metaSemanal = 1000;
  int _pontuacaoSemanaAtual = 320;

  final List<Map<String, dynamic>> _metas = [
    {
      'titulo': 'Meta de Exercício',
      'descricao': 'Fazer exercício 5x por semana',
      'concluida': true,
      'pontos': 100,
      'ativo': true,
    },
    {
      'titulo': 'Meta de Hidratação',
      'descricao': 'Beber 3L de água por dia',
      'concluida': false,
      'pontos': 50,
      'ativo': true,
    },
    {
      'titulo': 'Meta de Meditação',
      'descricao': 'Meditar 20 minutos por dia',
      'concluida': true,
      'pontos': 75,
      'ativo': true,
    },
    {
      'titulo': 'Meta de Leitura',
      'descricao': 'Ler 30 minutos por dia',
      'concluida': false,
      'pontos': 60,
      'ativo': false,
    },
  ];

  final List<Map<String, dynamic>> _desafios = [
    {
      'titulo': 'Semana Fitness',
      'descricao': 'Complete 5 sessões de exercício',
      'progresso': 3,
      'meta': 5,
      'recompensa': 250,
      'ativo': true,
      'concluida': false,
      'dificuldade': 'Média',
    },
    {
      'titulo': 'Hidratação Extrema',
      'descricao': 'Beba 3L de água todos os dias da semana',
      'progresso': 6,
      'meta': 7,
      'recompensa': 200,
      'ativo': true,
      'concluida': false,
      'dificuldade': 'Fácil',
    },
    {
      'titulo': 'Meditador Semanal',
      'descricao': 'Medite 20 minutos por dia durante 7 dias',
      'progresso': 4,
      'meta': 7,
      'recompensa': 300,
      'ativo': true,
      'concluida': false,
      'dificuldade': 'Difícil',
    },
    {
      'titulo': 'Super Atleta',
      'descricao': 'Complete 10 treinos intensos',
      'progresso': 7,
      'meta': 10,
      'recompensa': 400,
      'ativo': false,
      'concluida': false,
      'dificuldade': 'Muito Difícil',
    },
  ];

  final List<Map<String, dynamic>> _tarefasCompletoHistorico = [
    {'titulo': 'Treino de Academia', 'pontos': 50, 'data': 'Hoje'},
    {'titulo': 'Caminhada matinal', 'pontos': 30, 'data': 'Hoje'},
    {'titulo': 'Meditação', 'pontos': 25, 'data': 'Ontem'},
    {'titulo': 'Exercício em casa', 'pontos': 40, 'data': 'Ontem'},
  ];

  Color _getCorDificuldade(String dificuldade) {
    switch (dificuldade) {
      case 'Fácil':
        return AppColors.successForMode;
      case 'Média':
        return AppColors.warningForMode;
      case 'Difícil':
        return AppColors.error;
      case 'Muito Difícil':
        return AppColors.secondary;
      default:
        return AppColors.primary;
    }
  }

  @override
  void initState() {
    super.initState();
    _loadProgress();
  }

  Future<void> _loadProgress() async {
    final prefs = await SharedPreferences.getInstance();
    final savedMetas = prefs.getString(DesafiosPage.metasKey);
    final savedDesafios = prefs.getString(DesafiosPage.desafiosKey);
    final savedHistorico = prefs.getString(DesafiosPage.historicoKey);

    final List<Map<String, dynamic>> metas =
        savedMetas != null && savedMetas.isNotEmpty
            ? List<Map<String, dynamic>>.from(
                (jsonDecode(savedMetas) as List).map((item) => Map<String, dynamic>.from(item as Map)),
              )
            : List<Map<String, dynamic>>.from(_metas);

    final List<Map<String, dynamic>> desafios =
        savedDesafios != null && savedDesafios.isNotEmpty
            ? List<Map<String, dynamic>>.from(
                (jsonDecode(savedDesafios) as List).map((item) {
                  final desafio = Map<String, dynamic>.from(item as Map);
                  desafio['concluida'] ??= false;
                  return desafio;
                }),
              )
            : List<Map<String, dynamic>>.from(
                _desafios.map((item) {
                  final desafio = Map<String, dynamic>.from(item);
                  desafio['concluida'] ??= false;
                  return desafio;
                }),
              );

    final List<Map<String, dynamic>> historico =
        savedHistorico != null && savedHistorico.isNotEmpty
            ? List<Map<String, dynamic>>.from(
                (jsonDecode(savedHistorico) as List).map((item) => Map<String, dynamic>.from(item as Map)),
              )
            : List<Map<String, dynamic>>.from(_tarefasCompletoHistorico);

    if (!mounted) return;

    setState(() {
      _pontuacaoTotal = prefs.getInt(DesafiosPage.pontosTotalKey) ?? _pontuacaoTotal;
      _metaSemanal = prefs.getInt(DesafiosPage.metaSemanalKey) ?? _metaSemanal;
      _pontuacaoSemanaAtual =
          prefs.getInt(DesafiosPage.pontosSemanaAtualKey) ?? _pontuacaoSemanaAtual;

      _metas
        ..clear()
        ..addAll(metas);
      _desafios
        ..clear()
        ..addAll(desafios);
      _tarefasCompletoHistorico
        ..clear()
        ..addAll(historico);
    });
  }

  Future<void> _saveProgress() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setInt(DesafiosPage.pontosTotalKey, _pontuacaoTotal);
    await prefs.setInt(DesafiosPage.metaSemanalKey, _metaSemanal);
    await prefs.setInt(DesafiosPage.pontosSemanaAtualKey, _pontuacaoSemanaAtual);
    await prefs.setString(DesafiosPage.metasKey, jsonEncode(_metas));
    await prefs.setString(DesafiosPage.desafiosKey, jsonEncode(_desafios));
    await prefs.setString(DesafiosPage.historicoKey, jsonEncode(_tarefasCompletoHistorico));
  }

  List<Map<String, dynamic>> get desafiosAtivos => _desafios
      .where((desafio) => desafio['ativo'] == true && desafio['concluida'] != true)
      .toList();

  List<Map<String, dynamic>> get desafiosDisponiveis => _desafios
      .where((desafio) => desafio['ativo'] != true && desafio['concluida'] != true)
      .toList();

  void ativarDesafio(int index) {
    setState(() {
      _desafios[index]['ativo'] = true;
    });
    _saveProgress();
  }

  void concluirDesafio(int index) {
    final desafio = _desafios[index];
    final recompensa = (desafio['recompensa'] as num).toInt();

    setState(() {
      _desafios[index]['concluida'] = true;
      _desafios[index]['ativo'] = false;
      _pontuacaoTotal += recompensa;
      _pontuacaoSemanaAtual += recompensa;
      _tarefasCompletoHistorico.insert(0, {
        'titulo': desafio['titulo'],
        'pontos': recompensa,
        'data': 'Hoje',
      });
    });
    _saveProgress();
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final double percentualMeta = (_pontuacaoSemanaAtual / _metaSemanal).clamp(0.0, 1.0);
    final desafiosAtivos = this.desafiosAtivos;
    final desafiosDisponiveis = this.desafiosDisponiveis;

    return Scaffold(
      appBar: AppBar(
        backgroundColor: AppColors.primary,
        elevation: 0,
        title: Text('Pontuação e Desafios', style: TextStyle(color: AppColors.onPrimary)),
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [AppColors.primary, AppColors.secondary],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                borderRadius: BorderRadius.circular(18),
                boxShadow: [
                  BoxShadow(
                    color: AppColors.primary.withAlpha((0.18 * 255).round()),
                    blurRadius: 12,
                    offset: const Offset(0, 6),
                  ),
                ],
              ),
              child: Column(
                children: [
                  Text(
                    'Pontuação Total',
                    style: TextStyle(fontSize: 16, color: AppColors.onPrimary.withAlpha((0.8 * 255).round())),
                  ),
                  const SizedBox(height: 10),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(Icons.star, color: AppColors.rewardForMode, size: 40),
                      const SizedBox(width: 10),
                      Text(
                        '$_pontuacaoTotal',
                        style: TextStyle(
                          fontSize: 48,
                          fontWeight: FontWeight.bold,
                          color: AppColors.onPrimary,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 20),
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: AppColors.onPrimary.withAlpha((0.12 * 255).round()),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Column(
                      children: [
                        Text(
                          'Meta Semanal',
                          style: TextStyle(fontSize: 14, color: AppColors.onPrimary.withAlpha((0.8 * 255).round())),
                        ),
                        const SizedBox(height: 8),
                        ClipRRect(
                          borderRadius: BorderRadius.circular(8),
                          child: LinearProgressIndicator(
                            value: percentualMeta,
                            minHeight: 8,
                            backgroundColor: AppColors.onPrimary.withAlpha((0.28 * 255).round()),
                            valueColor: AlwaysStoppedAnimation<Color>(AppColors.rewardForMode),
                          ),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          '$_pontuacaoSemanaAtual / $_metaSemanal (${(percentualMeta * 100).toStringAsFixed(0)}%)',
                          style: TextStyle(
                            fontSize: 12,
                            color: AppColors.onPrimary.withAlpha((0.8 * 255).round()),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 25),
            Text(
              'Metas Identificadas',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: colorScheme.onSurface,
              ),
            ),
            const SizedBox(height: 15),
            ListView.builder(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: _metas.length,
              itemBuilder: (context, index) {
                final meta = _metas[index];
                return _buildMetaCard(meta, index);
              },
            ),
            const SizedBox(height: 25),
            Text(
              'Desafios Ativos',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: colorScheme.onSurface,
              ),
            ),
            const SizedBox(height: 15),
            ListView.builder(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: desafiosAtivos.length,
              itemBuilder: (context, index) {
                final desafio = desafiosAtivos[index];
                final desafioIndex = _desafios.indexWhere((item) => item['titulo'] == desafio['titulo']);
                return _buildDesafioCard(desafio, desafioIndex >= 0 ? desafioIndex : index);
              },
            ),
            const SizedBox(height: 25),
            Text(
              'Desafios Disponíveis',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: colorScheme.onSurface,
              ),
            ),
            const SizedBox(height: 15),
            ListView.builder(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: desafiosDisponiveis.length,
              itemBuilder: (context, index) {
                final desafio = desafiosDisponiveis[index];
                final desafioIndex = _desafios.indexWhere((item) => item['titulo'] == desafio['titulo']);
                return _buildDesafioCard(desafio, desafioIndex >= 0 ? desafioIndex : index);
              },
            ),
            const SizedBox(height: 25),
            Text(
              'Tarefas Concluídas',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: colorScheme.onSurface,
              ),
            ),
            const SizedBox(height: 15),
            ListView.builder(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: _tarefasCompletoHistorico.length,
              itemBuilder: (context, index) {
                final tarefa = _tarefasCompletoHistorico[index];
                return _buildTarefaHistoricoCard(tarefa);
              },
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildMetaCard(Map<String, dynamic> meta, int index) {
    final colorScheme = Theme.of(context).colorScheme;

    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Container(
        decoration: BoxDecoration(
          color: AppColors.surface,
          borderRadius: BorderRadius.circular(12),
          boxShadow: [
            BoxShadow(
              color: AppColors.primary.withAlpha((0.18 * 255).round()),
              blurRadius: 8,
              offset: const Offset(0, 2),
            ),
          ],
          border: Border.all(
        color: meta['concluida']
          ? AppColors.successForMode.withAlpha((0.32 * 255).round())
          : AppColors.onSurface.withAlpha(0),
        width: 2,
        ),
        ),
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        meta['titulo'],
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          color: meta['concluida'] ? AppColors.successForMode : colorScheme.onSurface,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        meta['descricao'],
                        style: TextStyle(
                          fontSize: 13,
                          color: AppColors.onSurface.withAlpha((0.7 * 255).round()),
                        ),
                      ),
                    ],
                  ),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                  decoration: BoxDecoration(
                    color: AppColors.rewardForMode.withAlpha((0.18 * 255).round()),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Row(
                    children: [
                      Icon(Icons.star, color: AppColors.rewardForMode, size: 16),
                      const SizedBox(width: 4),
                      Text(
                        '+${meta['pontos']}',
                        style: TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.bold,
                          color: AppColors.rewardForMode,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                Expanded(
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(8),
                    child: LinearProgressIndicator(
                      value: meta['concluida'] ? 1.0 : 0.6,
                      minHeight: 6,
                      backgroundColor: AppColors.onSurface.withAlpha((0.12 * 255).round()),
                      valueColor: AlwaysStoppedAnimation<Color>(
                        meta['concluida'] ? AppColors.successForMode : AppColors.warningForMode,
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                Switch(
                  value: meta['ativo'],
                  activeThumbColor: AppColors.successForMode,
                  onChanged: (value) {
                    setState(() {
                      _metas[index]['ativo'] = value;
                    });
                    _saveProgress();
                  },
                ),
              ],
            ),
            const SizedBox(height: 8),
            if (meta['ativo'] == true && meta['concluida'] != true)
              SizedBox(
                width: double.infinity,
                height: 40,
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.successForMode,
                    foregroundColor: AppColors.onPrimary,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                  ),
                  onPressed: () {
                    setState(() {
                      _metas[index]['concluida'] = true;
                      _metas.removeAt(index);
                      _pontuacaoTotal += (meta['pontos'] as num).toInt();
                      _pontuacaoSemanaAtual += (meta['pontos'] as num).toInt();
                      _tarefasCompletoHistorico.insert(0, {
                        'titulo': meta['titulo'],
                        'pontos': meta['pontos'],
                        'data': 'Hoje',
                      });
                    });
                    _saveProgress();
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text(
                          'Meta "${meta['titulo']}" concluída! +${meta['pontos']}',
                          style: TextStyle(color: AppColors.onPrimary),
                        ),
                        backgroundColor: AppColors.successForMode,
                        behavior: SnackBarBehavior.floating,
                      ),
                    );
                  },
                  child: Text(
                    'Concluir Meta',
                    style: TextStyle(fontWeight: FontWeight.bold, color: AppColors.onPrimary),
                  ),
                ),
              )
            else if (meta['concluida'] == true)
              Container(
                padding: const EdgeInsets.symmetric(vertical: 6),
                child: Text(
                  'Concluída',
                  style: TextStyle(color: AppColors.successForMode, fontWeight: FontWeight.bold),
                ),
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildDesafioCard(Map<String, dynamic> desafio, int index) {
    if (desafio['concluida'] == true) {
      return const SizedBox.shrink();
    }

    final colorScheme = Theme.of(context).colorScheme;
    final double percentualProgresso = ((desafio['progresso'] as num).toDouble() / (desafio['meta'] as num).toDouble()).clamp(0.0, 1.0);
    final Color corDificuldade = _getCorDificuldade(desafio['dificuldade']);

    return Padding(
      padding: const EdgeInsets.only(bottom: 15),
      child: Container(
        decoration: BoxDecoration(
          color: AppColors.surface,
          borderRadius: BorderRadius.circular(12),
          boxShadow: [
            BoxShadow(
              color: AppColors.primary.withAlpha((0.18 * 255).round()),
              blurRadius: 8,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        desafio['titulo'],
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          color: colorScheme.onSurface,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        desafio['descricao'],
                        style: TextStyle(
                          fontSize: 13,
                          color: AppColors.onSurface.withAlpha((0.7 * 255).round()),
                        ),
                      ),
                    ],
                  ),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                  decoration: BoxDecoration(
                    color: corDificuldade.withAlpha((0.18 * 255).round()),
                    borderRadius: BorderRadius.circular(6),
                  ),
                  child: Text(
                    desafio['dificuldade'],
                    style: TextStyle(
                      fontSize: 11,
                      fontWeight: FontWeight.bold,
                      color: corDificuldade,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 15),
            ClipRRect(
              borderRadius: BorderRadius.circular(8),
              child: LinearProgressIndicator(
                value: percentualProgresso,
                minHeight: 8,
                backgroundColor: AppColors.onSurface.withAlpha((0.12 * 255).round()),
                valueColor: AlwaysStoppedAnimation<Color>(corDificuldade),
              ),
            ),
            const SizedBox(height: 8),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  '${desafio['progresso']} / ${desafio['meta']}',
                  style: TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.bold,
                    color: AppColors.onSurface.withAlpha((0.7 * 255).round()),
                  ),
                ),
                Row(
                  children: [
                    Icon(Icons.star, color: AppColors.rewardForMode, size: 16),
                    const SizedBox(width: 4),
                    Text(
                      '+${desafio['recompensa']}',
                      style: TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.bold,
                        color: AppColors.rewardForMode,
                      ),
                    ),
                  ],
                ),
              ],
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                // if inactive show activate button
                if (!desafio['ativo'])
                  Expanded(
                    child: SizedBox(
                      height: 40,
                      child: ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppColors.primary,
                          foregroundColor: AppColors.onPrimary,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(8),
                          ),
                        ),
                        onPressed: () {
                          ativarDesafio(index);
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(
                              content: Text(
                                'Desafio "${desafio['titulo']}" ativado!',
                                style: TextStyle(color: AppColors.onPrimary),
                              ),
                              backgroundColor: AppColors.successForMode,
                              behavior: SnackBarBehavior.floating,
                              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                            ),
                          );
                        },
                        child: Text('Ativar Desafio', style: TextStyle(color: AppColors.onPrimary, fontWeight: FontWeight.bold)),
                      ),
                    ),
                  ),
                // if active show progress controls
                if (desafio['ativo']) ...[
                  IconButton(
                    onPressed: () {
                      setState(() {
                        final current = (desafio['progresso'] as num).toInt();
                        if (current > 0) {
                          _desafios[index]['progresso'] = current - 1;
                        }
                      });
                      _saveProgress();
                    },
                    icon: Icon(Icons.remove, color: AppColors.onSurface),
                  ),
                  Text('${desafio['progresso']}', style: TextStyle(fontWeight: FontWeight.bold, color: AppColors.onSurface)),
                  IconButton(
                    onPressed: () {
                      setState(() {
                        final current = (desafio['progresso'] as num).toInt();
                        final target = (desafio['meta'] as num).toInt();
                        if (current < target) {
                          _desafios[index]['progresso'] = current + 1;
                          if (current + 1 >= target) {
                            concluirDesafio(index);
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(
                                content: Text('Parabéns! Você concluiu "${desafio['titulo']}" e ganhou +${desafio['recompensa']}', style: TextStyle(color: AppColors.onPrimary)),
                                backgroundColor: AppColors.rewardForMode,
                                behavior: SnackBarBehavior.floating,
                              ),
                            );
                          }
                        }
                      });
                      _saveProgress();
                    },
                    icon: Icon(Icons.add, color: AppColors.onSurface),
                  ),
                ],
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTarefaHistoricoCard(Map<String, dynamic> tarefa) {
    final colorScheme = Theme.of(context).colorScheme;

    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: Container(
        decoration: BoxDecoration(
          color: AppColors.surface,
          borderRadius: BorderRadius.circular(12),
          boxShadow: [
            BoxShadow(
              color: AppColors.primary.withAlpha((0.18 * 255).round()),
              blurRadius: 7,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        padding: const EdgeInsets.all(12),
        child: Row(
          children: [
            Container(
              width: 45,
              height: 45,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: AppColors.successForMode,
              ),
              child: Icon(Icons.check, color: AppColors.onPrimary),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    tarefa['titulo'],
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.bold,
                      color: colorScheme.onSurface,
                    ),
                  ),
                  Text(
                    tarefa['data'],
                    style: TextStyle(
                      fontSize: 12,
                      color: AppColors.onSurface.withAlpha((0.7 * 255).round()),
                    ),
                  ),
                ],
              ),
            ),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
              decoration: BoxDecoration(
                color: AppColors.rewardForMode.withAlpha((0.18 * 255).round()),
                borderRadius: BorderRadius.circular(6),
              ),
              child: Text(
                '+${tarefa['pontos']}',
                style: TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.bold,
                  color: AppColors.rewardForMode,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}


