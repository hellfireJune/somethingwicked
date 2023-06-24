local this = {}

function this:ItemUse()
    local room = SomethingWicked.game:GetRoom()
    if room:GetType() == RoomType.ROOM_SHOP then
        room:ShopRestockFull()
    end
    --room:ShopReshuffle(false, true)
    --[[local shopItems = Isaac.FindByType(EntityType.ENTITY_PICKUP)
    for _, shopItem in ipairs(shopItems) do
        local pickup = shopItem:ToPickup()
        if pickup:IsShopItem() then
            pickup:Morph(EntityType.ENTITY_PICKUP, PickupVariant.PICKUP_SHOPITEM, 0, true) 
        end
    end]]
    return true
end

SomethingWicked:AddCallback(ModCallbacks.MC_USE_ITEM, this.ItemUse, CollectibleType.SOMETHINGWICKED_D_STOCK)

this.EIDEntries = {
    [CollectibleType.SOMETHINGWICKED_D_STOCK] = {
        desc = "Restocks the current shop",
        pools = {
            SomethingWicked.encyclopediaLootPools.POOL_SHOP,
            SomethingWicked.encyclopediaLootPools.POOL_GREED_SHOP,
        },
        encycloDesc = SomethingWicked:UtilGenerateWikiDesc({"Upon using inside a shop, restocks the pickups available"})
    }
}
return this