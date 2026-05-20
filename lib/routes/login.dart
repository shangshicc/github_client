import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:github_client_app/common/funs.dart';
import 'package:github_client_app/l10n/app_localizations.dart';
import 'package:github_client_app/models/index.dart';
import 'package:github_client_app/states/profile_state.dart';
import 'package:github_client_app/widgets/async_elevated_button.dart';

import '../common/git_api.dart';
import '../common/global.dart';

class LoginRoute extends ConsumerStatefulWidget {
  /// 创建登录页。
  ///
  /// [loginAction] 允许测试或上层注入自定义登录动作；为空时使用默认 GitHub 登录实现。
  /// [showLoadingIndicator] 表示是否在登录过程中额外展示全局 loading 对话框。
  const LoginRoute({
    super.key,
    this.loginAction,
    this.showLoadingIndicator = false,
  });

  /// 自定义登录动作。
  final Future<User> Function(String username, String password)? loginAction;

  /// 是否额外展示全局 loading 对话框。
  final bool showLoadingIndicator;

  @override
  ConsumerState<LoginRoute> createState() => _LoginRouteState();
}

class _LoginRouteState extends ConsumerState<LoginRoute> {
  final TextEditingController _unameController = TextEditingController();
  final TextEditingController _pwdController = TextEditingController();
  bool pwdShow = false;
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  bool _nameAutoFocus = false;

  @override
  void initState() {
    if (Global.profile.lastLogin != null) {
      _unameController.text = Global.profile.lastLogin!;
      if (_unameController.text.isNotEmpty) {
        _nameAutoFocus = false;
      }
    }
    super.initState();
  }

  @override
  void dispose() {
    _unameController.dispose();
    _pwdController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    return Scaffold(
      appBar: AppBar(title: Text(l10n.login)),
      body: Padding(
        padding: const EdgeInsets.all(10.0),
        child: Form(
          key: _formKey,
          autovalidateMode: AutovalidateMode.onUserInteraction,
          child: Column(
            children: [
              TextFormField(
                autofocus: _nameAutoFocus,
                controller: _unameController,
                decoration: InputDecoration(
                  labelText: l10n.userName,
                  hintText: l10n.userName,
                  prefixIcon: const Icon(Icons.person),
                ),
                // 效验用户名(不能为空)
                validator: (v) {
                  return v == null || v.trim().isNotEmpty
                      ? null
                      : l10n.userNameRequired;
                },
              ),
              TextFormField(
                controller: _pwdController,
                autofocus: !_nameAutoFocus,
                decoration: InputDecoration(
                  labelText: l10n.password,
                  hintText: l10n.password,
                  prefixIcon: const Icon(Icons.lock),
                  suffixIcon: IconButton(
                    icon: Icon(
                      pwdShow ? Icons.visibility_off : Icons.visibility,
                    ),
                    onPressed: () {
                      setState(() {
                        pwdShow = !pwdShow;
                      });
                    },
                  ),
                ),
                obscureText: !pwdShow,
                validator: (v) {
                  return v == null || v.trim().isNotEmpty
                      ? null
                      : l10n.passwordRequired;
                },
              ),
              Padding(
                padding: const EdgeInsets.only(top: 25),
                child: ConstrainedBox(
                  constraints: const BoxConstraints.expand(height: 55.0),
                  child: AsyncElevatedButton(
                    onPressed: _onLogin,
                    loadingChild: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: <Widget>[
                        const SizedBox(
                          width: 16,
                          height: 16,
                          child: CircularProgressIndicator(strokeWidth: 2),
                        ),
                        const SizedBox(width: 8),
                        Text(l10n.login),
                      ],
                    ),
                    child: Text(l10n.login),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  /// 执行登录动作并在成功后更新全局用户信息。
  ///
  /// 副作用：会校验表单、按配置展示或隐藏全局 loading，并在登录成功后写入 profile 状态与返回上一页。
  Future<void> _onLogin() async {
    final l10n = AppLocalizations.of(context);
    final navigator = Navigator.of(context);
    // 先验证各个表单字段是否合法
    if ((_formKey.currentState as FormState).validate()) {
      if (widget.showLoadingIndicator) {
        showLoading(context);
      }
      User? user;
      try {
        final Future<User> Function(String username, String password)
        loginAction = widget.loginAction ?? Git().login;
        user = await loginAction(_unameController.text, _pwdController.text);
        // 因为登录返回后，首页会build，所以我们传入false，这样更新user后便不触发更新。
        await ref.read(profileProvider.notifier).updateUser(user);
      } on DioException catch (e) {
        // 登录失败则提示
        if (e.response?.statusCode == 401) {
          // showToast
          showToast(l10n.userNameOrPasswordWrong);
        } else {
          showToast(e.toString());
        }
      } finally {
        // 隐藏loading框
        if (widget.showLoadingIndicator && navigator.canPop()) {
          navigator.pop();
        }
      }
      // 登录成功则返回
      if (user != null) {
        navigator.pop();
      }
    }
  }
}
