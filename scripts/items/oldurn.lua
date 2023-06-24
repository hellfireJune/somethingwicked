local this = {}

function this:OnPickup(player, room)
    for i = 1, 3, 1 do
        local soul = nil
        local crashPreventer = 0

        while soul == nil 
        or Isaac.GetItemConfig():GetCard(soul) == nil 
        or (((string.find((Isaac.GetItemConfig():GetCard(soul).Name):lower(), "soul")) == nil) and (crashPreventer < 100))
        do
            soul = SomethingWicked.game:GetItemPool():GetCard(Random() + 1, true, true, true)
            crashPreventer = crashPreventer + 1
            --while loops scare me
        end
        Isaac.Spawn(EntityType.ENTITY_PICKUP, PickupVariant.PICKUP_TAROTCARD, soul, room:FindFreePickupSpawnPosition(player.Position), Vector.Zero, player)  
    end 
end

SomethingWicked:AddCustomCBack(SomethingWicked.CustomCallbacks.SWCB_PICKUP_ITEM, this.OnPickup, CollectibleType.SOMETHINGWICKED_OLD_URN)

this.EIDEntries = {
    [CollectibleType.SOMETHINGWICKED_OLD_URN] = {
        desc = "Spawns 3 soul stones on pickup#Will spawn runes if no soul stones are unlocked",
        encycloDesc = SomethingWicked:UtilGenerateWikiDesc({"Spawns 3 soul stones upon picking up this item", "Will spawn regular runes as a fallback"}),
        pools = {
            SomethingWicked.encyclopediaLootPools.POOL_SHOP,
            SomethingWicked.encyclopediaLootPools.POOL_SECRET,
            SomethingWicked.encyclopediaLootPools.POOL_GREED_SHOP,
            SomethingWicked.encyclopediaLootPools.POOL_GREED_SECRET
        }
    }
}
return this