import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:sam_gig/core/config/app_config.dart';
import 'package:sam_gig/data/services/favorites_storage.dart';
import 'package:sam_gig/presentation/providers/favorites_provider.dart';
import 'package:sam_gig/presentation/screens/favorites_screen.dart';

import 'package:provider/provider.dart';
import 'package:sam_gig/presentation/screens/widgets/status_view.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  test('AppConfig exposes a valid default Pixabay API key', () {
    expect(AppConfig.pixabayApiKey, isNotEmpty);
  });

  testWidgets('StatusView shows its message and triggers the action', (
    tester,
  ) async {
    var retried = false;

    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: StatusView(
            icon: Icons.error_outline,
            title: 'Oops!',
            message: 'Boom',
            actionLabel: 'Try again',
            onAction: () => retried = true,
          ),
        ),
      ),
    );

    expect(find.text('Boom'), findsOneWidget);
    await tester.tap(find.text('Try again'));
    expect(retried, isTrue);
  });

  testWidgets('FavoritesScreen shows the empty state when nothing is saved', (
    tester,
  ) async {
    SharedPreferences.setMockInitialValues({});
    final prefs = await SharedPreferences.getInstance();

    await tester.pumpWidget(
      ChangeNotifierProvider(
        create: (_) => FavoritesProvider(FavoritesStorage(prefs)),
        child: const MaterialApp(home: FavoritesScreen()),
      ),
    );

    expect(find.text('No favorites yet'), findsOneWidget);
  });
}

