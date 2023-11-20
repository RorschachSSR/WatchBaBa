function Num = getSubNo(date, name)
    arguments
        date {mustBeInteger, mustBePositive}
        name char 
    end
    P = readtable('data/participants.csv');
    Num = P.SubNo(P.Date == date & strcmp(P.Name, name));
end