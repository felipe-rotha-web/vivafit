import 'package:flutter/material.dart';
import '../theme.dart';
import '../data/auth_service.dart';
import 'home_page.dart';
import 'welcome_page.dart';

// Classe LoginPage representa um componente ou widget da interface.
class LoginPage extends StatefulWidget {
  const LoginPage({super.key});

  @override
  State<LoginPage> createState() => _LoginPageState();
}

// Classe _LoginPageState representa um componente ou widget da interface.
class _LoginPageState extends State<LoginPage> {
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _senhaController = TextEditingController();
  bool _senhaVisivel = false;
  bool _isLoading = false;

  @override
  void dispose() {
    _emailController.dispose();
    _senhaController.dispose();
    super.dispose();
  }

  // Reúne os dados do formulário, valida, chama o AuthService e trata a navegação para a Home.
  void _fazerLogin() async {
    final String email = _emailController.text.trim();
    final String senha = _senhaController.text.trim();

    // Verifica se usuário e senha foram preenchidos antes de tentar autenticar.
    if (email.isEmpty || senha.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Por favor, preencha todos os campos'),
          backgroundColor: AppColors.error,
        ),
      );
      return;
    }

    // Exibe indicador de atividade enquanto a requisição de login está em andamento.
    setState(() => _isLoading = true);

    try {
      // Tenta autenticar com o serviço de autenticação local.
      final usuario = await AuthService.login(email: email, senha: senha);

      // Se a autenticação falhar, mantém o usuário na tela de login e mostra mensagem.
      if (usuario == null) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Usuário ou senha inválidos'),
              backgroundColor: AppColors.error,
            ),
          );
        }
        return;
      }

      if (mounted) {
        // Navega para a tela principal da aplicação e remove a tela de login da pilha.
        Navigator.of(context).pushReplacement(
          MaterialPageRoute(builder: (context) => HomePage(usuario: usuario)),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Falha ao fazer login: $e'),
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

  void _showResetPasswordDialog() {
    final emailController = TextEditingController(
      text: _emailController.text.trim(),
    );
    final codeController = TextEditingController();
    final senhaController = TextEditingController();
    final confirmarSenhaController = TextEditingController();
    final rootMessenger = ScaffoldMessenger.maybeOf(context);
    bool senhaVisivel = false;
    bool codigoEnviado = false;
    bool isLoading = false;

    showDialog<void>(
      context: context,
      builder: (dialogContext) {
        return StatefulBuilder(
          builder: (context, setState) {
            return AlertDialog(
              title: const Text('Recuperar senha'),
              content: SingleChildScrollView(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    TextField(
                      controller: emailController,
                      keyboardType: TextInputType.emailAddress,
                      enabled: !codigoEnviado && !isLoading,
                      decoration: const InputDecoration(
                        labelText: 'Email da sua conta',
                      ),
                    ),
                    if (codigoEnviado) ...[
                      const SizedBox(height: 12),
                      TextField(
                        controller: codeController,
                        keyboardType: TextInputType.number,
                        maxLength: 6,
                        decoration: const InputDecoration(
                          labelText: 'Código recebido por email',
                          counterText: '',
                        ),
                      ),
                      const SizedBox(height: 12),
                      TextField(
                        controller: senhaController,
                        obscureText: !senhaVisivel,
                        decoration: InputDecoration(
                          labelText: 'Nova senha (mínimo 6 caracteres)',
                          suffixIcon: IconButton(
                            icon: Icon(
                              senhaVisivel
                                  ? Icons.visibility
                                  : Icons.visibility_off,
                            ),
                            onPressed: () =>
                                setState(() => senhaVisivel = !senhaVisivel),
                          ),
                        ),
                      ),
                      const SizedBox(height: 12),
                      TextField(
                        controller: confirmarSenhaController,
                        obscureText: !senhaVisivel,
                        decoration: const InputDecoration(
                          labelText: 'Confirmar nova senha',
                        ),
                      ),
                    ],
                  ],
                ),
              ),
              actions: [
                TextButton(
                  onPressed: () {
                    Navigator.of(context).pop();
                  },
                  child: Text('Cancelar'),
                ),
                ElevatedButton(
                  onPressed: isLoading
                      ? null
                      : () async {
                          final email = emailController.text.trim();
                          final pageContext = this.context;
                          final rootMessenger =
                              ScaffoldMessenger.maybeOf(pageContext);
                          final messenger = rootMessenger ??
                              ScaffoldMessenger.maybeOf(context) ??
                              ScaffoldMessenger.maybeOf(
                                Navigator.of(context).context,
                              );

                          if (email.isEmpty ||
                              !RegExp(
                                r'^[^@\s]+@[^@\s]+\.[^@\s]+$',
                              ).hasMatch(email)) {
                            messenger?.showSnackBar(
                              const SnackBar(
                                content: Text('Informe um email válido.'),
                              ),
                            );
                            return;
                          }

                          if (!codigoEnviado) {
                            setState(() => isLoading = true);
                            try {
                              final message =
                                  await AuthService.requestPasswordResetCode(
                                    email: email,
                                  );
                              if (!mounted) {
                                return;
                              }
                              setState(() => codigoEnviado = true);
                              messenger?.showSnackBar(
                                SnackBar(content: Text(message)),
                              );
                            } catch (error) {
                              if (mounted) {
                                messenger?.showSnackBar(
                                  SnackBar(
                                    content: Text(
                                      'Não foi possível solicitar o código: $error',
                                    ),
                                    backgroundColor: AppColors.error,
                                  ),
                                );
                              }
                            } finally {
                              if (mounted) {
                                setState(() => isLoading = false);
                              }
                            }
                            return;
                          }

                          final code = codeController.text.trim();
                          final novaSenha = senhaController.text.trim();
                          if (!RegExp(r'^\d{6}$').hasMatch(code)) {
                            messenger?.showSnackBar(
                              const SnackBar(
                                content: Text('Informe o código de 6 dígitos.'),
                              ),
                            );
                            return;
                          }
                          if (novaSenha.length < 6) {
                            messenger?.showSnackBar(
                              const SnackBar(
                                content: Text(
                                  'A senha deve ter pelo menos 6 caracteres.',
                                ),
                              ),
                            );
                            return;
                          }
                          if (novaSenha !=
                              confirmarSenhaController.text.trim()) {
                            messenger?.showSnackBar(
                              const SnackBar(
                                content: Text('As senhas não conferem.'),
                              ),
                            );
                            return;
                          }

                          final rootContext = pageContext;
                          final rootNavigator =
                              Navigator.of(rootContext, rootNavigator: true);

                          setState(() => isLoading = true);
                          try {
                            final message =
                                await AuthService.confirmPasswordReset(
                                  email: email,
                                  code: code,
                                  novaSenha: novaSenha,
                                );

                            if (!mounted) {
                              return;
                            }

                            final usuarioLogado = await AuthService.login(
                              email: email,
                              senha: novaSenha,
                            );

                            if (rootNavigator.canPop()) {
                              rootNavigator.pop();
                            }

                            if (mounted && usuarioLogado != null) {
                              rootNavigator.pushReplacement(
                                MaterialPageRoute(
                                  builder: (_) => HomePage(usuario: usuarioLogado),
                                ),
                              );
                            }

                            if (mounted && rootMessenger != null) {
                              rootMessenger.showSnackBar(
                                SnackBar(
                                  content: Text(
                                    '$message Login realizado com sucesso.',
                                  ),
                                  backgroundColor: AppColors.success,
                                ),
                              );
                            }
                          } catch (error) {
                            if (mounted) {
                              final currentMessenger =
                                  rootMessenger ?? messenger ??
                                  ScaffoldMessenger.maybeOf(context);
                              currentMessenger?.showSnackBar(
                                SnackBar(
                                  content: Text(
                                    'Não foi possível redefinir a senha: $error',
                                  ),
                                  backgroundColor: AppColors.error,
                                ),
                              );
                            }
                          } finally {
                            if (mounted) {
                              setState(() => isLoading = false);
                            }
                          }
                        },
                  child: isLoading
                      ? const SizedBox(
                          width: 18,
                          height: 18,
                          child: CircularProgressIndicator(strokeWidth: 2),
                        )
                      : Text(
                          codigoEnviado ? 'Redefinir senha' : 'Enviar código',
                        ),
                ),
              ],
            );
          },
        );
      },
    );
  }

  // Constrói a interface da tela de login, incluindo campos de entrada, botões e mensagens de feedback.
  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    Color alphaColor(Color c, double opacity) =>
        c.withAlpha((opacity * 255).round());

    final screenWidth = MediaQuery.of(context).size.width;
    final logoSize = screenWidth < 360 ? screenWidth * 0.7 : 280.0;
    final viewInsets = MediaQuery.of(context).viewInsets;
    final bottomInset = viewInsets.bottom.isFinite
        ? viewInsets.bottom.clamp(0.0, double.infinity)
        : 0.0;

    return Scaffold(
      backgroundColor: AppColors.primary,
      appBar: AppBar(
        backgroundColor: AppColors.primary,
        elevation: 0,
        leading: IconButton(
          icon: Icon(Icons.arrow_back, color: colorScheme.onPrimary),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: SingleChildScrollView(
        padding: EdgeInsets.only(
          left: 20,
          right: 20,
          top: 20,
          bottom: 20 + bottomInset,
        ),
        child: Column(
          children: [
            const SizedBox(height: 30),
            Center(
              child: SizedBox(
                width: logoSize,
                height: logoSize,
                child: Image.asset(
                  'assets/images/Viva_Fit_logo.png',
                  fit: BoxFit.contain,
                ),
              ),
            ),
            const SizedBox(height: 30),
            Text(
              'Bem-vindo de Volta!',
              style: TextStyle(
                fontSize: 28,
                fontWeight: FontWeight.bold,
                color: AppColors.onPrimary,
              ),
            ),
            const SizedBox(height: 10),
            Text(
              'Faça login para continuar sua jornada',
              style: TextStyle(
                fontSize: 14,
                color: AppColors.onPrimary.withAlpha((0.72 * 255).round()),
              ),
            ),
            const SizedBox(height: 40),
            TextField(
              controller: _emailController,
              keyboardType: TextInputType.emailAddress,
              style: TextStyle(color: AppColors.onPrimary),
              decoration: InputDecoration(
                hintText: 'Email',
                hintStyle: TextStyle(
                  color: AppColors.onPrimary.withAlpha((0.72 * 255).round()),
                ),
                prefixIcon: Icon(
                  Icons.email_outlined,
                  color: AppColors.onPrimary.withAlpha((0.72 * 255).round()),
                ),
                filled: true,
                fillColor: AppColors.onPrimary.withAlpha((0.10 * 255).round()),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide(
                    color: AppColors.onPrimary.withAlpha((0.30 * 255).round()),
                  ),
                ),
                enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide(
                    color: AppColors.onPrimary.withAlpha((0.30 * 255).round()),
                  ),
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide(color: AppColors.onPrimary, width: 2),
                ),
              ),
            ),
            const SizedBox(height: 20),
            TextField(
              controller: _senhaController,
              obscureText: !_senhaVisivel,
              style: TextStyle(color: AppColors.onPrimary),
              decoration: InputDecoration(
                hintText: 'Senha',
                hintStyle: TextStyle(
                  color: AppColors.onPrimary.withAlpha((0.72 * 255).round()),
                ),
                prefixIcon: Icon(
                  Icons.lock,
                  color: AppColors.onPrimary.withAlpha((0.72 * 255).round()),
                ),
                suffixIcon: IconButton(
                  icon: Icon(
                    _senhaVisivel ? Icons.visibility : Icons.visibility_off,
                    color: AppColors.onPrimary.withAlpha((0.72 * 255).round()),
                  ),
                  onPressed: () {
                    setState(() => _senhaVisivel = !_senhaVisivel);
                  },
                ),
                filled: true,
                fillColor: AppColors.onPrimary.withAlpha((0.10 * 255).round()),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide(
                    color: AppColors.onPrimary.withAlpha((0.30 * 255).round()),
                  ),
                ),
                enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide(
                    color: AppColors.onPrimary.withAlpha((0.30 * 255).round()),
                  ),
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide(color: AppColors.onPrimary, width: 2),
                ),
              ),
            ),
            const SizedBox(height: 30),
            SizedBox(
              width: double.infinity,
              height: 55,
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.surface,
                  foregroundColor: AppColors.onSurface,
                  elevation: 5,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                onPressed: _isLoading ? null : _fazerLogin,
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
                        'Login',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: AppColors.onSurface,
                        ),
                      ),
              ),
            ),
            const SizedBox(height: 20),
            TextButton(
              onPressed: _showResetPasswordDialog,
              child: Text(
                'Esqueceu sua senha?',
                style: TextStyle(
                  color: AppColors.onPrimary.withAlpha((0.72 * 255).round()),
                  fontSize: 14,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
