import 'package:google_sign_in/google_sign_in.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'firebase_options.dart';
import 'router/app_router.dart';
import 'services/auth_service.dart';
import 'services/firestore_service.dart';
import 'services/quiz_service.dart';
import 'services/examiner_service.dart';
import 'services/masterclass_service.dart';
import 'services/discovery_service.dart';
import 'services/daily_challenge_service.dart';
import 'theme/app_theme.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);
  await GoogleSignIn.instance.initialize();
  runApp(const TotalSkillzApp());
}

class TotalSkillzApp extends StatelessWidget {
  const TotalSkillzApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => AuthService()),
        ChangeNotifierProvider(create: (_) => FirestoreService()),
        ChangeNotifierProvider(create: (_) => QuizService()),
        ChangeNotifierProvider(create: (_) => ExaminerService()),
        ChangeNotifierProvider(create: (_) => MasterclassService()),
        ChangeNotifierProvider(create: (_) => DiscoveryService()),
        ChangeNotifierProvider(create: (_) => DailyChallengeService()),
      ],
      child: MaterialApp.router(
        title: 'TotalSkillz',
        debugShowCheckedModeBanner: false,
        theme: AppTheme.dark,
        routerConfig: AppRouter.router,
      ),
    );
  }
}
