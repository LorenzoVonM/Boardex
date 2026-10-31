// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Spanish Castilian (`es`).
class AppLocalizationsEs extends AppLocalizations {
  AppLocalizationsEs([String locale = 'es']) : super(locale);

  @override
  String get appTitle => 'Boardex';

  @override
  String get navLibrary => 'Biblioteca';

  @override
  String get navMatches => 'Partidas';

  @override
  String get navSummary => 'Resumen';

  @override
  String get navTools => 'Herramientas';

  @override
  String get settingsTitle => 'Ajustes';

  @override
  String get settingsSectionLanguage => 'Idioma';

  @override
  String get langEnglish => 'English';

  @override
  String get langSpanish => 'Español';

  @override
  String get cancelButton => 'Cancelar';

  @override
  String get deleteButton => 'Eliminar';

  @override
  String get saveButton => 'Guardar';

  @override
  String get addButton => 'Añadir';

  @override
  String get removeButton => 'Eliminar';

  @override
  String get addGameTitle => 'Añadir Juego';

  @override
  String get editGameTitle => 'Editar Juego';

  @override
  String get gameNameLabel => 'Nombre del Juego';

  @override
  String get gameNameRequired => 'Por favor, ingresa el nombre del juego';

  @override
  String get durationMinutesLabel => 'Duración (minutos)';

  @override
  String get durationRequired => 'Por favor, ingresa la duración';

  @override
  String get durationInvalid => 'Por favor, ingresa una duración válida';

  @override
  String get numberOfPlayersLabel => 'Número de Jugadores';

  @override
  String get minLabel => 'Mín';

  @override
  String get maxLabel => 'Máx';

  @override
  String get ratingLabel => 'Calificación';

  @override
  String get weightLabel => 'Dificultad';

  @override
  String get gameAlreadyExists =>
      'Ya existe un juego con este nombre en tu biblioteca';

  @override
  String get gameUpdated => '¡Juego actualizado!';

  @override
  String get gameAdded => '¡Juego añadido!';

  @override
  String get addMatchTitle => 'Añadir Partida';

  @override
  String get editPlayerTitle => 'Editar Jugador';

  @override
  String get addPlayerTitle => 'Añadir Jugador';

  @override
  String get playerNameLabel => 'Nombre';

  @override
  String get playerNameRequired => 'El nombre es obligatorio';

  @override
  String get playerAlreadyAdded => 'Jugador ya añadido';

  @override
  String get playerColorLabel => 'Color (opcional)';

  @override
  String get playerScoreLabel => 'Puntuación (opcional)';

  @override
  String get matchesTitle => 'Partidas';

  @override
  String get searchMatchesTooltip => 'Buscar Partidas';

  @override
  String get noMatchesRecordedTitle => 'Sin partidas registradas';

  @override
  String get noMatchesRecordedSubtitle =>
      'Toca + para registrar tu primera partida';

  @override
  String get addGameToLibraryLabel => 'Añadir Juego a la Biblioteca';

  @override
  String get registerMatchLabel => 'Registrar Partida';

  @override
  String get matchDetailsTitle => 'Detalles de la Partida';

  @override
  String get exportStoryTooltip => 'Exportar Historia';

  @override
  String get deleteMatchTitle => 'Eliminar Partida';

  @override
  String deleteMatchConfirmation(String gameName) {
    return '¿Seguro que quieres eliminar esta partida de \"$gameName\"?';
  }

  @override
  String get matchDeleted => 'Partida eliminada';

  @override
  String get dateLabel => 'Fecha';

  @override
  String get timeLabel => 'Hora';

  @override
  String get durationLabel => 'Duración';

  @override
  String get playersLabel => 'Jugadores';

  @override
  String get searchMatchesTitle => 'Buscar Partidas';

  @override
  String get clearFiltersTooltip => 'Limpiar filtros';

  @override
  String get dateRangeLabel => 'Rango de Fechas';

  @override
  String get fromDateLabel => 'Desde';

  @override
  String get toDateLabel => 'Hasta';

  @override
  String get anyDatePlaceholder => 'Cualquiera';

  @override
  String get gameDetailsTitle => 'Detalles del Juego';

  @override
  String get deleteGameTitle => 'Eliminar Juego';

