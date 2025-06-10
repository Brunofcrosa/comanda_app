import 'package:flutter/material.dart';
import 'package:flutter_comandas_app/servicos/database/banco_dados.dart';
import 'package:flutter_comandas_app/modelos/usuario.dart';
import 'package:flutter_comandas_app/utilitarios/utils.dart';
import 'package:flutter_comandas_app/pages/login/cadastro.dart';
import 'package:flutter_comandas_app/pages/home/homepage.dart';

class LoginPage extends StatefulWidget {
  const LoginPage({super.key});

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  void _login() async {
    if (_formKey.currentState!.validate()) {
      final String email = _emailController.text.trim();
      final String senha = _passwordController.text;

      try {
        final Usuario? usuario = await BancoDados.instancia
            .buscarUsuarioPorEmail(email);

        if (!mounted) return;

        if (usuario != null && usuario.senha == senha) {
          showSnackBarMessage(context, 'Login efetuado com sucesso!');
          Navigator.of(context).pushReplacement(
            MaterialPageRoute(builder: (context) => const MainAppNavigator()),
          );
        } else {
          showSnackBarMessage(
            context,
            'E-mail ou senha incorretos.',
            isError: true,
          );
        }
      } catch (e) {
        if (mounted) {
          showSnackBarMessage(
            context,
            'Erro ao efetuar login: $e',
            isError: true,
          );
        }
        print('Erro ao efetuar login: $e');
      }
    }
  }

  void _navigateToSignUp() {
    Navigator.of(
      context,
    ).push(MaterialPageRoute(builder: (context) => const SignUpForm()));
  }

  void _forgotPassword() {
    showSnackBarMessage(
      context,
      'Funcionalidade de recuperar senha em desenvolvimento.',
    );
  }

  @override
  Widget build(BuildContext context) {
    final Color primaryColor = Theme.of(context).colorScheme.primary;
    final TextTheme textTheme = Theme.of(context).textTheme;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Login / Cadastro'),
        automaticallyImplyLeading: false,
      ),
      body: Center(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24.0),
          child: Form(
            key: _formKey,
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: <Widget>[
                Icon(Icons.restaurant, size: 60, color: primaryColor),
                const SizedBox(height: 30),
                TextFormField(
                  controller: _emailController,
                  keyboardType: TextInputType.emailAddress,
                  decoration: const InputDecoration(
                    labelText: 'E-mail',
                    prefixIcon: Icon(Icons.email),
                  ),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Por favor, insira seu e-mail.';
                    }
                    final emailRegex = RegExp(
                      r'^[a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+\.[a-zA-Z]{2,}$',
                    );
                    if (!emailRegex.hasMatch(value)) {
                      return 'E-mail inválido.';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 20),
                TextFormField(
                  controller: _passwordController,
                  obscureText: true,
                  decoration: const InputDecoration(
                    labelText: 'Senha',
                    hintText: '******',
                    prefixIcon: Icon(Icons.lock),
                  ),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Por favor, insira sua senha.';
                    }
                    if (value.length < 6) {
                      return 'A senha deve ter no mínimo 6 caracteres.';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 25),
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: _login,
                    child: const Text('Entrar'),
                  ),
                ),
                const SizedBox(height: 15),
                TextButton(
                  onPressed: _navigateToSignUp,
                  child: Text(
                    'Criar conta',
                    style: textTheme.labelLarge?.copyWith(
                      fontSize: 16,
                      color: primaryColor,
                    ),
                  ),
                ),
                TextButton(
                  onPressed: _forgotPassword,
                  child: Text(
                    'Esqueci minha senha',
                    style: textTheme.labelLarge?.copyWith(
                      fontSize: 16,
                      color: primaryColor,
                    ),
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
