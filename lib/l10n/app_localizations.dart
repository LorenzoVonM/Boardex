import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:intl/intl.dart' as intl;

import 'app_localizations_en.dart';
import 'app_localizations_es.dart';

// ignore_for_file: type=lint

/// Callers can lookup localized strings with an instance of AppLocalizations
/// returned by `AppLocalizations.of(context)`.
///
/// Applications need to include `AppLocalizations.delegate()` in their app's
/// `localizationDelegates` list, and the locales they support in the app's
/// `supportedLocales` list. For example:
///
/// ```dart
/// import 'l10n/app_localizations.dart';
///
/// return MaterialApp(
///   localizationsDelegates: AppLocalizations.localizationsDelegates,
///   supportedLocales: AppLocalizations.supportedLocales,
///   home: MyApplicationHome(),
/// );
/// ```
///
/// ## Update pubspec.yaml
///
/// Please make sure to update your pubspec.yaml to include the following
/// packages:
///
/// ```yaml
/// dependencies:
///   # Internationalization support.
///   flutter_localizations:
///     sdk: flutter
///   intl: any # Use the pinned version from flutter_localizations
///
///   # Rest of dependencies
/// ```
///
/// ## iOS Applications
///
/// iOS applications define key application metadata, including supported
/// locales, in an Info.plist file that is built into the application bundle.
/// To configure the locales supported by your app, you’ll need to edit this
/// file.
///
/// First, open your project’s ios/Runner.xcworkspace Xcode workspace file.
/// Then, in the Project Navigator, open the Info.plist file under the Runner
/// project’s Runner folder.
///
/// Next, select the Information Property List item, select Add Item from the
/// Editor menu, then select Localizations from the pop-up menu.
///
/// Select and expand the newly-created Localizations item then, for each
/// locale your application supports, add a new item and select the locale
/// you wish to add from the pop-up menu in the Value field. This list should
/// be consistent with the languages listed in the AppLocalizations.supportedLocales
/// property.
abstract class AppLocalizations {
  AppLocalizations(String locale)
    : localeName = intl.Intl.canonicalizedLocale(locale.toString());

  final String localeName;

  static AppLocalizations? of(BuildContext context) {
    return Localizations.of<AppLocalizations>(context, AppLocalizations);
  }

  static const LocalizationsDelegate<AppLocalizations> delegate =
      _AppLocalizationsDelegate();

  /// A list of this localizations delegate along with the default localizations
  /// delegates.
  ///
  /// Returns a list of localizations delegates containing this delegate along with
  /// GlobalMaterialLocalizations.delegate, GlobalCupertinoLocalizations.delegate,
  /// and GlobalWidgetsLocalizations.delegate.
  ///
  /// Additional delegates can be added by appending to this list in
  /// MaterialApp. This list does not have to be used at all if a custom list
  /// of delegates is preferred or required.
  static const List<LocalizationsDelegate<dynamic>> localizationsDelegates =
      <LocalizationsDelegate<dynamic>>[
        delegate,
        GlobalMaterialLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
      ];

  /// A list of this localizations delegate's supported locales.
  static const List<Locale> supportedLocales = <Locale>[
    Locale('en'),
    Locale('es'),
  ];

  /// No description provided for @appTitle.
  ///
  /// In en, this message translates to:
  /// **'Boardex'**
  String get appTitle;

  /// No description provided for @navLibrary.
  ///
  /// In en, this message translates to:
  /// **'Library'**
  String get navLibrary;

  /// No description provided for @navMatches.
  ///
  /// In en, this message translates to:
  /// **'Matches'**
  String get navMatches;

  /// No description provided for @navSummary.
  ///
  /// In en, this message translates to:
  /// **'Summary'**
  String get navSummary;

  /// No description provided for @navTools.
  ///
  /// In en, this message translates to:
  /// **'Tools'**
  String get navTools;