  @override
  String deleteGameConfirmation(String gameName) {
    return '¿Seguro que quieres eliminar \"$gameName\"?';
  }

  @override
  String get gameDeleted => 'Juego eliminado';

  @override
  String get ownedLabel => 'Poseído';

  @override
  String get notOwnedLabel => 'No Poseído';

  @override
  String get forSaleLabel => 'En Venta';

  @override
  String get forTradeLabel => 'Para Intercambiar';

  @override
  String get playedLabel => 'Jugado';

  @override
  String get marketplaceTitle => 'Mercado';

  @override
  String get exportCatalogLabel => 'Exportar Catálogo';

  @override
  String get selectGameToExport =>
      'Por favor, selecciona al menos un juego para exportar.';

  @override
  String get noGamesForSaleTitle => 'Sin juegos marcados para vender';

  @override
  String get catalogSaved => '¡Catálogo del mercado guardado en la galería!';

  @override
  String get saveImageButton => 'Guardar Imagen';

  @override
  String get savingButton => 'Guardando...';

  @override
  String get searchGamesTitle => 'Buscar Juegos';

  @override
  String searchResultsTitle(int count) {
    return 'Resultados ($count)';
  }

  @override
  String get noGamesFoundTitle => 'Sin juegos encontrados';

  @override
  String get noGamesFoundSubtitle =>
      'Intenta con diferentes criterios de búsqueda';

  @override
  String get weightLightLabel => '1.0 Ligero';

  @override
  String get weightHeavyLabel => '5.0 Pesado';

  @override
  String get mechanicsLabel => 'Mecánicas';

  @override
  String get selectToFilterHint => 'Selecciona para filtrar';

  @override
  String get categoryLabel => 'Categoría';

  @override
  String get ownershipStatusLabel => 'Estado de Propiedad';

  @override
  String get iOwnThisGame => 'Poseo este juego';

  @override
  String get toolsTitle => 'Herramientas';

  @override
  String get turnOrderTitle => 'Orden de Turnos';

  @override
  String get timerTitle => 'Temporizador';

  @override
  String get competitiveTitle => 'Competitivo';

  @override
  String get teamsButton => 'Equipos';

  @override
  String get howManyTeamsTitle => '¿Cuántos equipos?';

  @override
  String get twoTeamsLabel => '2 Equipos';

  @override
  String get threeTeamsLabel => '3 Equipos';

  @override
  String get resetTooltip => 'Reiniciar';

  @override
  String get touchInstruction => 'Todos coloquen un dedo\nen la pantalla';

  @override
  String get holdInstruction => 'Mantén durante 4 segundos';

  @override
  String get summaryTitle => 'Resumen';

  @override
  String get findMatchesHeading => 'Buscar Partidas';

  @override
  String get findMatchesSubheading => 'Filtra y agrupa tus partidas por juego';

  @override
  String get fromLabel => 'Desde';

  @override
  String get toLabel => 'Hasta';

  @override
  String get resultLabel => 'Resultado';

  @override
  String get allResultsLabel => 'Todos';

  @override
  String get winResultLabel => 'Victoria';

  @override
  String get drawResultLabel => 'Empate';

  @override
  String get lossResultLabel => 'Derrota';

  @override
  String get playersHintText => 'Deja vacío para incluir todos los jugadores';

  @override
  String get noPlayersFoundText => 'Sin jugadores encontrados en partidas';

  @override
  String get searchPlayersPlaceholder => 'Escribe para buscar jugadores...';

  @override
  String get viewSummaryButton => 'Ver Resumen';

  @override
  String get noMatchesFoundTitle => 'Sin partidas encontradas';

  @override
  String get noMatchesFoundSubtitle => 'Intenta ajustar tus filtros';

  @override
  String get filteredByLabel => 'Filtrado por: ';

  @override
  String get exportSummaryTitle => 'Exportar Resumen';

  @override
  String get boardGameRecapTitle => 'Resumen de Juegos de Mesa';

  @override
  String get matchesCountLabel => 'Partidas';

  @override
  String get gamesCountLabel => 'Juegos';

  @override
  String get winRateLabel => 'Tasa de Victoria';

