import 'package:flutter/material.dart';
import 'dart:convert';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:iidlive_app/plantillas/following_screen.dart';
import 'package:shared_preferences/shared_preferences.dart';

// Importaciones de pantallas
import 'package:iidlive_app/plantillas/home.dart';
import 'package:iidlive_app/plantillas/login.dart';
import 'package:iidlive_app/plantillas/registro.dart';
import 'package:iidlive_app/plantillas/reels.dart';
import 'package:iidlive_app/plantillas/post.dart';
import 'package:iidlive_app/plantillas/categorias.dart';
import 'package:iidlive_app/plantillas/lives.dart';
import 'package:iidlive_app/plantillas/todo_lives.dart';
import 'package:iidlive_app/plantillas/reelss.dart';
import 'package:iidlive_app/plantillas/Perfil_user.dart';
import 'package:iidlive_app/plantillas/editar_perfil.dart';
import 'package:iidlive_app/plantillas/followers_screen.dart';
import 'package:iidlive_app/plantillas/RecuperarContrasena.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  Future<Map<String, dynamic>> _getUserData() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final userData = prefs.getString('usuario');
      if (userData != null) {
        return jsonDecode(userData);
      } else {
        throw Exception("No se encontraron datos del usuario");
      }
    } catch (e) {
      throw Exception("Error al obtener los datos del usuario: $e");
    }
  }

  /// Widget de carga o error
  Widget _loadingOrError(AsyncSnapshot snapshot) {
    if (snapshot.connectionState == ConnectionState.waiting) {
      return const Scaffold(
        body: Center(child: CircularProgressIndicator()),
      );
    } else if (snapshot.hasError || !snapshot.hasData) {
      return const Scaffold(
        body: Center(child: Text('Error al cargar los datos del usuario')),
      );
    }
    return const SizedBox(); // Nunca se usa, pero el compilador lo pide
  }

  /// Método para construir rutas que necesitan datos del usuario
  Widget _buildFutureRoute(Widget Function(Map<String, dynamic>) builder) {
    return FutureBuilder<Map<String, dynamic>>(
      future: _getUserData(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting ||
            snapshot.hasError ||
            !snapshot.hasData) {
          return _loadingOrError(snapshot);
        } else {
          final usuario = snapshot.data!;
          return builder(usuario);
        }
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      localizationsDelegates: const [
        GlobalMaterialLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
      ],
      supportedLocales: const [
        Locale('es', 'ES'),
      ],
      locale: const Locale('es', 'ES'),
      initialRoute: '/login',
      routes: {
        
        'registro': (context) => const Registro(),
        '/recuperar': (context) => const RecuperarContrasena(),
        '/lives': (context) => const LiveStreamingPage(),
        '/salas': (context) => const LiveStreamingPages(),
        '/perfil': (context) => const PerfilScreen(),
        '/editar': (context) => const EditarPerfilScreen(),
        '/vistaReels': (context) => ReelsScreen(),
         '/login': (context) => Login(),
        // Rutas con FutureBuilder:
        '/home': (context) => _buildFutureRoute(
              (usuario) => Home(usuario: usuario),
            ),
        '/reels': (context) => _buildFutureRoute(
              (usuario) => SubirReelPage(
                userId: usuario['id'],
                usuario: usuario,
              ),
            ),
        '/post': (context) => _buildFutureRoute(
              (usuario) => CreatePostPage(
                userId: usuario['id'],
                usuario: usuario,
              ),
            ),
        '/followers': (context) => _buildFutureRoute(
              (usuario) => FollowersScreen(
                userId: usuario['id'],
                usuario: usuario,
              ),
            ),
          '/following': (context) => _buildFutureRoute(
              (usuario) => FollowingScreen(
                userId: usuario['id'],
                usuario: usuario,
              ),
            ),
        '/crear_categoria': (context) => _buildFutureRoute(
              (usuario) => CrearCategoriaScreen(
                userId: usuario['id'],
                usuario: usuario,
              ),
            ),
      },
    );
  }
}
