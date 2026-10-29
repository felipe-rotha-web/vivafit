import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../theme.dart';
import '../models/app_user.dart';
import 'desafios_page.dart';
import 'dias_intensivos_page.dart';
import 'cronograma_page.dart';
import 'anotacoes_page.dart';
import 'lembretes_page.dart';
import 'perfil_page.dart';

// Classe HomePage representa um componente ou widget da interface.
class HomePage extends StatefulWidget {
  const HomePage({super.key, required this.usuario, this.initialIndex = 0});

  final AppUser usuario;
  final int initialIndex;

  @override
  State<HomePage> createState() => _HomePageState();
}

// Classe _HomePageState representa um componente ou widget da interface.
class _HomePageState extends State<HomePage> {
  int _selectedIndex = 0;
  late final List<Widget> _pages;

  @override
  void initState() {
    super.initState();
    // Define as páginas que estarão disponíveis na barra de navegação inferior.
    // Cada página é mantida em memória pelo IndexedStack para preservar seu estado.
    _pages = [
      HomeContent(usuario: widget.usuario, onNavigate: (idx) => setState(() => _selectedIndex = idx)),
      const CronogramaPage(),
      const AnotacoesPage(),
      const LembretesPage(),
      PerfilPage(usuario: widget.usuario),
    ];
    _selectedIndex = widget.initialIndex;
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Scaffold(
      appBar: AppBar(
        automaticallyImplyLeading: false,
        backgroundColor: colorScheme.primary,
        foregroundColor: colorScheme.onPrimary,
        elevation: 0,
        title: Text(
          'AppVivaFit',
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
      // O IndexedStack mantém todas as páginas em memória, trocando apenas a visibilidade da ativa.
      body: IndexedStack(index: _selectedIndex, children: _pages),
      bottomNavigationBar: SafeArea(
        top: false,
        child: BottomNavigationBar(
          backgroundColor: colorScheme.primary,
          selectedItemColor: colorScheme.onPrimary,
          unselectedItemColor: colorScheme.onPrimary.withAlpha(
            (0.7 * 255).round(),
          ),
          currentIndex: _selectedIndex,
          type: BottomNavigationBarType.fixed,
          // Altera a aba ativa da tela Home e exibe a página correspondente no IndexedStack.
          onTap: (index) {
            setState(() => _selectedIndex = index);
          },
          items: [
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
      ),
    );
  }

  void _showThemeDialog() {
    showDialog<void>(
      context: context,
      builder: (context) {
        final isDarkMode = Theme.of(context).brightness == Brightness.dark;
        final dialogBackground = isDarkMode ? const Color(0xFF1A2333) : null;

        return AlertDialog(
          backgroundColor: dialogBackground,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(22)),
          title: Row(
            children: [
              Icon(Icons.accessible_forward_rounded, color: isDarkMode ? Colors.white : AppColors.primary),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  'Acessibilidade',
                  style: TextStyle(
                    color: isDarkMode ? Colors.white : AppColors.primary,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
            ],
          ),
          content: ValueListenableBuilder<AppThemeMode>(
            valueListenable: AppThemeController.mode,
            builder: (context, mode, child) {
              final cs = Theme.of(context).colorScheme;
              return SingleChildScrollView(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Temas e contraste',
                      style: TextStyle(
                        fontWeight: AppThemeController.boldText.value ? FontWeight.w700 : FontWeight.bold,
                        color: cs.onSurface,
                      ),
                    ),
                    const SizedBox(height: 8),
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
                            title: Text('Tema Padrão', style: TextStyle(color: cs.onSurface)),
                            subtitle: Text('Modo normal do app.', style: TextStyle(color: cs.onSurface.withAlpha((0.72 * 255).round()))),
                          ),
                          RadioListTile<AppThemeMode>(
                            value: AppThemeMode.dark,
                            title: Text('Tema Escuro', style: TextStyle(color: cs.onSurface)),
                            subtitle: Text('Visual mais escuro para uso noturno.', style: TextStyle(color: cs.onSurface.withAlpha((0.72 * 255).round()))),
                          ),
                          RadioListTile<AppThemeMode>(
                            value: AppThemeMode.accessible,
                            title: Text('Tema Acessível', style: TextStyle(color: cs.onSurface)),
                            subtitle: Text('Alto contraste e texto maior.', style: TextStyle(color: cs.onSurface.withAlpha((0.72 * 255).round()))),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 12),
                    Text(
                      'Ajustes de leitura',
                      style: TextStyle(
                        fontWeight: AppThemeController.boldText.value ? FontWeight.w700 : FontWeight.bold,
                        color: cs.onSurface,
                      ),
                    ),
                    const SizedBox(height: 8),
                    ValueListenableBuilder<double>(
                      valueListenable: AppThemeController.fontScale,
                      builder: (context, fontScale, _) {
                        return Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Tamanho da fonte: ${fontScale.toStringAsFixed(2)}x',
                              style: TextStyle(
                                color: cs.onSurface,
                              ),
                            ),
                            Slider(
                              value: fontScale,
                              min: 1.0,
                              max: 1.5,
                              divisions: 10,
                              label: '${fontScale.toStringAsFixed(2)}x',
                              onChanged: (value) async {
                                await AppThemeController.setFontScale(value);
                              },
                            ),
                          ],
                        );
                      },
                    ),
                    ValueListenableBuilder<double>(
                      valueListenable: AppThemeController.lineHeight,
                      builder: (context, lineHeight, _) {
                        return Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Espaçamento entre linhas: ${lineHeight.toStringAsFixed(2)}x',
                              style: TextStyle(
                                color: cs.onSurface,
                              ),
                            ),
                            Slider(
                              value: lineHeight,
                              min: 1.0,
                              max: 2.0,
                              divisions: 20,
                              label: '${lineHeight.toStringAsFixed(2)}x',
                              onChanged: (value) async {
                                await AppThemeController.setLineHeight(value);
                              },
                            ),
                          ],
                        );
                      },
                    ),
                    const SizedBox(height: 12),
                    if (mode == AppThemeMode.accessible) ...[
                      const SizedBox(height: 8),
                      ValueListenableBuilder<DaltonismVariant>(
                        valueListenable: AppThemeController.daltonismVariant,
                        builder: (context, variant, _) {
                          final cs2 = Theme.of(context).colorScheme;
                          return Column(
                            mainAxisSize: MainAxisSize.min,
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Padding(
                                padding: const EdgeInsets.only(bottom: 6),
                                child: Text(
                                  'Variante de Daltonismo',
                                  style: TextStyle(fontWeight: FontWeight.bold, color: cs2.onSurface),
                                ),
                              ),
                              RadioGroup<DaltonismVariant>(
                                groupValue: variant,
                                onChanged: (v) async {
                                  if (v != null) {
                                    await AppThemeController.setDaltonismVariant(v);
                                  }
                                },
                                child: Column(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    RadioListTile<DaltonismVariant>(
                                      value: DaltonismVariant.deuteranopia,
                                      title: Text('Deuteranopia', style: TextStyle(color: cs2.onSurface)),
                                      subtitle: Text('Compatível com perda de visão de verde.', style: TextStyle(color: cs2.onSurface.withAlpha((0.72 * 255).round()))),
                                    ),
                                    RadioListTile<DaltonismVariant>(
                                      value: DaltonismVariant.tritanopia,
                                      title: Text('Tritanopia', style: TextStyle(color: cs2.onSurface)),
                                      subtitle: Text('Compatível com perda de visão de azul.', style: TextStyle(color: cs2.onSurface.withAlpha((0.72 * 255).round()))),
                                    ),
                                    RadioListTile<DaltonismVariant>(
                                      value: DaltonismVariant.acromatopsia,
                                      title: Text('Acromatopsia', style: TextStyle(color: cs2.onSurface)),
                                      subtitle: Text('Visão em escala de cinza.', style: TextStyle(color: cs2.onSurface.withAlpha((0.72 * 255).round()))),
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          );
                        },
                      ),
                    ],
                  ],
                ),
              );
            },
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              style: TextButton.styleFrom(
                foregroundColor: isDarkMode ? Colors.white : AppColors.primary,
                backgroundColor: isDarkMode ? const Color(0xFF2A3A4E) : null,
              ),
              child: Text('Fechar'),
            ),
          ],
        );
      },
    );
  }
}

