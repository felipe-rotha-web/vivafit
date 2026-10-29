import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../theme.dart';

// Notifier global com a lista de tarefas do cronograma. A UI escuta esse notifier e se atualiza automaticamente.
final ValueNotifier<List<Map<String, dynamic>>> tarefasNotifier =
    ValueNotifier<List<Map<String, dynamic>>>([
  {
    'titulo': 'Academia - Treino de Perna',
    'hora': '07:00',
    'concluida': false,
    'icon': Icons.fitness_center,
    'colorKey': 'warning',
  },
  {
    'titulo': 'Café da manhã saudável',
    'hora': '08:45',
    'concluida': true,
    'icon': Icons.restaurant,
    'colorKey': 'success',
  },
  {
    'titulo': 'Meditação matinal',
    'hora': '09:30',
    'concluida': false,
    'icon': Icons.self_improvement,
    'colorKey': 'success',
  },
  {
    'titulo': 'Reunião de trabalho',
    'hora': '10:00',
    'concluida': false,
    'icon': Icons.work,
    'colorKey': 'warning',
  },
  {
    'titulo': 'Almoço leve',
    'hora': '12:30',
    'concluida': false,
    'icon': Icons.restaurant,
    'colorKey': 'warning',
  },
  {
    'titulo': 'Caminhada pós-almoço',
    'hora': '13:30',
    'concluida': false,
    'icon': Icons.directions_walk,
    'colorKey': 'success',
  },
  {
    'titulo': 'Sessão de estudos',
    'hora': '15:00',
    'concluida': false,
    'icon': Icons.book,
    'colorKey': 'warning',
  },
  {
    'titulo': 'Lanche saudável',
    'hora': '17:00',
    'concluida': false,
    'icon': Icons.local_cafe,
    'colorKey': 'success',
  },
  {
    'titulo': 'Jantar em família',
    'hora': '19:30',
    'concluida': false,
    'icon': Icons.restaurant,
    'colorKey': 'warning',
  },
  {
    'titulo': 'Leitura antes de dormir',
    'hora': '21:30',
    'concluida': false,
    'icon': Icons.menu_book,
    'colorKey': 'success',
  },
]);

class CronogramaPage extends StatefulWidget {
  const CronogramaPage({super.key});

  // Compatibilidade: API pública usada em testes antigos.
  static List<Map<String, dynamic>> ordenarTarefas(List<Map<String, dynamic>> tarefas) =>
      _CronogramaPageState._ordenarTarefas(tarefas);

  @override
  State<CronogramaPage> createState() => _CronogramaPageState();
}

class _CronogramaPageState extends State<CronogramaPage> {
  static const String _prefsKey = 'cronograma_tarefas_v1';

  final TextEditingController _novoTituloController = TextEditingController();
  final TextEditingController _novoHoraController = TextEditingController();

  final List<IconData> _iconOptions = const [
    Icons.fitness_center,
    Icons.restaurant,
    Icons.self_improvement,
    Icons.work,
    Icons.directions_walk,
    Icons.water_drop,
    Icons.check_circle_outline,
    Icons.local_cafe,
    Icons.home,
    Icons.book,
  ];

  final Map<IconData, String> _defaultColors = {
    Icons.fitness_center: 'warning',
    Icons.restaurant: 'success',
    Icons.self_improvement: 'success',
    Icons.work: 'warning',
    Icons.directions_walk: 'warning',
    Icons.water_drop: 'success',
    Icons.check_circle_outline: 'success',
    Icons.local_cafe: 'warning',
    Icons.home: 'success',
    Icons.book: 'warning',
  };

  @override
  void initState() {
    super.initState();
    _loadTarefas();
  }

  @override
  void dispose() {
    _novoTituloController.dispose();
    _novoHoraController.dispose();
    super.dispose();
  }

  static int _horaParaMinutos(String? hora) {
    if (hora == null || hora.isEmpty) return 24 * 60;
    final match = RegExp(r'(\d{1,2})\s*:?\s*(\d{2})').firstMatch(hora);
    if (match == null) return 24 * 60;
    final h = int.tryParse(match.group(1) ?? '0') ?? 0;
    final m = int.tryParse(match.group(2) ?? '0') ?? 0;
    return h * 60 + m;
  }