  @override
  String get exportSummaryImageTooltip => 'Exportar imagen de resumen';

  @override
  String get exportStoryTitle => 'Exportar Historia';

  @override
  String get themeLabel => 'Tema';

  @override
  String get titleColorLabel => 'Color del título';

  @override
  String get whiteLabel => 'Blanco';

  @override
  String get blackLabel => 'Negro';

  @override
  String get statsLabel => 'Estadísticas';

  @override
  String get openingInstagramStory => 'Abriendo Historia de Instagram...';

  @override
  String get instagramNotInstalled =>
      'No se pudo abrir la Historia de Instagram. Verifica si Instagram está instalado.';

  @override
  String get preparingStory => 'Preparando Historia...';

  @override
  String get exportToInstagramStory => 'Exportar a Historia de Instagram';

  @override
  String get searchHintText => 'Aplica filtros y pulsa Buscar';

  @override
  String get collectionStatusLabel => 'Estado de Colección';

  @override
  String get marketplaceStatusLabel => 'Estado de Mercado';

  @override
  String get editMatchTooltip => 'Editar Partida';

  @override
  String get sellPriceLabel => 'Precio de Venta';

  @override
  String get lastPlayedLabel => 'Última Partida';

  @override
  String get clearButton => 'Limpiar';

  @override
  String get winsLabel => 'Victorias';

  @override
  String get drawsLabel => 'Empates';

  @override
  String get lossesLabel => 'Derrotas';

  @override
  String get startButton => 'Iniciar';

  @override
  String get pauseButton => 'Pausar';

  @override
  String get resumeButton => 'Continuar';

  @override
  String get timeUpLabel => '¡TIEMPO!';

  @override
  String get minutesAbbr => 'min';

  @override
  String get secondsAbbr => 'seg';

  @override
  String get weightShortLabel => 'Peso';

  @override
  String get neverLabel => 'Nunca';

  @override
  String get gameSectionTitle => 'Juego';

  @override
  String get dateTimeSectionTitle => 'Fecha y Hora';

  @override
  String get matchResultSectionTitle => 'Resultado de la Partida';

  @override
  String get playersOptionalSectionTitle => 'Jugadores (opcional)';

  @override
  String get winnerSectionTitle => 'Ganador';

  @override
  String get matchDurationRequired =>
      'Por favor, ingresa la duración de la partida';

  @override
  String get noPlayersYet => 'Sin jugadores aún.';

  @override
  String get editPlayerTooltip => 'Editar jugador';

  @override
  String get addPlayerButtonLabel => 'Añadir Jugador';

  @override
  String get selectWinnerHint => 'Selecciona el ganador (opcional)';

  @override
  String get noWinnerOption => 'Sin ganador';

  @override
  String get selectPhotoSectionTitle => 'Seleccionar Foto';

  @override
  String get usingLibraryPhoto => 'Usando foto de la biblioteca';

  @override
  String get usingPreviousMatchPhoto => 'Usando foto de una partida anterior';

  @override
  String get noCarouselPhotos =>
      'Juego no está en la biblioteca — sin fotos anteriores reutilizables';

  @override
  String get updateMatchButton => 'Actualizar Partida';

  @override
  String get selectAllThatApply => 'Selecciona todos los que apliquen';

  @override
  String get lightLabel => 'Ligero';

  @override
  String get mediumLabel => 'Medio';

  @override
  String get heavyLabel => 'Pesado';

  @override
  String get updateGameButton => 'Actualizar Juego';

  @override
  String get validPriceRequired => 'Por favor, ingresa un precio válido';

  @override
  String get markForSellLabel => 'Marcar para Vender';

  @override
  String get markForTradeLabel => 'Marcar para Intercambiar';

  @override
  String get pausedLabel => 'PAUSADO';

  @override
  String holdInstructionTeams(int count) {
    return 'Mantén 4 segundos para formar $count equipos';
  }

  @override
  String teamStartsBanner(int number) {
    return '¡EQUIPO $number COMIENZA!';
  }

  @override
  String saveImageError(String error) {
    return 'No se pudo guardar la imagen: $error';
  }

  @override
  String couldNotExportStory(String error) {
    return 'No se pudo exportar la historia: $error';
  }
}
