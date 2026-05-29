import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:github_client_app/common/app_theme.dart';
import 'package:github_client_app/l10n/app_localizations.dart';
import 'package:github_client_app/states/profile_state.dart';

import '../common/logger.dart';

final _log = createLogger('ThemeChangeRoute');

class ThemeChangeRoute extends ConsumerWidget {
  const ThemeChangeRoute({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final AppLocalizations l10n = AppLocalizations.of(context);
    final AppSkin currentSkin = ref.watch(skinProvider);
    final Color selectedColor = Theme.of(context).colorScheme.primary;

    return Scaffold(
      appBar: AppBar(title: Text(l10n.theme)),
      body: ListView(
        children: <Widget>[
          ListTile(title: Text(l10n.theme)),
          ...AppTheme.skins.map((AppSkin skin) {
            final bool selected = currentSkin.id == skin.id;
            return ListTile(
              key: ValueKey<String>('skin-${skin.id}'),
              leading: CircleAvatar(backgroundColor: skin.swatch),
              title: Text(skin.label),
              trailing:
                  selected ? Icon(Icons.done, color: selectedColor) : null,
              onTap: () {
                _log.i('Skin selected, skin=${skin.id}');
                ref.read(profileProvider.notifier).updateSkin(skin.id);
              },
            );
          }),
        ],
      ),
    );
  }
}
