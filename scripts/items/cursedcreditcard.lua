local this = {}
this.ProcChance = 0.35

this.couldBuyItemTable = {
    [PickupPrice.PRICE_ONE_HEART] = function (player)
        return player:GetEffectiveMaxHearts() >= 1, 1
    end,
    [PickupPrice.PRICE_TWO_HEARTS] = function (player)
        return player:GetEffectiveMaxHearts() >= 1, 0.5
    end,
    [PickupPrice.PRICE_THREE_SOULHEARTS] = function (player)
        return player:GetEffectiveMaxHearts() >= 1, 0.5
    end,
}

function this:PickupCollision(pickup, collider)
    if collider.Type ~= EntityType.ENTITY_PLAYER then
        return
    end

    if (pickup.Price ~= PickupPrice.PRICE_ONE_HEART
    and pickup.Price ~= PickupPrice.PRICE_TWO_HEARTS
    and pickup.Price ~= PickupPrice.PRICE_THREE_SOULHEARTS) then
        return
    end

    collider = collider:ToPlayer()

    local canBuy, mult = this.couldBuyItemTable[pickup.Price](collider)
    if collider:HasCollectible(CollectibleType.SOMETHINGWICKED_CURSED_CREDIT_CARD) 
    and collider:CanPickupItem() and collider:IsExtraAnimationFinished() and canBuy then
        local rng = collider:GetCollectibleRNG(CollectibleType.SOMETHINGWICKED_CURSED_CREDIT_CARD)
        local proc = rng:RandomFloat()
        if proc <= this.ProcChance * mult then
            pickup.Price = PickupPrice.PRICE_FREE
        end
    end
end

SomethingWicked:AddCallback(ModCallbacks.MC_PRE_PICKUP_COLLISION, this.PickupCollision)

this.EIDEntries = {
    [CollectibleType.SOMETHINGWICKED_CURSED_CREDIT_CARD] = {
        desc = "Buying a Devil Deal Item has a "..(this.ProcChance * 100).."% chance to not cost hearts#Items which cost more hearts have less of a chance to work#+1 black heart",
        pools = {
            SomethingWicked.encyclopediaLootPools.POOL_CURSE,
            SomethingWicked.encyclopediaLootPools.POOL_ULTRA_SECRET,
        },
        encycloDesc = SomethingWicked:UtilGenerateWikiDesc({"Buying a Devil Deal Item has a "..(this.ProcChance * 100).."% chance to not cost hearts","Items which cost more hearts have less of a chance to work","Adds 1 black heart on pickup"})
    }
}
return this