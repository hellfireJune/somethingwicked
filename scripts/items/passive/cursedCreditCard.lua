local procChance = 0.5
local couldBuyItemTable = {
    [PickupPrice.PRICE_ONE_HEART] = function (player)
        return player:GetEffectiveMaxHearts() >= 1, 1
    end,
    [PickupPrice.PRICE_TWO_HEARTS] = function (player)
        return player:GetEffectiveMaxHearts() >= 1, 0.5
    end,
    [PickupPrice.PRICE_THREE_SOULHEARTS] = function (player)
        return player:GetSoulHearts() >= 1, 0.5
    end,
}

local function PickupCollision(_, pickup, collider)
    if collider.Type ~= EntityType.ENTITY_PLAYER then
        return
    end

    if (pickup.Price ~= PickupPrice.PRICE_ONE_HEART
    and pickup.Price ~= PickupPrice.PRICE_TWO_HEARTS
    and pickup.Price ~= PickupPrice.PRICE_THREE_SOULHEARTS) then
        return
    end

    collider = collider:ToPlayer()

    local canBuy, mult = couldBuyItemTable[pickup.Price](collider)
    if collider:HasCollectible(mod.ITEMS.CURSED_CREDIT_CARD) 
    and collider:CanPickupItem() and collider:IsExtraAnimationFinished() and canBuy then
        local rng = collider:GetCollectibleRNG(mod.ITEMS.CURSED_CREDIT_CARD)
        local proc = rng:RandomFloat()
        if proc <= procChance * mult then
            pickup.Price = PickupPrice.PRICE_FREE
        end
    end
end

SomethingWicked:AddCallback(ModCallbacks.MC_PRE_PICKUP_COLLISION, PickupCollision)