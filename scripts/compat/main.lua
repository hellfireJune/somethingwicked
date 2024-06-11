local mod = SomethingWicked
local directory = "scripts/compat/"
local game = Game()

local ffInit = include(directory.."fiendfolio")
include(directory.."retribution")
include(directory.."tainted")
local milkshakeInit = include(directory.."milkshake")

local moddedThrowables = {
    "Cursed Candle",
    "Balrog's Head",
    --"Ice Wand",
    "Boline",
    --"Facestabber",

    --fOLIO
    "D2",
    "Sanguine Hook",
    "Grappling Hook",

    --milkshake
    "Shattered Orb",

    --ret
    "Puffstool"
}
function mod:CompatInit()
        ffInit()
        milkshakeInit()
        
        for _, cardHud in ipairs(moddedThrowables) do
            local card = Isaac.GetItemIdByName(cardHud)
            if card ~= -1 then
                table.insert(mod.edensHeadthrowables, card)
            end
        end
end

mod:AddCallback(ModCallbacks.MC_POST_MODS_LOADED, mod.CompatInit)

