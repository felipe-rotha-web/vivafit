
import 'package:flutter/material.dart';
import '../theme.dart';
import '../data/auth_service.dart';
import '../models/app_user.dart';
import 'home_page.dart';

// Classe CadUserPage representa um componente ou widget da interface.
class CadUserPage extends StatefulWidget {
  const CadUserPage({super.key});

  @override
  State<CadUserPage> createState() => _CadUserPageState();
}

// Classe _CadUserPageState representa um componente ou widget da interface.
class _CadUserPageState extends State<CadUserPage> {
  final TextEditingController _nomeController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _senhaController = TextEditingController();
  final TextEditingController _confirmarSenhaController =
      TextEditingController();
  final TextEditingController _idadeController = TextEditingController();

  String? _nivelAtividade = 'Sedentário';
  String? _genero = 'Masculino';
  bool _senhaVisivel = false;
  bool _confirmarSenhaVisivel = false;
  bool _isLoading = false;

  final List<String> _niveis = [
    'Sedentário',
    'Leve',
    'Moderado',
    'Intenso',
    'Muito Intenso',
  ];
  final List<String> _generos = ['Masculino', 'Feminino'];

  @override
  void dispose() {
    _nomeController.dispose();
    _emailController.dispose();
    _senhaController.dispose();
    _confirmarSenhaController.dispose();
    _idadeController.dispose();
    super.dispose();
  }

