
import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../theme.dart';

// Classe LembretesPage representa um componente ou widget da interface.
class LembretesPage extends StatefulWidget {
  const LembretesPage({super.key});

  static int _horaParaMinutos(dynamic valor) {
    if (valor == null) {
      return 24 * 60;
    }

    final texto = valor.toString().trim();
    if (texto.isEmpty) {
      return 24 * 60;
    }

    final match = RegExp(r'(\d{1,2})\s*:\s*(\d{2})').firstMatch(texto);
    if (match == null) {
      return 24 * 60;
    }

    final horas = int.tryParse(match.group(1) ?? '0') ?? 0;
    final minutos = int.tryParse(match.group(2) ?? '0') ?? 0;
    return (horas * 60) + minutos;
  }

  static List<Map<String, dynamic>> ordenarLembretes(
    List<Map<String, dynamic>> lembretes,
  ) {
    final lista = List<Map<String, dynamic>>.from(lembretes);
    lista.sort((a, b) {
      final aHora = _horaParaMinutos(a['hora']);
      final bHora = _horaParaMinutos(b['hora']);
      if (aHora == bHora) {
        return 0;
      }
      return aHora.compareTo(bHora);
    });
    return lista;
  }

  @override
  State<LembretesPage> createState() => _LembretesPageState();
}

// Classe _LembretesPageState representa um componente ou widget da interface.
class _LembretesPageState extends State<LembretesPage> {
  final TextEditingController _tituloController = TextEditingController();
  final TextEditingController _horaController = TextEditingController();

  // Notifier global que mantém a lista de lembretes para atualizar a UI dinamicamente.
  static final ValueNotifier<List<Map<String, dynamic>>>
  lembretesNotifier = ValueNotifier<List<Map<String, dynamic>>>([
    {'titulo': 'Tomar remédio', 'hora': '08:00', 'ativo': true, 'diario': true},
    {
      'titulo': 'Exercício matinal',
      'hora': '07:00',
      'ativo': true,
      'diario': true,
    },
    {'titulo': 'Beber água', 'hora': '12:00', 'ativo': true, 'diario': true},
    {'titulo': 'Meditação', 'hora': '18:00', 'ativo': false, 'diario': false},
  ]);

  static const String _prefsKey = 'lembretes_v1';

  @override
  void initState() {
    super.initState();
    _loadLembretes();
  }

  @override
  void dispose() {
    _tituloController.dispose();
    _horaController.dispose();
    super.dispose();
  }