  /// No description provided for @settingsTitle.
  ///
  /// In en, this message translates to:
  /// **'Settings'**
  String get settingsTitle;

  /// No description provided for @settingsSectionLanguage.
  ///
  /// In en, this message translates to:
  /// **'Language'**
  String get settingsSectionLanguage;

  /// No description provided for @langEnglish.
  ///
  /// In en, this message translates to:
  /// **'English'**
  String get langEnglish;

  /// No description provided for @langSpanish.
  ///
  /// In en, this message translates to:
  /// **'Español'**
  String get langSpanish;

  /// No description provided for @cancelButton.
  ///
  /// In en, this message translates to:
  /// **'Cancel'**
  String get cancelButton;

  /// No description provided for @deleteButton.
  ///
  /// In en, this message translates to:
  /// **'Delete'**
  String get deleteButton;

  /// No description provided for @saveButton.
  ///
  /// In en, this message translates to:
  /// **'Save'**
  String get saveButton;

  /// No description provided for @addButton.
  ///
  /// In en, this message translates to:
  /// **'Add'**
  String get addButton;

  /// No description provided for @removeButton.
  ///
  /// In en, this message translates to:
  /// **'Remove'**
  String get removeButton;

  /// No description provided for @addGameTitle.
  ///
  /// In en, this message translates to:
  /// **'Add Game'**
  String get addGameTitle;

  /// No description provided for @editGameTitle.
  ///
  /// In en, this message translates to:
  /// **'Edit Game'**
  String get editGameTitle;

  /// No description provided for @gameNameLabel.
  ///
  /// In en, this message translates to:
  /// **'Game Name'**
  String get gameNameLabel;

  /// No description provided for @gameNameRequired.
  ///
  /// In en, this message translates to:
  /// **'Please enter a game name'**
  String get gameNameRequired;

  /// No description provided for @durationMinutesLabel.
  ///
  /// In en, this message translates to:
  /// **'Duration (minutes)'**
  String get durationMinutesLabel;

  /// No description provided for @durationRequired.
  ///
  /// In en, this message translates to:
  /// **'Please enter duration'**
  String get durationRequired;

  /// No description provided for @durationInvalid.
  ///
  /// In en, this message translates to:
  /// **'Please enter a valid duration'**
  String get durationInvalid;

  /// No description provided for @numberOfPlayersLabel.
  ///
  /// In en, this message translates to:
  /// **'Number of Players'**
  String get numberOfPlayersLabel;

  /// No description provided for @minLabel.
  ///
  /// In en, this message translates to:
  /// **'Min'**
  String get minLabel;

  /// No description provided for @maxLabel.
  ///
  /// In en, this message translates to:
  /// **'Max'**
  String get maxLabel;

  /// No description provided for @ratingLabel.
  ///
  /// In en, this message translates to:
  /// **'Rating'**
  String get ratingLabel;

  /// No description provided for @weightLabel.
  ///
  /// In en, this message translates to:
  /// **'Weight (Difficulty)'**
  String get weightLabel;

  /// No description provided for @gameAlreadyExists.
  ///
  /// In en, this message translates to:
  /// **'A game with this name already exists in your library'**
  String get gameAlreadyExists;

  /// No description provided for @gameUpdated.
  ///
  /// In en, this message translates to:
  /// **'Game updated!'**
  String get gameUpdated;

  /// No description provided for @gameAdded.
  ///
  /// In en, this message translates to:
  /// **'Game added!'**
  String get gameAdded;

  /// No description provided for @addMatchTitle.
  ///
  /// In en, this message translates to:
  /// **'Add Match'**
  String get addMatchTitle;

  /// No description provided for @editPlayerTitle.
  ///
  /// In en, this message translates to:
  /// **'Edit Player'**
  String get editPlayerTitle;

  /// No description provided for @addPlayerTitle.
  ///
  /// In en, this message translates to:
  /// **'Add Player'**
  String get addPlayerTitle;

