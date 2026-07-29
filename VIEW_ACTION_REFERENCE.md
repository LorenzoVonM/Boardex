# App View And Action Reference

This file is a communication guide for requesting app changes.

Use this format when talking to the agent:
- View: use the screen class name, for example `LibraryScreen` or `AddMatchScreen`.
- Action: use the action name listed under that view, for example `library_open_add_game`.
- Request pattern: "In `LibraryScreen`, change `library_open_add_game` so it..."

Action naming rule:

- Format: `view_verb_target`
- The prefix stays tied to the view where the user triggers the action.

## Shared Navigation

### `AppDrawer`
Description: Main navigation drawer used from the top-level sections of the app.

Actions:
- `drawer_go_library`: Open `LibraryScreen`.
- `drawer_go_matches`: Open `MatchesScreen`.
- `drawer_go_summary`: Open `SummarySearchScreen`.
- `drawer_go_player_tool`: Open `PlayerToolScreen`.
- `drawer_close`: Close the drawer without navigation.

## Main Views

### `LibraryScreen` (`Library`)
Description: Default home screen. Loads the saved board game library and shows games in a grid.

Actions:
- `library_open_drawer`: Open the main drawer.
- `library_refresh_games`: Pull to refresh the game grid.
- `library_open_game_detail`: Tap a game card to open `GameDetailScreen`.
- `library_open_search_games`: Open `SearchScreen` from the floating action menu.
- `library_open_add_game`: Open `AddGameScreen` from the floating action menu.
- `library_open_register_match`: Open `AddMatchScreen` from the floating action menu.
- `library_redirect_to_matches_after_match_save`: After saving a new match from this entry point, replace the screen with `MatchesScreen`.

### `SearchScreen` (`Search Games`)
Description: Advanced game search form for the library.

Actions:
- `search_open_drawer`: Open the drawer when this screen is reached directly.
- `search_set_game_name`: Type a game name filter.
- `search_set_min_players`: Set the minimum player filter.
- `search_set_max_players`: Set the maximum player filter.
- `search_set_min_duration`: Set the minimum duration filter.
- `search_set_max_duration`: Set the maximum duration filter.
- `search_set_min_rating`: Set the minimum rating filter.
- `search_set_max_rating`: Set the maximum rating filter.
- `search_set_min_weight`: Set the minimum difficulty filter.
- `search_set_max_weight`: Set the maximum difficulty filter.
- `search_toggle_mechanic_filter`: Select or clear a mechanic chip.
- `search_toggle_category_filter`: Select or clear a category chip.
- `search_toggle_marked_for_sell`: Enable or disable the sell filter.
- `search_toggle_marked_for_trade`: Enable or disable the trade filter.
- `search_clear_filters`: Clear every active filter.
- `search_execute`: Run the search and open `SearchResultsScreen`.

### `SearchResultsScreen` (`Results`)
Description: Read-only result grid for game search results.

Actions:
- `search_results_open_game_detail`: Tap a result card to open `GameDetailScreen`.
- `search_results_go_back`: Return to `SearchScreen`.

### `AddGameScreen` (`Add Board Game` / `Edit Board Game`)
Description: Form used to create a new board game entry or edit an existing one.

Actions:
- `add_game_set_name`: Enter or edit the game name.
- `add_game_pick_name_suggestion`: Choose an autocomplete suggestion based on match history.
- `add_game_set_duration`: Enter the game duration in minutes.
- `add_game_set_min_players`: Adjust the minimum player count.
- `add_game_set_max_players`: Adjust the maximum player count.
- `add_game_set_rating`: Move the rating slider.
- `add_game_set_weight`: Move the difficulty slider.
- `add_game_toggle_mechanic`: Select or clear a mechanic chip.
- `add_game_toggle_category`: Select or clear a category chip.
- `add_game_toggle_mark_for_sell`: Enable or disable the sell flag.
- `add_game_toggle_mark_for_trade`: Enable or disable the trade flag.
- `add_game_change_photo`: Add, replace, or remove the game photo through `PhotoCaptureSection`.
- `add_game_save`: Save the form as a new game.
- `add_game_update`: Save changes when editing an existing game.
- `add_game_cancel`: Leave the form with system back navigation.

### `GameDetailScreen` (`Game Details`)
Description: Detail view for one board game, including photo, stats, mechanics, categories, and sell/trade markers.

Actions:
- `game_detail_go_back`: Return to the previous screen.
- `game_detail_open_edit`: Open `AddGameScreen` in edit mode.
- `game_detail_delete`: Delete the game after confirmation.
- `game_detail_confirm_delete`: Confirm deletion in the delete dialog.
- `game_detail_cancel_delete`: Cancel deletion in the delete dialog.

