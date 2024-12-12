library;

import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

export 'package:dapp/l10n/localization_context.dart';
export 'package:flutter_gen/gen_l10n/app_localizations.dart';

extension LocalizationContext on BuildContext {
  AppLocalizations get localizations => AppLocalizations.of(this)!;
}