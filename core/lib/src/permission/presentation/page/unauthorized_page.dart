import 'package:flutter/material.dart';
import 'package:flutter_modular/flutter_modular.dart';

class UnauthorizedPage extends StatelessWidget {
  const UnauthorizedPage({
    super.key,
    this.message =
        'Usuário sem permissão de acesso, solicite acesso ao Administrador do sistema',
  });

  final String message;

  @override
  Widget build(BuildContext context) => Scaffold(
      appBar: AppBar(
        title: const Text(
          'Acesso Negado',
          style: TextStyle(fontFamily: 'OpenSans'),
        ),
        backgroundColor: Colors.red.shade700,
        foregroundColor: Colors.white,
        leading: IconButton(
          icon: const Icon(Icons.logout),
          tooltip: 'Sair',
          onPressed: () => Modular.to.navigate('/auth/'),
        ),
      ),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(32),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(Icons.lock_outline, size: 80, color: Colors.red.shade400),
              const SizedBox(height: 24),
              Text(
                message,
                textAlign: TextAlign.center,
                style: const TextStyle(
                  fontSize: 16,
                  fontFamily: 'OpenSans',
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
          ),
        ),
      ),
    );
}
