import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'Login.dart'; 
import 'autenticacao_servico.dart';
import 'abertura.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();
  runApp(AuthenticateApp());
}

class AuthenticateApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Orçamento App',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: RoteadorTela(),
    );
  }
}

class RoteadorTela extends StatelessWidget {
  const RoteadorTela({Key? key});

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<User?>(
      // Escuta mudanças na autenticação do usuário
      stream: AutenticacaoServico.instance.userChanges(),
      builder: (context, snapshot) {
        if (snapshot.hasData) {
          // Se houver dados do usuário, navega para Abertura
          return Abertura();
        } else if (snapshot.hasError) {
          // Se houver erro, exibe a mensagem de erro
          return Text('Error: ${snapshot.error}');
        } else {
          // Se estiver aguardando ou sem dados, mostra um indicador de carregamento ou LoginPage
          return snapshot.connectionState == ConnectionState.waiting
              ? const Center(child: CircularProgressIndicator())
              : LoginPage();
        }
      },
    );
  }
}
