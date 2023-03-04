local mod = SomethingWicked
local ff = FiendFolio
local directory = "scripts/misc/compat/FF/"

local fuzzy = include(directory.."fuzzyPickle")

function mod.compat:FFInit()
    if ff then
        ff.ReferenceItems.Actives = TableConcat(ff.ReferenceItems.Actives, fuzzy.Actives)
        ff.ReferenceItems.Passives = TableConcat(ff.ReferenceItems.Passives, fuzzy.Passives)
        ff.ReferenceItems.Trinkets = TableConcat(ff.ReferenceItems.Trinkets, fuzzy.Trinkets)
    end
end

--https://www.tutorialspoint.com/concatenation-of-tables-in-lua-programming
function TableConcat(t1,t2)
    for i=1,#t2 do
       t1[#t1+1] = t2[i]
    end
    return t1
 end