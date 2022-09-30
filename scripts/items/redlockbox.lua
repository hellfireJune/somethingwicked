local this = {}
CollectibleType.SOMETHINGWICKED_RED_LOCKBOX = Isaac.GetItemIdByName("Red Lockbox")

function this:OnPickup(player, room)
    local myRNG = RNG()
    myRNG:SetSeed(Random() + 1, 1)
    for i = 1, 4 + myRNG:RandomInt(3), 1 do            
        local pickup = Isaac.Spawn(EntityType.ENTITY_PICKUP, PickupVariant.PICKUP_HEART, HeartSubType.HEART_SOUL, room:FindFreePickupSpawnPosition(player.Position), Vector.Zero, player)  
    end 
end

SomethingWicked:AddCustomCBack(SomethingWicked.enums.CustomCallbacks.SWCB_PICKUP_ITEM, this.OnPickup, CollectibleType.SOMETHINGWICKED_RED_LOCKBOX)

this.EIDEntries = {
    [CollectibleType.SOMETHINGWICKED_RED_LOCKBOX] = {
        desc = "↑ Spawns 4-6 soul hearts on pickup",
        pools = {
            SomethingWicked.encyclopediaLootPools.POOL_RED_CHEST,
            SomethingWicked.encyclopediaLootPools.POOL_DEMON_BEGGAR,
            SomethingWicked.encyclopediaLootPools.POOL_KEY_MASTER,
            SomethingWicked.encyclopediaLootPools.POOL_ULTRA_SECRET,
        },
        encycloDesc = SomethingWicked:UtilGenerateWikiDesc({"Spawns 4-6 soul hearts on pickup"})
    }
}
return this

--[[function this:PEffectUpdate(player)
    local p_data = player:GetData()
    if p_data.somethingWicked_heldRedLockbox then
        if player:IsExtraAnimationFinished() then
            
            p_data.somethingWicked_timesPickedUpRedLockbox = p_data.somethingWicked_timesPickedUpRedLockbox or 0
            if p_data.somethingWicked_timesPickedUpRedLockbox < player:GetCollectibleNum(CollectibleType.SOMETHINGWICKED_RED_LOCKBOX) then
                local room = SomethingWicked.game:GetRoom(_, _, _)
                local myRNG = RNG()
                myRNG:SetSeed(Random() + 1, 1)
                for i = 1, 4 + myRNG:RandomInt(3), 1 do            
                    Isaac.Spawn(EntityType.ENTITY_PICKUP, PickupVariant.PICKUP_HEART, HeartSubType.HEART_SOUL, room:FindFreePickupSpawnPosition(player.Position), Vector.Zero, player)  
                end 

                p_data.somethingWicked_heldRedLockbox = nil
            end
            p_data.somethingWicked_timesPickedUpRedLockbox = player:GetCollectibleNum(CollectibleType.SOMETHINGWICKED_RED_LOCKBOX)
        end
    else
        local targetItem = player.QueuedItem.Item
        if not targetItem
        or not (targetItem.ID == CollectibleType.SOMETHINGWICKED_RED_LOCKBOX)
        then
            return
        end
        p_data.somethingWicked_heldRedLockbox = true
    end
    
end

SomethingWicked:AddCallback(ModCallbacks.MC_POST_PEFFECT_UPDATE, this.PEffectUpdate)]]