  /// No description provided for @playerNameLabel.
  ///
  /// In en, this message translates to:
  /// **'Name'**
  String get playerNameLabel;

  /// No description provided for @playerNameRequired.
  ///
  /// In en, this message translates to:
  /// **'Name is required'**
  String get playerNameRequired;

  /// No description provided for @playerAlreadyAdded.
  ///
  /// In en, this message translates to:
  /// **'Player already added'**
  String get playerAlreadyAdded;

  /// No description provided for @playerColorLabel.
  ///
  /// In en, this message translates to:
  /// **'Color (optional)'**
  String get playerColorLabel;

  /// No description provided for @playerScoreLabel.
  ///
  /// In en, this message translates to:
  /// **'Score (optional)'**
  String get playerScoreLabel;

  /// No description provided for @matchesTitle.
  ///
  /// In en, this message translates to:
  /// **'Matches'**
  String get matchesTitle;

  /// No description provided for @searchMatchesTooltip.
  ///
  /// In en, this message translates to:
  /// **'Search Matches'**
  String get searchMatchesTooltip;

  /// No description provided for @noMatchesRecordedTitle.
  ///
  /// In en, this message translates to:
  /// **'No matches recorded'**
  String get noMatchesRecordedTitle;

  /// No description provided for @noMatchesRecordedSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Tap + to register your first match'**
  String get noMatchesRecordedSubtitle;

  /// No description provided for @addGameToLibraryLabel.
  ///
  /// In en, this message translates to:
  /// **'Add Game to Library'**
  String get addGameToLibraryLabel;

  /// No description provided for @registerMatchLabel.
  ///
  /// In en, this message translates to:
  /// **'Register Match'**
  String get registerMatchLabel;

  /// No description provided for @matchDetailsTitle.
  ///
  /// In en, this message translates to:
  /// **'Match Details'**
  String get matchDetailsTitle;

  /// No description provided for @exportStoryTooltip.
  ///
  /// In en, this message translates to:
  /// **'Export Story'**
  String get exportStoryTooltip;

  /// No description provided for @deleteMatchTitle.
  ///
  /// In en, this message translates to:
  /// **'Delete Match'**
  String get deleteMatchTitle;

  /// No description provided for @deleteMatchConfirmation.
  ///
  /// In en, this message translates to:
  /// **'Are you sure you want to delete this match of \"{gameName}\"?'**
  String deleteMatchConfirmation(String gameName);

  /// No description provided for @matchDeleted.
  ///
  /// In en, this message translates to:
  /// **'Match deleted'**
  String get matchDeleted;

  /// No description provided for @dateLabel.
  ///
  /// In en, this message translates to:
  /// **'Date'**
  String get dateLabel;

  /// No description provided for @timeLabel.
  ///
  /// In en, this message translates to:
  /// **'Time'**
  String get timeLabel;

  /// No description provided for @durationLabel.
  ///
  /// In en, this message translates to:
  /// **'Duration'**
  String get durationLabel;

  /// No description provided for @playersLabel.
  ///
  /// In en, this message translates to:
  /// **'Players'**
  String get playersLabel;

  /// No description provided for @searchMatchesTitle.
  ///
  /// In en, this message translates to:
  /// **'Search Matches'**
  String get searchMatchesTitle;

  /// No description provided for @clearFiltersTooltip.
  ///
  /// In en, this message translates to:
  /// **'Clear filters'**
  String get clearFiltersTooltip;

  /// No description provided for @dateRangeLabel.
  ///
  /// In en, this message translates to:
  /// **'Date Range'**
  String get dateRangeLabel;

  /// No description provided for @fromDateLabel.
  ///
  /// In en, this message translates to:
  /// **'From Date'**
  String get fromDateLabel;

  /// No description provided for @toDateLabel.
  ///
  /// In en, this message translates to:
  /// **'To Date'**
  String get toDateLabel;

