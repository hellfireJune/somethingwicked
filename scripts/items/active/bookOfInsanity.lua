local mod = SomethingWicked

local function UseItem(_, _, _, player, flags)
    --local p_data = player:GetData()
    mod:SpawnNightmare(player, player.Position)

    return true
end

local function WispUpdate(_, familiar)
    if familiar.SubType == mod.ITEMS.BOOK_OF_INSANITY then    
        local player = familiar.Player
        
        mod:FluctuatingOrbitFunc(familiar, player)
    end
end

SomethingWicked:AddCallback(ModCallbacks.MC_FAMILIAR_UPDATE, WispUpdate, FamiliarVariant.WISP)
SomethingWicked:AddCallback(ModCallbacks.MC_USE_ITEM, UseItem, mod.ITEMS.BOOK_OF_INSANITY)