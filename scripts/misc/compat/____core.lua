local mod = SomethingWicked
mod.compat = {}
local callbacksAdded = false

function mod.compat:Init()
    if not callbacksAdded then
        
    end
end
if mod.game:GetFrameCount() ~= 0 then
    mod.compat:Init()
end
mod:AddCallback(ModCallbacks.MC_POST_GAME_STARTED, mod.compat.Init)