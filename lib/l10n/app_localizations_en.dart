// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for English (`en`).
class AppLocalizationsEn extends AppLocalizations {
  AppLocalizationsEn([String locale = 'en']) : super(locale);

  @override
  String get appTitle => 'Boardex';

  @override
  String get navLibrary => 'Library';

  @override
  String get navMatches => 'Matches';

  @override
  String get navSummary => 'Summary';

  @override
  String get navTools => 'Tools';

  @override
  String get settingsTitle => 'Settings';

  @override
  String get settingsSectionLanguage => 'Language';

  @override
  String get langEnglish => 'English';

  @override
  String get langSpanish => 'Español';

  @override
  String get cancelButton => 'Cancel';

  @override
  String get deleteButton => 'Delete';

  @override
  String get saveButton => 'Save';

  @override
  String get addButton => 'Add';

  @override
  String get removeButton => 'Remove';

  @override
  String get addGameTitle => 'Add Game';

  @override
  String get editGameTitle => 'Edit Game';

  @override
  String get gameNameLabel => 'Game Name';

  @override
  String get gameNameRequired => 'Please enter a game name';

  @override
  String get durationMinutesLabel => 'Duration (minutes)';

  @override
  String get durationRequired => 'Please enter duration';

  @override
  String get durationInvalid => 'Please enter a valid duration';

  @override
  String get numberOfPlayersLabel => 'Number of Players';

  @override
  String get minLabel => 'Min';

  @override
  String get maxLabel => 'Max';

  @override
  String get ratingLabel => 'Rating';

  @override
  String get weightLabel => 'Weight (Difficulty)';

  @override
  String get gameAlreadyExists =>
      'A game with this name already exists in your library';

  @override
  String get gameUpdated => 'Game updated!';

  @override
  String get gameAdded => 'Game added!';

  @override
  String get addMatchTitle => 'Add Match';

  @override
  String get editPlayerTitle => 'Edit Player';

  @override
  String get addPlayerTitle => 'Add Player';

  @override
  String get playerNameLabel => 'Name';

  @override
  String get playerNameRequired => 'Name is required';

  @override
  String get playerAlreadyAdded => 'Player already added';

  @override
  String get playerColorLabel => 'Color (optional)';

  @override
  String get playerScoreLabel => 'Score (optional)';

  @override
  String get matchesTitle => 'Matches';

  @override
  String get searchMatchesTooltip => 'Search Matches';

  @override
  String get noMatchesRecordedTitle => 'No matches recorded';

  @override
  String get noMatchesRecordedSubtitle => 'Tap + to register your first match';

  @override
  String get addGameToLibraryLabel => 'Add Game to Library';

  @override
  String get registerMatchLabel => 'Register Match';

  @override
  String get matchDetailsTitle => 'Match Details';

  @override
  String get exportStoryTooltip => 'Export Story';

  @override
  String get deleteMatchTitle => 'Delete Match';

  @override
  String deleteMatchConfirmation(String gameName) {
    return 'Are you sure you want to delete this match of \"$gameName\"?';
  }

  @override
  String get matchDeleted => 'Match deleted';

  @override
  String get dateLabel => 'Date';

  @override
  String get timeLabel => 'Time';

  @override
  String get durationLabel => 'Duration';

  @override
  String get playersLabel => 'Players';

  @override
  String get searchMatchesTitle => 'Search Matches';

  @override
  String get clearFiltersTooltip => 'Clear filters';

  @override
  String get dateRangeLabel => 'Date Range';

  @override
  String get fromDateLabel => 'From Date';

  @override
  String get toDateLabel => 'To Date';

  @override
  String get anyDatePlaceholder => 'Any';

  @override
  String get gameDetailsTitle => 'Game Details';

  @override
  String get deleteGameTitle => 'Delete Game';

  @override
  String deleteGameConfirmation(String gameName) {
    return 'Are you sure you want to delete \"$gameName\"?';
  }

  @override
  String get gameDeleted => 'Game deleted';

  @override
  String get ownedLabel => 'Owned';

  @override
  String get notOwnedLabel => 'Not Owned';

  @override
  String get forSaleLabel => 'For Sale';

  @override
  String get forTradeLabel => 'For Trade';

  @override
  String get playedLabel => 'Played';

  @override
  String get marketplaceTitle => 'Marketplace';

  @override
  String get exportCatalogLabel => 'Export Catalog';

  @override
  String get selectGameToExport => 'Please select at least one game to export.';

  @override
  String get noGamesForSaleTitle => 'No games marked for sale';

  @override
  String get catalogSaved => 'Marketplace catalog saved to gallery!';

  @override
  String get saveImageButton => 'Save Image';

  @override
  String get savingButton => 'Saving...';

  @override
  String get searchGamesTitle => 'Search Games';

  @override
  String searchResultsTitle(int count) {
    return 'Results ($count)';
  }

  @override
  String get noGamesFoundTitle => 'No games found';

  @override
  String get noGamesFoundSubtitle => 'Try different search criteria';

  @override
  String get weightLightLabel => '1.0 Light';

  @override
  String get weightHeavyLabel => '5.0 Heavy';

  @override
  String get mechanicsLabel => 'Mechanics';

  @override
  String get selectToFilterHint => 'Select to filter';

  @override
  String get categoryLabel => 'Category';

  @override
  String get ownershipStatusLabel => 'Ownership Status';

  @override
  String get iOwnThisGame => 'I own this game';

  @override
  String get toolsTitle => 'Tools';

  @override
  String get turnOrderTitle => 'Turn Order';

  @override
  String get timerTitle => 'Timer';