### `MatchesScreen` (`Matches`)
Description: Main match history view. Shows registered matches in a chronological list.

Actions:
- `matches_open_drawer`: Open the main drawer.
- `matches_refresh_list`: Pull to refresh the match list.
- `matches_open_match_detail`: Tap a match card to open `MatchDetailScreen`.
- `matches_open_search_matches`: Open `MatchSearchScreen` from the floating action menu.
- `matches_open_add_game`: Open `AddGameScreen` from the floating action menu.
- `matches_open_register_match`: Open `AddMatchScreen` from the floating action menu.
- `matches_redirect_to_library_after_game_save`: After saving a game from this entry point, replace the screen with `LibraryScreen`.

### `MatchSearchScreen` (`Search Matches`)
Description: Filter screen for searching recorded matches.

Actions:
- `match_search_set_game_name`: Type or select a game name filter.
- `match_search_clear_game_name`: Clear the selected game name.
- `match_search_set_start_date`: Pick the start date.
- `match_search_set_end_date`: Pick the end date.
- `match_search_set_result_filter`: Choose `All`, `Win`, `Draw`, or `Loss`.
- `match_search_clear_filters`: Clear all active filters.
- `match_search_execute`: Run the search and load the inline result list.
- `match_search_open_match_detail`: Tap a result card to open `MatchDetailScreen`.
- `match_search_refresh_after_detail_change`: Re-run the active search after returning from a changed match.

### `AddMatchScreen` (`Register Match` / `Edit Match`)
Description: Form used to create or edit a match record, including game identity, date/time, result, players, winner, and photo source.

Actions:
- `add_match_set_game_name`: Enter or edit the game name.
- `add_match_pick_game_name_suggestion`: Choose an autocomplete suggestion from known match names.
- `add_match_set_duration`: Enter match duration in minutes.
- `add_match_set_played_date`: Pick the date played.
- `add_match_set_played_time`: Pick the time played.
- `add_match_set_result`: Choose `Win`, `Draw`, or `Loss`.
- `add_match_open_add_player`: Open the player dialog in add mode.
- `add_match_open_edit_player`: Open the player dialog in edit mode for one player.
- `add_match_set_winner`: Choose a winner from the current player list.
- `add_match_select_library_photo`: Use the linked library photo when available.
- `add_match_select_custom_photo`: Use a custom match photo.
- `add_match_change_custom_photo`: Add, replace, or remove the custom match photo through `PhotoCaptureSection`.
- `add_match_save`: Save the form as a new match.
- `add_match_update`: Save changes when editing an existing match.
- `add_match_cancel`: Leave the form with system back navigation.

### `AddMatchScreen` Player Dialog (`Add Player` / `Edit Player`)
Description: Modal dialog used from `AddMatchScreen` to manage one player entry.

Actions:
- `add_match_player_set_name`: Enter or edit the player name.
- `add_match_player_set_color`: Select or clear the player color.
- `add_match_player_set_score`: Enter or edit the optional score.
- `add_match_player_confirm_add`: Save a new player.
- `add_match_player_confirm_edit`: Save changes to an existing player.
- `add_match_player_remove`: Remove the current player from the match.
- `add_match_player_cancel`: Close the dialog without applying changes.

### `MatchDetailScreen` (`Match Details`)
Description: Detail view for one recorded match, including photo, result, date/time, player list, scores, and winner.

Actions:
- `match_detail_go_back`: Return to the previous screen.
- `match_detail_open_story_export`: Open `MatchStoryExportScreen`.
- `match_detail_open_edit`: Open `AddMatchScreen` in edit mode.
- `match_detail_delete`: Delete the match after confirmation.
- `match_detail_confirm_delete`: Confirm deletion in the delete dialog.
- `match_detail_cancel_delete`: Cancel deletion in the delete dialog.

### `MatchStoryExportScreen` (`Story Export`)
Description: Instagram Story export preview for a single match. Exports a sticker-only image for Instagram Story sharing.

Actions:
- `match_story_select_coral_background`: Use the `Coral` background color for the story preview and Instagram background color.
- `match_story_select_sand_background`: Use the `Sand` background color for the story preview and Instagram background color.
- `match_story_select_moss_background`: Use the `Moss` background color for the story preview and Instagram background color.
- `match_story_select_ochre_background`: Use the `Ochre` background color for the story preview and Instagram background color.
- `match_story_select_twilight_background`: Use the `Twilight` background color for the story preview and Instagram background color.
- `match_story_export_to_instagram`: Capture the preview and open Instagram Story sharing.
- `match_story_go_back`: Return to `MatchDetailScreen`.

### `SummarySearchScreen` (`Summary`)
Description: Filter screen for building a grouped summary of matches over a date range.

