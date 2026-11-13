import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';

class LoginScreen extends StatelessWidget {
  const LoginScreen({super.key});

  // Función que muestra el Pop-up de penalización
  void _showPenaltyDialog(BuildContext context) {
    showDialog(
      context: context,
      barrierDismissible: false, // El usuario está obligado a presionar el botón para cerrar
      builder: (BuildContext context) {
        return AlertDialog(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
          icon: const Icon(Icons.gavel_rounded, size: 50, color: Colors.redAccent),
          title: const Text('Cuenta Suspendida', style: TextStyle(fontWeight: FontWeight.bold)),
          content: const Text(
            'Tu cuenta ha sido penalizada por 24 horas debido a que no retiraste tu reserva en el bloque horario correspondiente.\n\nPor favor, contacta a soporte si crees que es un error.',
            textAlign: TextAlign.center,
          ),
          actionsAlignment: MainAxisAlignment.center,
          actions: [
            FilledButton(
              style: FilledButton.styleFrom(
                backgroundColor: Colors.redAccent,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
              ),
              onPressed: () {
                Navigator.of(context).pop(); // Cierra el pop-up
              },
              child: const Text('Entendido', style: TextStyle(fontWeight: FontWeight.bold)),
            ),
          ],
        ).animate().scale(duration: 300.ms, curve: Curves.easeOutBack); // Animación de rebote al abrir
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      resizeToAvoidBottomInset: true,
      body: Container(
        width: double.infinity,
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            colors: [Color(0xFF2563EB), Color(0xFF047857)], 
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
        ),
        child: SafeArea(
          child: Center(
            child: SingleChildScrollView(
              padding: const EdgeInsets.symmetric(horizontal: 24.0),
              child: Card(
                elevation: 12,
                shadowColor: Colors.black45,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(24),
                ),
                child: Padding(
                  padding: const EdgeInsets.all(32.0),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Container(
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          color: const Color(0xFF2563EB).withOpacity(0.1),
                          shape: BoxShape.circle,
                        ),
                        child: const Icon(Icons.fastfood_rounded, size: 60, color: Color(0xFF2563EB)),
                      ).animate().scale(duration: 600.ms, curve: Curves.easeOutBack),
                      
                      const SizedBox(height: 16),
                      const Text(
                        'Quiosco USM',
                        style: TextStyle(fontSize: 26, fontWeight: FontWeight.bold, color: Colors.black87),
                      ).animate().fadeIn(delay: 200.ms).slideY(begin: 0.5, end: 0),
                      
                      const SizedBox(height: 8),
                      const Text(
                        'Reserva tus snacks sin filas',
                        style: TextStyle(fontSize: 14, color: Colors.grey),
                      ).animate().fadeIn(delay: 300.ms),
                      
                      const SizedBox(height: 32),
                      
                      TextField(
                        decoration: InputDecoration(
                          labelText: 'Correo institucional',
                          prefixIcon: const Icon(Icons.email_outlined),
                          filled: true,
                          fillColor: Colors.grey.shade50,
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(16),
                            borderSide: BorderSide.none,
                          ),
                        ),
                      ).animate().fadeIn(delay: 400.ms).slideX(begin: -0.1, end: 0),
                      
                      const SizedBox(height: 16),
                      
                      TextField(
                        obscureText: true,
                        decoration: InputDecoration(
                          labelText: 'Contraseña',
                          prefixIcon: const Icon(Icons.lock_outline),
                          filled: true,
                          fillColor: Colors.grey.shade50,
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(16),
                            borderSide: BorderSide.none,
                          ),
                        ),
                      ).animate().fadeIn(delay: 500.ms).slideX(begin: -0.1, end: 0),
                      
                      const SizedBox(height: 32),
                      
                      // --- BOTONES DE DEMOSTRACIÓN ---
                      SizedBox(
                        width: double.infinity,
                        height: 50,
                        child: FilledButton(
                          style: FilledButton.styleFrom(
                            backgroundColor: const Color(0xFF2563EB),
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                          ),
                          onPressed: () => Navigator.pushReplacementNamed(context, '/userHome'),
                          child: const Text('Entrar como Usuario', style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600)),
                        ),
                      ).animate().fadeIn(delay: 600.ms).scale(),
                      
                      const SizedBox(height: 12),
                      
                      SizedBox(
                        width: double.infinity,
                        height: 50,
                        child: OutlinedButton(
                          style: OutlinedButton.styleFrom(
                            side: const BorderSide(color: Color(0xFF047857), width: 2),
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                          ),
                          onPressed: () => Navigator.pushReplacementNamed(context, '/ownerHome'),
                          child: const Text('Entrar como Dueño', style: TextStyle(fontSize: 16, color: Color(0xFF047857), fontWeight: FontWeight.w600)),
                        ),
                      ).animate().fadeIn(delay: 700.ms).scale(),

                      const SizedBox(height: 12),

                      // Botón del usuario penalizado
                      SizedBox(
                        width: double.infinity,
                        height: 50,
                        child: TextButton(
                          style: TextButton.styleFrom(
                            side: const BorderSide(color: Color.fromARGB(255, 197, 20, 20), width: 2),
                            foregroundColor: const Color.fromARGB(255, 197, 20, 20),
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                          ),
                          onPressed: () => _showPenaltyDialog(context),
                          child: const Text('Usuario Penalizado', style: TextStyle(fontSize: 14, fontWeight: FontWeight.w600)),
                        ),
                      ).animate().fadeIn(delay: 800.ms).scale(),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}