  /// No description provided for @anyDatePlaceholder.
  ///
  /// In en, this message translates to:
  /// **'Any'**
  String get anyDatePlaceholder;

  /// No description provided for @gameDetailsTitle.
  ///
  /// In en, this message translates to:
  /// **'Game Details'**
  String get gameDetailsTitle;

  /// No description provided for @deleteGameTitle.
  ///
  /// In en, this message translates to:
  /// **'Delete Game'**
  String get deleteGameTitle;

  /// No description provided for @deleteGameConfirmation.
  ///
  /// In en, this message translates to:
  /// **'Are you sure you want to delete \"{gameName}\"?'**
  String deleteGameConfirmation(String gameName);

  /// No description provided for @gameDeleted.
  ///
  /// In en, this message translates to:
  /// **'Game deleted'**
  String get gameDeleted;

  /// No description provided for @ownedLabel.
  ///
  /// In en, this message translates to:
  /// **'Owned'**
  String get ownedLabel;

  /// No description provided for @notOwnedLabel.
  ///
  /// In en, this message translates to:
  /// **'Not Owned'**
  String get notOwnedLabel;

  /// No description provided for @forSaleLabel.
  ///
  /// In en, this message translates to:
  /// **'For Sale'**
  String get forSaleLabel;

  /// No description provided for @forTradeLabel.
  ///
  /// In en, this message translates to:
  /// **'For Trade'**
  String get forTradeLabel;

  /// No description provided for @playedLabel.
  ///
  /// In en, this message translates to:
  /// **'Played'**
  String get playedLabel;

  /// No description provided for @marketplaceTitle.
  ///
  /// In en, this message translates to:
  /// **'Marketplace'**
  String get marketplaceTitle;

  /// No description provided for @exportCatalogLabel.
  ///
  /// In en, this message translates to:
  /// **'Export Catalog'**
  String get exportCatalogLabel;

  /// No description provided for @selectGameToExport.
  ///
  /// In en, this message translates to:
  /// **'Please select at least one game to export.'**
  String get selectGameToExport;

  /// No description provided for @noGamesForSaleTitle.
  ///
  /// In en, this message translates to:
  /// **'No games marked for sale'**
  String get noGamesForSaleTitle;

  /// No description provided for @catalogSaved.
  ///
  /// In en, this message translates to:
  /// **'Marketplace catalog saved to gallery!'**
  String get catalogSaved;

  /// No description provided for @saveImageButton.
  ///
  /// In en, this message translates to:
  /// **'Save Image'**
  String get saveImageButton;

  /// No description provided for @savingButton.
  ///
  /// In en, this message translates to:
  /// **'Saving...'**
  String get savingButton;

  /// No description provided for @searchGamesTitle.
  ///
  /// In en, this message translates to:
  /// **'Search Games'**
  String get searchGamesTitle;

  /// No description provided for @searchResultsTitle.
  ///
  /// In en, this message translates to:
  /// **'Results ({count})'**
  String searchResultsTitle(int count);

  /// No description provided for @noGamesFoundTitle.
  ///
  /// In en, this message translates to:
  /// **'No games found'**
  String get noGamesFoundTitle;

  /// No description provided for @noGamesFoundSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Try different search criteria'**
  String get noGamesFoundSubtitle;

  /// No description provided for @weightLightLabel.
  ///
  /// In en, this message translates to:
  /// **'1.0 Light'**
  String get weightLightLabel;

  /// No description provided for @weightHeavyLabel.
  ///
  /// In en, this message translates to:
  /// **'5.0 Heavy'**
  String get weightHeavyLabel;

  /// No description provided for @mechanicsLabel.
  ///
  /// In en, this message translates to:
  /// **'Mechanics'**
  String get mechanicsLabel;

  /// No description provided for @selectToFilterHint.
  ///
  /// In en, this message translates to:
  /// **'Select to filter'**
  String get selectToFilterHint;

