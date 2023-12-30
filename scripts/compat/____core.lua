local mod = SomethingWicked
mod.compat = {}
local callbacksAdded = false
local directory = "scripts/misc/compat/"
local game = Game()

include(directory.."__fiendfolio")
include(directory.."__retribution")
include(directory.."__tainted")

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
}
function mod.compat:Init()
    if not callbacksAdded then
        callbacksAdded = true

        mod.compat:FFInit()

        
        for _, cardHud in ipairs(moddedThrowables) do
            local card = Isaac.GetItemIdByName(cardHud)
            if card ~= -1 then
                table.insert(mod.edensHeadthrowables, card)
            end
        end
    end
end


if game:GetFrameCount() ~= 0 then
    mod.compat:Init()
end
mod:AddCallback(ModCallbacks.MC_POST_GAME_STARTED, mod.compat.Init)