  static List<Map<String, dynamic>> _ordenarTarefas(List<Map<String, dynamic>> t) {
    final copia = List<Map<String, dynamic>>.from(t);
    copia.sort((a, b) => _horaParaMinutos(a['hora'] as String?)
        .compareTo(_horaParaMinutos(b['hora'] as String?)));
    return copia;
  }

  Color _colorFromKey(String? key) {
    switch (key) {
      case 'warning':
        return AppColors.warning;
      case 'secondary':
      case 'primary':
      case 'info':
      case 'reward':
        return AppColors.warning;
      case 'success':
        return AppColors.success;
      default:
        return AppColors.warning;
    }
  }

  Map<String, dynamic> _serializeTarefa(Map<String, dynamic> tarefa) {
    final icon = tarefa['icon'] as IconData?;
    final colorKey = tarefa['colorKey'] as String?;
    final color = tarefa['color'] as Color?;

    return {
      'titulo': tarefa['titulo'] ?? '',
      'hora': tarefa['hora'] ?? '',
      'concluida': tarefa['concluida'] == true,
      'iconCodePoint': icon?.codePoint ?? Icons.check_circle_outline.codePoint,
      'colorKey': colorKey,
      'colorValue': color?.toARGB32() ?? AppColors.warning.toARGB32(),
    };
  }

  String? _keyFromColorValue(int? v) {
    return switch (v) {
      null => null,
      _ when v == AppColors.primary.toARGB32() => 'primary',
      _ when v == AppColors.secondary.toARGB32() => 'secondary',
      _ when v == AppColors.warning.toARGB32() => 'warning',
      _ when v == AppColors.success.toARGB32() => 'success',
      _ when v == AppColors.info.toARGB32() => 'info',
      _ when v == AppColors.reward.toARGB32() => 'reward',
      _ => null,
    };
  }

  Map<String, dynamic> _deserializeTarefa(Map<String, dynamic> json) {
    final iconCode = json['iconCodePoint'] as int?;
    final colorValue = json['colorValue'] as int?;
    final colorKey = (json['colorKey'] as String?) ?? _keyFromColorValue(colorValue);

    return {
      'titulo': json['titulo']?.toString() ?? '',
      'hora': json['hora']?.toString() ?? '',
      'concluida': json['concluida'] == true,
      'icon': IconData(iconCode ?? Icons.check_circle_outline.codePoint,
          fontFamily: 'MaterialIcons'),
      'colorKey': colorKey,
      'color': colorKey != null
          ? _colorFromKey(colorKey)
          : Color(colorValue ?? AppColors.primary.toARGB32()),
    };
  }

  Future<void> _saveTarefas() async {
    final prefs = await SharedPreferences.getInstance();
    final jsonStr = jsonEncode(tarefasNotifier.value.map(_serializeTarefa).toList());
    await prefs.setString(_prefsKey, jsonStr);
  }

  Future<void> _loadTarefas() async {
    final prefs = await SharedPreferences.getInstance();
    final str = prefs.getString(_prefsKey);
    if (str == null || str.isEmpty) return;
    try {
      final decoded = jsonDecode(str) as List<dynamic>;
      final list = decoded
          .map((e) => _deserializeTarefa(Map<String, dynamic>.from(e as Map)))
          .toList();
      tarefasNotifier.value = _ordenarTarefas(list);
    } catch (_) {
      // ignore and keep defaults
    }
  }