// Classe HomeContent representa um componente ou widget da interface.
class HomeContent extends StatefulWidget {
  const HomeContent({super.key, required this.usuario, this.onNavigate});

  final AppUser usuario;
  final void Function(int index)? onNavigate;

  @override
  State<HomeContent> createState() => _HomeContentState();
}

// Classe _HomeContentState representa um componente ou widget da interface.
class _HomeContentState extends State<HomeContent> {
  static const String _hydrationPrefsKey = 'hydration_consumed_ml_v1';
  static const String _hydrationGoalKey = 'hydration_goal_ml_v1';
  int _hydrationGoalMl = 3000;
  static const String _diasIntensivosCountKey = 'dias_intensivos_count_v1';
  static const String _diasIntensivosMetaKey = 'dias_intensivos_meta_v1';

  int _hydrationMl = 0;
  late Future<int> _pontosFuture;
  int _diasIntensivosCount = 0;
  int _diasIntensivosMeta = 7;

  Future<int> _loadPontuacaoTotal() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getInt(DesafiosPage.pontosTotalKey) ?? DesafiosPage.pontosDefault;
  }

  void _refreshPontuacao() {
    setState(() {
      _pontosFuture = _loadPontuacaoTotal();
    });
  }

  @override
  void initState() {
    super.initState();
    _pontosFuture = _loadPontuacaoTotal();
    _loadHydration();
    _loadDiasIntensivosCountAndMeta();
  }

  Future<void> _loadDiasIntensivosCountAndMeta() async {
    final prefs = await SharedPreferences.getInstance();
    final count = prefs.getInt(_diasIntensivosCountKey) ?? 0;
    final meta = prefs.getInt(_diasIntensivosMetaKey) ?? 7;
    if (!mounted) return;
    setState(() {
      _diasIntensivosCount = count;
      _diasIntensivosMeta = meta;
    });
  }

  // Lê o progresso de hidratação armazenado localmente quando o widget é iniciado.
  Future<void> _loadHydration() async {
    // Acessa SharedPreferences para obter o valor persistido de hidratação.
    final prefs = await SharedPreferences.getInstance();
    final loaded = prefs.getInt(_hydrationPrefsKey) ?? 0;
    final loadedGoal = prefs.getInt(_hydrationGoalKey) ?? _hydrationGoalMl;
    if (!mounted) {
      return;
    }

    // Atualiza o estado local com o valor carregado e força a interface a re-renderizar.
    setState(() {
      _hydrationGoalMl = loadedGoal;
      _hydrationMl = loaded.clamp(0, _hydrationGoalMl);
    });
  }

  // Persiste localmente a quantidade de água consumida pelo usuário.
  Future<void> _saveHydration() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setInt(_hydrationPrefsKey, _hydrationMl);
  }

  Future<void> _saveHydrationGoal() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setInt(_hydrationGoalKey, _hydrationGoalMl);
  }

  // Incrementa a hidratação atual em mililitros e salva o novo valor.
  void _addHydration(int amountMl) {
    final updated = (_hydrationMl + amountMl).clamp(0, _hydrationGoalMl);
    setState(() {
      _hydrationMl = updated;
    });
    _saveHydration();
  }

  // Reseta o contador de hidratação para zero e grava a alteração.
  void _resetHydration() {
    setState(() {
      _hydrationMl = 0;
    });
    _saveHydration();
  }

  // Exibe diálogo para o usuário escolher quanto de água ele consumiu naquele momento.
  void _showHydrationDialog(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final customController = TextEditingController();

    showDialog<void>(
      context: context,
      builder: (dialogContext) {
        final dialogTheme = Theme.of(dialogContext);
        final isDarkMode = dialogTheme.brightness == Brightness.dark;
        final onSurface = dialogTheme.colorScheme.onSurface;
        final hintColor = onSurface.withAlpha((0.68 * 255).round());
        final fieldFill = isDarkMode ? const Color(0xFF243247) : const Color(0xFFF3F6FA);
        final fieldBorder = isDarkMode
            ? Colors.white.withAlpha((0.12 * 255).round())
            : colorScheme.primary.withAlpha((0.14 * 255).round());

        InputDecoration dialogDecoration(String label) {
          return InputDecoration(
            labelText: label,
            labelStyle: TextStyle(color: hintColor),
            filled: true,
            fillColor: fieldFill,
            border: OutlineInputBorder(borderRadius: BorderRadius.circular(16)),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(16),
              borderSide: BorderSide(color: fieldBorder),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(16),
              borderSide: BorderSide(
                color: isDarkMode ? colorScheme.primary.withAlpha((0.9 * 255).round()) : colorScheme.primary,
                width: 2,
              ),
            ),
          );
        }

        return AlertDialog(
          backgroundColor:
              isDarkMode
                  ? const Color(0xFF1A2333)
                  : (dialogTheme.dialogTheme.backgroundColor ?? dialogTheme.colorScheme.surface),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(24),
          ),
          titlePadding: const EdgeInsets.fromLTRB(24, 24, 24, 8),
          contentPadding: const EdgeInsets.fromLTRB(24, 0, 24, 8),
          actionsPadding: const EdgeInsets.fromLTRB(24, 0, 24, 20),
          title: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Registrar Hidratação',
                style: TextStyle(
                  color: onSurface,
                  fontWeight: FontWeight.w700,
                  fontSize: 22,
                ),
              ),
              const SizedBox(height: 6),
              Text(
                'Meta atual: ${(_hydrationGoalMl / 1000).toStringAsFixed(0)}L',
                style: TextStyle(fontSize: 13, color: hintColor),
              ),
              const SizedBox(height: 6),
              Text(
                'Escolha uma quantidade rápida para somar ao seu dia.',
                style: TextStyle(fontSize: 13, color: hintColor),
              ),
            ],
          ),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Wrap(
                  spacing: 8,
                  runSpacing: 8,
                  children: [
                    _quickHydrationChip(dialogContext, '100 ml', 100),
                    _quickHydrationChip(dialogContext, '250 ml', 250),
                    _quickHydrationChip(dialogContext, '500 ml', 500),
                    _quickHydrationChip(dialogContext, '750 ml', 750),
                    _quickHydrationChip(dialogContext, '1 L', 1000),
                  ],
                ),
                const SizedBox(height: 12),
                TextField(
                  controller: customController,
                  keyboardType: TextInputType.number,
                  cursorColor: colorScheme.primary,
                  style: TextStyle(color: onSurface),
                  decoration: dialogDecoration('Quantidade personalizada (ml)'),
                ),
                const SizedBox(height: 18),
                // Actions arranged in a single horizontal layout for consistent dark-mode styling.
                Wrap(
                  spacing: 10,
                  runSpacing: 10,
                  children: [
                    SizedBox(
                      width: 150,
                      child: OutlinedButton(
                        onPressed: () async {
                          final goalController = TextEditingController(text: (_hydrationGoalMl / 1000).toStringAsFixed(0));
                          final messenger = ScaffoldMessenger.of(context);
                          final result = await showDialog<String?>(
                            context: dialogContext,
                            builder: (ctx) => AlertDialog(
                              backgroundColor: isDarkMode ? const Color(0xFF1A2333) : null,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(20),
                              ),
                              title: Text(
                                'Editar meta de hidratação (L)',
                                style: TextStyle(
                                  color: isDarkMode ? Colors.white : colorScheme.onSurface,
                                  fontWeight: FontWeight.w700,
                                ),
                              ),
                              content: TextField(
                                controller: goalController,
                                keyboardType: TextInputType.number,
                                cursorColor: colorScheme.primary,
                                style: TextStyle(
                                  color: isDarkMode ? Colors.white : colorScheme.onSurface,
                                ),
                                decoration: InputDecoration(
                                  hintText: 'Litros por dia, ex: 3',
                                  hintStyle: TextStyle(
                                    color: isDarkMode
                                        ? Colors.white.withAlpha((0.6 * 255).round())
                                        : colorScheme.onSurface.withAlpha((0.6 * 255).round()),
                                  ),
                                  filled: true,
                                  fillColor: isDarkMode ? const Color(0xFF243247) : null,
                                  enabledBorder: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(14),
                                    borderSide: BorderSide(
                                      color: isDarkMode
                                          ? Colors.white.withAlpha((0.12 * 255).round())
                                          : colorScheme.primary.withAlpha((0.14 * 255).round()),
                                    ),
                                  ),
                                  focusedBorder: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(14),
                                    borderSide: BorderSide(
                                      color: isDarkMode ? Colors.white : colorScheme.primary,
                                      width: 2,
                                    ),
                                  ),
                                ),
                              ),
                              actions: [
                                TextButton(
                                  onPressed: () => Navigator.of(ctx).pop(null),
                                  style: TextButton.styleFrom(
                                    foregroundColor: isDarkMode ? Colors.white : colorScheme.primary,
                                    backgroundColor: isDarkMode ? const Color(0xFF2A3A4E) : null,
                                    textStyle: const TextStyle(fontWeight: FontWeight.w600),
                                  ),
                                  child: Text('Cancelar'),
                                ),
                                ElevatedButton(
                                  onPressed: () => Navigator.of(ctx).pop(goalController.text.trim()),
                                  style: ElevatedButton.styleFrom(
                                    backgroundColor: AppColors.warning,
                                    foregroundColor: AppColors.onPrimary,
                                    padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 12),
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(12),
                                    ),
                                    textStyle: const TextStyle(fontWeight: FontWeight.bold),
                                  ),
                                  child: Text('Salvar'),
                                ),
                              ],
                            ),
                          );
                          if (result != null) {
                            final v = int.tryParse(result);
                            if (v != null && v > 0) {
                              setState(() {
                                _hydrationGoalMl = (v * 1000);
                                _hydrationMl = _hydrationMl.clamp(0, _hydrationGoalMl);
                              });
                              await _saveHydrationGoal();
                              await _saveHydration();
                              messenger.showSnackBar(
                                SnackBar(content: Text('Meta de hidratação atualizada para ${v}L')),
                              );
                            } else {
                              messenger.showSnackBar(const SnackBar(content: Text('Informe um número válido')));
                            }
                          }
                        },
                        style: OutlinedButton.styleFrom(
                          foregroundColor: isDarkMode ? Colors.white : colorScheme.primary,
                          side: BorderSide(
                            color: isDarkMode
                                ? Colors.white.withAlpha((0.16 * 255).round())
                                : colorScheme.primary.withAlpha((0.12 * 255).round()),
                          ),
                          backgroundColor: isDarkMode ? const Color(0xFF2A3A4E) : null,
                          textStyle: const TextStyle(fontWeight: FontWeight.w600),
                        ),
                        child: const Text('Editar meta'),
                      ),
                    ),
                    SizedBox(
                      width: 110,
                      child: TextButton(
                        onPressed: () {
                          Navigator.pop(dialogContext);
                          _resetHydration();
                          if (!mounted) return;
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(
                              content: Text('Hidratação do dia zerada'),
                              backgroundColor: AppColors.info,
                            ),
                          );
                        },
                        style: TextButton.styleFrom(
                          foregroundColor: isDarkMode ? Colors.white : AppColors.error,
                          backgroundColor: isDarkMode ? const Color(0xFF2A3A4E) : null,
                          textStyle: const TextStyle(fontWeight: FontWeight.w600),
                        ),
                        child: const Text('Zerar'),
                      ),
                    ),
                    SizedBox(
                      width: 110,
                      child: TextButton(
                        onPressed: () => Navigator.pop(dialogContext),
                        style: TextButton.styleFrom(
                          foregroundColor: isDarkMode ? Colors.white : colorScheme.primary,
                          backgroundColor: isDarkMode ? const Color(0xFF2A3A4E) : null,
                          textStyle: const TextStyle(fontWeight: FontWeight.w600),
                        ),
                        child: const Text('Cancelar'),
                      ),
                    ),
                    SizedBox(
                      width: 120,
                      child: ElevatedButton(
                        onPressed: () {
                          final value = int.tryParse(customController.text.trim());
                          if (value == null || value <= 0) {
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(
                                content: Text('Informe uma quantidade válida em ml'),
                                backgroundColor: AppColors.error,
                              ),
                            );
                            return;
                          }

                          Navigator.pop(dialogContext);
                          _addHydration(value);
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(
                              content: Text('Adicionado ${value}ml à hidratação do dia'),
                              backgroundColor: AppColors.success,
                            ),
                          );
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppColors.warning,
                          foregroundColor: AppColors.onPrimary,
                          padding: const EdgeInsets.symmetric(
                            horizontal: 18,
                            vertical: 12,
                          ),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(14),
                          ),
                          textStyle: const TextStyle(fontWeight: FontWeight.bold),
                        ),
                        child: const Text('Adicionar'),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        );
      },
    );
  }
  // Constrói um chip de ação rápida para registrar a quantidade de água consumida pelo usuário.
  Widget _quickHydrationChip(BuildContext dialogContext, String label, int amountMl) {
    final isDarkMode = Theme.of(dialogContext).brightness == Brightness.dark;
    final chipBackground = isDarkMode
        ? const Color(0xFF25344A)
        : AppColors.primary.withAlpha((0.08 * 255).round());
    final chipForeground = isDarkMode ? Colors.white : AppColors.primary;
    final chipBorder = isDarkMode
        ? Colors.white.withAlpha((0.12 * 255).round())
        : AppColors.primary.withAlpha((0.16 * 255).round());

    return ActionChip(
      label: Text(label),
      backgroundColor: chipBackground,
      labelStyle: TextStyle(
        color: chipForeground,
        fontWeight: FontWeight.w600,
      ),
      side: BorderSide(color: chipBorder),
      onPressed: () {
        Navigator.of(dialogContext).pop();
        _addHydration(amountMl);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Adicionado ${amountMl}ml à hidratação do dia'),
            backgroundColor: AppColors.success,
          ),
        );
      },
    );
  }
  // Constrói o cartão de boas-vindas exibindo o progresso do usuário nas tarefas do dia.
  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final hydrationValueLabel =
        '${(_hydrationMl / 1000).toStringAsFixed(_hydrationMl % 1000 == 0 ? 0 : 1)}L / ${(_hydrationGoalMl / 1000).toStringAsFixed(0)}L';
    final peso = widget.usuario.peso;
    final altura = widget.usuario.altura;
    final bool temImc = peso != null && altura != null && altura > 0;
    final double? imc = temImc ? peso / (altura * altura) : null;
    final String imcValue = imc != null ? imc.toStringAsFixed(1) : '--';
    String imcCategory = 'Sem dados';

    if (imc != null) {
      if (imc < 18.5) {
        imcCategory = 'Abaixo do peso';
      } else if (imc < 25) {
        imcCategory = 'Peso normal';
      } else if (imc < 30) {
        imcCategory = 'Sobrepeso';
      } else {
        imcCategory = 'Obesidade';
      }
    }
    // Constrói a interface principal da tela Home, exibindo estatísticas, ações rápidas e cartões de progresso.
    return SingleChildScrollView(
      padding: EdgeInsets.fromLTRB(
        16,
        16,
        16,
        16 + MediaQuery.of(context).padding.bottom + kBottomNavigationBarHeight,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildWelcomeCard(context),
          const SizedBox(height: 16),
          Text(
            'Suas Estatísticas',
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: colorScheme.onSurface,
            ),
          ),
          const SizedBox(height: 15),
          GridView.count(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            crossAxisCount: 2,
            crossAxisSpacing: 12,
            mainAxisSpacing: 12,
            children: [
              FutureBuilder<int>(
                future: _pontosFuture,
                builder: (context, snapshot) {
                  final pontos = snapshot.data ?? 0;
                  return _buildStatCard(
                    context,
                    'Pontos',
                    pontos.toString(),
                    Icons.star,
                    AppColors.reward,
                    () async {
                      await Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => const DesafiosPage(),
                        ),
                      );
                      _refreshPontuacao();
                    },
                  );
                },
              ),
              // Constrói o cartão de hidratação exibindo a quantidade de água consumida pelo usuário.
              _buildStatCard(
                context,
                'Hidratação',
                hydrationValueLabel,
                Icons.water_drop,
                AppColors.info,
                () => _showHydrationDialog(context),
              ),
              // Constrói o cartão de tarefas exibindo o progresso do usuário em relação a essa meta.
              ValueListenableBuilder<List<Map<String, dynamic>>>(
                valueListenable: tarefasNotifier,
                builder: (context, tarefas, _) {
                  final int concluidas = tarefas
                      .where((t) => t['concluida'] == true)
                      .length;
                  final int total = tarefas.length;
                  final String value = '$concluidas/$total';

                  return _buildStatCard(
                    context,
                    'Tarefas',
                    value,
                    Icons.check_circle,
                    AppColors.success,
                    () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => Scaffold(
                            appBar: AppBar(
                              title: Text('Cronograma do Dia', style: TextStyle(color: AppColors.onSurface)),
                            ),
                            body: const CronogramaPage(),
                          ),
                        ),
                      );
                    },
                  );
                },
              ),
              // Constrói o cartão de dias intensivos exibindo o progresso do usuário em relação a essa meta.
              _buildStatCard(
                context,
                'Dias Intensivos',
                '$_diasIntensivosCount/$_diasIntensivosMeta',
                Icons.local_fire_department,
                AppColors.error,
                () async {
                  await Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => const DiasIntensivosPage(),
                    ),
                  );
                  await _loadDiasIntensivosCountAndMeta();
                },
              ),
            ],
          ),
          const SizedBox(height: 25),
          Text(
            'Ações Rápidas',
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: colorScheme.onSurface,
            ),
          ),
          const SizedBox(height: 15),
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: colorScheme.surface,
              borderRadius: BorderRadius.circular(15),
              boxShadow: [
                BoxShadow(
                  color: AppColors.onSurface.withAlpha((0.22 * 255).round()),
                  blurRadius: 10,
                  offset: const Offset(0, 2),
                ),
              ],
              border: Border.all(
                color: AppColors.primary.withAlpha((0.14 * 255).round()),
              ),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Container(
                      width: 52,
                      height: 52,
                      decoration: BoxDecoration(
                        color: AppColors.primary.withAlpha(
                          (0.18 * 255).round(),
                        ),
                        shape: BoxShape.circle,
                      ),
                      child: Icon(
                        Icons.fitness_center,
                        color: AppColors.primary,
                        size: 30,
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'IMC',
                            style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                              color: colorScheme.onSurface,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            imcValue == '--'
                                ? 'Adicione peso e altura no perfil.'
                                : 'IMC: $imcValue • $imcCategory',
                            style: TextStyle(
                              fontSize: 13,
                              color: colorScheme.onSurface.withAlpha(
                                (0.75 * 255).round(),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 14),
                SizedBox(
                  width: double.infinity,
                  height: 44,
                  child: ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.transparent,
                      foregroundColor: AppColors.warning,
                      side: BorderSide(color: AppColors.warning, width: 1.3),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    onPressed: () {
                      // Instead of pushing a new HomePage onto the stack (which
                      // can create duplicated internal keys), request the
                      // parent to switch the selected index.
                      if (widget.onNavigate != null) {
                        widget.onNavigate!(4);
                      } else {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => HomePage(
                              usuario: widget.usuario,
                              initialIndex: 4,
                            ),
                          ),
                        );
                      }
                    },
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(Icons.person, color: AppColors.onPrimary),
                        const SizedBox(width: 8),
                        Text(
                          'Ir para Perfil',
                          style: TextStyle(
                            color: AppColors.onPrimary,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 15),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.warning,
                foregroundColor: AppColors.onPrimary,
                padding: const EdgeInsets.symmetric(vertical: 12),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => const DesafiosPage()),
                );
              },
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.emoji_events, color: AppColors.onPrimary),
                  const SizedBox(width: 8),
                  Text(
                    'Ver Desafios Semanais',
                    style: TextStyle(
                      color: AppColors.onPrimary,
                      fontWeight: FontWeight.bold,
                      fontSize: 16,
                    ),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 15),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.primary,
                foregroundColor: AppColors.onPrimary,
                padding: const EdgeInsets.symmetric(vertical: 12),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              onPressed: () {
                Navigator.pushNamed(context, '/tutoriais');
              },
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.menu_book_rounded, color: AppColors.onPrimary),
                  const SizedBox(width: 8),
                  Text(
                    'Abrir Tutoriais',
                    style: TextStyle(
                      color: AppColors.onPrimary,
                      fontWeight: FontWeight.bold,
                      fontSize: 16,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  // Constrói o cartão de boas-vindas exibindo o progresso do usuário nas tarefas do dia.
  Widget _buildWelcomeCard(BuildContext context) {
    final onPrimary = AppColors.onPrimary;

    return ValueListenableBuilder<List<Map<String, dynamic>>>(
      valueListenable: tarefasNotifier,
      builder: (context, tarefas, _) {
        final int concluidas =
            tarefas.where((t) => t['concluida'] == true).length;
        final int total = tarefas.length;
        final double percent = total == 0 ? 0 : concluidas / total;
        final int percentInt = (percent * 100).round();

        return Container(
          width: double.infinity,
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [AppColors.primary, AppColors.secondary],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
            borderRadius: BorderRadius.circular(14),
            boxShadow: [
              BoxShadow(
                color: AppColors.onSurface.withAlpha((0.22 * 255).round()),
                blurRadius: 12,
                offset: const Offset(0, 3),
              ),
            ],
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Bem-vindo!',
                style: TextStyle(
                  color: onPrimary,
                  fontWeight: FontWeight.w800,
                  fontSize: 20,
                ),
              ),
              const SizedBox(height: 6),
              Text(
                'Você está progredindo muito bem!',
                style: TextStyle(
                  color: onPrimary.withAlpha((0.95 * 255).round()),
                  fontSize: 13,
                ),
              ),
              const SizedBox(height: 12),
              ClipRRect(
                borderRadius: BorderRadius.circular(8),
                child: LinearProgressIndicator(
                  value: percent,
                  minHeight: 8,
                  backgroundColor: onPrimary.withAlpha((0.18 * 255).round()),
                  valueColor: AlwaysStoppedAnimation<Color>(
                      AppColors.onPrimary.withAlpha((0.95 * 255).round())),
                ),
              ),
              const SizedBox(height: 8),
              Text(
                '$percentInt% das tarefas do dia concluídas',
                style: TextStyle(
                  color: onPrimary.withAlpha((0.95 * 255).round()),
                  fontSize: 12,
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  // Constrói um cartão de estatísticas exibindo informações como pontos, hidratação, tarefas e dias intensivos.
  Widget _buildStatCard(
    BuildContext context,
    String title,
    String value,
    IconData icon,
    Color color,
    VoidCallback onTap,
  ) {
    final colorScheme = Theme.of(context).colorScheme;

    return GestureDetector(
      onTap: onTap,
      child: Container(
        decoration: BoxDecoration(
          color: colorScheme.surface,
          borderRadius: BorderRadius.circular(15),
          boxShadow: [
            BoxShadow(
              color: AppColors.onSurface.withAlpha((0.22 * 255).round()),
              blurRadius: 10,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        padding: const EdgeInsets.all(15),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              width: 50,
              height: 50,
              decoration: BoxDecoration(
                color: color.withAlpha((0.2 * 255).round()),
                shape: BoxShape.circle,
              ),
              child: Icon(icon, color: color, size: 28),
            ),
            const SizedBox(height: 10),
            Text(
              value,
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: colorScheme.onSurface,
              ),
            ),
            const SizedBox(height: 5),
            Text(
              title,
              style: TextStyle(
                fontSize: 12,
                color: colorScheme.onSurface.withAlpha((0.7 * 255).round()),
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }
}
