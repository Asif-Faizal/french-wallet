import 'package:ewallet2/presentation/screens/dashboard/agent/agent_home_screen.dart';
import 'package:ewallet2/presentation/screens/dashboard/coorporate/coorporate_home_screen.dart';
import 'package:ewallet2/presentation/screens/dashboard/retail/retail_home_screen.dart';
import 'package:ewallet2/presentation/screens/initial/corporate_promot_screen.dart';
import 'package:ewallet2/presentation/screens/login/executive_login_screen.dart';
import 'package:ewallet2/presentation/screens/services/coorporate/view_child_card_screen.dart';
import 'package:ewallet2/presentation/screens/services/shared/search_user_screen.dart';
import 'package:ewallet2/presentation/screens/services/shared/completed_screen.dart';
import 'package:ewallet2/presentation/screens/services/shared/enter_amount_screen.dart';
import 'package:ewallet2/presentation/screens/services/shared/error_screen.dart';
import 'package:ewallet2/presentation/screens/signup_screen/add_email_screen.dart';
import 'package:ewallet2/presentation/screens/signup_screen/address_screen.dart';
import 'package:ewallet2/presentation/screens/signup_screen/business%20owner/business_info.dart';
import 'package:ewallet2/presentation/screens/signup_screen/business%20owner/financial_info_screen.dart';
import 'package:ewallet2/presentation/screens/signup_screen/business%20owner/upload_docs_screen.dart';
import 'package:ewallet2/presentation/screens/signup_screen/identity_verify_screen.dart';
import 'package:ewallet2/presentation/screens/signup_screen/income_screen.dart';
import 'package:ewallet2/presentation/screens/signup_screen/personal_details_screen.dart';
import 'package:ewallet2/presentation/screens/signup_screen/politically_screen.dart';
import 'package:ewallet2/presentation/screens/signup_screen/privacy_policy_screen.dart';
import 'package:ewallet2/presentation/screens/signup_screen/sent_otp_screen.dart';
import 'package:ewallet2/presentation/screens/signup_screen/set_passcode_screen.dart';
import 'package:ewallet2/presentation/screens/signup_screen/take_selfie_screen.dart';
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
      ),
      GoRoute(
        path: '/personalDetails',
        name: 'personalDetails',
        builder: (context, state) => const PersonalDetailsScreen(),
      ),
      GoRoute(
        path: '/addressDetails',
        name: 'addressDetails',
        builder: (context, state) => const AddressDetailsScreen(),
      ),
      GoRoute(
        path: '/addEmail',
        name: 'addEmail',
        builder: (context, state) => const EmailDetailsScreen(),
      ),
      GoRoute(
        path: '/incomeDetails',
        name: 'incomeDetails',
        builder: (context, state) => const OccupationIncomeDetailsScreen(),
      ),
      GoRoute(
        path: '/politicallyExposed',
        name: 'politicallyExposed',
        builder: (context, state) => const PoliticallyExposedScreen(),
      ),
      GoRoute(
        path: '/privacyPolicy',
        name: 'privacyPolicy',
        builder: (context, state) => const PrivacyPolicyScreen(),
      ),
      GoRoute(
        path: '/selfie',
        name: 'selfie',
        builder: (context, state) => TakeSelfieScreen(),
      ),
      GoRoute(
        path: '/setPassCode',
        name: 'setPassCode',
        builder: (context, state) => SetPasscodeScreen(),
      ),
      GoRoute(
        path: '/retailHome',
        name: 'retailHome',
        builder: (context, state) => RetailHomeScreen(),
      ),
      GoRoute(
        path: '/agentHome',
        name: 'agentHome',
        builder: (context, state) => AgentHomeScreen(),
      ),
      GoRoute(
        path: '/executiveLogin',
        name: 'executiveLogin',
        builder: (context, state) => const ExecutiveLoginScreen(),
      ),
      GoRoute(
        path: '/financialInfo',
        name: 'financialInfo',
        builder: (context, state) => FinancialInfoScreen(),
      ),
      GoRoute(
        path: '/businessInfo',
        name: 'businessInfo',
        builder: (context, state) => BusinessInfoScreen(),
      ),
      GoRoute(
        path: '/uploadPdf',
        name: 'uploadPdf',
        builder: (context, state) => UploadPdfScreen(),
      ),
      GoRoute(
        path: '/coorporateHome',
        name: 'coorporateHome',
        builder: (context, state) => CoorporateHomeScreen(),
      ),
      GoRoute(
        path: '/searchUser',
        name: 'searchUser',
        builder: (context, state) => SearchUserScreen(),
      ),
      GoRoute(
        path: '/enterAmount',
        name: 'enterAmount',
        builder: (context, state) => EnterAmountPage(),
      ),
      GoRoute(
        path: '/completedAnimation',
        name: 'completedAnimation',
        builder: (context, state) => CompletedAnimationScreen(),
      ),
      GoRoute(
        path: '/errorAnimation',
        name: 'errorAnimation',
        builder: (context, state) => ErrorAnimationScreen(),
      ),
      GoRoute(
        path: '/viewChildCard',
        name: 'viewChildCard',
        builder: (context, state) => ViewChildCardScreen(),
      )
    ],
  );
}
