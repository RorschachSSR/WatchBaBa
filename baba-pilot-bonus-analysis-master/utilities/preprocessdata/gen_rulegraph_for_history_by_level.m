% Generate rule graph for level history

LvlNo = [4, 5, 3];
VerId = {[0, 0, 0, 0], [0 0 0 1 1], [0 1 1]};

for chp = 1:3
    for lvl = 1 : LvlNo(chp)
        for ver = 0:VerId{chp}(lvl)
            tic
            filedir = sprintf('data/level_player_map_history/chp_%d_lvl_%d_ver_%d.mat', chp, lvl, ver);
            load(filedir)
            if chp < 3
                logicalArray = [levelConfigs(:).chapter] == chp ...
                    & [levelConfigs(:).level] == lvl ...
                    & [levelConfigs(:).version] == ver;
            else
                logicalArray = [levelConfigs(:).chapter] == chp;
            end
            levelConfig = levelConfigs(logicalArray);
            height = levelConfig.size.y;
            gridMap = cellfun(@(x) entityCluster2mapArray(x, height), {levelHistory(:).entities}, 'UniformOutput', false);
            [levelHistory(:).gridmap] = deal(gridMap{:});
            [r, ~, ~] = arrayfun(@(x) gameLogicAnalyzer(x), levelHistory, 'UniformOutput', false);
            [levelHistory(:).ruleGraph] = deal(r{:});
            newfilename = sprintf('data/level_player_map_history/withRule_chp_%d_lvl_%d_ver_%d.mat', chp, lvl, ver);
            save(newfilename, 'levelHistory')
            clear r gridMap
            fprintf('chp_%d_lvl_%d_ver_%d: ', chp, lvl, ver)
            toc
        end
    end
end