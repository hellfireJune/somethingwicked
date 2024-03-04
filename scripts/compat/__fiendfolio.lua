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
    end
end