  /// No description provided for @categoryLabel.
  ///
  /// In en, this message translates to:
  /// **'Category'**
  String get categoryLabel;

  /// No description provided for @ownershipStatusLabel.
  ///
  /// In en, this message translates to:
  /// **'Ownership Status'**
  String get ownershipStatusLabel;

  /// No description provided for @iOwnThisGame.
  ///
  /// In en, this message translates to:
  /// **'I own this game'**
  String get iOwnThisGame;

  /// No description provided for @toolsTitle.
  ///
  /// In en, this message translates to:
  /// **'Tools'**
  String get toolsTitle;

  /// No description provided for @turnOrderTitle.
  ///
  /// In en, this message translates to:
  /// **'Turn Order'**
  String get turnOrderTitle;

  /// No description provided for @timerTitle.
  ///
  /// In en, this message translates to:
  /// **'Timer'**
  String get timerTitle;

  /// No description provided for @competitiveTitle.
  ///
  /// In en, this message translates to:
  /// **'Competitive'**
  String get competitiveTitle;

  /// No description provided for @teamsButton.
  ///
  /// In en, this message translates to:
  /// **'Teams'**
  String get teamsButton;

  /// No description provided for @howManyTeamsTitle.
  ///
  /// In en, this message translates to:
  /// **'How many teams?'**
  String get howManyTeamsTitle;

  /// No description provided for @twoTeamsLabel.
  ///
  /// In en, this message translates to:
  /// **'2 Teams'**
  String get twoTeamsLabel;

  /// No description provided for @threeTeamsLabel.
  ///
  /// In en, this message translates to:
  /// **'3 Teams'**
  String get threeTeamsLabel;

  /// No description provided for @resetTooltip.
  ///
  /// In en, this message translates to:
  /// **'Reset'**
  String get resetTooltip;

  /// No description provided for @touchInstruction.
  ///
  /// In en, this message translates to:
  /// **'Everyone place a finger\non the screen'**
  String get touchInstruction;

  /// No description provided for @holdInstruction.
  ///
  /// In en, this message translates to:
  /// **'Hold for 4 seconds'**
  String get holdInstruction;

  /// No description provided for @summaryTitle.
  ///
  /// In en, this message translates to:
  /// **'Summary'**
  String get summaryTitle;

  /// No description provided for @findMatchesHeading.
  ///
  /// In en, this message translates to:
  /// **'Find Matches'**
  String get findMatchesHeading;

  /// No description provided for @findMatchesSubheading.
  ///
  /// In en, this message translates to:
  /// **'Filter and group your matches by game'**
  String get findMatchesSubheading;

  /// No description provided for @fromLabel.
  ///
  /// In en, this message translates to:
  /// **'From'**
  String get fromLabel;

  /// No description provided for @toLabel.
  ///
  /// In en, this message translates to:
  /// **'To'**
  String get toLabel;

  /// No description provided for @resultLabel.
  ///
  /// In en, this message translates to:
  /// **'Result'**
  String get resultLabel;

  /// No description provided for @allResultsLabel.
  ///
  /// In en, this message translates to:
  /// **'All'**
  String get allResultsLabel;

  /// No description provided for @winResultLabel.
  ///
  /// In en, this message translates to:
  /// **'Win'**
  String get winResultLabel;

  /// No description provided for @drawResultLabel.
  ///
  /// In en, this message translates to:
  /// **'Draw'**
  String get drawResultLabel;

  /// No description provided for @lossResultLabel.
  ///
  /// In en, this message translates to:
  /// **'Loss'**
  String get lossResultLabel;

  /// No description provided for @playersHintText.
  ///
  /// In en, this message translates to:
  /// **'Leave empty to include all players'**
  String get playersHintText;

  /// No description provided for @noPlayersFoundText.
  ///
  /// In en, this message translates to:
  /// **'No players found in matches'**
  String get noPlayersFoundText;

