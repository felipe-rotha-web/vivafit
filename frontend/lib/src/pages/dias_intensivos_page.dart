
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../theme.dart';

// Classe DiasIntensivosPage representa um componente ou widget da interface.
class DiasIntensivosPage extends StatefulWidget {
  const DiasIntensivosPage({super.key});

  @override
  State<DiasIntensivosPage> createState() => _DiasIntensivosPageState();
}

// Classe _DiasIntensivosPageState representa um componente ou widget da interface.
class _DiasIntensivosPageState extends State<DiasIntensivosPage> {
  static const String _prefsCountKey = 'dias_intensivos_count_v1';
  static const String _prefsMetaKey = 'dias_intensivos_meta_v1';

  int _diasIntensivosContagem = 0;
  int _metaDiasIntensivos = 7; // uma semana = 7 dias
  int _nivel = 0; // nível/ciclos completados

  final List<Map<String, dynamic>> _diasIntensivos = [
    {
      'data': '17 de abril',
      'dia': 'Segunda',
      'atividades': 'Academia + Corrida + Meditação',
      'concluido': true,
    },
    {
      'data': '16 de abril',
      'dia': 'Domingo',
      'atividades': 'Treino em casa + Yoga',
      'concluido': true,
    },
    {
      'data': '15 de abril',
      'dia': 'Sábado',
      'atividades': 'Natação + Alongamento',
      'concluido': false,
    },
    {
      'data': '14 de abril',
      'dia': 'Sexta',
      'atividades': 'Academia + Caminhada',
      'concluido': true,
    },
  ];

  String _mensagemDoDiaPorProgresso() {
    final count = _diasIntensivosContagem;

    if (_metaDiasIntensivos > 0 && count >= _metaDiasIntensivos) {
      return 'Semana concluída! Você fechou a meta de 7 dias com consistência e foco.';
    }
    if (count == 1) {
      return 'Primeiro dia intenso registrado. O movimento começou com força.';
    }
    if (count == 2) {
      return 'Dois dias seguidos: a rotina já está ganhando forma.';
    }
    if (count == 3) {
      return 'Terceiro dia intenso! Sua consistência está ficando mais forte.';
    }
    if (count == 4) {
      return 'Quatro dias de esforço: você está no caminho certo.';
    }
    if (count == 5) {
      return 'Cinco dias intensivos e a disciplina está falando por você.';
    }
    if (count == 6) {
      return 'Falta só mais um passo para fechar a semana com chave de ouro.';
    }
    if (count >= (_metaDiasIntensivos * 0.75)) {
      return 'Quase lá! Falta pouco para concluir a meta de $_metaDiasIntensivos dias.';
    }
    if (count >= (_metaDiasIntensivos * 0.45)) {
      return 'Você está no caminho certo. O ritmo está forte e a evolução aparece.';
    }
    return 'Dia intensivo registrado ($_diasIntensivosContagem de $_metaDiasIntensivos). Continue assim.';
  }

