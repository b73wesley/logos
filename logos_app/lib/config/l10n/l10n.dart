import 'package:logos_app/config/l10n/arb/app_localizations.dart';
import 'package:flutter/material.dart';

extension AppLocalizationsX on BuildContext {
  AppLocalizations get l10n => AppLocalizations.of(this)!;
}