  /// No description provided for @searchPlayersPlaceholder.
  ///
  /// In en, this message translates to:
  /// **'Type to search players...'**
  String get searchPlayersPlaceholder;

  /// No description provided for @viewSummaryButton.
  ///
  /// In en, this message translates to:
  /// **'View Summary'**
  String get viewSummaryButton;

  /// No description provided for @noMatchesFoundTitle.
  ///
  /// In en, this message translates to:
  /// **'No matches found'**
  String get noMatchesFoundTitle;

  /// No description provided for @noMatchesFoundSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Try adjusting your filters'**
  String get noMatchesFoundSubtitle;

  /// No description provided for @filteredByLabel.
  ///
  /// In en, this message translates to:
  /// **'Filtered by: '**
  String get filteredByLabel;

  /// No description provided for @exportSummaryTitle.
  ///
  /// In en, this message translates to:
  /// **'Export Summary'**
  String get exportSummaryTitle;

  /// No description provided for @boardGameRecapTitle.
  ///
  /// In en, this message translates to:
  /// **'Board Game Recap'**
  String get boardGameRecapTitle;

  /// No description provided for @matchesCountLabel.
  ///
  /// In en, this message translates to:
  /// **'Matches'**
  String get matchesCountLabel;

  /// No description provided for @gamesCountLabel.
  ///
  /// In en, this message translates to:
  /// **'Games'**
  String get gamesCountLabel;

  /// No description provided for @winRateLabel.
  ///
  /// In en, this message translates to:
  /// **'Win Rate'**
  String get winRateLabel;

  /// No description provided for @exportSummaryImageTooltip.
  ///
  /// In en, this message translates to:
  /// **'Export summary image'**
  String get exportSummaryImageTooltip;

  /// No description provided for @exportStoryTitle.
  ///
  /// In en, this message translates to:
  /// **'Export Story'**
  String get exportStoryTitle;

  /// No description provided for @themeLabel.
  ///
  /// In en, this message translates to:
  /// **'Theme'**
  String get themeLabel;

  /// No description provided for @titleColorLabel.
  ///
  /// In en, this message translates to:
  /// **'Title color'**
  String get titleColorLabel;

  /// No description provided for @whiteLabel.
  ///
  /// In en, this message translates to:
  /// **'White'**
  String get whiteLabel;

  /// No description provided for @blackLabel.
  ///
  /// In en, this message translates to:
  /// **'Black'**
  String get blackLabel;

  /// No description provided for @statsLabel.
  ///
  /// In en, this message translates to:
  /// **'Stats'**
  String get statsLabel;

  /// No description provided for @openingInstagramStory.
  ///
  /// In en, this message translates to:
  /// **'Opening Instagram Story...'**
  String get openingInstagramStory;

  /// No description provided for @instagramNotInstalled.
  ///
  /// In en, this message translates to:
  /// **'Could not open Instagram Story. Check if Instagram is installed.'**
  String get instagramNotInstalled;

  /// No description provided for @preparingStory.
  ///
  /// In en, this message translates to:
  /// **'Preparing Story...'**
  String get preparingStory;

  /// No description provided for @exportToInstagramStory.
  ///
  /// In en, this message translates to:
  /// **'Export to Instagram Story'**
  String get exportToInstagramStory;

  /// No description provided for @searchHintText.
  ///
  /// In en, this message translates to:
  /// **'Set filters and tap Search'**
  String get searchHintText;

  /// No description provided for @collectionStatusLabel.
  ///
  /// In en, this message translates to:
  /// **'Collection Status'**
  String get collectionStatusLabel;

  /// No description provided for @marketplaceStatusLabel.
  ///
  /// In en, this message translates to:
  /// **'Marketplace Status'**
  String get marketplaceStatusLabel;

  /// No description provided for @editMatchTooltip.
  ///
  /// In en, this message translates to:
  /// **'Edit Match'**
  String get editMatchTooltip;