  void _adicionarDiaIntensivo() {
    setState(() {
      final proximoValor = _diasIntensivosContagem + 1;
      final cicloCompletado = _metaDiasIntensivos > 0 &&
          proximoValor >= _metaDiasIntensivos;

      _diasIntensivosContagem = proximoValor;

      if (cicloCompletado) {
        _nivel++;
        _diasIntensivosContagem = 0;

        showDialog<void>(
          context: context,
          barrierDismissible: false,
          builder: (context) => AlertDialog(
            backgroundColor: AppColors.surface,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
            title: Row(
              children: [
                Icon(Icons.emoji_events_rounded, color: AppColors.rewardForMode, size: 30),
                const SizedBox(width: 10),
                const Expanded(
                  child: Text('Semana concluída!'),
                ),
              ],
            ),
            content: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  '7/7 dias intensivos concluídos!',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 22,
                    fontWeight: FontWeight.bold,
                    color: AppColors.primary,
                  ),
                ),
                const SizedBox(height: 12),
                Text(
                  'Você fechou a semana com disciplina, foco e consistência. Já concluiu $_nivel semana(s) neste desafio, e isso mostra que o hábito está ficando mais forte.',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 14,
                    color: AppColors.onSurface.withAlpha((0.75 * 255).round()),
                  ),
                ),
                const SizedBox(height: 18),
                Container(
                  padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
                  decoration: BoxDecoration(
                    color: AppColors.rewardForMode.withAlpha((0.14 * 255).round()),
                    borderRadius: BorderRadius.circular(14),
                  ),
                  child: Text(
                    'Novo ciclo liberado: sua rotina está mais forte.',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      color: AppColors.primary,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ),
              ],
            ),
            actions: [
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.rewardForMode,
                    foregroundColor: AppColors.onPrimary,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                    padding: const EdgeInsets.symmetric(vertical: 12),
                  ),
                  onPressed: () => Navigator.of(context).pop(),
                  child: Text('Celebrar progresso'),
                ),
              ),
            ],
          ),
        );

        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Row(
              children: [
                Icon(Icons.emoji_events_rounded, color: AppColors.onPrimary),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    'Semana perfeita: 7/7 concluídos! Novo ciclo iniciado.',
                    style: TextStyle(color: AppColors.onPrimary),
                  ),
                ),
              ],
            ),
            backgroundColor: AppColors.rewardForMode,
            behavior: SnackBarBehavior.floating,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
            duration: const Duration(milliseconds: 2400),
          ),
        );
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              _mensagemDoDiaPorProgresso(),
              style: TextStyle(color: AppColors.onPrimary),
            ),
            backgroundColor: AppColors.successForMode,
            behavior: SnackBarBehavior.floating,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          ),
        );
      }
      _savePrefs();
    });
  }

  @override
  void initState() {
    super.initState();
    _loadPrefs();
  }

  Future<void> _loadPrefs() async {
    final prefs = await SharedPreferences.getInstance();
    final count = prefs.getInt(_prefsCountKey) ?? 0;
    final meta = prefs.getInt(_prefsMetaKey) ?? _metaDiasIntensivos;
    if (!mounted) return;
    setState(() {
      _diasIntensivosContagem = count;
      _metaDiasIntensivos = meta;
    });
  }

  Future<void> _savePrefs() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setInt(_prefsCountKey, _diasIntensivosContagem);
    await prefs.setInt(_prefsMetaKey, _metaDiasIntensivos);
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final int dentroCiclo = _metaDiasIntensivos > 0
        ? _diasIntensivosContagem % _metaDiasIntensivos
        : _diasIntensivosContagem;
    final double progressoCiclo = (_metaDiasIntensivos > 0)
        ? (dentroCiclo / _metaDiasIntensivos).clamp(0.0, 1.0)
        : 0.0;
    final double percentualMeta = progressoCiclo * 100;
    final int restanteMeta = _metaDiasIntensivos > 0
        ? (_metaDiasIntensivos - dentroCiclo).clamp(0, _metaDiasIntensivos)
        : 0;

    final String statusText = _metaDiasIntensivos > 0
        ? (_diasIntensivosContagem >= _metaDiasIntensivos
            ? 'Meta alcançada! Você está em alta e no ritmo certo.'
            : _diasIntensivosContagem >= (_metaDiasIntensivos * 0.75)
                ? 'Quase lá! Falta só $restanteMeta dia(s) para bater a meta.'
                : _diasIntensivosContagem >= (_metaDiasIntensivos * 0.45)
                    ? 'Você está no caminho certo. O momentum está forte e a consistência está trabalhando a seu favor.'
                    : 'Cada dia intenso conta. Continue assim e a evolução vai aparecer na prática.')
        : 'Defina sua meta para acompanhar o progresso do ciclo.';

    final String badgeText = _metaDiasIntensivos > 0
        ? (_diasIntensivosContagem >= _metaDiasIntensivos
            ? 'Meta batida'
            : _diasIntensivosContagem >= (_metaDiasIntensivos * 0.75)
                ? 'Quase lá'
                : 'Em progresso')
        : 'Meta livre';

    return Scaffold(
      appBar: AppBar(
        backgroundColor: AppColors.primary,
        elevation: 0,
        title: Text('Dias Intensivos'),
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Expanded(
                  child: Text(
                    'Sistema de Dias Intensivos',
                    style: TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                      color: colorScheme.onSurface,
                    ),
                  ),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                  decoration: BoxDecoration(
                    color: AppColors.successForMode.withAlpha((0.14 * 255).round()),
                    borderRadius: BorderRadius.circular(999),
                  ),
                  child: Text(
                    badgeText,
                    style: TextStyle(
                      color: AppColors.successForMode,
                      fontWeight: FontWeight.w700,
                      fontSize: 12,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),
            Text(
              'Concluir atividades intensas conta +1 ponto',
              style: TextStyle(fontSize: 14, color: AppColors.onSurface.withAlpha((0.7 * 255).round())),
            ),
            const SizedBox(height: 16),
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [
                    AppColors.primary,
                    AppColors.secondary,
                  ],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                borderRadius: BorderRadius.circular(20),
                boxShadow: [
                  BoxShadow(
                    color: AppColors.primary.withAlpha((0.18 * 255).round()),
                    blurRadius: 14,
                    offset: const Offset(0, 8),
                  ),
                ],
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        'Sua meta',
                        style: TextStyle(fontSize: 16, color: AppColors.onPrimary.withAlpha((0.7 * 255).round())),
                      ),
                      IconButton(
                        icon: Icon(Icons.edit, color: AppColors.onPrimary),
                        onPressed: _editarMeta,
                        tooltip: 'Editar meta',
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      Text(
                        '$dentroCiclo / $_metaDiasIntensivos',
                        style: TextStyle(
                          fontSize: 38,
                          fontWeight: FontWeight.bold,
                          color: AppColors.onPrimary,
                        ),
                      ),
                      const SizedBox(width: 8),
                      Padding(
                        padding: const EdgeInsets.only(bottom: 8),
                        child: Text(
                          'dias',
                          style: TextStyle(
                            color: AppColors.onPrimary.withAlpha((0.7 * 255).round()),
                            fontSize: 14,
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 10),
                  Text(
                    statusText,
                    style: TextStyle(
                      fontSize: 14,
                      color: AppColors.onPrimary,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  const SizedBox(height: 14),
                  ClipRRect(
                    borderRadius: BorderRadius.circular(10),
                    child: LinearProgressIndicator(
                      value: (_metaDiasIntensivos > 0) ? progressoCiclo : 0.0,
                      minHeight: 12,
                      backgroundColor: AppColors.onPrimary.withAlpha((0.18 * 255).round()),
                      valueColor: AlwaysStoppedAnimation<Color>(
                        _progressColor(dentroCiclo, _metaDiasIntensivos),
                      ),
                    ),
                  ),
                  const SizedBox(height: 10),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        '${percentualMeta.toStringAsFixed(0)}% do ciclo atual',
                        style: TextStyle(fontSize: 13, color: AppColors.onPrimary.withAlpha((0.7 * 255).round())),
                      ),
                      Text(
                        'Restam: $restanteMeta dias',
                        style: TextStyle(fontSize: 13, color: AppColors.onPrimary.withAlpha((0.7 * 255).round())),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            const SizedBox(height: 18),
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: AppColors.primary.withAlpha((0.06 * 255).round()),
                borderRadius: BorderRadius.circular(16),
                border: Border.all(
                  color: AppColors.primary.withAlpha((0.12 * 255).round()),
                ),
              ),
              child: Row(
                children: [
                  Container(
                    width: 46,
                    height: 46,
                    decoration: BoxDecoration(
                      color: AppColors.rewardForMode.withAlpha((0.15 * 255).round()),
                      shape: BoxShape.circle,
                    ),
                    child: Icon(Icons.emoji_events_rounded, color: AppColors.rewardForMode),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          _diasIntensivosContagem >= _metaDiasIntensivos
                              ? 'Você já alcançou a marca.'
                              : 'Você está no caminho certo.',
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            color: AppColors.primary,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          _diasIntensivosContagem >= _metaDiasIntensivos
                              ? 'Seu esforço está refletindo em progresso real. Continue mantendo a consistência.'
                              : 'Cada dia intenso ajuda a fechar o ciclo e construir um hábito mais forte.',
                          style: TextStyle(fontSize: 12, color: AppColors.onSurface.withAlpha((0.7 * 255).round())),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 20),
            SizedBox(
              width: double.infinity,
              height: 52,
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.successForMode,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(14),
                  ),
                  elevation: 0,
                ),
                onPressed: _adicionarDiaIntensivo,
                    child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(Icons.add_rounded, color: AppColors.onPrimary),
                    const SizedBox(width: 8),
                    Text(
                      'Registrar Dia Intensivo',
                      style: TextStyle(
                        color: AppColors.onPrimary,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 25),
            Text(
              'Histórico Recente',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: colorScheme.onSurface,
              ),
            ),
            const SizedBox(height: 15),
            ListView.builder(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: _diasIntensivos.length,
              itemBuilder: (context, index) {
                final dia = _diasIntensivos[index];
                return _buildDiaCard(dia);
              },
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDiaCard(Map<String, dynamic> dia) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Container(
        decoration: BoxDecoration(
          color: AppColors.surface,
          borderRadius: BorderRadius.circular(12),
          boxShadow: [
            BoxShadow(
              color: AppColors.primary.withAlpha((0.22 * 255).round()),
              blurRadius: 8,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        padding: const EdgeInsets.all(16),
        child: Row(
          children: [
            Container(
              width: 60,
              height: 60,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: dia['concluido']
                    ? AppColors.success.withAlpha((0.2 * 255).round())
                    : AppColors.warning.withAlpha((0.2 * 255).round()),
              ),
              child: Icon(
                dia['concluido'] ? Icons.check_circle : Icons.schedule,
                color: dia['concluido'] ? AppColors.successForMode : AppColors.warningForMode,
                size: 30,
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    dia['data'],
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.bold,
                      color: AppColors.primary,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    dia['dia'],
                    style: TextStyle(
                      fontSize: 12,
                      color: AppColors.onSurface.withAlpha((0.7 * 255).round()),
                    ),
                  ),
                  const SizedBox(height: 6),
                  Text(
                    dia['atividades'],
                    style: TextStyle(
                      fontSize: 13,
                      color: AppColors.onSurface.withAlpha((0.87 * 255).round()),
                    ),
                  ),
                ],
              ),
            ),
            if (dia['concluido'])
              Icon(Icons.check, color: AppColors.successForMode, size: 24),
          ],
        ),
      ),
    );
  }

  void _editarMeta() {
    final controller = TextEditingController(
      text: _metaDiasIntensivos.toString(),
    );
    final messenger = ScaffoldMessenger.of(context);
    final navigator = Navigator.of(context);

    showDialog<void>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Editar meta de dias'),
        content: TextField(
          controller: controller,
          keyboardType: TextInputType.number,
          decoration: const InputDecoration(
            hintText: 'Insira número de dias por ciclo',
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => navigator.pop(),
            child: Text('Cancelar'),
          ),
          ElevatedButton(
            onPressed: () async {
              final v = int.tryParse(controller.text.trim());
              if (v == null || v <= 0) {
                messenger.showSnackBar(
                  const SnackBar(content: Text('Informe um número válido')),
                );
                return;
              }
              setState(() {
                _metaDiasIntensivos = v;
                _nivel = _diasIntensivosContagem ~/ _metaDiasIntensivos;
              });
              await _savePrefs();
              navigator.pop();
              messenger.showSnackBar(
                SnackBar(
                  content: Text('Meta atualizada para $_metaDiasIntensivos'),
                  behavior: SnackBarBehavior.floating,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                ),
              );
            },
            child: Text('Salvar'),
          ),
        ],
      ),
    );
  }
}

// Helpers adicionados
Color _progressColor(int dentroCiclo, int meta) {
  if (meta <= 0) return AppColors.info;
  final double pct = dentroCiclo / meta;
  if (pct >= 0.9) return AppColors.reward;
  if (pct >= 0.6) return AppColors.success;
  if (pct >= 0.3) return AppColors.info;
  return AppColors.warning;
}


