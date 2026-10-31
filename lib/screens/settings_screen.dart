import 'package:flutter/material.dart';

import '../l10n/app_localizations.dart';
import '../utils/locale_notifier.dart';
import '../utils/theme_utils.dart';
import '../widgets/glass_app_bar.dart';

class SettingsScreen extends StatelessWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final topPadding = MediaQuery.of(context).padding.top + kToolbarHeight + 12;
    return Scaffold(
      extendBodyBehindAppBar: true,
      appBar: GlassAppBar(
        title: l10n.settingsTitle,
        titleColor: AppColors.headerCoral,
        titleIcon: Icons.settings_rounded,
      ),
      body: ListView(
        padding: EdgeInsets.fromLTRB(16, topPadding, 16, 24),
        children: [
          // ── Language section — add more _SectionHeader + tiles below for new settings
          _SectionHeader(label: l10n.settingsSectionLanguage),
          const _LanguageTile(),
        ],
      ),
    );
  }
}

class _SectionHeader extends StatelessWidget {
  final String label;
  const _SectionHeader({required this.label});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(top: 8, bottom: 4),
      child: Text(
        label.toUpperCase(),
        style: Theme.of(context).textTheme.labelSmall?.copyWith(
          color: AppColors.headerCoral,
          fontWeight: FontWeight.w800,
          letterSpacing: 1.1,
        ),
      ),
    );
  }
}

class _LanguageTile extends StatelessWidget {
  const _LanguageTile();

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    // Add new (label, locale) entries here to support more languages.
    final languages = [
      (label: l10n.langEnglish, locale: const Locale('en')),
      (label: l10n.langSpanish, locale: const Locale('es')),
    ];

    return ValueListenableBuilder<Locale>(
      valueListenable: LocaleNotifier.instance,
      builder: (context, currentLocale, _) {
        return Card(
          margin: EdgeInsets.zero,
          child: Column(
            children: languages.map((lang) {
              final isSelected =
                  currentLocale.languageCode == lang.locale.languageCode;
              return ListTile(
                title: Text(lang.label),
                trailing: isSelected
                    ? Icon(Icons.check_rounded, color: AppColors.headerCoral)
                    : null,
                onTap: () => LocaleNotifier.instance.switchTo(lang.locale),
              );
            }).toList(),
          ),
        );
      },
    );
  }
}