  void _mostrarDialogAdicionar({int? editIndex}) {
    showDialog<void>(
      context: context,
      builder: (context) {
        final isDarkMode = Theme.of(context).brightness == Brightness.dark;
        final onSurface = Theme.of(context).colorScheme.onSurface;
        final dialogBackground = isDarkMode ? const Color(0xFF1A2333) : Theme.of(context).dialogTheme.backgroundColor ?? Theme.of(context).cardColor;

        int selectedIconIndex = 6;
        String selectedColorKey = _defaultColors[_iconOptions[selectedIconIndex]] ?? 'primary';
        Color selectedColor = _colorFromKey(selectedColorKey);
        TimeOfDay selectedTime = const TimeOfDay(hour: 8, minute: 0);

        if (editIndex != null && editIndex >= 0 && editIndex < tarefasNotifier.value.length) {
          final tarefa = tarefasNotifier.value[editIndex];
          _novoTituloController.text = tarefa['titulo'] ?? '';
          _novoHoraController.text = tarefa['hora'] ?? '';
          final ic = tarefa['icon'] as IconData?;
          selectedIconIndex = ic != null ? _iconOptions.indexOf(ic) : selectedIconIndex;
          selectedIconIndex = selectedIconIndex < 0 ? 6 : selectedIconIndex;
          selectedColorKey = tarefa['colorKey'] as String? ?? selectedColorKey;
          selectedColor = _colorFromKey(selectedColorKey);
          final horaStr = tarefa['hora'] as String? ?? '';
          final match = RegExp(r"(\d{1,2})\s*:?\s*(\d{2})").firstMatch(horaStr);
          if (match != null) {
            final h = int.tryParse(match.group(1) ?? '0') ?? 8;
            final m = int.tryParse(match.group(2) ?? '0') ?? 0;
            selectedTime = TimeOfDay(hour: h, minute: m);
          }
        } else {
          _novoTituloController.clear();
          _novoHoraController.clear();
        }

        return StatefulBuilder(builder: (context, setState) {
          final textFieldBorder = OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: BorderSide(color: onSurface.withAlpha((0.26 * 255).round())),
          );

          InputDecoration dialogDecoration(String hint) => InputDecoration(
                hintText: hint,
                labelText: hint,
                labelStyle: TextStyle(color: onSurface.withAlpha((0.75 * 255).round())),
                hintStyle: TextStyle(color: onSurface.withAlpha((0.6 * 255).round())),
                filled: true,
                fillColor: onSurface.withAlpha((0.05 * 255).round()),
                border: textFieldBorder,
                enabledBorder: textFieldBorder,
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide(color: Theme.of(context).colorScheme.primary, width: 2),
                ),
                contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 14),
              );

          return AlertDialog(
            backgroundColor: dialogBackground,
            surfaceTintColor: Colors.transparent,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
            titleTextStyle: TextStyle(color: onSurface, fontWeight: FontWeight.w700, fontSize: 20),
            contentTextStyle: TextStyle(color: onSurface),
            title: Text(editIndex != null ? 'Editar Tarefa' : 'Adicionar Tarefa', style: TextStyle(color: onSurface, fontWeight: FontWeight.w700)),
            content: SingleChildScrollView(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  TextField(
                    controller: _novoTituloController,
                    decoration: dialogDecoration('Título'),
                    style: TextStyle(color: onSurface),
                    cursorColor: Theme.of(context).colorScheme.primary,
                  ),
                  const SizedBox(height: 12),
                  Row(children: [
                    Expanded(child: Text('Horário: ${selectedTime.format(context)}', style: TextStyle(color: onSurface))),
                    TextButton(
                      style: TextButton.styleFrom(
                        foregroundColor: AppColors.warning,
                        backgroundColor: Colors.transparent,
                        side: BorderSide(color: AppColors.warning, width: 1.2),
                        minimumSize: const Size(110, 42),
                        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                      ),
                      onPressed: () async {
                        final picked = await showTimePicker(
                          context: context,
                          initialTime: selectedTime,
                          builder: (context, child) {
                            return Theme(
                              data: Theme.of(context).copyWith(
                                timePickerTheme: TimePickerThemeData(
                                  backgroundColor: dialogBackground,
                                  hourMinuteTextStyle: TextStyle(
                                    color: onSurface,
                                    fontSize: 32,
                                    fontWeight: FontWeight.w700,
                                  ),
                                  dayPeriodTextStyle: TextStyle(
                                    color: onSurface,
                                    fontSize: 16,
                                    fontWeight: FontWeight.w600,
                                  ),
                                  dialTextColor: onSurface,
                                  dialBackgroundColor: onSurface.withAlpha((0.04 * 255).round()),
                                  hourMinuteColor: onSurface.withAlpha((0.06 * 255).round()),
                                  helpTextStyle: TextStyle(
                                    color: onSurface,
                                    fontWeight: FontWeight.w700,
                                  ),
                                  inputDecorationTheme: InputDecorationTheme(
                                    filled: true,
                                    fillColor: onSurface.withAlpha((0.05 * 255).round()),
                                    labelStyle: TextStyle(color: onSurface),
                                    hintStyle: TextStyle(color: onSurface.withAlpha((0.7 * 255).round())),
                                  ),
                                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(18)),
                                ),
                                textButtonTheme: TextButtonThemeData(
                                  style: TextButton.styleFrom(
                                    foregroundColor: AppColors.warning,
                                    backgroundColor: Colors.transparent,
                                    side: BorderSide(color: AppColors.warning, width: 1.2),
                                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                                  ),
                                ),
                              ),
                              child: child!,
                            );
                          },
                        );
                        if (picked != null) setState(() => selectedTime = picked);
                      },
                      child: const Text('Alterar'),
                    )
                  ]),
                  const SizedBox(height: 12),
                  Align(alignment: Alignment.centerLeft, child: Text('Ícone', style: TextStyle(color: onSurface))),
                  const SizedBox(height: 8),
                  Wrap(spacing: 8, runSpacing: 8, children: List.generate(_iconOptions.length, (i) {
                    final ic = _iconOptions[i];
                    final selected = i == selectedIconIndex;
                    return ChoiceChip(
                      label: Icon(ic, color: selected ? AppColors.onSurface : onSurface.withAlpha((0.9 * 255).round())),
                      selected: selected,
                      selectedColor: selectedColor.withAlpha((0.16 * 255).round()),
                      backgroundColor: onSurface.withAlpha((0.04 * 255).round()),
                      onSelected: (_) => setState(() {
                        selectedIconIndex = i;
                        selectedColorKey = _defaultColors[ic] ?? 'warning';
                        selectedColor = _colorFromKey(selectedColorKey);
                      }),
                    );
                  })),
                  const SizedBox(height: 12),
                  Align(alignment: Alignment.centerLeft, child: Text('Cor', style: TextStyle(color: onSurface))),
                  const SizedBox(height: 8),
                  Row(children: [
                    for (final k in ['warning', 'success'])
                      Padding(padding: const EdgeInsets.only(right: 12), child: GestureDetector(
                        onTap: () => setState(() {
                          selectedColorKey = k;
                          selectedColor = _colorFromKey(k);
                        }),
                        child: Container(width: 40, height: 40, decoration: BoxDecoration(color: _colorFromKey(k), borderRadius: BorderRadius.circular(8), border: Border.all(color: selectedColor == _colorFromKey(k) ? _colorFromKey(k).withAlpha((0.9 * 255).round()) : AppColors.onSurface.withAlpha(0), width: 2))),
                      ))
                  ]),
                ],
              ),
            ),
            actions: [
              TextButton(
                style: TextButton.styleFrom(
                  foregroundColor: AppColors.warning,
                  backgroundColor: Colors.transparent,
                  side: BorderSide(color: AppColors.warning, width: 1.2),
                  minimumSize: const Size(120, 46),
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                ),
                onPressed: () {
                  _novoTituloController.clear();
                  _novoHoraController.clear();
                  Navigator.of(context).pop();
                },
                child: const Text('Cancelar'),
              ),
              ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.transparent,
                  foregroundColor: AppColors.success,
                  side: BorderSide(color: AppColors.success, width: 1.2),
                  minimumSize: const Size(120, 46),
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                ),
                onPressed: () {
                  final titulo = _novoTituloController.text.trim();
                  final hora = '${selectedTime.hour.toString().padLeft(2, '0')}:${selectedTime.minute.toString().padLeft(2, '0')}';
                  if (titulo.isEmpty) {
                    ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Preencha título')));
                    return;
                  }

                  final newTask = {
                    'titulo': titulo,
                    'hora': hora,
                    'concluida': false,
                    'icon': _iconOptions[selectedIconIndex],
                    'colorKey': selectedColorKey,
                  };

                  if (editIndex != null) {
                    final updated = List<Map<String, dynamic>>.from(tarefasNotifier.value);
                    updated[editIndex] = newTask;
                    tarefasNotifier.value = _ordenarTarefas(updated);
                  } else {
                    tarefasNotifier.value = _ordenarTarefas([newTask, ...tarefasNotifier.value]);
                  }
                  _saveTarefas();
                  _novoTituloController.clear();
                  _novoHoraController.clear();
                  Navigator.of(context).pop();
                  ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(editIndex != null ? 'Tarefa atualizada' : 'Tarefa adicionada')));
                },
                child: const Text('Salvar'),
              ),
            ],
          );
        });
      },
    );
  }

  Future<void> _mostrarDialogExcluir(int index) async {
    final tarefa = tarefasNotifier.value[index];
    final confirmado = await showDialog<bool>(context: context, builder: (c) {
      return AlertDialog(
        title: const Text('Excluir tarefa?'),
        content: Text('Tem certeza que deseja excluir a tarefa "${tarefa['titulo']}"?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(c).pop(false),
            style: TextButton.styleFrom(
              foregroundColor: AppColors.warning,
              backgroundColor: Colors.transparent,
              side: BorderSide(color: AppColors.warning, width: 1.2),
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
            ),
            child: const Text('Não'),
          ),
          TextButton(
            onPressed: () => Navigator.of(c).pop(true),
            style: TextButton.styleFrom(
              foregroundColor: AppColors.error,
              backgroundColor: Colors.transparent,
              side: BorderSide(color: AppColors.error, width: 1.2),
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
            ),
            child: const Text('Sim'),
          ),
        ],
      );
    });

    if (confirmado == true) {
      final updated = List<Map<String, dynamic>>.from(tarefasNotifier.value)..removeAt(index);
      tarefasNotifier.value = updated;
      await _saveTarefas();
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Tarefa excluída')));
    }
  }

  Widget _buildTarefaCard(Map<String, dynamic> tarefa, int index) {
    final isDarkMode = Theme.of(context).brightness == Brightness.dark;
    final baseColor = tarefa.containsKey('colorKey')
        ? _colorFromKey(tarefa['colorKey'] as String?)
        : (tarefa['color'] as Color?) ?? AppColors.primary;

    final bgColor = tarefa['concluida'] == true ? AppColors.success.withAlpha((0.2 * 255).round()) : baseColor.withAlpha((0.12 * 255).round());
    final iconColor = tarefa['concluida'] == true ? AppColors.success : baseColor;
    final actionIconColor = isDarkMode ? Colors.white : AppColors.onSurface;
    final checkboxBorderColor = isDarkMode ? Colors.white : AppColors.onSurface.withAlpha((0.6 * 255).round());

    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Material(
        color: Theme.of(context).cardColor,
        elevation: 1,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12), side: BorderSide(color: tarefa['concluida'] == true ? AppColors.success.withAlpha((0.24 * 255).round()) : AppColors.onSurface.withAlpha(0), width: 1)),
        child: ListTile(
          contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          leading: Container(
            width: 45,
            height: 45,
            decoration: BoxDecoration(color: bgColor, shape: BoxShape.circle),
            child: Icon(tarefa['icon'] as IconData? ?? Icons.check_circle_outline, color: iconColor),
          ),
          title: Text(tarefa['titulo'] ?? '', style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600, decoration: tarefa['concluida'] == true ? TextDecoration.lineThrough : null, color: tarefa['concluida'] == true ? Theme.of(context).disabledColor : AppColors.onSurface)),
          subtitle: Text(tarefa['hora'] ?? '', style: TextStyle(fontSize: 12, color: AppColors.onSurface.withAlpha((0.65 * 255).round()))),
          trailing: Row(mainAxisSize: MainAxisSize.min, children: [
            Checkbox(
              value: tarefa['concluida'] == true,
              activeColor: AppColors.success,
              checkColor: Colors.white,
              side: BorderSide(color: checkboxBorderColor, width: 1.8),
              onChanged: (v) {
                final updated = List<Map<String, dynamic>>.from(tarefasNotifier.value);
                final item = Map<String, dynamic>.from(updated[index]);
                item['concluida'] = v == true;
                updated[index] = item;
                tarefasNotifier.value = updated;
                _saveTarefas();
              },
            ),
            PopupMenuButton<String>(
              icon: Icon(Icons.more_vert, color: actionIconColor),
              onSelected: (v) {
                if (v == 'edit') _mostrarDialogAdicionar(editIndex: index);
                if (v == 'delete') _mostrarDialogExcluir(index);
              },
              itemBuilder: (c) => [
                PopupMenuItem(value: 'edit', child: Text('Editar', style: TextStyle(color: AppColors.onSurface))),
                PopupMenuItem(value: 'delete', child: Text('Excluir', style: TextStyle(color: AppColors.onSurface))),
              ],
            ),
          ]),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder<AppThemeMode>(
      valueListenable: AppThemeController.mode,
      builder: (context, mode, _) {
        return ValueListenableBuilder<DaltonismVariant>(
          valueListenable: AppThemeController.daltonismVariant,
          builder: (context, variant, _) {
            return ValueListenableBuilder<List<Map<String, dynamic>>>(
              valueListenable: tarefasNotifier,
              builder: (context, tarefas, _) {
                final concluidas = tarefas.where((t) => t['concluida'] == true).length;
                final total = tarefas.length;
                final progresso = total > 0 ? concluidas / total : 0.0;

                return SingleChildScrollView(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Cronograma do Dia',
                        style: TextStyle(
                          fontSize: 24,
                          fontWeight: FontWeight.bold,
                          color: Theme.of(context).colorScheme.onSurface,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        'Acompanhe suas atividades diárias',
                        style: TextStyle(
                          fontSize: 14,
                          color: AppColors.onSurface.withAlpha((0.7 * 255).round()),
                        ),
                      ),
                      const SizedBox(height: 20),
                      Material(
                        color: AppColors.primary,
                        elevation: 8,
                        shadowColor: AppColors.primary.withAlpha((0.24 * 255).round()),
                        borderRadius: BorderRadius.circular(20),
                        child: InkWell(
                          borderRadius: BorderRadius.circular(20),
                          onTap: _mostrarDialogAdicionar,
                          child: Container(
                            width: double.infinity,
                            padding: const EdgeInsets.all(18),
                            decoration: BoxDecoration(
                              gradient: LinearGradient(
                                colors: [AppColors.primary, AppColors.secondary],
                                begin: Alignment.topLeft,
                                end: Alignment.bottomRight,
                              ),
                              borderRadius: BorderRadius.circular(20),
                            ),
                            child: Row(
                              children: [
                                Container(
                                  width: 48,
                                  height: 48,
                                  decoration: BoxDecoration(
                                    color: AppColors.onPrimary.withAlpha((0.14 * 255).round()),
                                    shape: BoxShape.circle,
                                  ),
                                  child: Icon(Icons.add_task_rounded, color: AppColors.onPrimary),
                                ),
                                const SizedBox(width: 14),
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    mainAxisSize: MainAxisSize.min,
                                    children: [
                                      Text(
                                        'Adicionar Tarefa',
                                        style: TextStyle(
                                          color: AppColors.onPrimary,
                                          fontSize: 18,
                                          fontWeight: FontWeight.w700,
                                        ),
                                      ),
                                      const SizedBox(height: 4),
                                      Text(
                                        'Toque para criar um compromisso no cronograma.',
                                        style: TextStyle(
                                          color: AppColors.onPrimary.withAlpha((0.78 * 255).round()),
                                          fontSize: 13,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                                Icon(
                                  Icons.chevron_right_rounded,
                                  color: AppColors.onPrimary.withAlpha((0.82 * 255).round()),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(height: 20),
                      Container(
                        width: double.infinity,
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          color: AppColors.primary,
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Progresso de Hoje',
                              style: TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                                color: AppColors.onPrimary,
                              ),
                            ),
                            const SizedBox(height: 10),
                            ClipRRect(
                              borderRadius: BorderRadius.circular(8),
                              child: LinearProgressIndicator(
                                value: progresso,
                                minHeight: 10,
                                backgroundColor: AppColors.onPrimary.withAlpha((0.3 * 255).round()),
                                valueColor: AlwaysStoppedAnimation<Color>(AppColors.onPrimary),
                              ),
                            ),
                            const SizedBox(height: 8),
                            Text(
                              '$concluidas de $total tarefas concluídas (${(progresso * 100).round()}%)',
                              style: TextStyle(
                                fontSize: 12,
                                color: AppColors.onPrimary.withAlpha((0.7 * 255).round()),
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 20),
                      ListView.builder(
                        shrinkWrap: true,
                        physics: const NeverScrollableScrollPhysics(),
                        itemCount: tarefas.length,
                        itemBuilder: (c, i) => _buildTarefaCard(tarefas[i], i),
                      ),
                    ],
                  ),
                );
              },
            );
          },
        );
      },
    );
  }
}
