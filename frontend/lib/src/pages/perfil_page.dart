import 'dart:convert';

import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import '../theme.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../data/auth_service.dart';
import '../models/app_user.dart';
import 'desafios_page.dart';

// Classe PerfilPage representa um componente ou widget da interface.
class PerfilPage extends StatefulWidget {
  const PerfilPage({super.key, required this.usuario});

  final AppUser usuario;

  @override
  State<PerfilPage> createState() => _PerfilPageState();
}

// Classe _PerfilPageState representa um componente ou widget da interface.
class _PerfilPageState extends State<PerfilPage> {
  late String _nome;
  late String _email;
  late String _genero;
  late int _idade;
  late String _nivelAtividade;
  String? _fotoPerfilBase64;

  double? _peso;
  double? _altura;

  final List<String> _generos = ['Masculino', 'Feminino', 'Outro'];
  final List<String> _niveis = [
    'Sedentário',
    'Leve',
    'Moderado',
    'Intenso',
    'Muito Intenso',
  ];

  double? get _imc {
    if (_peso == null || _altura == null || _altura == 0) {
      return null;
    }

    return _peso! / (_altura! * _altura!);
  }

  @override
  void initState() {
    super.initState();
    _nome = widget.usuario.nome;
    _email = widget.usuario.email;
    _genero = widget.usuario.genero;
    _idade = widget.usuario.idade;
    _nivelAtividade = widget.usuario.nivelAtividade;
    _peso = widget.usuario.peso;
    _altura = widget.usuario.altura;
    _loadSettings();
  }

  // User preferences (persisted locally)
  bool _compartilharDados = true;
  bool _analytics = true;

  bool _notificacoesAtivas = true;
  bool _lembretesDiarios = true;
  TimeOfDay _horarioLembrete = const TimeOfDay(hour: 8, minute: 0);

  static const String _prefsCompartilhar = 'pref_compartilhar';
  static const String _prefsAnalytics = 'pref_analytics';
  static const String _prefsNotificacoes = 'pref_notificacoes';
  static const String _prefsLembretesDiarios = 'pref_lembretes_diarios';
  static const String _prefsHorarioLembrete = 'pref_horario_lembrete';
  static const String _prefsFotoPerfilBase64 = 'pref_foto_perfil_base64';

