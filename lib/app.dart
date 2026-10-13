import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'core/theme/app_theme.dart';
import 'data/repositories/image_repository.dart';
import 'data/services/download_service.dart';
import 'data/services/favorites_storage.dart';
import 'data/services/pixabay_api_service.dart';
import 'presentation/providers/favorites_provider.dart';
import 'presentation/providers/gallery_provider.dart';
import 'presentation/providers/theme_provider.dart';
import 'presentation/screens/home_shell.dart';


class InfiniteGalleryApp extends StatelessWidget {
  const InfiniteGalleryApp({super.key, required this.prefs});

  final SharedPreferences prefs;

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        
        Provider<ImageRepository>(
          create: (_) => PixabayImageRepository(PixabayApiService()),
        ),
        Provider<DownloadService>(create: (_) => DownloadService()),

        
        ChangeNotifierProvider(create: (_) => ThemeProvider(prefs)),
        ChangeNotifierProvider(
          create: (_) => FavoritesProvider(FavoritesStorage(prefs)),
        ),
        ChangeNotifierProvider(
          lazy: false, 
          create: (context) =>
              GalleryProvider(context.read<ImageRepository>())..loadInitial(),
        ),
      ],
      
      child: Consumer<ThemeProvider>(
        builder: (context, theme, _) => MaterialApp(
          title: 'Infinite Gallery',
          debugShowCheckedModeBanner: false,
          theme: AppTheme.light,
          darkTheme: AppTheme.dark,
          themeMode: theme.mode,
          home: const HomeShell(),
        ),
      ),
    );
  }
}