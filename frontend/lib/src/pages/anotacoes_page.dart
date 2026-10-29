
import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../theme.dart';

// Classe AnotacoesPage representa um componente ou widget da interface.
class AnotacoesPage extends StatefulWidget {
  const AnotacoesPage({super.key});

  @override
  State<AnotacoesPage> createState() => _AnotacoesPageState();
}

// Classe _AnotacoesPageState representa um componente ou widget da interface.
class _AnotacoesPageState extends State<AnotacoesPage> {
  final TextEditingController _tituloController = TextEditingController();
  final TextEditingController _conteudoController = TextEditingController();

  // Notifier global que mantém as anotações do usuário e permite atualizar a tela automaticamente.
  static final ValueNotifier<List<Map<String, String>>>
  anotacoesNotifier = ValueNotifier<List<Map<String, String>>>([
    {
      'titulo': 'Treino de Perna - Dicas',
      'conteudo':
          'Fazer aquecimento de 10 minutos antes do treino\nLembrança: aumentar peso gradually',
      'data': '17 de abr',
    },
    {
      'titulo': 'Refeição Pós Treino',
      'conteudo':
          'Ingerir proteína nos primeiros 30 minutos\nAcompanhamento de carboidrato importante',
      'data': '16 de abr',
    },
    {
      'titulo': 'Meta de Hidratação',
      'conteudo': 'Beber 3L de água por dia\nDistribuir ao longo do dia',
      'data': '15 de abr',
    },
  ]);

  static const String _prefsKey = 'anotacoes_v1';

  @override
  void dispose() {
    _tituloController.dispose();
    _conteudoController.dispose();
    super.dispose();
  }

  @override
  void initState() {
    super.initState();
    _loadAnotacoes();
  }

