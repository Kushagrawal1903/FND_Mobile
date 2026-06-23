import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:truthlens/core/routing/app_router.dart';
import 'package:truthlens/core/theme/app_theme.dart';
import 'package:truthlens/core/storage/local_cache_service.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  
  // Initialize Local Cache (Hive)
  final localCache = LocalCacheService();
  await localCache.init();

  runApp(
    ProviderScope(
      overrides: [
        localCacheProvider.overrideWithValue(localCache),
      ],
      child: const TruthLensApp(),
    ),
  );
}

class TruthLensApp extends ConsumerWidget {
  const TruthLensApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final router = ref.watch(appRouterProvider);

    return MaterialApp.router(
      title: 'TruthLens',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.lightTheme,
      routerConfig: router,
    );
  }
}
