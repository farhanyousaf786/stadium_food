import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:flutter_stripe/flutter_stripe.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:stadium_food/src/app.dart';
import 'package:stadium_food/src/bloc/chat/chat_bloc.dart';
import 'package:stadium_food/src/bloc/food/food_bloc.dart';
import 'package:stadium_food/src/bloc/forgot_password/forgot_password_bloc.dart';
import 'package:stadium_food/src/bloc/login/login_bloc.dart';
import 'package:stadium_food/src/bloc/menu/menu_bloc.dart';
import 'package:stadium_food/src/bloc/offer/offer_bloc.dart';
import 'package:stadium_food/src/bloc/order/order_bloc.dart';
import 'package:stadium_food/src/bloc/order_detail/order_detail_bloc.dart';
import 'package:stadium_food/src/bloc/profile/profile_bloc.dart';
import 'package:stadium_food/src/bloc/register/register_bloc.dart';
import 'package:stadium_food/src/bloc/language/language_bloc.dart';
import 'package:stadium_food/src/bloc/settings/settings_bloc.dart';
import 'package:stadium_food/src/bloc/testimonial/testimonial_bloc.dart';
import 'package:stadium_food/src/bloc/theme/theme_bloc.dart';
import 'package:stadium_food/src/bloc/stadium/stadium_bloc.dart';
import 'package:stadium_food/src/bloc/shop/shop_bloc.dart';
import 'package:stadium_food/src/data/repositories/offer_repository.dart';
import 'package:stadium_food/src/data/repositories/order_repository.dart';
import 'package:stadium_food/src/data/services/hive_adapters.dart';
import 'package:stadium_food/src/services/notification_class.dart';
import 'package:stadium_food/src/core/config/app_config.dart';
import 'package:stadium_food/src/core/config/stadium_theme.dart';
import 'package:stadium_food/src/core/config/stripe_config.dart';
import 'package:stadium_food/src/data/models/stadium.dart';
import 'package:stadium_food/src/data/services/currency_service.dart';
import 'package:stadium_food/src/presentation/utils/app_colors.dart';
import 'firebase_options.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  
  if (Firebase.apps.isEmpty) {
    await Firebase.initializeApp(
      options: DefaultFirebaseOptions.currentPlatform,
    );
  }
  
  // Load environment variables from .env (fallback keys only)
  await dotenv.load(fileName: '.env');

  // Admin Stripe test/live mode + publishable key (matches web /api/config)
  try {
    await AppConfig.load();
  } catch (_) {
    // Fall back to .env StripeConfig if server config is unreachable
  }

  Stripe.publishableKey = StripeConfig.publishableKey;
  Stripe.merchantIdentifier = 'merchant.com.fanmunch';
  await Stripe.instance.applySettings();
  debugPrint(
    '[Stripe] mode=${StripeConfig.mode} useTestApis=${AppConfig.useTestApis} '
    'key=${Stripe.publishableKey.substring(0, 12)}…',
  );

  await Hive.initFlutter();
  Hive.registerAdapter(FirestoreDocumentReferenceAdapter());
//  Hive.registerAdapter(RestaurantAdapter());
  Hive.registerAdapter(FoodAdapter());
  await Hive.openBox('myBox');

  // Restore venue theme from previously selected stadium
  ThemeData? restoredTheme;
  try {
    final saved = Hive.box('myBox').get('selectedStadium');
    if (saved is Map && saved['id'] != null) {
      final stadium = Stadium.fromHiveMap(Map<String, dynamic>.from(saved));
      final venue = StadiumTheme.fromStadium(stadium);
      AppColors.brandName = venue.appName;
      AppColors.logoUrl = venue.logoUrl;
      AppColors.bannerUrl = venue.bannerUrl;
      restoredTheme = venue.apply();
    }
  } catch (_) {}

  // Initialize currency exchange rates (12h cache)
  await CurrencyService.initializeRates();

  OrderRepository.loadCart();
  NotificationServiceClass().initMessaging();

  runApp(
    MultiBlocProvider(
      providers: [
        BlocProvider(
          create: (context) => RegisterBloc(),
        ),
        BlocProvider(
          create: (context) => LoginBloc(),
        ),
        BlocProvider(
          create: (context) => ForgotPasswordBloc(),
        ),
        BlocProvider(
          create: (context) => FoodBloc(),
        ),
        BlocProvider(
          create: (context) => ProfileBloc(),
        ),
        BlocProvider(
          create: (context) => OrderBloc(),
        ),
        BlocProvider(
          create: (context) => OrderDetailBloc(),
        ),
        BlocProvider(
          create: (context) => TestimonialBloc(),
        ),
        BlocProvider(
          create: (context) => ChatBloc(),
        ),
        BlocProvider(
          create: (context) => SettingsBloc(),
        ),
        BlocProvider(
          create: (context) {
            final bloc = ThemeBloc();
            if (restoredTheme != null) {
              bloc.add(ChangeTheme(themeData: restoredTheme));
            }
            return bloc;
          },
        ),
        BlocProvider(
          create: (context) => StadiumBloc(),
        ),
        BlocProvider(
          create: (context) => ShopBloc(),
        ),
        BlocProvider(
          create: (context) => MenuBloc(),
        ),
        BlocProvider(
          create: (context) => OfferBloc(
            offerRepository: OfferRepository(),
          ),
        ),
        BlocProvider(
          create: (context) => LanguageBloc()..add(LanguageLoadStarted()),
        ),
      ],
      child: const MyApp(),
    ),
  );
}
//