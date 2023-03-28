# README

## How to generate video replay

Scripts are in `utilities/dataprocessing` folder.
Create `player_map_analyzed` and `video` folder in `data/` directory if they do not exist.

1. Run `import_json_map.m`
    - merge each participant's `player_map_history_json` with `player_operation_history`
    - each participant may take 1-2 min
2. Run `export_video.m`
    - change input arguments of `mapHistory2video` to select levels
    - if you do not want to the figure window, set figure(..., 'visible', 'on') in the `mapHistory2video` function to 'off' (line 72)

> `player_map_analyzed` and `video` folder are ignored in git
