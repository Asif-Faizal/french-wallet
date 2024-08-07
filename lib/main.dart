import 'package:ewallet2/data/checkmobile/checkmobile_datasource.dart';
import 'package:ewallet2/data/checkmobile/checkmobile_repo_impl.dart';
import 'package:ewallet2/data/documents/doc_datasource.dart';
import 'package:ewallet2/data/documents/doc_repo.dart';
import 'package:ewallet2/data/image/image_datasource.dart';
import 'package:ewallet2/data/image/image_repo.dart';
import 'package:ewallet2/data/login/login_datasource.dart';
import 'package:ewallet2/data/wallet/wallet_datasource.dart';
import 'package:ewallet2/domain/login/login_repo_impl.dart';
import 'package:ewallet2/data/signup/industry_sector/industry_sector_datasource.dart';
import 'package:ewallet2/data/signup/industry_sector/industry_sector_repo_impl.dart';
import 'package:ewallet2/domain/checkmobile/checkmobile.dart';
import 'package:ewallet2/domain/documents/upload_doc.dart';
import 'package:ewallet2/domain/image/upload_image.dart';
import 'package:ewallet2/domain/login/login.dart';
import 'package:ewallet2/domain/wallet/get_wallet_details.dart';
import 'package:ewallet2/domain/wallet/wallet_repo_impl.dart';
import 'package:ewallet2/presentation/bloc/change_card_pin/change_card_pin_bloc.dart';
import 'package:ewallet2/presentation/bloc/change_card_status/change_card_status_bloc.dart';
import 'package:ewallet2/presentation/bloc/sent_card_otp/sent_card_otp_bloc.dart';
import 'package:ewallet2/presentation/bloc/verify_card_pin/verify_card_pin_bloc.dart';
import 'package:ewallet2/presentation/bloc/documents/doc_bloc.dart';
import 'package:ewallet2/presentation/bloc/image/image_bloc.dart';
import 'package:ewallet2/presentation/bloc/login/login_bloc.dart';
import 'package:ewallet2/presentation/bloc/wallet/wallet_bloc.dart';
import 'package:ewallet2/shared/config/api_config.dart';
import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'data/signup/business_type/business_info_datasource.dart';
import 'data/signup/business_type/business_info_repo_impl.dart';
import 'domain/signup/business_type/get_business_type.dart';
import 'domain/signup/industry_sector/get_industry_sector.dart';
import 'l10n/l10n.dart';
import 'presentation/bloc/business info/business_info_bloc.dart';
import 'presentation/bloc/checkmobile/checkmobile_bloc.dart';
import 'presentation/bloc/industry sector/industry_sector_bloc.dart';
import 'presentation/bloc/language/localization_bloc.dart';
import 'presentation/bloc/wallet/wallet_event.dart';
import 'shared/theme/theme.dart';
import 'shared/router/router_config.dart';
import 'package:http/http.dart' as http;

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  final prefs = await SharedPreferences.getInstance();
  final bool isLoggedIn = prefs.getBool('isLoggedIn') ?? false;
  final walletDataSource = WalletDataSource();
  final walletRepository = WalletRepositoryImpl(walletDataSource);
  final getWalletDetails = GetWalletDetails(walletRepository);

  runApp(MyApp(
    getWalletDetails: getWalletDetails,
    isLoggedIn: isLoggedIn,
  ));
}

class MyApp extends StatelessWidget {
  final bool isLoggedIn;
  final GetWalletDetails getWalletDetails;
  MyApp({super.key, required this.getWalletDetails, required this.isLoggedIn});
  @override
  Widget build(BuildContext context) {
    return MultiBlocProvider(
      providers: [
        BlocProvider<LocalizationBloc>(
          create: (_) => LocalizationBloc(),
        ),
        BlocProvider<BusinessTypeBloc>(
          create: (context) => BusinessTypeBloc(
            getBusinessTypes: GetBusinessTypes(
              repository: BusinessInfoRepositoryImpl(
                dataSource: BusinessInfoDataSourceImpl(
                  client: http.Client(),
                ),
              ),
            ),
          )..add(FetchBusinessTypes()),
        ),
        BlocProvider<IndustrySectorBloc>(
          create: (context) => IndustrySectorBloc(
            getIndustrySectors: GetIndustrySectors(
              repository: IndustrySectorRepositoryImpl(
                dataSource: IndustrySectorDataSourceImpl(
                  client: http.Client(),
                ),
              ),
            ),
          )..add(FetchIndustrySectors()),
        ),
        BlocProvider<UploadImageBloc>(
            create: (context) => UploadImageBloc(
                uploadImageUseCase: UploadImageUseCase(
                    repository: ImageRepository(
                        dataSource:
                            ImageDataSource(uploadUrl: Config.upload_image))))),
        BlocProvider(
            create: (context) => UploadPdfBloc(UploadPdfUseCase(
                UploadPdfRepositoryImpl(
                    UploadPdfDataSourceImpl(http.Client()))))),
        BlocProvider<CheckMobileBloc>(
          create: (context) => CheckMobileBloc(
              checkMobileUseCase: CheckMobileUseCase(
                  checkMobileRepository: CheckMobileRepositoryImpl(
                      dataSource: CheckMobileDataSourceImpl()))),
        ),
        BlocProvider<LoginBloc>(
            create: (context) => LoginBloc(
                loginUseCase: LoginUseCase(
                    repository: LoginRepositoryImpl(
                        dataSource: LoginDataSourceImpl())))),
        BlocProvider<WalletBloc>(
            create: (context) => WalletBloc(getWalletDetails: getWalletDetails)
              ..add(FetchWalletDetails())),
        BlocProvider(create: (context) => VerifyCardPinBloc()),
        BlocProvider(create: (context) => SentCardOtpBloc()),
        BlocProvider(create: (context) => ChangeCardPinBloc()),
        BlocProvider(create: (context) => ChangeCardStatusBloc())
      ],
      child: MyAppView(
        isLoggedIn: isLoggedIn,
      ),
    );
  }
}

class MyAppView extends StatelessWidget {
  final bool isLoggedIn;
  const MyAppView({super.key, required this.isLoggedIn});

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<LocalizationBloc, LocalizationState>(
      builder: (context, state) {
        final router = GoRouter(
          initialLocation: isLoggedIn ? '/login' : '/',
          routes: AppRouter.routes,
        );
        return MaterialApp.router(
          debugShowCheckedModeBanner: false,
          routerConfig: router,
          locale: state.locale,
          supportedLocales: L10n.all,
          localizationsDelegates: const [
            AppLocalizations.delegate,
            GlobalMaterialLocalizations.delegate,
            GlobalCupertinoLocalizations.delegate,
            GlobalWidgetsLocalizations.delegate,
          ],
          title: 'ePurse',
          theme: AppThemes.lightTheme,
          darkTheme: AppThemes.darkTheme,
          themeMode: ThemeMode.system,
        );
      },
    );
  }
}
