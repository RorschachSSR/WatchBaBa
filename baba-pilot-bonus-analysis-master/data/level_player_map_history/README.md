# Explanation of the 'ver' variable

The 'ver' specifies the type of map configuration the participant encounters.

## Chapter 2 (training)

For level 4 and level 5 in chapter 2, the 'ver' variable is part of the experiment manipulation and is pre-assigned to each participant before the experiment. 

| ver | type | details|
| --- |:-------- |:--------------------------------|
| 0 | naive | encounter the 'defeat' property word |
| 1 | familiar | encounter the 'hot' and 'melt' property pair|

## Chapter 3 (bonus)

For level 2 and level 3 in chapter 3, the map configuration adapts to participants' behavior to encourage them to look for novel solutions. All three levels in chapter 3 are basically the same, except for local modifications to disable solutions already used by a participant.

|level| ver | type | details|
| ----- | --- |:-------- |:--------------------------------|
| 2 | 0 | noBagIsPush | use "Bag Is Push" solution in level 1|
| 2 | 1 | noMelt | use "Bag Is Melt & Hot" solution in level 1|
| 3 | 0 | noBag  | use "Bag Is Melt & Hot" and "Bag Is Push" in level 1 & 2 (in either order) |
| 3 | 1 | noPush | use "Bag Is Push" and "Pumpkin is Push" in level 1 & 2 (in either order) |

For the chapter 3 map, there are three solutions:

- "Bag Is Push"
- "Bag is Melt & Hot"
- "Pumpkin is Push" (furthur divided into "Other Is You" and "Break Hot or Melt")

Theoretically, there can be 3 types of configuration for level 2, and 6 for level 3. But some of them do not exist empirically in our experiment, so not presented here.
