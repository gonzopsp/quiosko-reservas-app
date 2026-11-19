import 'package:material_ui/material_ui.dart';
import 'package:google_fonts/google_fonts.dart';
import 'screens/login_screen.dart';
import 'screens/user_home_screen.dart';
import 'screens/owner_home_screen.dart';
import 'data/database.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Database.initializeImages();
  runApp(const QuioscoApp());
}

class QuioscoApp extends StatelessWidget {
  const QuioscoApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Reserva Quiosco',
      theme: ThemeData(
        // Paleta de colores moderna
        colorScheme: ColorScheme.fromSeed(
          seedColor: const Color(0xFF2563EB), // Un azul vibrante
          primary: const Color(0xFF2563EB),
          secondary: const Color(0xFFF59E0B), // Naranja para contrastes
        ),
        // Conserva el TextTheme de Flutter y aplica la familia tipográfica Poppins.
        textTheme: ThemeData.light()
            .textTheme
            .apply(fontFamily: GoogleFonts.poppins().fontFamily),
        useMaterial3: true,
      ),
      initialRoute: '/login',
      routes: {
        '/login': (context) => const LoginScreen(),
        '/userHome': (context) => const UserHomeScreen(),
        '/ownerHome': (context) => const OwnerHomeScreen(),
      },
    );
  }
}