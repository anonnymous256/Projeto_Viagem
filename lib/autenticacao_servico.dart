import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';

class AutenticacaoServico {
  final FirebaseAuth _firebaseAuth = FirebaseAuth.instance;

  AutenticacaoServico._(); // Construtor privado

  static final AutenticacaoServico _instance = AutenticacaoServico._(); // Instância única
  static AutenticacaoServico get instance => _instance; // Método estático para acessar a instância única

   Stream<User?> userChanges() {
    return _firebaseAuth.authStateChanges();
  }

  Future<bool> verificarEmail(String email) async {
    try {
      UserCredential userCredential =
          await _firebaseAuth.createUserWithEmailAndPassword(
        email: email,
        password: 'temporary_password', 
      );
      await userCredential.user!.delete(); // Exclui o usuário criado temporariamente
      return false; // Retorna falso indicando que o e-mail não está em uso
    } catch (e) {
      if (e is FirebaseAuthException && e.code == 'email-already-in-use') {
        return true; // Retorna verdadeiro se o e-mail já estiver em uso
      } else {
        print('Erro ao verificar e-mail: $e');
        throw e; // Lança exceção se ocorrer outro erro
      }
    }
  }

  Future<void> cadastrarUsuario({
    required String email,
    required String senha,
    required String confirmarSenha,
    required String nome,
    required BuildContext context,
  }) async {
    if (senha != confirmarSenha) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('As senhas não coincidem!'),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    try {
      await _firebaseAuth.createUserWithEmailAndPassword(
        email: email,
        password: senha,
      );

      User? user = _firebaseAuth.currentUser;
      if (user != null) {
        await user.updateDisplayName(nome);
      }
    } catch (e) {
      if (e is FirebaseAuthException && e.code == 'email-already-in-use') {
        throw 'O e-mail já está cadastrado. Por favor, use outro e-mail.';
      } else {
        print('Erro ao cadastrar usuário: $e');
        throw e;
      }
    }
  }

  Future<bool> autenticarUsuario(String email, String senha) async {
    try {
      await _firebaseAuth.signInWithEmailAndPassword(
        email: email,
        password: senha,
      );
      return true; // Retorna verdadeiro se o login for bem-sucedido
    } catch (e) {
      print('Erro ao fazer login: $e');
      return false; // Retorna falso se ocorrer um erro durante o login
    }
  }
}
