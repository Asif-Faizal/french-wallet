import 'package:ewallet2/presentation/screens/initial/corporate_promot_screen.dart';
import 'package:ewallet2/presentation/screens/signup_screen/identity_verify_screen.dart';
import 'package:ewallet2/presentation/screens/signup_screen/sent_otp_screen.dart';
import 'package:ewallet2/presentation/screens/signup_screen/upload_id_screen.dart';
import 'package:ewallet2/presentation/screens/signup_screen/verify_number_screen.dart';
import 'package:go_router/go_router.dart';

import '../../presentation/screens/initial/loginorsignup_screen.dart';
import '../../presentation/screens/initial/prompt_screen.dart';
import '../../presentation/screens/login/login_screen.dart';

class AppRouter {
  static final router = GoRouter(
    initialLocation: '/',
    routes: [
      GoRoute(
        name: 'prompt',
        path: '/',
        builder: (context, state) => const PromptScreen(),
      ),
      GoRoute(
        path: '/corporatePrompt',
        name: 'corporatePrompt',
        builder: (context, state) => const CorporatePromptScreen(),
      ),
      GoRoute(
        name: 'loginOrSignup',
        path: '/login_or_signup',
        builder: (context, state) => const LoginOrSignupScreen(),
      ),
      GoRoute(
        name: 'login',
        path: '/login',
        builder: (context, state) => const LoginScreen(),
      ),
      GoRoute(
        name: 'verifyNumber',
        path: '/verifyNumber',
        builder: (context, state) => const VerifyNumber(),
      ),
      GoRoute(
        name: 'sentOtpSignIn',
        path: '/sentOtpSignIn',
        builder: (context, state) => const SentOtpSignInScreen(),
      ),
      GoRoute(
        path: '/identityVerify',
        name: 'identityVerify',
        builder: (context, state) => const IdentityVerifyScreen(),
      ),
      GoRoute(
        path: '/uploadIdScreen',
        name: 'uploadIdScreen',
        builder: (context, state) => const UploadIdScreen(),
      )
    ],
  );
}
