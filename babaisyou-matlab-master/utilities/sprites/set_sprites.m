%% Sprites

spriteSet = {'Cloud','Sun','Dice','Pumpkin','Bone','Chocolate',...
    'Glove','Bag','Rug','Football','Glass','Fan',...
    'Box','Book','Heart','Lemon','Pear','Kiwi','Mirror', ...
    'Text'};
valueSet = [1:19, 10000];

Sprites = containers.Map(spriteSet,valueSet);

clear spriteSet valueSet