  // Processa o envio do formulário de cadastro, valida dados e navega para a Home em caso de sucesso.
  void _cadastrar() async {
    // Validação dos campos obrigatórios antes de realizar o cadastro.
    if (_nomeController.text.isEmpty ||
        _emailController.text.trim().isEmpty ||
        _senhaController.text.isEmpty ||
        _confirmarSenhaController.text.isEmpty ||
        _idadeController.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Por favor, preencha todos os campos'),
          backgroundColor: AppColors.error,
        ),
      );
      return;
    }

    final email = _emailController.text.trim();
    if (!RegExp(r'^[^@\s]+@[^@\s]+\.[^@\s]+$').hasMatch(email)) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Informe um email válido'),
          backgroundColor: AppColors.error,
        ),
      );
      return;
    }

    // Se a senha e confirmação não baterem, impede o envio e mostra erro.
    if (_senhaController.text != _confirmarSenhaController.text) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('As senhas não conferem'),
          backgroundColor: AppColors.error,
        ),
      );
      return;
    }

    // Exige uma senha mínima de 6 caracteres para cadastro.
    if (_senhaController.text.length < 6) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('A senha deve ter pelo menos 6 caracteres'),
          backgroundColor: AppColors.error,
        ),
      );
      return;
    }

    // Valida se o campo idade contém um número válido maior que zero.
    final int? idade = int.tryParse(_idadeController.text.trim());
    if (idade == null || idade <= 0) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Informe uma idade válida'),
          backgroundColor: AppColors.error,
        ),
      );
      return;
    }

    // Ativa o estado de carregamento enquanto cria o objeto de usuário.
    setState(() => _isLoading = true);

    // Monta o objeto AppUser com os dados do formulário.
    final AppUser novoUsuario = AppUser(
      nome: _nomeController.text.trim(),
      email: email,
      senha: _senhaController.text.trim(),
      idade: idade,
      genero: _genero ?? 'Outro',
      nivelAtividade: _nivelAtividade ?? 'Sedentário',
      peso: null,
      altura: null,
    );

    try {
      // Tenta salvar o usuário usando o serviço de autenticação simulado.
      final bool cadastrado = await AuthService.cadastrar(novoUsuario);

      if (!cadastrado) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Já existe usuário com esse nome'),
              backgroundColor: AppColors.error,
            ),
          );
        }
        return;
      }

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Cadastro realizado com sucesso!'),
            backgroundColor: AppColors.success,
          ),
        );

        // Redireciona para a Home e impede retorno ao cadastro com o botão de voltar.
        Navigator.of(context).pushReplacement(
          MaterialPageRoute(
            builder: (context) =>
                HomePage(usuario: AuthService.usuarioLogado ?? novoUsuario),
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Falha ao cadastrar: $e'),
            backgroundColor: AppColors.error,
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  Widget _buildFieldLabel(String text) {
    return Align(
      alignment: Alignment.centerLeft,
      child: Padding(
        padding: const EdgeInsets.only(bottom: 8),
        child: Text(
          text,
          style: TextStyle(
            color: AppColors.onPrimary,
            fontSize: 16,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.primary,
      appBar: AppBar(
        backgroundColor: AppColors.primary,
        elevation: 0,
        leading: IconButton(
          icon: Icon(Icons.arrow_back, color: AppColors.onPrimary),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text(
          'Cadastro',
          style: TextStyle(color: AppColors.onPrimary, fontWeight: FontWeight.bold),
        ),
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          children: [
            const SizedBox(height: 20),
            Text(
              'Crie sua Conta',
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
                color: AppColors.onPrimary,
              ),
            ),
            const SizedBox(height: 30),
            // Nome
            _buildFieldLabel('Nome'),
            TextField(
              controller: _nomeController,
              style: TextStyle(color: AppColors.onPrimary),
              decoration: InputDecoration(
                hintText: 'Nome Completo',
                hintStyle: TextStyle(color: AppColors.onPrimary.withAlpha((0.7 * 255).round())),
                prefixIcon: Icon(Icons.person, color: AppColors.onPrimary.withAlpha((0.7 * 255).round())),
                filled: true,
                fillColor: AppColors.onPrimary.withAlpha((0.1 * 255).round()),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide(color: AppColors.onPrimary.withAlpha((0.3 * 255).round())),
                ),
                enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide(color: AppColors.onPrimary.withAlpha((0.3 * 255).round())),
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide(color: AppColors.onPrimary, width: 2),
                ),
              ),
            ),
            const SizedBox(height: 15),
            _buildFieldLabel('Email'),
            TextField(
              controller: _emailController,
              keyboardType: TextInputType.emailAddress,
              style: TextStyle(color: AppColors.onPrimary),
              decoration: InputDecoration(
                hintText: 'seu@email.com',
                hintStyle: TextStyle(color: AppColors.onPrimary.withAlpha((0.7 * 255).round())),
                prefixIcon: Icon(Icons.email_outlined, color: AppColors.onPrimary.withAlpha((0.7 * 255).round())),
                filled: true,
                fillColor: AppColors.onPrimary.withAlpha((0.1 * 255).round()),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide(color: AppColors.onPrimary.withAlpha((0.3 * 255).round())),
                ),
                enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide(color: AppColors.onPrimary.withAlpha((0.3 * 255).round())),
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide(color: AppColors.onPrimary, width: 2),
                ),
              ),
            ),
            const SizedBox(height: 15),
            // Idade
            _buildFieldLabel('Idade'),
            TextField(
              controller: _idadeController,
              keyboardType: TextInputType.number,
              style: TextStyle(color: AppColors.onPrimary),
              decoration: InputDecoration(
                hintText: 'Idade',
                hintStyle: TextStyle(color: AppColors.onPrimary.withAlpha((0.7 * 255).round())),
                prefixIcon: Icon(
                  Icons.calendar_today,
                  color: AppColors.onPrimary.withAlpha((0.7 * 255).round()),
                ),
                filled: true,
                fillColor: AppColors.onPrimary.withAlpha((0.1 * 255).round()),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide(color: AppColors.onPrimary.withAlpha((0.3 * 255).round())),
                ),
                enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide(color: AppColors.onPrimary.withAlpha((0.3 * 255).round())),
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide(color: AppColors.onPrimary, width: 2),
                ),
              ),
            ),
            const SizedBox(height: 15),
            // Sexo biológico
            _buildFieldLabel('Sexo biológico'),
            Container(
              decoration: BoxDecoration(
                color: AppColors.onPrimary.withAlpha((0.1 * 255).round()),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: AppColors.onPrimary.withAlpha((0.3 * 255).round())),
              ),
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 12),
                child: DropdownButton<String>(
                  value: _genero,
                  isExpanded: true,
                  underline: const SizedBox(),
                  dropdownColor: AppColors.primary,
                  style: TextStyle(color: AppColors.onPrimary, fontSize: 16),
                  hint: Text(
                    'Selecione',
                    style: TextStyle(color: AppColors.onPrimary.withAlpha((0.7 * 255).round())),
                  ),
                  items: _generos.map((String value) {
                    return DropdownMenuItem<String>(
                      value: value,
                      child: Text(value),
                    );
                  }).toList(),
                  onChanged: (String? newValue) {
                    setState(() => _genero = newValue);
                  },
                ),
              ),
            ),
            const SizedBox(height: 15),
            // Nível de Atividade
            _buildFieldLabel('Nível de atividade física'),
            Container(
              decoration: BoxDecoration(
                color: AppColors.onPrimary.withAlpha((0.1 * 255).round()),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: AppColors.onPrimary.withAlpha((0.3 * 255).round())),
              ),
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 12),
                child: DropdownButton<String>(
                  value: _nivelAtividade,
                  isExpanded: true,
                  underline: const SizedBox(),
                  dropdownColor: AppColors.primary,
                  style: TextStyle(color: AppColors.onPrimary, fontSize: 16),
                  hint: Text(
                    'Selecione o Nível de Atividade',
                    style: TextStyle(color: AppColors.onPrimary.withAlpha((0.7 * 255).round())),
                  ),
                  items: _niveis.map((String value) {
                    return DropdownMenuItem<String>(
                      value: value,
                      child: Text(value),
                    );
                  }).toList(),
                  onChanged: (String? newValue) {
                    setState(() => _nivelAtividade = newValue);
                  },
                ),
              ),
            ),
            const SizedBox(height: 15),
            // Senha
            _buildFieldLabel('Senha'),
            TextField(
              controller: _senhaController,
              obscureText: !_senhaVisivel,
              style: TextStyle(color: AppColors.onPrimary),
              decoration: InputDecoration(
                hintText: 'Senha',
                hintStyle: TextStyle(color: AppColors.onPrimary.withAlpha((0.7 * 255).round())),
                prefixIcon: Icon(Icons.lock, color: AppColors.onPrimary.withAlpha((0.7 * 255).round())),
                suffixIcon: IconButton(
                  icon: Icon(
                    _senhaVisivel ? Icons.visibility : Icons.visibility_off,
                    color: AppColors.onPrimary.withAlpha((0.7 * 255).round()),
                  ),
                  onPressed: () {
                    setState(() => _senhaVisivel = !_senhaVisivel);
                  },
                ),
                filled: true,
                fillColor: AppColors.onPrimary.withAlpha((0.1 * 255).round()),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide(color: AppColors.onPrimary.withAlpha((0.3 * 255).round())),
                ),
                enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide(color: AppColors.onPrimary.withAlpha((0.3 * 255).round())),
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide(color: AppColors.onPrimary, width: 2),
                ),
              ),
            ),
            const SizedBox(height: 15),
            // Confirmar Senha
            _buildFieldLabel('Confirmar senha'),
            TextField(
              controller: _confirmarSenhaController,
              obscureText: !_confirmarSenhaVisivel,
              style: TextStyle(color: AppColors.onPrimary),
              decoration: InputDecoration(
                hintText: 'Confirmar Senha',
                hintStyle: TextStyle(color: AppColors.onPrimary.withAlpha((0.7 * 255).round())),
                prefixIcon: Icon(Icons.lock, color: AppColors.onPrimary.withAlpha((0.7 * 255).round())),
                suffixIcon: IconButton(
                  icon: Icon(
                    _confirmarSenhaVisivel
                        ? Icons.visibility
                        : Icons.visibility_off,
                    color: AppColors.onPrimary.withAlpha((0.7 * 255).round()),
                  ),
                  onPressed: () {
                    setState(
                      () => _confirmarSenhaVisivel = !_confirmarSenhaVisivel,
                    );
                  },
                ),
                filled: true,
                fillColor: AppColors.onPrimary.withAlpha((0.1 * 255).round()),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide(color: AppColors.onPrimary.withAlpha((0.3 * 255).round())),
                ),
                enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide(color: AppColors.onPrimary.withAlpha((0.3 * 255).round())),
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide(color: AppColors.onPrimary, width: 2),
                ),
              ),
            ),
            const SizedBox(height: 30),
            // Botão Cadastrar
            SizedBox(
              width: double.infinity,
              height: 55,
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.onPrimary,
                  elevation: 5,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                onPressed: _isLoading ? null : _cadastrar,
                child: _isLoading
                    ? SizedBox(
                        height: 25,
                        width: 25,
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                          valueColor: AlwaysStoppedAnimation<Color>(
                            AppColors.primary,
                          ),
                        ),
                      )
                    : Text(
                        'Cadastrar',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: AppColors.primary,
                        ),
                      ),
              ),
            ),
            const SizedBox(height: 20),
          ],
        ),
      ),
    );
  }
}
