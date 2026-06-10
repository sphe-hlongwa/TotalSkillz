import 'package:sentry_flutter/sentry_flutter.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'router/app_router.dart';
import 'services/auth_service.dart';
import 'services/firestore_service.dart';
import 'services/quiz_service.dart';
import 'services/examiner_service.dart';
import 'services/masterclass_service.dart';
import 'services/discovery_service.dart';
import 'services/daily_challenge_service.dart';
import 'services/theme_service.dart';
import 'services/bug_report_service.dart';
import 'theme/app_theme.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  if (Firebase.apps.isEmpty) {
    await Firebase.initializeApp();
  }
  
  // Initialize ThemeService
  final themeService = ThemeService();
  await themeService.init();
  
  // Initialize Sentry and run app
  await SentryFlutter.init(
    (options) {
      options.dsn = 'https://58077086a3c2bd4c6d6f52c432a42ffd@o4511536084484096.ingest.us.sentry.io/4511536214114304';
      options.tracesSampleRate = 1.0;
      options.sendDefaultPii = true;
    },
    appRunner: () => runApp(TotalSkillzApp(themeService: themeService)),
  );
}

class TotalSkillzApp extends StatelessWidget {
  final ThemeService themeService;

  const TotalSkillzApp({
    required this.themeService,
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => themeService),
        ChangeNotifierProvider(create: (_) => AuthService()),
        ChangeNotifierProvider(create: (_) => FirestoreService()),
        ChangeNotifierProvider(create: (_) => QuizService()),
        ChangeNotifierProvider(create: (_) => ExaminerService()),
        ChangeNotifierProvider(create: (_) => MasterclassService()),
        ChangeNotifierProvider(create: (_) => DiscoveryService()),
        ChangeNotifierProvider(create: (_) => DailyChallengeService()),
        ChangeNotifierProvider(create: (_) => BugReportService()),
      ],
      child: Consumer<ThemeService>(
        builder: (context, themeService, _) {
          return MaterialApp.router(
            title: 'TotalSkillz',
            debugShowCheckedModeBanner: false,
            theme: themeService.isDarkMode ? AppTheme.dark : AppTheme.light,
            routerConfig: AppRouter.router,
          );
        },
      ),
    );
  }
}
