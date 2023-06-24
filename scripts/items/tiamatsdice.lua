local this = {}
this.PricePool = 
{
    { 0, 20},
    { PickupPrice.PRICE_ONE_HEART, 13},
    { PickupPrice.PRICE_TWO_HEARTS, 10},
    { PickupPrice.PRICE_THREE_SOULHEARTS, 7},
    { PickupPrice.PRICE_SPIKES, 12},
}
for i = 1, 46, 1 do
    table.insert(this.PricePool, {i + 7, 0.75})
end

function this:UseItem(_, rngObj)
    local itemsInRoom = Isaac.FindByType(EntityType.ENTITY_PICKUP, PickupVariant.PICKUP_COLLECTIBLE)

    for _, item in ipairs(itemsInRoom) do
        if item.SubType > 0 then
            item = item:ToPickup()
            local itempool = rngObj:RandomInt(31)
            local collectible = SomethingWicked.game:GetItemPool():GetCollectible(itempool, true)
    
            item:Morph(EntityType.ENTITY_PICKUP, PickupVariant.PICKUP_COLLECTIBLE, collectible, false)
            local price = SomethingWicked:UtilWeightedGetThing(this.PricePool, rngObj)
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

SomethingWicked:AddCallback(ModCallbacks.MC_USE_ITEM, this.UseItem, CollectibleType.SOMETHINGWICKED_TIAMATS_DICE)

this.EIDEntries = {
    [CollectibleType.SOMETHINGWICKED_TIAMATS_DICE] = {
        desc = "Rerolls items into items from a random item pool, with a random cost",
        encycloDesc = SomethingWicked:UtilGenerateWikiDesc(
            {"Upon use, rerolls all items in the room into other items from a random item pool, with a random price attached"}
        ),
        pools = {
            SomethingWicked.encyclopediaLootPools.POOL_SECRET,
            SomethingWicked.encyclopediaLootPools.POOL_GREED_SECRET
        }
    }
}
return this