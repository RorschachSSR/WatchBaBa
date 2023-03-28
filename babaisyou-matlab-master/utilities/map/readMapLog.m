function [mapHistory, row] = readMapLog(filename)
%readMapLog Read the map history log generated by Unity
%   INPUT: filename
%   OUTPUT: a struct containing timing and map information
%           timestamp | size | blocks

    fid = fopen(filename);
    row = 0;

    % import map history as struct
    mapHistory = struct('timestamp', {}, 'size', {}, 'blocks', {});
    while ~feof(fid)
        tline = fgetl(fid);
        if ischar(tline)
            row = row + 1;
            mapHistory(row) = jsondecode(tline);
        end
    end
    
    fclose(fid);
end

