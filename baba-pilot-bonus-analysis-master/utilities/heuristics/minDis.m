function output = minDis(posList1, posList2, bnd)
    manhattan = @(x,y) sum(abs(x-y));
    output = bnd;
    for i = 1:size(posList1, 1)
        for j = 1:size(posList2, 1)
            temp = manhattan(posList1(i, :), posList2(j, :));
            if temp < output
                output = temp;
            end
        end
    end
end

