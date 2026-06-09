import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// Local, on-device preferences. Nothing sensitive lives here — just UI choices
/// (whether onboarding has been seen, whether the balance is hidden by default).
class PrefsService {
  PrefsService(this._prefs);

  final SharedPreferences _prefs;

  static const String _kOnboardingSeen = 'onboarding_seen';
  static const String _kBalanceHidden = 'balance_hidden';

  bool get onboardingSeen => _prefs.getBool(_kOnboardingSeen) ?? false;
  Future<void> setOnboardingSeen(bool value) =>
      _prefs.setBool(_kOnboardingSeen, value);

  bool get balanceHidden => _prefs.getBool(_kBalanceHidden) ?? false;
  Future<void> setBalanceHidden(bool value) =>
      _prefs.setBool(_kBalanceHidden, value);
}

/// Overridden in `main()` once [SharedPreferences] has loaded, so the rest of
/// the app can read prefs synchronously.
final sharedPreferencesProvider = Provider<SharedPreferences>(
  (ref) => throw UnimplementedError('Override in main() after loading prefs'),
);

final prefsServiceProvider = Provider<PrefsService>(
  (ref) => PrefsService(ref.watch(sharedPreferencesProvider)),
);

/// Reactive balance-visibility state, persisted to prefs. Shared by the
/// dashboard toggle and the settings default.
class BalanceVisibilityNotifier extends Notifier<bool> {
  @override
  bool build() => ref.read(prefsServiceProvider).balanceHidden;

  Future<void> toggle() => set(!state);

  Future<void> set(bool hidden) async {
    state = hidden;
    await ref.read(prefsServiceProvider).setBalanceHidden(hidden);
  }
}

final balanceHiddenProvider = NotifierProvider<BalanceVisibilityNotifier, bool>(
  BalanceVisibilityNotifier.new,
);
