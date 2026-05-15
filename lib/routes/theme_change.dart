import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:github_client_app/l10n/app_localizations.dart';
import 'package:github_client_app/states/profile_state.dart';
import '../common/global.dart';
import '../common/logger.dart';

final _log = createLogger('ThemeChangeRoute');

class ThemeChangeRoute extends ConsumerWidget {
  const ThemeChangeRoute({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context);
    return Scaffold(
      appBar: AppBar(
        title: Text(l10n.theme),
      ),
      body: ListView(
        children: Global.themes.map((e) {
          return GestureDetector(
            child: Padding(
              padding: const EdgeInsets.symmetric(vertical: 5, horizontal: 10),
              child: Container(
                color: e,
                height: 40,
              ),
            ),
            onTap: () {
              _log.i('Theme selected, swatch=${e.toARGB32()}');
              ref.read(profileProvider.notifier).updateTheme(e);
            },
          );
        }).toList(),
      ),
    );
  }
}