  // Processa a criação ou edição de um lembrete, salva a lista atualizada.
  void _adicionarLembrete({required bool diario, int? editIndex}) {
    final titulo = _tituloController.text.trim();
    final hora = _horaController.text.trim();

    if (titulo.isEmpty || hora.isEmpty) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('Preencha título e hora')));
      return;
    }

    final novoLembrete = {
      'titulo': titulo,
      'hora': hora,
      'ativo': true,
      'diario': diario,
    };

    if (editIndex != null) {
      final updated = List<Map<String, dynamic>>.from(lembretesNotifier.value);
      updated[editIndex] = novoLembrete;
      lembretesNotifier.value = LembretesPage.ordenarLembretes(updated);
    } else {
      final lembretesAtualizados = LembretesPage.ordenarLembretes([
        novoLembrete,
        ...lembretesNotifier.value,
      ]);
      lembretesNotifier.value = lembretesAtualizados;
    }

    _saveLembretes();

    _tituloController.clear();
    _horaController.clear();
    Navigator.pop(context);

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(editIndex != null ? 'Lembrete atualizado' : 'Lembrete adicionado com sucesso!'),
        backgroundColor: AppColors.success,
      ),
    );
  }

  Future<void> _mostrarDialogExcluir(int index) async {
    final lembrete = lembretesNotifier.value[index];
    final bool? confirmado = await showDialog<bool>(
      context: context,
      builder: (context) {
        return AlertDialog(
          backgroundColor: Theme.of(context).dialogTheme.backgroundColor ?? Theme.of(context).colorScheme.surface,
          title: Text(
            'Excluir lembrete?',
            style: TextStyle(color: AppColors.onSurface),
          ),
          content: Text(
            'Tem certeza que deseja excluir o lembrete "${lembrete['titulo']}"?',
            style: TextStyle(color: AppColors.onSurface.withAlpha((0.8 * 255).round())),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context, false),
              style: TextButton.styleFrom(
                foregroundColor: AppColors.onPrimary,
                backgroundColor: AppColors.warning,
                minimumSize: const Size(110, 42),
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
              ),
              child: Text('Não'),
            ),
            TextButton(
              onPressed: () => Navigator.pop(context, true),
              style: TextButton.styleFrom(
                foregroundColor: AppColors.onPrimary,
                backgroundColor: AppColors.error,
                minimumSize: const Size(110, 42),
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
              ),
              child: Text('Sim'),
            ),
          ],
        );
      },
    );

    if (confirmado != true) {
      return;
    }

    final updated = List<Map<String, dynamic>>.from(lembretesNotifier.value)
      ..removeAt(index);
    lembretesNotifier.value = updated;
    await _saveLembretes();

    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Lembrete excluído')),
    );
  }

  void _mostrarDialogAdicionar({int? editIndex}) {
    final isEdit = editIndex != null;

    showDialog<void>(
      context: context,
      builder: (context) {
        final theme = Theme.of(context);
        final colorScheme = theme.colorScheme;
        final dialogBackground =
          theme.dialogTheme.backgroundColor ?? colorScheme.surface;
        final onSurface = colorScheme.onSurface;
        final hintColor = onSurface.withAlpha((0.58 * 255).round());
        final fieldFill = onSurface.withAlpha((0.05 * 255).round());
        bool diario = true;
        TimeOfDay selectedTime = const TimeOfDay(hour: 8, minute: 0);

        if (editIndex != null && editIndex >= 0 && editIndex < lembretesNotifier.value.length) {
          final lemb = lembretesNotifier.value[editIndex];
          _tituloController.text = lemb['titulo'] ?? '';
          _horaController.text = lemb['hora'] ?? '';
          diario = lemb['diario'] == true;
          final match = RegExp(r"(\d{1,2})\s*:\s*(\d{2})").firstMatch(lemb['hora'] ?? '');
          if (match != null) {
            final h = int.tryParse(match.group(1) ?? '0') ?? 8;
            final m = int.tryParse(match.group(2) ?? '0') ?? 0;
            selectedTime = TimeOfDay(hour: h, minute: m);
          }
        }

        InputDecoration dialogDecoration(String hint) {
          return InputDecoration(
            hintText: hint,
            hintStyle: TextStyle(color: hintColor),
            filled: true,
            fillColor: fieldFill,
            border: OutlineInputBorder(borderRadius: BorderRadius.circular(16)),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(16),
              borderSide: BorderSide(
                color: colorScheme.primary.withAlpha((0.14 * 255).round()),
              ),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(16),
              borderSide: BorderSide(color: colorScheme.primary, width: 2),
            ),
          );
        }

        return StatefulBuilder(
          builder: (context, setDialogState) {
            return AlertDialog(
              backgroundColor: dialogBackground,
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
                    isEdit ? 'Editar lembrete' : 'Novo Lembrete',
                    style: TextStyle(
                      color: onSurface,
                      fontWeight: FontWeight.w700,
                      fontSize: 22,
                    ),
                  ),
                  const SizedBox(height: 6),
                  Text(
                    isEdit
                        ? 'Atualize o lembrete e seu horário.'
                        : 'Crie uma notificação rápida com horário definido.',
                    style: TextStyle(fontSize: 13, color: hintColor),
                  ),
                ],
              ),
              content: SingleChildScrollView(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    TextField(
                      controller: _tituloController,
                      autofocus: true,
                      cursorColor: colorScheme.primary,
                      style: TextStyle(color: onSurface),
                      decoration: dialogDecoration('Título'),
                    ),
                    const SizedBox(height: 12),
                    // Time picker instead of free-text hora field
                    Row(
                      children: [
                        Expanded(
                          child: Text(
                            'Horário: ${selectedTime.format(context)}',
                            style: TextStyle(color: onSurface),
                          ),
                        ),
                        TextButton(
                          onPressed: () async {
                            final picked = await showTimePicker(
                              context: context,
                              initialTime: selectedTime,
                            );
                            if (picked != null) setDialogState(() => selectedTime = picked);
                          },
                          style: TextButton.styleFrom(
                            foregroundColor: AppColors.warning,
                            backgroundColor: Colors.transparent,
                            side: BorderSide(color: AppColors.warning, width: 1.2),
                            minimumSize: const Size(110, 42),
                            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(10),
                            ),
                          ),
                          child: Text('Alterar'),
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),
                    SwitchListTile.adaptive(
                      contentPadding: EdgeInsets.zero,
                      value: diario,
                      activeThumbColor: AppColors.warning,
                      title: Text(
                        'Lembrete diário',
                        style: TextStyle(color: onSurface),
                      ),
                      subtitle: Text(
                        diario
                            ? 'Repete todos os dias'
                            : 'Acontece apenas uma vez',
                        style: TextStyle(color: hintColor),
                      ),
                      onChanged: (value) {
                        setDialogState(() {
                          diario = value;
                        });
                      },
                    ),
                  ],
                ),
              ),
              actions: [
                TextButton(
                  onPressed: () {
                    _tituloController.clear();
                    _horaController.clear();
                    Navigator.pop(context);
                  },
                  style: TextButton.styleFrom(
                    foregroundColor: AppColors.warning,
                    backgroundColor: Colors.transparent,
                    side: BorderSide(color: AppColors.warning, width: 1.2),
                    minimumSize: const Size(120, 46),
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                    textStyle: const TextStyle(fontWeight: FontWeight.w600),
                  ),
                  child: Text('Cancelar'),
                ),
                ElevatedButton(
                  onPressed: () {
                    _horaController.text = '${selectedTime.hour.toString().padLeft(2, '0')}:${selectedTime.minute.toString().padLeft(2, '0')}';
                    _adicionarLembrete(diario: diario, editIndex: editIndex);
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.transparent,
                    foregroundColor: AppColors.success,
                    side: BorderSide(color: AppColors.success, width: 1.2),
                    minimumSize: const Size(120, 46),
                    padding: const EdgeInsets.symmetric(
                      horizontal: 16,
                      vertical: 12,
                    ),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                    textStyle: const TextStyle(fontWeight: FontWeight.bold),
                  ),
                  child: Text(isEdit ? 'Salvar alterações' : 'Adicionar'),
                ),
              ],
            );
          },
        );
      },
    );
  }

  // Persiste lembretes como JSON no armazenamento local do dispositivo.
  Future<void> _saveLembretes() async {
    final prefs = await SharedPreferences.getInstance();
    final jsonStr = jsonEncode(lembretesNotifier.value);
    await prefs.setString(_prefsKey, jsonStr);
  }

  // Carrega lembretes salvos para exibir mesmo após o app ser fechado e reaberto.
  Future<void> _loadLembretes() async {
    final prefs = await SharedPreferences.getInstance();
    final str = prefs.getString(_prefsKey);
    if (str != null && str.isNotEmpty) {
      try {
        final List<dynamic> decoded = jsonDecode(str);
        final List<Map<String, dynamic>> loaded = decoded
            .map<Map<String, dynamic>>((e) {
              return Map<String, dynamic>.from(e as Map);
            })
            .toList();
        lembretesNotifier.value = LembretesPage.ordenarLembretes(loaded);
      } catch (_) {
        // mantém a lista padrão se a leitura falhar
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Lembretes',
            style: TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.bold,
              color: AppColors.onSurface,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Receba notificações sobre suas tarefas',
            style: TextStyle(
              fontSize: 14,
              color: colorScheme.onSurface.withAlpha((0.7 * 255).round()),
            ),
          ),
          const SizedBox(height: 20),
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: colorScheme.primary.withAlpha((0.08 * 255).round()),
              borderRadius: BorderRadius.circular(16),
              border: Border.all(
                color: colorScheme.primary.withAlpha((0.16 * 255).round()),
              ),
            ),
            child: Row(
              children: [
                Icon(Icons.info, color: AppColors.warning),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(
                    'Ative os lembretes para receber notificações sobre suas tarefas',
                    style: TextStyle(
                      fontSize: 13,
                      color: colorScheme.onSurface,
                    ),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 20),
          Material(
            color: colorScheme.primary,
            elevation: 8,
            shadowColor: colorScheme.primary.withAlpha((0.24 * 255).round()),
            borderRadius: BorderRadius.circular(20),
            child: InkWell(
              borderRadius: BorderRadius.circular(20),
              onTap: _mostrarDialogAdicionar,
              child: Container(
                width: double.infinity,
                padding: const EdgeInsets.all(18),
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [colorScheme.primary, colorScheme.secondary],
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
                        color: AppColors.onSurface.withAlpha(
                          (0.14 * 255).round(),
                        ),
                        shape: BoxShape.circle,
                      ),
                      child: Icon(
                        Icons.notifications_active_outlined,
                        color: colorScheme.onPrimary,
                      ),
                    ),
                    const SizedBox(width: 14),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Text(
                            'Novo Lembrete',
                            style: TextStyle(
                              color: AppColors.onPrimary,
                              fontSize: 18,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            'Toque para criar uma notificação.',
                            style: TextStyle(
                              color: AppColors.onPrimary.withAlpha(
                                (0.78 * 255).round(),
                              ),
                              fontSize: 13,
                            ),
                          ),
                        ],
                      ),
                    ),
                    Icon(
                      Icons.chevron_right_rounded,
                      color: AppColors.onPrimary.withAlpha(
                        (0.82 * 255).round(),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
          const SizedBox(height: 20),
          ValueListenableBuilder<List<Map<String, dynamic>>>(
            valueListenable: lembretesNotifier,
            builder: (context, lembretes, _) {
              return ListView.builder(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                itemCount: lembretes.length,
                itemBuilder: (context, index) {
                  final lembrete = lembretes[index];
                  return _buildLembreteCard(context, lembrete, index);
                },
              );
            },
          ),
        ],
      ),
    );
  }

  Widget _buildLembreteCard(
    BuildContext context,
    Map<String, dynamic> lembrete,
    int index,
  ) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Container(
        decoration: BoxDecoration(
          color: colorScheme.surface,
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: AppColors.onSurface.withAlpha((0.20 * 255).round()),
              blurRadius: 6,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        padding: const EdgeInsets.all(16),
        child: Row(
          children: [
            Container(
              width: 50,
              height: 50,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: AppColors.warning.withAlpha((0.18 * 255).round()),
              ),
              child: Icon(Icons.notifications, color: AppColors.onPrimary),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    lembrete['titulo'],
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: AppColors.onSurface,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Row(
                    children: [
                      Icon(
                        Icons.access_time,
                        size: 14,
                        color: colorScheme.onSurface.withAlpha((0.7 * 255).round()),
                      ),
                      const SizedBox(width: 4),
                      Text(
                        lembrete['hora'],
                        style: TextStyle(
                          fontSize: 12,
                          color: colorScheme.onSurface.withAlpha((0.7 * 255).round()),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 8,
                          vertical: 2,
                        ),
                        decoration: BoxDecoration(
                          color: lembrete['diario']
                              ? AppColors.success.withAlpha((0.2 * 255).round())
                              : AppColors.onSurface.withAlpha((0.2 * 255).round()),
                          borderRadius: BorderRadius.circular(4),
                        ),
                        child: Text(
                          lembrete['diario'] ? 'Diário' : 'Única',
                            style: TextStyle(
                              fontSize: 10,
                              color: lembrete['diario']
                                  ? AppColors.success
                                  : colorScheme.onSurface.withAlpha((0.7 * 255).round()),
                              fontWeight: FontWeight.bold,
                            ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Switch(
                  value: lembrete['ativo'],
                  activeThumbColor: AppColors.success,
                  onChanged: (value) {
                    final updated = List<Map<String, dynamic>>.from(
                      lembretesNotifier.value,
                    );
                    updated[index] = {...updated[index], 'ativo': value};
                    lembretesNotifier.value = updated;
                    _saveLembretes();
                    setState(() {});
                  },
                ),
                PopupMenuButton<String>(
                  onSelected: (v) {
                    if (v == 'edit') {
                      _mostrarDialogAdicionar(editIndex: index);
                    } else if (v == 'delete') {
                      _mostrarDialogExcluir(index);
                    }
                  },
                  itemBuilder: (context) => [
                    PopupMenuItem(value: 'edit', child: Text('Editar', style: TextStyle(color: Theme.of(context).colorScheme.onSurface))),
                    PopupMenuItem(value: 'delete', child: Text('Excluir', style: TextStyle(color: Theme.of(context).colorScheme.onSurface))),
                  ],
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
