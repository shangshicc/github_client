import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:github_client_app/common/global.dart';
import 'package:github_client_app/models/index.dart';
import 'package:github_client_app/states/profile_state.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  setUp(() async {
    SharedPreferences.setMockInitialValues(<String, Object>{});
    await Global.init();
    Global.profile = Profile()..theme = Global.themes.first.toARGB32();
  });

  test('updateUser 在 user 与 cache 为空时不应因克隆 Profile 崩溃', () async {
    final ProviderContainer container = ProviderContainer();
    addTearDown(container.dispose);

    final ProfileNotifier notifier = container.read(profileProvider.notifier);
    final User user = User()
      ..login = 'tester'
      ..id = 1;

    await expectLater(notifier.updateUser(user), completes);

    final Profile profile = container.read(profileProvider);
    expect(profile.user?.login, 'tester');
    expect(profile.lastLogin, isNull);
  });
}