  /// No description provided for @sellPriceLabel.
  ///
  /// In en, this message translates to:
  /// **'Sell Price'**
  String get sellPriceLabel;

  /// No description provided for @lastPlayedLabel.
  ///
  /// In en, this message translates to:
  /// **'Last Played'**
  String get lastPlayedLabel;

  /// No description provided for @clearButton.
  ///
  /// In en, this message translates to:
  /// **'Clear'**
  String get clearButton;

  /// No description provided for @winsLabel.
  ///
  /// In en, this message translates to:
  /// **'Wins'**
  String get winsLabel;

  /// No description provided for @drawsLabel.
  ///
  /// In en, this message translates to:
  /// **'Draws'**
  String get drawsLabel;

  /// No description provided for @lossesLabel.
  ///
  /// In en, this message translates to:
  /// **'Losses'**
  String get lossesLabel;

  /// No description provided for @startButton.
  ///
  /// In en, this message translates to:
  /// **'Start'**
  String get startButton;

  /// No description provided for @pauseButton.
  ///
  /// In en, this message translates to:
  /// **'Pause'**
  String get pauseButton;

  /// No description provided for @resumeButton.
  ///
  /// In en, this message translates to:
  /// **'Resume'**
  String get resumeButton;

  /// No description provided for @timeUpLabel.
  ///
  /// In en, this message translates to:
  /// **'TIME\'S UP'**
  String get timeUpLabel;

  /// No description provided for @minutesAbbr.
  ///
  /// In en, this message translates to:
  /// **'min'**
  String get minutesAbbr;

  /// No description provided for @secondsAbbr.
  ///
  /// In en, this message translates to:
  /// **'sec'**
  String get secondsAbbr;

  /// No description provided for @weightShortLabel.
  ///
  /// In en, this message translates to:
  /// **'Weight'**
  String get weightShortLabel;

  /// No description provided for @neverLabel.
  ///
  /// In en, this message translates to:
  /// **'Never'**
  String get neverLabel;

  /// No description provided for @gameSectionTitle.
  ///
  /// In en, this message translates to:
  /// **'Game'**
  String get gameSectionTitle;

  /// No description provided for @dateTimeSectionTitle.
  ///
  /// In en, this message translates to:
  /// **'Date & Time'**
  String get dateTimeSectionTitle;

  /// No description provided for @matchResultSectionTitle.
  ///
  /// In en, this message translates to:
  /// **'Match Result'**
  String get matchResultSectionTitle;

  /// No description provided for @playersOptionalSectionTitle.
  ///
  /// In en, this message translates to:
  /// **'Players (optional)'**
  String get playersOptionalSectionTitle;

  /// No description provided for @winnerSectionTitle.
  ///
  /// In en, this message translates to:
  /// **'Winner'**
  String get winnerSectionTitle;

  /// No description provided for @matchDurationRequired.
  ///
  /// In en, this message translates to:
  /// **'Please enter match duration'**
  String get matchDurationRequired;

  /// No description provided for @noPlayersYet.
  ///
  /// In en, this message translates to:
  /// **'No players yet.'**
  String get noPlayersYet;

  /// No description provided for @editPlayerTooltip.
  ///
  /// In en, this message translates to:
  /// **'Edit player'**
  String get editPlayerTooltip;

  /// No description provided for @addPlayerButtonLabel.
  ///
  /// In en, this message translates to:
  /// **'Add Player'**
  String get addPlayerButtonLabel;

  /// No description provided for @selectWinnerHint.
  ///
  /// In en, this message translates to:
  /// **'Select winner (optional)'**
  String get selectWinnerHint;

  /// No description provided for @noWinnerOption.
  ///
  /// In en, this message translates to:
  /// **'No winner selected'**
  String get noWinnerOption;