  @override
  String get competitiveTitle => 'Competitive';

  @override
  String get teamsButton => 'Teams';

  @override
  String get howManyTeamsTitle => 'How many teams?';

  @override
  String get twoTeamsLabel => '2 Teams';

  @override
  String get threeTeamsLabel => '3 Teams';

  @override
  String get resetTooltip => 'Reset';

  @override
  String get touchInstruction => 'Everyone place a finger\non the screen';

  @override
  String get holdInstruction => 'Hold for 4 seconds';

  @override
  String get summaryTitle => 'Summary';

  @override
  String get findMatchesHeading => 'Find Matches';

  @override
  String get findMatchesSubheading => 'Filter and group your matches by game';

  @override
  String get fromLabel => 'From';

  @override
  String get toLabel => 'To';

  @override
  String get resultLabel => 'Result';

  @override
  String get allResultsLabel => 'All';

  @override
  String get winResultLabel => 'Win';

  @override
  String get drawResultLabel => 'Draw';

  @override
  String get lossResultLabel => 'Loss';

  @override
  String get playersHintText => 'Leave empty to include all players';

  @override
  String get noPlayersFoundText => 'No players found in matches';

  @override
  String get searchPlayersPlaceholder => 'Type to search players...';

  @override
  String get viewSummaryButton => 'View Summary';

  @override
  String get noMatchesFoundTitle => 'No matches found';

  @override
  String get noMatchesFoundSubtitle => 'Try adjusting your filters';

  @override
  String get filteredByLabel => 'Filtered by: ';

  @override
  String get exportSummaryTitle => 'Export Summary';

  @override
  String get boardGameRecapTitle => 'Board Game Recap';

  @override
  String get matchesCountLabel => 'Matches';

  @override
  String get gamesCountLabel => 'Games';

  @override
  String get winRateLabel => 'Win Rate';

  @override
  String get exportSummaryImageTooltip => 'Export summary image';

  @override
  String get exportStoryTitle => 'Export Story';

  @override
  String get themeLabel => 'Theme';

  @override
  String get titleColorLabel => 'Title color';

  @override
  String get whiteLabel => 'White';

  @override
  String get blackLabel => 'Black';

  @override
  String get statsLabel => 'Stats';

  @override
  String get openingInstagramStory => 'Opening Instagram Story...';

  @override
  String get instagramNotInstalled =>
      'Could not open Instagram Story. Check if Instagram is installed.';

  @override
  String get preparingStory => 'Preparing Story...';

  @override
  String get exportToInstagramStory => 'Export to Instagram Story';

  @override
  String get searchHintText => 'Set filters and tap Search';

  @override
  String get collectionStatusLabel => 'Collection Status';

  @override
  String get marketplaceStatusLabel => 'Marketplace Status';

  @override
  String get editMatchTooltip => 'Edit Match';

  @override
  String get sellPriceLabel => 'Sell Price';

  @override
  String get lastPlayedLabel => 'Last Played';

  @override
  String get clearButton => 'Clear';

  @override
  String get winsLabel => 'Wins';

  @override
  String get drawsLabel => 'Draws';

  @override
  String get lossesLabel => 'Losses';

  @override
  String get startButton => 'Start';

  @override
  String get pauseButton => 'Pause';

  @override
  String get resumeButton => 'Resume';

  @override
  String get timeUpLabel => 'TIME\'S UP';

  @override
  String get minutesAbbr => 'min';

  @override
  String get secondsAbbr => 'sec';

  @override
  String get weightShortLabel => 'Weight';

  @override
  String get neverLabel => 'Never';

  @override
  String get gameSectionTitle => 'Game';

  @override
  String get dateTimeSectionTitle => 'Date & Time';

  @override
  String get matchResultSectionTitle => 'Match Result';

  @override
  String get playersOptionalSectionTitle => 'Players (optional)';

  @override
  String get winnerSectionTitle => 'Winner';

  @override
  String get matchDurationRequired => 'Please enter match duration';

  @override
  String get noPlayersYet => 'No players yet.';

  @override
  String get editPlayerTooltip => 'Edit player';

  @override
  String get addPlayerButtonLabel => 'Add Player';

  @override
  String get selectWinnerHint => 'Select winner (optional)';

  @override
  String get noWinnerOption => 'No winner selected';

  @override
  String get selectPhotoSectionTitle => 'Select Photo';

  @override
  String get usingLibraryPhoto => 'Using library photo';

  @override
  String get usingPreviousMatchPhoto => 'Using photo from a previous match';

  @override
  String get noCarouselPhotos =>
      'Game not in library — no previous photos to reuse';

  @override
  String get updateMatchButton => 'Update Match';

  @override
  String get selectAllThatApply => 'Select all that apply';

  @override
  String get lightLabel => 'Light';

  @override
  String get mediumLabel => 'Medium';

  @override
  String get heavyLabel => 'Heavy';

  @override
  String get updateGameButton => 'Update Game';

  @override
  String get validPriceRequired => 'Please enter a valid price';

  @override
  String get markForSellLabel => 'Mark for Sell';

  @override
  String get markForTradeLabel => 'Mark for Trade';

  @override
  String get pausedLabel => 'PAUSED';

  @override
  String holdInstructionTeams(int count) {
    return 'Hold for 4 seconds to form $count teams';
  }

  @override
  String teamStartsBanner(int number) {
    return 'TEAM $number STARTS!';
  }

  @override
  String saveImageError(String error) {
    return 'Could not save image: $error';
  }

  @override
  String couldNotExportStory(String error) {
    return 'Could not export story: $error';
  }
}
