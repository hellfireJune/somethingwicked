local mod = SomethingWicked
local sfx = SFXManager()
local this = {}
local sHeartValues = { [HeartSubType.HEART_HALF_SOUL] = 1, [HeartSubType.HEART_SOUL] = 2}
CollectibleType.SOMETHINGWICKED_RED_CAP = Isaac.GetItemIdByName("Red Cap")

mod:AddPriorityCallback(ModCallbacks.MC_PRE_PICKUP_COLLISION, CallbackPriority.LATE, function (_, pickup, player)
    if not mod.ItemHelpers:CanPickupPickupGeneric(pickup, player) then
        return
    end

    player = player:ToPlayer()
    if not player or not player:HasCollectible(CollectibleType.SOMETHINGWICKED_RED_CAP) then
        return
    end

    if sHeartValues[pickup.SubType] ~= nil
    and player:GetHearts() < player:GetEffectiveMaxHearts() then
        local sValue = sHeartValues[pickup.SubType]
        local heartsNeededToHeal = player:GetEffectiveMaxHearts() - player:GetHearts()
        while sValue > 0 and heartsNeededToHeal > 0 do
            sValue = sValue - 1
            player:AddHearts(2)
            heartsNeededToHeal = heartsNeededToHeal - 2
        end
        player:AddSoulHearts(sValue)

        local sprite = pickup:GetSprite()
        sprite:Play("Collect")
        pickup:Die()
        sfx:Play(SoundEffect.SOUND_HOLY)
        return true
    end
end, PickupVariant.PICKUP_HEART)

mod:AddCallback(ModCallbacks.MC_EVALUATE_CACHE, function (_, player, flags)
    local itemNult = player:GetCollectibleNum(CollectibleType.SOMETHINGWICKED_RED_CAP)

    if flags == CacheFlag.CACHE_SHOTSPEED then
        player.ShotSpeed = player.ShotSpeed - (0.15 * itemNult)
    end
    if flags == CacheFlag.CACHE_RANGE then
        player.TearRange = player.TearRange - (itemNult * 40 * 0.8)
    end
end)

mod:AddCallback(ModCallbacks.MC_POST_PICKUP_UPDATE, function (_, pickup)
    if mod.ItemHelpers:GlobalPlayerHasCollectible(CollectibleType.SOMETHINGWICKED_RED_CAP)
    and sHeartValues[pickup.SubType] ~= nil then
        local red = ((math.sin(pickup.FrameCount / 20)+1)/10)
        pickup:SetColor(Color(1, 0.9, 0.9, 1, red), 2, 1, false, false)
    end
end, PickupVariant.PICKUP_HEART)

this.EIDEntries = {
    [CollectibleType.SOMETHINGWICKED_RED_CAP] = {
        desc = "Picking up a soul heart with empty red hearts will convert it to red hearts, at a 2x rate#+2 max hearts#+Heals 3 hearts on pickup#+0.15 shot speed down#+0.8 range down",
        pools = { mod.encyclopediaLootPools.POOL_TREASURE, mod.encyclopediaLootPools.POOL_SECRET, mod.encyclopediaLootPools.POOL_ULTRA_SECRET }
    }
}
return this