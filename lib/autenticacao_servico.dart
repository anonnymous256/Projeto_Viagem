import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';

class AutenticacaoServico {
  final FirebaseAuth _firebaseAuth = FirebaseAuth.instance;

  Future<bool> verificarEmail(String email) async {
    try {
      UserCredential userCredential =
          await _firebaseAuth.createUserWithEmailAndPassword(
        email: email,
        password:
            'temporary_password', 
      );
      await userCredential.user!
          .delete(); 
      return false; 
    } catch (e) {
      if (e is FirebaseAuthException && e.code == 'email-already-in-use') {
        return true; 
      } else {
        print('Erro ao verificar e-mail: $e');
        throw e;
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
      return true;
    } catch (e) {
      print('Erro ao fazer login: $e');
      return false;
    }
  }
}
