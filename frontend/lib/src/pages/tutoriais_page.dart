
import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../data/auth_service.dart';
import '../theme.dart';
import 'home_page.dart';

// Classe TutoriaisPage representa um componente ou widget da interface.
class TutoriaisPage extends StatefulWidget {
  const TutoriaisPage({super.key});

  @override
  State<TutoriaisPage> createState() => _TutoriaisPageState();
}

// Classe _TutoriaisPageState representa um componente ou widget da interface.
class _TutoriaisPageState extends State<TutoriaisPage> {
  static const String _prefsKey = 'tutoriais_concluidos_v1';

  final List<Map<String, dynamic>> _tutoriais = [
    {
      'id': 'comece_treino',
      'titulo': 'Como começar seu treino',
      'descricao':
          'Aprenda os primeiros passos para começar uma rotina de exercícios',
      'duracao': '5 min',
      'dificuldade': 'Iniciante',
      'icon': Icons.fitness_center,
      'objetivo': 'Montar uma rotina simples e segura para começar hoje.',
      'passos': [
        'Faça 5 minutos de aquecimento leve.',
        'Escolha 3 exercícios básicos para o corpo todo.',
        'Execute 2 séries com foco em técnica, não em carga.',
        'Finalize com alongamento leve e água.',
      ],
      'resultado': 'Você sai com um treino inicial prático e sustentável.',
    },
    {
      'id': 'meditacao_basica',
      'titulo': 'Técnicas de Meditação',
      'descricao':
          'Domine as técnicas básicas de meditação para aumentar seu bem-estar',
      'duracao': '8 min',
      'dificuldade': 'Intermediário',
      'icon': Icons.self_improvement,
      'objetivo': 'Aprender uma prática curta para reduzir a ansiedade.',
      'passos': [
        'Sente-se em um local silencioso e confortável.',
        'Respire fundo por 1 minuto, soltando o ar lentamente.',
        'Observe a respiração por 3 minutos sem forçar pensamentos.',
        'Volte a atenção ao corpo e termine com calma.',
      ],
      'resultado': 'Você consegue repetir uma meditação curta quando precisar.',
    },
    {
      'id': 'nutricao_equilibrada',
      'titulo': 'Nutrição Adequada',
      'descricao':
          'Entenda como manter uma alimentação equilibrada para seus objetivos',
      'duracao': '10 min',
      'dificuldade': 'Intermediário',
      'icon': Icons.restaurant,
      'objetivo': 'Estruturar refeições mais equilibradas ao longo do dia.',
      'passos': [
        'Monte o prato com proteína, carboidrato e legumes.',
        'Priorize água antes de bebidas açucaradas.',
        'Evite pular refeições para não exagerar depois.',
        'Planeje um lanche saudável de emergência.',
      ],
      'resultado': 'Você passa a identificar escolhas mais consistentes.',
    },
    {
      'id': 'hidratacao_saude',
      'titulo': 'Hidratação e Saúde',
      'descricao': 'Saiba a importância de manter-se hidratado durante o dia',
      'duracao': '4 min',
      'dificuldade': 'Iniciante',
      'icon': Icons.water_drop,
      'objetivo': 'Criar uma meta simples de hidratação diária.',
      'passos': [
        'Defina um total diário de água para acompanhar.',
        'Use garrafa ou copo para medir o consumo.',
        'Beba pequenas quantidades ao longo do dia.',
        'Associe água a momentos fixos da rotina.',
      ],
      'resultado':
          'Você consegue acompanhar e distribuir melhor a ingestão de água.',
    },
    {
      'id': 'recuperacao_muscular',
      'titulo': 'Recuperação Muscular',
      'descricao': 'Técnicas avançadas para recuperação após treinos intensos',
      'duracao': '12 min',
      'dificuldade': 'Avançado',
      'icon': Icons.healing,
      'objetivo': 'Recuperar melhor depois de treinos mais pesados.',
      'passos': [
        'Faça desaquecimento leve por alguns minutos.',
        'Aplique alongamentos suaves e mobilidade.',
        'Dê atenção ao sono e à alimentação pós-treino.',
        'Use descanso ativo quando o corpo pedir menos impacto.',
      ],
      'resultado': 'Você reduz fadiga e melhora a consistência do treino.',
    },
  ];

  final Set<String> _concluidos = <String>{};

  @override
  void initState() {
    super.initState();
    _loadConcluidos();
  }

  Color _getCorDificuldade(String dificuldade) {
    switch (dificuldade) {
      case 'Iniciante':
        return AppColors.success;
      case 'Intermediário':
        return AppColors.warning;
      case 'Avançado':
        return AppColors.error;
      default:
        return AppColors.onSurface.withAlpha((0.7 * 255).round());
    }
  }

