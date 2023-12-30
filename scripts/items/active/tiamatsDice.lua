local game = Game()
local mod = SomethingWicked

local PricePool = 
{
    { 0, 20},
    { PickupPrice.PRICE_ONE_HEART, 13},
    { PickupPrice.PRICE_TWO_HEARTS, 10},
    { PickupPrice.PRICE_THREE_SOULHEARTS, 7},
    { PickupPrice.PRICE_SPIKES, 12},
}
for i = 1, 86, 1 do
    table.insert(PricePool, {i + 7, 0.4})
end

local function UseItem(_, _, rngObj)
    local itemsInRoom = Isaac.FindByType(EntityType.ENTITY_PICKUP, PickupVariant.PICKUP_COLLECTIBLE)

    for _, item in ipairs(itemsInRoom) do
        if item.SubType > 0 then
            item = item:ToPickup()
            local itempool = mod:GetRandomPool(rngObj)
            local collectible = game:GetItemPool():GetCollectible(itempool, true)
    
            item:Morph(EntityType.ENTITY_PICKUP, PickupVariant.PICKUP_COLLECTIBLE, collectible, false)
            local price = mod:UtilWeightedGetThing(PricePool, rngObj)
            if price ~= nil then
                item.Price = price
                item.AutoUpdatePrice = false
                item.ShopItemId = -1
            end
    
            Isaac.Spawn(EntityType.ENTITY_EFFECT, EffectVariant.POOF01, 0, item.Position, Vector.Zero, item)
        end
    end

    return true
end

mod:AddCallback(ModCallbacks.MC_USE_ITEM, UseItem, CollectibleType.SOMETHINGWICKED_TIAMATS_DICE)