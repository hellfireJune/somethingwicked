local mod = SomethingWicked
mod.compat = {}
local callbacksAdded = false
local directory = "scripts/misc/compat/"

include(directory.."__fiendfolio")
include(directory.."__retribution")
include(directory.."__tainted")

function mod.compat:Init()
    if not callbacksAdded then
        mod.compat:FFInit()
    end
end
if mod.game:GetFrameCount() ~= 0 then
    mod.compat:Init()
end
mod:AddCallback(ModCallbacks.MC_POST_GAME_STARTED, mod.compat.Init)