  // Recupera a lista de tutoriais marcados como concluídos da memória local.
  Future<void> _loadConcluidos() async {
    final prefs = await SharedPreferences.getInstance();
    final raw = prefs.getString(_prefsKey);
    if (raw == null || raw.isEmpty) {
      return;
    }

    try {
      final decoded = jsonDecode(raw) as List<dynamic>;
      if (!mounted) {
        return;
      }
      setState(() {
        _concluidos
          ..clear()
          ..addAll(decoded.map((item) => item.toString()));
      });
    } catch (_) {
      // mantém o estado padrão se a leitura falhar
    }
  }

  // Salva localmente os IDs de tutoriais concluídos para manter o progresso do usuário.
  Future<void> _saveConcluidos() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_prefsKey, jsonEncode(_concluidos.toList()));
  }

  @override
  Widget build(BuildContext context) {
    final currentUser = AuthService.usuarioLogado;
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Scaffold(
      appBar: AppBar(
        backgroundColor: colorScheme.primary,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => Navigator.of(context).maybePop(),
        ),
        title: Text(
          'Tutoriais',
          style: TextStyle(
            fontWeight: FontWeight.bold,
            fontSize: 24,
            color: colorScheme.onPrimary,
          ),
        ),
        centerTitle: true,
        actions: [
          IconButton(
            tooltip: 'Acessibilidade',
            icon: Icon(Icons.accessible, color: colorScheme.onPrimary),
            onPressed: _showThemeDialog,
          ),
        ],
      ),
      body: _buildBody(context),
      bottomNavigationBar: BottomNavigationBar(
        backgroundColor: colorScheme.primary,
        selectedItemColor: colorScheme.onPrimary,
        unselectedItemColor: colorScheme.onPrimary.withAlpha((0.7 * 255).round()),
        currentIndex: 0,
        type: BottomNavigationBarType.fixed,
        onTap: (index) {
          final usuario = currentUser;
          if (usuario == null) {
            Navigator.of(context).maybePop();
            return;
          }

          Navigator.of(context).pushReplacement(
            MaterialPageRoute(
              builder: (context) =>
                  HomePage(usuario: usuario, initialIndex: index),
            ),
          );
        },
        items: const [
          BottomNavigationBarItem(icon: Icon(Icons.home), label: 'Home'),
          BottomNavigationBarItem(
            icon: Icon(Icons.calendar_today),
            label: 'Cronograma',
          ),
          BottomNavigationBarItem(icon: Icon(Icons.note), label: 'Anotações'),
          BottomNavigationBarItem(
            icon: Icon(Icons.notifications),
            label: 'Lembretes',
          ),
          BottomNavigationBarItem(icon: Icon(Icons.person), label: 'Perfil'),
        ],
      ),
    );
  }

  Widget _buildBody(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final isDarkMode = theme.brightness == Brightness.dark;
    final headingColor = isDarkMode ? colorScheme.onSurface : colorScheme.primary;

    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Aprenda a fazer as atividades',
            style: TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.bold,
              color: headingColor,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Cada tutorial tem passos práticos e pode ser marcado como concluído.',
            style: TextStyle(
              fontSize: 14,
              color: colorScheme.onSurface.withAlpha((0.7 * 255).round()),
            ),
          ),
          const SizedBox(height: 20),
          ListView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            itemCount: _tutoriais.length,
            itemBuilder: (context, index) {
              final tutorial = _tutoriais[index];
              return _buildTutorialCard(context, tutorial);
            },
          ),
        ],
      ),
    );
  }

  Widget _buildTutorialCard(BuildContext context, Map<String, dynamic> tutorial) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final isDarkMode = theme.brightness == Brightness.dark;
    final accentColor = isDarkMode ? AppColors.success : colorScheme.primary;
    final titleColor = isDarkMode ? colorScheme.onSurface : colorScheme.primary;
    final Color corDificuldade = _getCorDificuldade(tutorial['dificuldade']);
    final bool concluido = _concluidos.contains(tutorial['id']);

    return Padding(
      padding: const EdgeInsets.only(bottom: 15),
      child: GestureDetector(
        onTap: () => _mostrarTutorial(tutorial),
        child: Container(
          decoration: BoxDecoration(
            color: theme.cardColor,
            borderRadius: BorderRadius.circular(12),
            boxShadow: [
              BoxShadow(
                color: theme.shadowColor.withAlpha((0.22 * 255).round()),
                blurRadius: 6,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Container(
                    width: 50,
                    height: 50,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: accentColor.withAlpha((0.2 * 255).round()),
                    ),
                    child: Icon(tutorial['icon'], color: accentColor),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Expanded(
                              child: Text(
                                tutorial['titulo'],
                                style: TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.bold,
                                  color: titleColor,
                                ),
                              ),
                            ),
                            if (concluido)
                              Icon(
                                Icons.check_circle,
                                color: AppColors.warning,
                                size: 20,
                              ),
                          ],
                        ),
                        const SizedBox(height: 4),
                        Text(
                          tutorial['descricao'],
                          style: TextStyle(
                            fontSize: 12,
                            color: colorScheme.onSurface.withAlpha((0.7 * 255).round()),
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Row(
                    children: [
                      Icon(
                        Icons.timer,
                        size: 14,
                        color: colorScheme.onSurface.withAlpha((0.7 * 255).round()),
                      ),
                      const SizedBox(width: 4),
                      Text(
                        tutorial['duracao'],
                        style: TextStyle(
                          fontSize: 12,
                          color: colorScheme.onSurface.withAlpha((0.7 * 255).round()),
                        ),
                      ),
                    ],
                  ),
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 10,
                      vertical: 4,
                    ),
                    decoration: BoxDecoration(
                      color: corDificuldade.withAlpha((0.2 * 255).round()),
                      borderRadius: BorderRadius.circular(6),
                    ),
                    child: Text(
                      tutorial['dificuldade'],
                      style: TextStyle(
                        fontSize: 11,
                        fontWeight: FontWeight.bold,
                        color: corDificuldade,
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _mostrarTutorial(Map<String, dynamic> tutorial) {
    final bool concluido = _concluidos.contains(tutorial['id']);
    final List<String> passos = List<String>.from(tutorial['passos'] as List);

    showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      builder: (sheetContext) {
        final theme = Theme.of(sheetContext);
        final colorScheme = theme.colorScheme;
        final isDarkMode = theme.brightness == Brightness.dark;
        final accentColor = isDarkMode ? AppColors.success : colorScheme.primary;

        return DraggableScrollableSheet(
          initialChildSize: 0.88,
          minChildSize: 0.65,
          maxChildSize: 0.96,
          expand: false,
          builder: (context, scrollController) {
            return Container(
              decoration: BoxDecoration(
                color: colorScheme.surface,
                borderRadius: const BorderRadius.vertical(
                  top: Radius.circular(24),
                ),
              ),
              child: SingleChildScrollView(
                controller: scrollController,
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Center(
                      child: Container(
                        width: 44,
                        height: 5,
                        decoration: BoxDecoration(
                          color: colorScheme.onSurface.withAlpha(
                            (0.18 * 255).round(),
                          ),
                          borderRadius: BorderRadius.circular(999),
                        ),
                      ),
                    ),
                    const SizedBox(height: 16),
                    Row(
                      children: [
                        Icon(
                          tutorial['icon'],
                          color: colorScheme.primary,
                          size: 32,
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                tutorial['titulo'],
                                style: TextStyle(
                                  fontSize: 20,
                                  fontWeight: FontWeight.bold,
                                  color: colorScheme.primary,
                                ),
                              ),
                              Text(
                                'Duração: ${tutorial['duracao']} | ${tutorial['dificuldade']}',
                                style: TextStyle(
                                  fontSize: 12,
                                  color: colorScheme.onSurface.withAlpha(
                                    (0.65 * 255).round(),
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 20),
                    Text(
                      'Objetivo',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: colorScheme.onSurface,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      tutorial['objetivo'],
                      style: TextStyle(
                        fontSize: 14,
                        height: 1.5,
                        color: colorScheme.onSurface,
                      ),
                    ),
                    const SizedBox(height: 20),
                    Text(
                      'Passos',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: colorScheme.onSurface,
                      ),
                    ),
                    const SizedBox(height: 8),
                    ...List.generate(passos.length, (index) {
                      return Padding(
                        padding: const EdgeInsets.only(bottom: 10),
                        child: Container(
                          width: double.infinity,
                          padding: const EdgeInsets.all(12),
                          decoration: BoxDecoration(
                            color: colorScheme.primary.withAlpha(
                              (0.06 * 255).round(),
                            ),
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Row(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Container(
                                width: 26,
                                height: 26,
                                alignment: Alignment.center,
                                decoration: BoxDecoration(
                                  color: colorScheme.primary,
                                  shape: BoxShape.circle,
                                ),
                                child: Text(
                                  '${index + 1}',
                                  style: TextStyle(
                                    color: colorScheme.onPrimary,
                                    fontWeight: FontWeight.bold,
                                    fontSize: 12,
                                  ),
                                ),
                              ),
                              const SizedBox(width: 10),
                              Expanded(
                                child: Text(
                                  passos[index],
                                  style: TextStyle(
                                    fontSize: 14,
                                    height: 1.45,
                                    color: colorScheme.onSurface,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      );
                    }),
                    const SizedBox(height: 8),
                    Text(
                      'Resultado esperado',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: colorScheme.onSurface,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Container(
                      width: double.infinity,
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: AppColors.success.withAlpha(
                          (0.12 * 255).round(),
                        ),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Text(
                        tutorial['resultado'],
                        style: TextStyle(
                          fontSize: 14,
                          height: 1.5,
                          color: colorScheme.onSurface,
                        ),
                      ),
                    ),
                    const SizedBox(height: 20),
                    if (concluido)
                      Container(
                        width: double.infinity,
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: AppColors.success.withAlpha(
                            (0.14 * 255).round(),
                          ),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Text(
                          'Tutorial concluído',
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            color: AppColors.success,
                          ),
                        ),
                      ),
                    if (concluido) const SizedBox(height: 12),
                    SizedBox(
                      width: double.infinity,
                      height: 50,
                      child: ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppColors.warning,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                        onPressed: () async {
                          final id = tutorial['id'] as String;
                          setState(() {
                            _concluidos.add(id);
                          });
                          await _saveConcluidos();
                          if (!sheetContext.mounted) return;
                          Navigator.pop(sheetContext);
                          ScaffoldMessenger.of(sheetContext).showSnackBar(
                            SnackBar(
                              content: Text(
                                'Tutorial "${tutorial['titulo']}" concluído e salvo!',
                              ),
                              backgroundColor: AppColors.success,
                            ),
                          );
                        },
                        child: Text(
                          concluido
                              ? 'Rever tutorial'
                              : 'Marcar como concluído',
                          style: TextStyle(
                            color: isDarkMode ? Colors.black : colorScheme.onPrimary,
                            fontWeight: FontWeight.bold,
                            fontSize: 16,
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(height: 12),
                    SizedBox(
                      width: double.infinity,
                      height: 50,
                      child: OutlinedButton(
                        style: OutlinedButton.styleFrom(
                          side: BorderSide(
                            color: accentColor,
                            width: 2,
                          ),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                        onPressed: () {
                          Navigator.pop(sheetContext);
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(
                              content: Text(
                                'Tutorial "${tutorial['titulo']}" iniciado!',
                              ),
                              backgroundColor: accentColor,
                            ),
                          );
                        },
                        child: Text(
                          'Iniciar agora',
                          style: TextStyle(
                            color: accentColor,
                            fontWeight: FontWeight.bold,
                            fontSize: 16,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            );
          },
        );
      },
    );
  }

  void _showThemeDialog() {
    showDialog<void>(
      context: context,
      builder: (context) {
        final theme = Theme.of(context);
        final colorScheme = theme.colorScheme;

        return AlertDialog(
          title: Text(
            'Tema para Deficientes Visuais',
            style: TextStyle(color: colorScheme.onSurface),
          ),
          content: ValueListenableBuilder<AppThemeMode>(
            valueListenable: AppThemeController.mode,
            builder: (context, mode, child) {
              return Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  RadioGroup<AppThemeMode>(
                    groupValue: mode,
                    onChanged: (selected) async {
                      if (selected != null) {
                        await AppThemeController.setMode(selected);
                      }
                    },
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        RadioListTile<AppThemeMode>(
                          value: AppThemeMode.normal,
                          title: Text(
                            'Tema Padrão',
                            style: TextStyle(color: colorScheme.onSurface),
                          ),
                          subtitle: Text(
                            'Modo normal do app.',
                            style: TextStyle(color: colorScheme.onSurface.withAlpha((0.72 * 255).round())),
                          ),
                        ),
                        RadioListTile<AppThemeMode>(
                          value: AppThemeMode.dark,
                          title: Text(
                            'Tema Escuro',
                            style: TextStyle(color: colorScheme.onSurface),
                          ),
                          subtitle: Text(
                            'Visual mais escuro para uso noturno.',
                            style: TextStyle(color: colorScheme.onSurface.withAlpha((0.72 * 255).round())),
                          ),
                        ),
                        RadioListTile<AppThemeMode>(
                          value: AppThemeMode.accessible,
                          title: Text(
                            'Tema Acessível',
                            style: TextStyle(color: colorScheme.onSurface),
                          ),
                          subtitle: Text(
                            'Alto contraste e texto maior.',
                            style: TextStyle(color: colorScheme.onSurface.withAlpha((0.72 * 255).round())),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              );
            },
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              style: TextButton.styleFrom(
                foregroundColor: AppThemeController.mode.value == AppThemeMode.accessible
                    ? colorScheme.onSurface
                    : colorScheme.primary,
              ),
              child: Text('Fechar'),
            ),
          ],
        );
      },
    );
  }
}
