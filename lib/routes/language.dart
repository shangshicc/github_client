import 'package:flutter/material.dart';
import 'package:github_client_app/l10n/app_localizations.dart';
import 'package:github_client_app/states/profile_change_notifier.dart';
import 'package:provider/provider.dart';

class LanguageRoute extends StatelessWidget {
  const LanguageRoute({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    var color = Theme.of(context).primaryColor;
    var localModel = Provider.of<LocaleModel>(context);
    final l10n = AppLocalizations.of(context);

  Widget buildLanguageItem(String lan, value) {
    return ListTile(
      title: Text(
        lan, style: TextStyle(color: localModel.locale == value ? color : null),
      ),
      trailing: localModel.locale == value ? Icon(Icons.done, color: color) : null,
      onTap: () {
        // 此行代码会通知MaterialApp重写build
        localModel.locale = value;
      },
    );
  }

    return Scaffold(
      appBar: AppBar(
        title: Text(l10n.language),
      ),
      body: ListView(
        children: [
          buildLanguageItem("中文简体", "zh"),
          buildLanguageItem("English", "en"),
          buildLanguageItem(l10n.auto, null),
        ],
      ),
    );
  }
}