  // Cria uma nova anotação, salva na lista observável e persiste no armazenamento local.
  void _adicionarAnotacao() {
    if (_tituloController.text.isEmpty || _conteudoController.text.isEmpty) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('Preencha todos os campos')));
      return;
    }

    final newNote = {
      'titulo': _tituloController.text,
      'conteudo': _conteudoController.text,
      'data': 'Agora',
    };

    // Atualiza notifier e persiste
    anotacoesNotifier.value = [newNote, ...anotacoesNotifier.value];
    _saveAnotacoes();

    _tituloController.clear();
    _conteudoController.clear();
    Navigator.pop(context);

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Anotação adicionada com sucesso!'),
        backgroundColor: AppColors.success,
      ),
    );
  }

  void _mostrarDialogAdicionar() {
    showDialog(
      context: context,
      builder: (context) {
        final theme = Theme.of(context);
        final colorScheme = theme.colorScheme;
        final dialogBackground =
            theme.dialogTheme.backgroundColor ?? colorScheme.surface;
        final onSurface = colorScheme.onSurface;
        final hintColor = onSurface.withAlpha((0.58 * 255).round());
        final fieldFill = onSurface.withAlpha((0.05 * 255).round());

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
                'Nova Anotação',
                style: TextStyle(
                  color: onSurface,
                  fontWeight: FontWeight.w700,
                  fontSize: 22,
                ),
              ),
              const SizedBox(height: 6),
              Text(
                'Registre uma ideia, dica ou observação rápida.',
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
                TextField(
                  controller: _conteudoController,
                  maxLines: 5,
                  cursorColor: colorScheme.primary,
                  style: TextStyle(color: onSurface),
                  decoration: dialogDecoration('Conteúdo'),
                ),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () {
                _tituloController.clear();
                _conteudoController.clear();
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
              onPressed: _adicionarAnotacao,
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
              child: Text('Adicionar'),
            ),
          ],
        );
      },
    );
  }

  // Persistência: salvar e carregar anotações
  // Salva a lista de anotações em JSON no armazenamento local para manter o histórico.
  Future<void> _saveAnotacoes() async {
    final prefs = await SharedPreferences.getInstance();
    final jsonStr = jsonEncode(anotacoesNotifier.value);
    await prefs.setString(_prefsKey, jsonStr);
  }

  // Carrega anotações salvas anteriormente e reconstrói a lista de notas quando a página abre.
  Future<void> _loadAnotacoes() async {
    final prefs = await SharedPreferences.getInstance();
    final str = prefs.getString(_prefsKey);
    if (str != null && str.isNotEmpty) {
      try {
        final List<dynamic> decoded = jsonDecode(str);
        final List<Map<String, String>> loaded = decoded
            .map<Map<String, String>>((e) {
              return Map<String, String>.from(e as Map);
            })
            .toList();
        anotacoesNotifier.value = loaded;
      } catch (_) {
        // ignore parse errors, keep defaults
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
            'Anotações',
            style: TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.bold,
              color: colorScheme.primary,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Anote suas atividades e observações',
            style: TextStyle(
              fontSize: 14,
              color: colorScheme.onSurface.withAlpha((0.7 * 255).round()),
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
                        color: colorScheme.onPrimary.withAlpha(
                          (0.14 * 255).round(),
                        ),
                        shape: BoxShape.circle,
                      ),
                      child: Icon(
                        Icons.add_comment_rounded,
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
                            'Nova Anotação',
                            style: TextStyle(
                              color: colorScheme.onPrimary,
                              fontSize: 18,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            'Toque para criar um registro rápido.',
                            style: TextStyle(
                              color: colorScheme.onPrimary.withAlpha(
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
                      color: colorScheme.onPrimary.withAlpha(
                        (0.82 * 255).round(),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
          const SizedBox(height: 20),
          // Lista de Anotações (reativa)
          ValueListenableBuilder<List<Map<String, String>>>(
            valueListenable: anotacoesNotifier,
            builder: (context, anotacoes, _) {
              return ListView.builder(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                itemCount: anotacoes.length,
                itemBuilder: (context, index) {
                  final anotacao = anotacoes[index];
                  return _buildAnotacaoCard(context, anotacao, index);
                },
              );
            },
          ),
        ],
      ),
    );
  }

  Widget _buildAnotacaoCard(
    BuildContext context,
    Map<String, String> anotacao,
    int index,
  ) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: GestureDetector(
        onLongPress: () {
          final dialogBackground =
              theme.dialogTheme.backgroundColor ?? colorScheme.surface;
          final onSurface = colorScheme.onSurface;
          final hintColor = onSurface.withAlpha((0.66 * 255).round());

          showDialog(
            context: context,
            builder: (context) => AlertDialog(
              backgroundColor: dialogBackground,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(24),
              ),
              title: Text(
                'Excluir anotação?',
                style: TextStyle(color: onSurface, fontWeight: FontWeight.w700),
              ),
              content: Text(
                'Tem certeza que deseja excluir?',
                style: TextStyle(color: hintColor),
              ),
              actions: [
                TextButton(
                  onPressed: () => Navigator.pop(context),
                  style: TextButton.styleFrom(
                    foregroundColor: AppColors.warning,
                    backgroundColor: Colors.transparent,
                    side: BorderSide(color: AppColors.warning, width: 1.2),
                    minimumSize: const Size(120, 46),
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                  ),
                  child: Text('Cancelar'),
                ),
                TextButton(
                  onPressed: () {
                    final updated = List<Map<String, String>>.from(
                      anotacoesNotifier.value,
                    );
                    updated.removeAt(index);
                    anotacoesNotifier.value = updated;
                    _saveAnotacoes();
                    Navigator.pop(context);
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text('Anotação removida')),
                    );
                  },
                  style: TextButton.styleFrom(
                    foregroundColor: AppColors.error,
                    backgroundColor: Colors.transparent,
                    side: BorderSide(color: AppColors.error, width: 1.2),
                    minimumSize: const Size(120, 46),
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                  ),
                  child: Text('Excluir'),
                ),
              ],
            ),
          );
        },
        child: Material(
          color: colorScheme.surface,
          elevation: 3,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
            side: BorderSide(
              color: colorScheme.primary.withAlpha((0.08 * 255).round()),
              width: 1,
            ),
          ),
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Expanded(
                      child: Text(
                        anotacao['titulo']!,
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w700,
                          color: colorScheme.primary,
                        ),
                      ),
                    ),
                    Text(
                      anotacao['data']!,
                      style: TextStyle(
                        fontSize: 12,
                        color: colorScheme.onSurface.withAlpha(
                          (0.7 * 255).round(),
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                Text(
                  anotacao['conteudo']!,
                  style: TextStyle(
                    fontSize: 14,
                    color: colorScheme.onSurface,
                    height: 1.5,
                  ),
                ),
                const SizedBox(height: 12),
                Text(
                  'Pressione e segure para excluir',
                  style: TextStyle(
                    fontSize: 11,
                    color: colorScheme.onSurface.withAlpha(
                      (0.66 * 255).round(),
                    ),
                    fontStyle: FontStyle.italic,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
