# Experience Effect on Bonus Levels

- PKU onsite participants
- with hints
- Level-up experience

## Change in experiment settings

The self-adaptation procedure in the bonus chapter (in Unity script `SolutionDataManager.cs`) is changed after 1:00AM, March 27, 2022.

## Raw gameplay data folder

- `data/participants.csv`
    - Columns: `SubNo | Date | Name | Condition`
    - `Condition`: version of the level map in Chapter 2, Level 4 & 5
        1. Naïve Naïve
        2. Naïve Familiar
        3. Familiar Naïve
        4. Familiar Familiar
- `data/player_level_timer/`
- `data/player_bonus_solution/`
- `data/player_operation_history/`
    - `data/player_map_history_json/`: regenerated from the operation history in unity editor

## Process raw data

To handle raw data, **first** run `parse_json_level_info.m` to merge operation data (`player_operation_history`) with unity-replayed map data (`player_map_history_json/`). Merged `mat` files will be saved into a git-ignored folder `player_map_analyzed`. 

Run `parse_json_level_info.m` to get timing and bonus level info only when needed (for convenience, it is included in `importData.m`).
