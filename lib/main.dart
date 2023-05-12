import 'package:flutter/material.dart';
import 'login_page.dart';
import 'admin_dashboard.dart';
import 'student_dashboard.dart';
import 'admin_search.dart';
import 'pending_reviews.dart';
import 'pending_resources.dart';
import 'approval_history.dart';
import 'student_search.dart';
import 'std_view_courses.dart';
import 'std_course_details.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'firebase_options.dart';
import 'admin_course_details.dart';
import 'admin_add_course.dart';
import 'admin_view_courses.dart';
import 'forgot_password.dart';
import 'package:flex_color_scheme/flex_color_scheme.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
  runApp(const MyApp());
}

class GlobalData {
  static String? userEmail;
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      routes: {
        '/loginPage': (context) => LoginPage(),
        '/forgotPassword': (context) => ForgotPasswordPage(),
        '/adminDashboard': (context) => AdminDashboard(),
        '/studentDashboard': (context) => StudentDashboard(
              userEmail: ModalRoute.of(context)!.settings.arguments as String,
            ),
        '/adminSearch': (context) => AdminSearch(
              searchQuery: ModalRoute.of(context)!.settings.arguments as String,
            ),
        '/admin_course_details': (context) => AdminCourseDetails(
              courseData: ModalRoute.of(context)!.settings.arguments
                  as Map<String, dynamic>,
            ),
        '/adminAddCourse': (context) => AdminAddCourse(),
        '/viewAllCourses': (context) => ViewAllCourses(),
        '/studentSearch': (context) => StudentSearch(
              searchDetails: ModalRoute.of(context)!.settings.arguments
                  as Map<String, dynamic>,
            ),
        '/pendingReviews': (context) => PendingReviewsPage(),
        '/pendingResources': (context) => PendingResourcesPage(),
        '/approvalHistory': (context) => ApprovalHistoryPage(),
        '/stdViewCourses': (context) => StudentViewCourses(
              userEmail: ModalRoute.of(context)!.settings.arguments as String,
            ),
        '/std_course_details': (context) => StudentCourseDetails(
              courseData: ModalRoute.of(context)!.settings.arguments
                  as Map<String, dynamic>,
            ),
      },
      title: 'Course Tracker',
      //theme: ThemeData(
      //  primarySwatch: Colors.blue,
      //),
      theme: FlexThemeData.light(
        scheme: FlexScheme.blumineBlue,
        surfaceMode: FlexSurfaceMode.highSurfaceLowScaffold,
        blendLevel: 22,
        appBarStyle: FlexAppBarStyle.primary,
        appBarOpacity: 0.9,
        appBarElevation: 11,
        transparentStatusBar: true,
        tabBarStyle: FlexTabBarStyle.forAppBar,
        tooltipsMatchBackground: true,
        swapColors: false,
        lightIsWhite: false,
        //useSubThemes: true,
        visualDensity: FlexColorScheme.comfortablePlatformDensity,
        // To use playground font, add GoogleFonts package and uncomment:
        // fontFamily: GoogleFonts.notoSans().fontFamily,
        subThemesData: const FlexSubThemesData(
          useTextTheme: true,
          fabUseShape: true,
          interactionEffects: true,
          bottomNavigationBarElevation: 0,
          bottomNavigationBarOpacity: 0.95,
          navigationBarOpacity: 0.95,
          //navigationBarMutedUnselectedText: true,
          navigationBarMutedUnselectedIcon: true,
          inputDecoratorIsFilled: true,
          inputDecoratorBorderType: FlexInputBorderType.underline,
          inputDecoratorUnfocusedHasBorder: false,
          //inputDecoratorSchemeColor: SchemeColor.primaryVariant,
          blendOnColors: true,
          blendTextTheme: true,
          popupMenuOpacity: 0.95,
        ),
      ),

// If you do not have a themeMode switch, uncomment this line
// to let the device system mode control the theme mode:
      themeMode: ThemeMode.system,

      home: const LoginPage(),
    );
  }
}
