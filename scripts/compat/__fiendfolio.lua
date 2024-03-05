local mod = SomethingWicked
local ff = FiendFolio
local directory = "scripts/compat/FF/"

--https://www.tutorialspoint.com/concatenation-of-tables-in-lua-programming
local function TableConcat(t1,t2)
    for i=1,#t2 do
       t1[#t1+1] = t2[i]
    end
    return t1
 end

local fuzzy = include(directory.."fuzzyPickle")
local stacks = include(directory.."stackableItems")
function mod.compat:FFInit()
    if ff then
        ff.ReferenceItems.Actives = TableConcat(ff.ReferenceItems.Actives, fuzzy.Actives)
        ff.ReferenceItems.Passives = TableConcat(ff.ReferenceItems.Passives, fuzzy.Passives)
        ff.ReferenceItems.Trinkets = TableConcat(ff.ReferenceItems.Trinkets, fuzzy.Trinkets)

        ff:AddStackableItems(stacks)

        ff.electrumSynergies = TableConcat(ff.electrumSynergies, include(directory.."electrum"))

        local itemTab = ff.ITEM.COLLECTIBLE
        SomethingWicked.FiendFolioCrownLocusts = {
            {itemTab.AVGM, 1},
            {itemTab.BEDTIME_STORY, 3},
            {itemTab.BEE_SKIN, 1},
            {itemTab.BLACK_MOON, 1},
            {itemTab.PRANK_COOKIE, 1},
            {itemTab.DEVILS_DAGGER, 1},
            {itemTab.DEVILS_UMBRELLA, 1},
            {itemTab.EMOJI_GLASSES, 1},
            {itemTab.FAMILIAR_FLY, 1},
            {itemTab.GORGONEION, 1},
            --{itemTab.STORE_WHISTLE, 1},
            {itemTab.HYPNO_RING, 1},
            {itemTab.INFINITY_VOLT, 1},
            {itemTab.KALUS_HEAD, 1},
            {itemTab.SMASH_TROPHY, 1},
            {itemTab.NIL_PASTA, 1},
            {itemTab.PINHEAD, 2},
            {itemTab.TIME_ITSELF, 1},
            {itemTab.TOY_PIANO, 1},

        }
    end
end