  /// No description provided for @selectPhotoSectionTitle.
  ///
  /// In en, this message translates to:
  /// **'Select Photo'**
  String get selectPhotoSectionTitle;

  /// No description provided for @usingLibraryPhoto.
  ///
  /// In en, this message translates to:
  /// **'Using library photo'**
  String get usingLibraryPhoto;

  /// No description provided for @usingPreviousMatchPhoto.
  ///
  /// In en, this message translates to:
  /// **'Using photo from a previous match'**
  String get usingPreviousMatchPhoto;

  /// No description provided for @noCarouselPhotos.
  ///
  /// In en, this message translates to:
  /// **'Game not in library — no previous photos to reuse'**
  String get noCarouselPhotos;

  /// No description provided for @updateMatchButton.
  ///
  /// In en, this message translates to:
  /// **'Update Match'**
  String get updateMatchButton;

  /// No description provided for @selectAllThatApply.
  ///
  /// In en, this message translates to:
  /// **'Select all that apply'**
  String get selectAllThatApply;

  /// No description provided for @lightLabel.
  ///
  /// In en, this message translates to:
  /// **'Light'**
  String get lightLabel;

  /// No description provided for @mediumLabel.
  ///
  /// In en, this message translates to:
  /// **'Medium'**
  String get mediumLabel;

  /// No description provided for @heavyLabel.
  ///
  /// In en, this message translates to:
  /// **'Heavy'**
  String get heavyLabel;

  /// No description provided for @updateGameButton.
  ///
  /// In en, this message translates to:
  /// **'Update Game'**
  String get updateGameButton;

  /// No description provided for @validPriceRequired.
  ///
  /// In en, this message translates to:
  /// **'Please enter a valid price'**
  String get validPriceRequired;

  /// No description provided for @markForSellLabel.
  ///
  /// In en, this message translates to:
  /// **'Mark for Sell'**
  String get markForSellLabel;

  /// No description provided for @markForTradeLabel.
  ///
  /// In en, this message translates to:
  /// **'Mark for Trade'**
  String get markForTradeLabel;

  /// No description provided for @pausedLabel.
  ///
  /// In en, this message translates to:
  /// **'PAUSED'**
  String get pausedLabel;

  /// No description provided for @holdInstructionTeams.
  ///
  /// In en, this message translates to:
  /// **'Hold for 4 seconds to form {count} teams'**
  String holdInstructionTeams(int count);

  /// No description provided for @teamStartsBanner.
  ///
  /// In en, this message translates to:
  /// **'TEAM {number} STARTS!'**
  String teamStartsBanner(int number);

  /// No description provided for @saveImageError.
  ///
  /// In en, this message translates to:
  /// **'Could not save image: {error}'**
  String saveImageError(String error);

  /// No description provided for @couldNotExportStory.
  ///
  /// In en, this message translates to:
  /// **'Could not export story: {error}'**
  String couldNotExportStory(String error);
}

class _AppLocalizationsDelegate
    extends LocalizationsDelegate<AppLocalizations> {
  const _AppLocalizationsDelegate();

  @override
  Future<AppLocalizations> load(Locale locale) {
    return SynchronousFuture<AppLocalizations>(lookupAppLocalizations(locale));
  }

  @override
  bool isSupported(Locale locale) =>
      <String>['en', 'es'].contains(locale.languageCode);

  @override
  bool shouldReload(_AppLocalizationsDelegate old) => false;
}

AppLocalizations lookupAppLocalizations(Locale locale) {
  // Lookup logic when only language code is specified.
  switch (locale.languageCode) {
    case 'en':
      return AppLocalizationsEn();
    case 'es':
      return AppLocalizationsEs();
  }

  throw FlutterError(
    'AppLocalizations.delegate failed to load unsupported locale "$locale". This is likely '
    'an issue with the localizations generation tool. Please file an issue '
    'on GitHub with a reproducible sample app and the gen-l10n configuration '
    'that was used.',
  );
}