Actions:
- `summary_search_open_drawer`: Open the main drawer.
- `summary_search_set_from_date`: Pick the start date.
- `summary_search_set_to_date`: Pick the end date.
- `summary_search_set_result_filter_all`: Filter for all results.
- `summary_search_set_result_filter_won`: Filter for win matches.
- `summary_search_set_result_filter_tie`: Filter for draw matches.
- `summary_search_set_result_filter_lost`: Filter for loss matches.
- `summary_search_add_player_filter`: Add a player to the selected player filter list.
- `summary_search_remove_player_filter`: Remove a selected player chip.
- `summary_search_clear_player_query`: Clear the player autocomplete text.
- `summary_search_execute`: Open `SummaryResultsScreen` with the chosen filters.

### `SummaryResultsScreen` (date range title)
Description: Aggregated summary view grouped by game, with total counts, activity heatmap, and per-game cards.

Actions:
- `summary_results_open_export`: Open `SummaryExportScreen`.
- `summary_results_open_game_matches`: Tap a game card to open the game-specific match list bottom sheet.
- `summary_results_go_back`: Return to `SummarySearchScreen`.

### `SummaryResultsScreen` Game Matches Sheet
Description: Bottom sheet that lists all matches for one game inside the current summary range.

Actions:
- `summary_game_matches_close`: Dismiss the bottom sheet.
- `summary_game_matches_open_match_detail`: Tap a listed match to close the sheet and open `MatchDetailScreen`.

### `SummaryExportScreen` (`Summary Export`)
Description: Export builder for summary posters saved to the device gallery. This flow now supports a flexible `Dashboard` template and a fixed `Summary` template based closely on `SummaryResultsScreen`.

Actions:
- `summary_export_select_dashboard_template`: Switch to the dashboard export template.
- `summary_export_select_summary_template`: Switch to the fixed summary-results export template.
- `summary_export_toggle_header_section`: Include or exclude the header section.
- `summary_export_toggle_stats_section`: Include or exclude the stats section.
- `summary_export_toggle_filters_section`: Include or exclude the filters section.
- `summary_export_toggle_activity_section`: Include or exclude the activity section.
- `summary_export_toggle_top_games_section`: Include or exclude the top games section.
- `summary_export_save_image`: Capture the poster and save it to the gallery.
- `summary_export_go_back`: Return to `SummaryResultsScreen`.

### `PlayerToolScreen` (`Player Selection Tool`)
Description: Entry screen for quick in-person player selection tools.

Actions:
- `player_tool_open_drawer`: Open the main drawer.
- `player_tool_open_competitive`: Open `SinglePlayerSelectionScreen`.
- `player_tool_open_team_dialog`: Open the team count dialog.

### `PlayerToolScreen` Team Count Dialog (`How many teams?`)
Description: Modal picker that decides whether the team tool runs in 2-team or 3-team mode.

Actions:
- `player_tool_select_2_teams`: Open `TeamSelectionScreen` with `teamCount: 2`.
- `player_tool_select_3_teams`: Open `TeamSelectionScreen` with `teamCount: 3`.
- `player_tool_close_team_dialog`: Dismiss the dialog without choosing a team count.

### `SinglePlayerSelectionScreen` (`Competitive`)
Description: Multi-touch picker that assigns a random sequential order after everyone holds a finger on screen for 4 seconds.

Actions:
- `competitive_place_finger`: Put a finger on the screen to join the draw.
- `competitive_move_finger`: Move an active finger before the selection completes.
- `competitive_release_finger`: Remove a finger before the selection completes.
- `competitive_wait_for_selection`: Keep touches held for 4 seconds to trigger random assignment.
- `competitive_reset_selection`: Reset the finished selection with the refresh action or by starting over.

### `TeamSelectionScreen` (`2 Teams` / `3 Teams`)
Description: Multi-touch team assignment tool. Randomly assigns players to teams, then randomly picks a winning team.

Actions:
- `team_selection_place_finger`: Put a finger on the screen to join the assignment.
- `team_selection_move_finger`: Move an active finger before assignment completes.
- `team_selection_release_finger`: Remove a finger before assignment completes.
- `team_selection_wait_for_assignment`: Hold touches for 4 seconds to assign teams.
- `team_selection_reset_assignment`: Reset the finished assignment with the refresh action or by starting over.

## Suggested Request Examples

- "In `LibraryScreen`, change `library_open_register_match` so it returns to `LibraryScreen` instead of `MatchesScreen`."
- "In `AddMatchScreen`, change `add_match_open_add_player` so the dialog also asks for team name."
- "In `SummaryResultsScreen`, redesign `summary_results_open_game_matches` so the bottom sheet shows thumbnails."
- "In `PlayerToolScreen`, change `player_tool_open_team_dialog` so it supports 4 teams too."