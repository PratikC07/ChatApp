import 'package:chat_app/core/services/database_service.dart';
import 'package:chat_app/core/utils/route_utils.dart';
import 'package:chat_app/ui/screens/other/user_provider.dart';
import 'package:chat_app/ui/screens/splash/splash_screen.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:provider/provider.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();
  await Supabase.initialize(
    url: 'SUPABASE_URL',
    anonKey:
        'SUPABASE_ANON_KEY',)
  runApp(const ChatApp());
}

class ChatApp extends StatelessWidget {
  const ChatApp({super.key});

  @override
  Widget build(BuildContext context) {
    return ScreenUtilInit(
      builder:
          (context, child) => ChangeNotifierProvider(
            create: (context) => UserProvider(DatabaseService()),

            child: MaterialApp(
              debugShowCheckedModeBanner: false,
              onGenerateRoute: RouteUtils.onGenerateRoute,
              home: SplashScreen(),
            ),
          ),
    );
  }
}
