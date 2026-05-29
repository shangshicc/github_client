import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:github_client_app/l10n/app_localizations.dart';
import 'package:github_client_app/states/profile_state.dart';

class LanguageRoute extends ConsumerWidget {
  const LanguageRoute({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final Color selectedColor = Theme.of(context).colorScheme.primary;
    final String? localeCode = ref.watch(localeCodeProvider);
    final AppLocalizations l10n = AppLocalizations.of(context);

    Widget buildLanguageItem(String lan, String? value) {
      return ListTile(
        title: Text(
          lan,
          style: TextStyle(color: localeCode == value ? selectedColor : null),
        ),
        trailing:
            localeCode == value ? Icon(Icons.done, color: selectedColor) : null,
        onTap: () {
          ref.read(profileProvider.notifier).updateLocale(value);
        },
      );
    }

    return Scaffold(
      appBar: AppBar(title: Text(l10n.language)),
      body: ListView(
        children: [
          buildLanguageItem('中文简体', 'zh'),
          buildLanguageItem('English', 'en'),
          buildLanguageItem(l10n.auto, null),
        ],
      ),
    );
  }
}
