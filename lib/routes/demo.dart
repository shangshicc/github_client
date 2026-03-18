import 'package:flutter/material.dart';
import 'package:github_client_app/common/funs.dart';
import 'package:github_client_app/l10n/app_localizations.dart';

class DemoRoute extends StatelessWidget {
  const DemoRoute({super.key});

  @override
  Widget build(BuildContext context) {
    // 运行时常量
    final l10n = AppLocalizations.of(context);
    return Scaffold(
      appBar: AppBar(
        title: Text(l10n.demo),
      ),
      body: ListView(
        children: [
          Column(
            children: [
              ElevatedButton(onPressed: onPressed, child: Text(
                  l10n.demo
              ))
            ],
          ),
        ],
      ),
    );
  }

  void onPressed() {
    showToast("test");
  }
}