  Future<int> _carregarPontuacaoTotal() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getInt(DesafiosPage.pontosTotalKey) ??
        DesafiosPage.pontosDefault;
  }

  Future<void> _loadSettings() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      _compartilharDados = prefs.getBool(_prefsCompartilhar) ?? true;
      _analytics = prefs.getBool(_prefsAnalytics) ?? true;
      _notificacoesAtivas = prefs.getBool(_prefsNotificacoes) ?? true;
      _lembretesDiarios = prefs.getBool(_prefsLembretesDiarios) ?? true;
      final horario = prefs.getString(_prefsHorarioLembrete);
      if (horario != null && horario.contains(':')) {
        final parts = horario.split(':');
        final h = int.tryParse(parts[0]) ?? 8;
        final m = int.tryParse(parts[1]) ?? 0;
        _horarioLembrete = TimeOfDay(hour: h, minute: m);
      }
      _fotoPerfilBase64 = prefs.getString(_prefsFotoPerfilBase64);
    });
  }

  Future<void> _saveSettings() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_prefsCompartilhar, _compartilharDados);
    await prefs.setBool(_prefsAnalytics, _analytics);
    await prefs.setBool(_prefsNotificacoes, _notificacoesAtivas);
    await prefs.setBool(_prefsLembretesDiarios, _lembretesDiarios);
    await prefs.setString(
      _prefsHorarioLembrete,
      '${_horarioLembrete.hour.toString().padLeft(2, '0')}:${_horarioLembrete.minute.toString().padLeft(2, '0')}',
    );
  }

  Future<void> _escolherFotoPerfil() async {
    final file = await FilePicker.pickFile(type: FileType.image);

    if (file == null) {
      return;
    }

    final bytes = await file.readAsBytes();

    final base64Value = base64Encode(bytes);
    final prefs = await SharedPreferences.getInstance();
    if (!mounted) {
      return;
    }

    setState(() {
      _fotoPerfilBase64 = base64Value;
    });

    await prefs.setString(_prefsFotoPerfilBase64, base64Value);
  }

  Widget _buildAvatar(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final photoBytes = _fotoPerfilBase64 == null
        ? null
        : (() {
            try {
              return base64Decode(_fotoPerfilBase64!);
            } catch (_) {
              return null;
            }
          })();

    return Container(
      width: 120,
      height: 120,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: colorScheme.primary,
      ),
      child: ClipOval(
        child: photoBytes != null
            ? Image.memory(
                photoBytes,
                width: 120,
                height: 120,
                fit: BoxFit.cover,
                gaplessPlayback: true,
              )
            : Icon(Icons.person, size: 60, color: colorScheme.onPrimary),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final isDarkMode = Theme.of(context).brightness == Brightness.dark;

    return ValueListenableBuilder<AppThemeMode>(
      valueListenable: AppThemeController.mode,
      builder: (context, mode, _) {
        return ValueListenableBuilder<DaltonismVariant>(
          valueListenable: AppThemeController.daltonismVariant,
          builder: (context, variant, _) {
            return SingleChildScrollView(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Header do Perfil
                  Center(
                    child: Column(
                      children: [
                        _buildAvatar(context),
                        const SizedBox(height: 12),
                        TextButton.icon(
                          onPressed: _escolherFotoPerfil,
                          icon: const Icon(Icons.photo_library_outlined),
                          label: const Text('Escolher foto do arquivo'),
                        ),
                        const SizedBox(height: 12),
                        Text(
                          _nome,
                          style: TextStyle(
                            fontSize: 24,
                            fontWeight: FontWeight.bold,
                            color: colorScheme.onSurface,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          _email,
                          style: TextStyle(
                            fontSize: 14,
                            color: colorScheme.onSurface.withAlpha(
                              (0.7 * 255).round(),
                            ),
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          'Nível: $_nivelAtividade',
                          style: TextStyle(
                            fontSize: 14,
                            color: colorScheme.onSurface.withAlpha(
                              (0.7 * 255).round(),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 16),
                  FutureBuilder<int>(
                    future: _carregarPontuacaoTotal(),
                    builder: (context, snapshot) {
                      final pontos = snapshot.data ?? 0;
                      return Container(
                        width: double.infinity,
                        padding: const EdgeInsets.all(14),
                        decoration: BoxDecoration(
                          gradient: LinearGradient(
                            colors: [
                              AppColors.rewardForMode,
                              AppColors.primary,
                            ],
                            begin: Alignment.centerLeft,
                            end: Alignment.centerRight,
                          ),
                          borderRadius: BorderRadius.circular(14),
                        ),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Row(
                              children: [
                                Icon(
                                  Icons.emoji_events,
                                  color: AppColors.onPrimary,
                                ),
                                const SizedBox(width: 10),
                                Text(
                                  'Pontuação total',
                                  style: TextStyle(
                                    color: AppColors.onPrimary,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ],
                            ),
                            Text(
                              pontos.toString(),
                              style: TextStyle(
                                color: AppColors.onPrimary,
                                fontWeight: FontWeight.bold,
                                fontSize: 18,
                              ),
                            ),
                          ],
                        ),
                      );
                    },
                  ),
                  const SizedBox(height: 25),
                  // Informações Pessoais
                  Text(
                    'Informações Pessoais',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: colorScheme.onSurface,
                    ),
                  ),
                  const SizedBox(height: 15),
                  _buildInfoCard('Gênero', _genero, Icons.wc),
                  _buildInfoCard('Idade', '$_idade anos', Icons.calendar_today),
                  _buildInfoCard(
                    'Nível de Atividade',
                    _nivelAtividade,
                    Icons.fitness_center,
                  ),
                  const SizedBox(height: 25),
                  // Informações de Saúde
                  Text(
                    'Informações de Saúde',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: colorScheme.onSurface,
                    ),
                  ),
                  const SizedBox(height: 15),
                  Container(
                    decoration: BoxDecoration(
                      color: isDarkMode
                          ? const Color(0xFF1D2A3A)
                          : AppColors.surface,
                      borderRadius: BorderRadius.circular(12),
                      boxShadow: [
                        BoxShadow(
                          color: isDarkMode
                              ? Colors.black.withAlpha((0.24 * 255).round())
                              : AppColors.primary.withAlpha(
                                  (0.18 * 255).round(),
                                ),
                          blurRadius: 6,
                          offset: const Offset(0, 2),
                        ),
                      ],
                    ),
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Dados Corporais e IMC',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                            color: colorScheme.onSurface,
                          ),
                        ),
                        const SizedBox(height: 15),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceAround,
                          children: [
                            Column(
                              children: [
                                Text(
                                  _peso == null
                                      ? '--'
                                      : '${_peso!.toStringAsFixed(1)} kg',
                                  style: TextStyle(
                                    fontSize: 20,
                                    fontWeight: FontWeight.bold,
                                    color: AppColors.warning,
                                  ),
                                ),
                                Text(
                                  'Peso Atual',
                                  style: TextStyle(
                                    fontSize: 12,
                                    color: colorScheme.onSurface.withAlpha(
                                      (0.7 * 255).round(),
                                    ),
                                  ),
                                ),
                              ],
                            ),
                            Column(
                              children: [
                                Text(
                                  _altura == null
                                      ? '--'
                                      : '${(_altura! * 100).toStringAsFixed(0)} cm',
                                  style: TextStyle(
                                    fontSize: 20,
                                    fontWeight: FontWeight.bold,
                                    color: AppColors.success,
                                  ),
                                ),
                                Text(
                                  'Altura',
                                  style: TextStyle(
                                    fontSize: 12,
                                    color: colorScheme.onSurface.withAlpha(
                                      (0.7 * 255).round(),
                                    ),
                                  ),
                                ),
                              ],
                            ),
                            Column(
                              children: [
                                Text(
                                  _imc == null
                                      ? '--'
                                      : _imc!.toStringAsFixed(1),
                                  style: TextStyle(
                                    fontSize: 20,
                                    fontWeight: FontWeight.bold,
                                    color: AppColors.warning,
                                  ),
                                ),
                                Text(
                                  'IMC',
                                  style: TextStyle(
                                    fontSize: 12,
                                    color: colorScheme.onSurface.withAlpha(
                                      (0.7 * 255).round(),
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                        const SizedBox(height: 20),
                        SizedBox(
                          width: double.infinity,
                          height: 45,
                          child: ElevatedButton(
                            style: ElevatedButton.styleFrom(
                              backgroundColor: AppColors.primary,
                              foregroundColor: AppColors.onPrimary,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(10),
                              ),
                            ),
                            onPressed: () {
                              _mostrarCalculadoraImc();
                            },
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Icon(
                                  Icons.calculate,
                                  color: AppColors.onPrimary,
                                ),
                                const SizedBox(width: 8),
                                Text(
                                  'Calcular IMC',
                                  style: TextStyle(
                                    color: AppColors.onPrimary,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                        const SizedBox(height: 12),
                        // Resultado do IMC no card (número + nível) similar à Home
                        if (_imc != null)
                          Container(
                            width: double.infinity,
                            padding: const EdgeInsets.all(12),
                            decoration: BoxDecoration(
                              color: AppColors.warning.withAlpha(
                                (0.12 * 255).round(),
                              ),
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      'IMC: ${double.parse(_imc!.toStringAsFixed(1))}',
                                      style: TextStyle(
                                        fontWeight: FontWeight.bold,
                                        color: AppColors.warningForMode,
                                        fontSize: 16,
                                      ),
                                    ),
                                    const SizedBox(height: 4),
                                    Text(
                                      (_imc! < 18.5)
                                          ? 'Abaixo do peso'
                                          : (_imc! < 25)
                                          ? 'Peso normal'
                                          : (_imc! < 30)
                                          ? 'Sobrepeso'
                                          : 'Obesidade',
                                      style: TextStyle(
                                        color: colorScheme.onSurface,
                                      ),
                                    ),
                                  ],
                                ),
                              ],
                            ),
                          ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 25),
                  // Seção de Configurações
                  Text(
                    'Configurações',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: colorScheme.onSurface,
                    ),
                  ),
                  const SizedBox(height: 15),
                  _buildSettingItem('Editar Perfil', Icons.edit, () {
                    _mostrarDialogoEditarPerfil();
                  }),
                  _buildSettingItem('Privacidade', Icons.security, () {
                    _mostrarDialogPrivacidade();
                  }),
                  _buildSettingItem('Notificações', Icons.notifications, () {
                    _mostrarDialogNotificacoes();
                  }),
                  _buildSettingItem('Sobre', Icons.info, () {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text('AppVivaFit v15.4')),
                    );
                  }),
                  const SizedBox(height: 20),
                  // Botão Sair
                  SizedBox(
                    width: double.infinity,
                    height: 50,
                    child: ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.error,
                        foregroundColor: AppColors.onPrimary,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                      onPressed: () {
                        _mostrarDialogoSair();
                      },
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(Icons.logout, color: AppColors.onPrimary),
                          const SizedBox(width: 8),
                          Text(
                            'Sair',
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
                  const SizedBox(height: 25),
                ],
              ),
            );
          },
        );
      },
    );
  }

  Widget _buildInfoCard(String titulo, String valor, IconData icon) {
    final isDarkMode = Theme.of(context).brightness == Brightness.dark;
    final colorScheme = Theme.of(context).colorScheme;

    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Container(
        decoration: BoxDecoration(
          color: isDarkMode ? const Color(0xFF1D2A3A) : AppColors.surface,
          borderRadius: BorderRadius.circular(12),
          boxShadow: [
            BoxShadow(
              color: isDarkMode
                  ? Colors.black.withAlpha((0.24 * 255).round())
                  : AppColors.primary.withAlpha((0.18 * 255).round()),
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
                color: isDarkMode
                    ? AppColors.primary.withAlpha((0.42 * 255).round())
                    : AppColors.primary.withAlpha((0.2 * 255).round()),
              ),
              child: Icon(
                icon,
                color: isDarkMode ? AppColors.onPrimary : AppColors.primary,
              ),
            ),
            const SizedBox(width: 16),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  titulo,
                  style: TextStyle(
                    fontSize: 12,
                    color: colorScheme.onSurface.withAlpha((0.7 * 255).round()),
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  valor,
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: colorScheme.onSurface,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSettingItem(String titulo, IconData icon, VoidCallback onTap) {
    final isDarkMode = Theme.of(context).brightness == Brightness.dark;
    final colorScheme = Theme.of(context).colorScheme;

    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: GestureDetector(
        onTap: onTap,
        child: Container(
          decoration: BoxDecoration(
            color: isDarkMode ? const Color(0xFF1D2A3A) : AppColors.surface,
            borderRadius: BorderRadius.circular(12),
            boxShadow: [
              BoxShadow(
                color: isDarkMode
                    ? Colors.black.withAlpha((0.24 * 255).round())
                    : AppColors.primary.withAlpha((0.18 * 255).round()),
                blurRadius: 6,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          padding: const EdgeInsets.all(16),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: [
                  Icon(
                    icon,
                    color: isDarkMode ? AppColors.onSurface : AppColors.primary,
                    size: 24,
                  ),
                  const SizedBox(width: 16),
                  Text(
                    titulo,
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w500,
                      color: colorScheme.onSurface,
                    ),
                  ),
                ],
              ),
              Icon(
                Icons.arrow_forward_ios,
                size: 16,
                color: colorScheme.onSurface.withAlpha((0.7 * 255).round()),
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _mostrarDialogoEditarPerfil() {
    final TextEditingController nomeController = TextEditingController(
      text: _nome,
    );
    final TextEditingController emailController = TextEditingController(
      text: _email,
    );
    final TextEditingController idadeController = TextEditingController(
      text: _idade.toString(),
    );

    String generoSelecionado = _genero;
    String nivelSelecionado = _nivelAtividade;

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

        InputDecoration formDecoration(String label) {
          return InputDecoration(
            labelText: label,
            labelStyle: TextStyle(color: hintColor),
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
                    'Editar Perfil',
                    style: TextStyle(
                      color: onSurface,
                      fontWeight: FontWeight.w700,
                      fontSize: 22,
                    ),
                  ),
                  const SizedBox(height: 6),
                  Text(
                    'Atualize seus dados pessoais e de atividade.',
                    style: TextStyle(fontSize: 13, color: hintColor),
                  ),
                ],
              ),
              content: SingleChildScrollView(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    TextField(
                      controller: nomeController,
                      autofocus: true,
                      cursorColor: colorScheme.primary,
                      style: TextStyle(color: onSurface),
                      decoration: formDecoration('Nome'),
                    ),
                    const SizedBox(height: 12),
                    TextField(
                      controller: emailController,
                      keyboardType: TextInputType.emailAddress,
                      cursorColor: colorScheme.primary,
                      style: TextStyle(color: onSurface),
                      decoration: formDecoration('Email'),
                    ),
                    const SizedBox(height: 12),
                    TextField(
                      controller: idadeController,
                      keyboardType: TextInputType.number,
                      cursorColor: colorScheme.primary,
                      style: TextStyle(color: onSurface),
                      decoration: formDecoration('Idade'),
                    ),
                    const SizedBox(height: 12),
                    DropdownButtonFormField<String>(
                      initialValue: generoSelecionado,
                      decoration: formDecoration('Gênero'),
                      dropdownColor: dialogBackground,
                      iconEnabledColor: colorScheme.primary,
                      items: _generos.map((String genero) {
                        return DropdownMenuItem<String>(
                          value: genero,
                          child: Text(genero),
                        );
                      }).toList(),
                      onChanged: (String? novoValor) {
                        if (novoValor == null) {
                          return;
                        }
                        setDialogState(() => generoSelecionado = novoValor);
                      },
                    ),
                    const SizedBox(height: 12),
                    DropdownButtonFormField<String>(
                      initialValue: nivelSelecionado,
                      decoration: formDecoration('Nível de atividade'),
                      dropdownColor: dialogBackground,
                      iconEnabledColor: colorScheme.primary,
                      items: _niveis.map((String nivel) {
                        return DropdownMenuItem<String>(
                          value: nivel,
                          child: Text(nivel),
                        );
                      }).toList(),
                      onChanged: (String? novoValor) {
                        if (novoValor == null) {
                          return;
                        }
                        setDialogState(() => nivelSelecionado = novoValor);
                      },
                    ),
                  ],
                ),
              ),
              actions: [
                TextButton(
                  onPressed: () => Navigator.pop(context),
                  style: TextButton.styleFrom(
                    foregroundColor: colorScheme.onSurface,
                    textStyle: const TextStyle(fontWeight: FontWeight.w600),
                  ),
                  child: Text(
                    'Cancelar',
                    style: TextStyle(color: colorScheme.onSurface),
                  ),
                ),
                ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.warning,
                    foregroundColor: colorScheme.onPrimary,
                    padding: const EdgeInsets.symmetric(
                      horizontal: 18,
                      vertical: 12,
                    ),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(14),
                    ),
                    textStyle: const TextStyle(fontWeight: FontWeight.bold),
                  ),
                  onPressed: () async {
                    final String novoNome = nomeController.text.trim();
                    final String novoEmail = emailController.text.trim();
                    final int? novaIdade = int.tryParse(
                      idadeController.text.trim(),
                    );

                    if (novoNome.isEmpty ||
                        !RegExp(
                          r'^[^@\s]+@[^@\s]+\.[^@\s]+$',
                        ).hasMatch(novoEmail) ||
                        novaIdade == null ||
                        novaIdade <= 0) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: Text(
                            'Preencha nome, email e idade válidos',
                            style: TextStyle(color: AppColors.onPrimary),
                          ),
                          backgroundColor: AppColors.error,
                        ),
                      );
                      return;
                    }

                    final navigator = Navigator.of(context);
                    final messenger = ScaffoldMessenger.of(context);

                    try {
                      await AuthService.updateProfile(
                        nome: novoNome,
                        email: novoEmail,
                      );

                      if (!mounted) {
                        return;
                      }

                      setState(() {
                        _nome = novoNome;
                        _email = novoEmail;
                        _idade = novaIdade;
                        _genero = generoSelecionado;
                        _nivelAtividade = nivelSelecionado;
                      });

                      navigator.pop();
                      messenger.showSnackBar(
                        SnackBar(
                          content: Text(
                            'Perfil atualizado com sucesso!',
                            style: TextStyle(color: AppColors.onPrimary),
                          ),
                          backgroundColor: AppColors.success,
                        ),
                      );
                    } catch (error) {
                      if (!mounted) {
                        return;
                      }
                      messenger.showSnackBar(
                        SnackBar(
                          content: Text('Falha ao atualizar perfil: $error'),
                          backgroundColor: AppColors.error,
                        ),
                      );
                    }
                  },
                  child: Text(
                    'Salvar',
                    style: TextStyle(color: AppColors.onPrimary),
                  ),
                ),
              ],
            );
          },
        );
      },
    );
  }

  void _mostrarCalculadoraImc() {
    final TextEditingController pesoController = TextEditingController(
      text: _peso != null ? _peso!.toStringAsFixed(1) : '',
    );
    final TextEditingController alturaController = TextEditingController(
      text: _altura != null ? (_altura! * 100).toStringAsFixed(0) : '',
    );

    showDialog(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setDialogState) {
          void calculate() {
            final double? peso = double.tryParse(
              pesoController.text.replaceAll(',', '.').trim(),
            );
            final double? alturaCm = double.tryParse(
              alturaController.text.replaceAll(',', '.').trim(),
            );

            if (peso == null ||
                peso <= 0 ||
                alturaCm == null ||
                alturaCm <= 0) {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text(
                    'Informe peso e altura válidos',
                    style: TextStyle(color: AppColors.onPrimary),
                  ),
                  backgroundColor: AppColors.error,
                ),
              );
              return;
            }

            final hm = alturaCm / 100.0;

            setDialogState(() {});

            setState(() {
              _peso = peso;
              _altura = hm;
            });

            AuthService.updateUsuario(
              AppUser(
                id: widget.usuario.id,
                nome: _nome,
                email: _email,
                senha: widget.usuario.senha,
                idade: _idade,
                genero: _genero,
                nivelAtividade: _nivelAtividade,
                peso: _peso,
                altura: _altura,
              ),
            );
          }

          void clearAll() {
            pesoController.clear();
            alturaController.clear();
            setDialogState(() {});
            setState(() {
              _peso = null;
              _altura = null;
            });
            AuthService.updateUsuario(
              AppUser(
                id: widget.usuario.id,
                nome: _nome,
                email: _email,
                senha: widget.usuario.senha,
                idade: _idade,
                genero: _genero,
                nivelAtividade: _nivelAtividade,
                peso: null,
                altura: null,
              ),
            );
          }

          // compute display IMC if available
          double? displayImc() {
            final double? pesoVal =
                double.tryParse(pesoController.text.replaceAll(',', '.')) ??
                _peso;
            final double? alturaCmVal =
                double.tryParse(alturaController.text.replaceAll(',', '.')) ??
                (_altura != null ? _altura! * 100.0 : null);
            if (pesoVal == null || alturaCmVal == null || alturaCmVal <= 0) {
              return null;
            }
            final hm = alturaCmVal / 100.0;
            return pesoVal / (hm * hm);
          }

          final dialogImc = displayImc();

          final isDarkMode = Theme.of(context).brightness == Brightness.dark;
          final dialogSurface = isDarkMode
              ? const Color(0xFF1D2A3A)
              : AppColors.surface;
          final dialogTextColor = Theme.of(context).colorScheme.onSurface;
          final dialogSubtleText = dialogTextColor.withAlpha(
            (0.72 * 255).round(),
          );

          return AlertDialog(
            backgroundColor: dialogSurface,
            title: Text(
              'Calcular IMC',
              style: TextStyle(color: dialogTextColor),
            ),
            content: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextField(
                  controller: pesoController,
                  keyboardType: TextInputType.numberWithOptions(decimal: true),
                  decoration: InputDecoration(
                    labelText: 'Peso (kg)',
                    hintText: 'Ex: 70.5',
                    filled: true,
                    fillColor: dialogSurface,
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                    enabledBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(8),
                      borderSide: BorderSide(color: AppColors.warning),
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(8),
                      borderSide: BorderSide(
                        color: AppColors.warning,
                        width: 2,
                      ),
                    ),
                    labelStyle: TextStyle(color: dialogTextColor),
                    hintStyle: TextStyle(color: dialogSubtleText),
                  ),
                  style: TextStyle(color: dialogTextColor),
                ),
                const SizedBox(height: 12),
                TextField(
                  controller: alturaController,
                  keyboardType: TextInputType.number,
                  decoration: InputDecoration(
                    labelText: 'Altura (cm)',
                    hintText: 'Ex: 170',
                    filled: true,
                    fillColor: dialogSurface,
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                    enabledBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(8),
                      borderSide: BorderSide(color: AppColors.success),
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(8),
                      borderSide: BorderSide(
                        color: AppColors.success,
                        width: 2,
                      ),
                    ),
                    labelStyle: TextStyle(color: dialogTextColor),
                    hintStyle: TextStyle(color: dialogSubtleText),
                  ),
                  style: TextStyle(color: dialogTextColor),
                ),
                const SizedBox(height: 12),
                if (dialogImc != null) ...[
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: AppColors.secondary.withAlpha(
                        (0.12 * 255).round(),
                      ),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'IMC: ${double.parse(dialogImc.toStringAsFixed(1))}',
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            color: AppColors.warningForMode,
                          ),
                        ),
                        const SizedBox(height: 6),
                        Text(
                          (dialogImc < 18.5)
                              ? 'Abaixo do peso'
                              : (dialogImc < 25)
                              ? 'Peso normal'
                              : (dialogImc < 30)
                              ? 'Sobrepeso'
                              : 'Obesidade',
                          style: TextStyle(color: dialogTextColor),
                        ),
                      ],
                    ),
                  ),
                ],
              ],
            ),
            actions: [
              Center(
                child: Wrap(
                  alignment: WrapAlignment.center,
                  runAlignment: WrapAlignment.center,
                  spacing: 8,
                  runSpacing: 8,
                  children: [
                    SizedBox(
                      width: 94,
                      child: TextButton(
                        onPressed: () => Navigator.pop(context),
                        style: TextButton.styleFrom(
                          foregroundColor: AppColors.warning,
                          backgroundColor: Colors.transparent,
                          side: BorderSide(
                            color: AppColors.warning,
                            width: 1.2,
                          ),
                          minimumSize: const Size(0, 42),
                          padding: const EdgeInsets.symmetric(
                            horizontal: 10,
                            vertical: 10,
                          ),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(10),
                          ),
                        ),
                        child: Text('Fechar'),
                      ),
                    ),
                    SizedBox(
                      width: 94,
                      child: OutlinedButton(
                        onPressed: () {
                          clearAll();
                        },
                        style: OutlinedButton.styleFrom(
                          side: BorderSide(
                            color: AppColors.warning,
                            width: 1.2,
                          ),
                          foregroundColor: AppColors.warning,
                          backgroundColor: Colors.transparent,
                          minimumSize: const Size(0, 42),
                          padding: const EdgeInsets.symmetric(
                            horizontal: 10,
                            vertical: 10,
                          ),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(10),
                          ),
                        ),
                        child: Text('Limpar'),
                      ),
                    ),
                    SizedBox(
                      width: 108,
                      child: ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.transparent,
                          foregroundColor: AppColors.success,
                          side: BorderSide(
                            color: AppColors.success,
                            width: 1.2,
                          ),
                          minimumSize: const Size(0, 42),
                          padding: const EdgeInsets.symmetric(
                            horizontal: 10,
                            vertical: 10,
                          ),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(10),
                          ),
                        ),
                        onPressed: () {
                          calculate();
                          setDialogState(() {});
                        },
                        child: Text(
                          'Calcular',
                          style: TextStyle(color: AppColors.success),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          );
        },
      ),
    );
  }

  void _mostrarDialogoSair() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Sair', style: TextStyle(color: AppColors.onSurface)),
        content: Text(
          'Tem certeza que deseja sair da sua conta?',
          style: TextStyle(color: AppColors.onSurface),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text(
              'Cancelar',
              style: TextStyle(color: AppColors.onSurface),
            ),
          ),
          TextButton(
            onPressed: () {
              AuthService.logout();
              Navigator.pushNamedAndRemoveUntil(context, '/', (route) => false);
            },
            child: Text('Sair', style: TextStyle(color: AppColors.error)),
          ),
        ],
      ),
    );
  }

  void _mostrarDialogPrivacidade() {
    showDialog<void>(
      context: context,
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setState) {
            return AlertDialog(
              title: Text(
                'Privacidade',
                style: TextStyle(color: AppColors.onSurface),
              ),
              content: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  SwitchListTile.adaptive(
                    contentPadding: EdgeInsets.zero,
                    title: Text(
                      'Compartilhar dados anônimos',
                      style: TextStyle(color: AppColors.onSurface),
                    ),
                    value: _compartilharDados,
                    onChanged: (v) => setState(() => _compartilharDados = v),
                  ),
                  const SizedBox(height: 8),
                  SwitchListTile.adaptive(
                    contentPadding: EdgeInsets.zero,
                    title: Text(
                      'Ativar analytics',
                      style: TextStyle(color: AppColors.onSurface),
                    ),
                    subtitle: Text(
                      'Enviar dados de uso anônimos',
                      style: TextStyle(
                        color: AppColors.onSurface.withAlpha(
                          (0.78 * 255).round(),
                        ),
                      ),
                    ),
                    value: _analytics,
                    onChanged: (v) => setState(() => _analytics = v),
                  ),
                ],
              ),
              actions: [
                TextButton(
                  onPressed: () => Navigator.pop(context),
                  child: Text(
                    'Cancelar',
                    style: TextStyle(color: AppColors.onSurface),
                  ),
                ),
                ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.primary,
                  ),
                  onPressed: () async {
                    final dialogContext = context;
                    await _saveSettings();
                    if (!mounted || !dialogContext.mounted) return;
                    Navigator.of(dialogContext).pop();
                    if (!mounted || !dialogContext.mounted) return;
                    ScaffoldMessenger.of(dialogContext).showSnackBar(
                      SnackBar(
                        content: Text(
                          'Preferências de privacidade salvas',
                          style: TextStyle(color: AppColors.onPrimary),
                        ),
                        backgroundColor: AppColors.primary,
                      ),
                    );
                  },
                  child: Text(
                    'Salvar',
                    style: TextStyle(color: AppColors.onPrimary),
                  ),
                ),
              ],
            );
          },
        );
      },
    );
  }

  void _mostrarDialogNotificacoes() {
    showDialog<void>(
      context: context,
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setState) {
            return AlertDialog(
              title: Text(
                'Notificações',
                style: TextStyle(color: AppColors.onSurface),
              ),
              content: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  SwitchListTile.adaptive(
                    contentPadding: EdgeInsets.zero,
                    title: Text(
                      'Ativar notificações',
                      style: TextStyle(color: AppColors.onSurface),
                    ),
                    value: _notificacoesAtivas,
                    onChanged: (v) => setState(() => _notificacoesAtivas = v),
                  ),
                  const SizedBox(height: 8),
                  SwitchListTile.adaptive(
                    contentPadding: EdgeInsets.zero,
                    title: Text(
                      'Lembretes diários',
                      style: TextStyle(color: AppColors.onSurface),
                    ),
                    value: _lembretesDiarios,
                    onChanged: (v) => setState(() => _lembretesDiarios = v),
                  ),
                  const SizedBox(height: 12),
                  Row(
                    children: [
                      const Icon(Icons.access_time, size: 18),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          'Horário: ${_horarioLembrete.format(context)}',
                          style: TextStyle(color: AppColors.onSurface),
                        ),
                      ),
                      TextButton(
                        onPressed: () async {
                          final pickerContext = context;
                          final picked = await showTimePicker(
                            context: pickerContext,
                            initialTime: _horarioLembrete,
                          );
                          if (!mounted || !pickerContext.mounted) return;
                          if (picked != null)
                            setState(() => _horarioLembrete = picked);
                        },
                        child: Text(
                          'Alterar',
                          style: TextStyle(color: AppColors.onSurface),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
              actions: [
                TextButton(
                  onPressed: () => Navigator.pop(context),
                  child: Text(
                    'Cancelar',
                    style: TextStyle(color: AppColors.onSurface),
                  ),
                ),
                ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.primary,
                  ),
                  onPressed: () async {
                    final dialogContext = context;
                    await _saveSettings();
                    if (!mounted || !dialogContext.mounted) return;
                    Navigator.of(dialogContext).pop();
                    if (!mounted || !dialogContext.mounted) return;
                    ScaffoldMessenger.of(dialogContext).showSnackBar(
                      SnackBar(
                        content: Text(
                          'Configurações de notificações salvas',
                          style: TextStyle(color: AppColors.onPrimary),
                        ),
                        backgroundColor: AppColors.primary,
                      ),
                    );
                  },
                  child: Text(
                    'Salvar',
                    style: TextStyle(color: AppColors.onPrimary),
                  ),
                ),
              ],
            );
          },
        );
      },
    );
  }
}
