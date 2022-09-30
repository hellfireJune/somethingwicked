local this = {}
CollectibleType.SOMETHINGWICKED_ABANDONED_BOX = Isaac.GetItemIdByName("Abandoned Box")

function this:UseItem(_, rngObj, player, flags)
    if flags & UseFlag.USE_CARBATTERY ~= 0 then
        return
    end
    
    local pool = SomethingWicked.game:GetItemPool()
    local room = SomethingWicked.game:GetRoom()
    local familiar = this:GetFamiliarFromPool(pool, room)
    pool:RemoveCollectible(familiar)

    local pickup = Isaac.Spawn(EntityType.ENTITY_PICKUP, PickupVariant.PICKUP_COLLECTIBLE, familiar, room:FindFreePickupSpawnPosition(player.Position), Vector.Zero, player)
    Isaac.Spawn(EntityType.ENTITY_EFFECT, EffectVariant.POOF01, 0, pickup.Position, Vector.Zero, pickup)

    return {ShowAnim = true, Remove = true}
end

function this:GetFamiliarFromPool(pool, room)
    local itemConfig = Isaac.GetItemConfig()
    
    local poolType = pool:GetPoolForRoom(room:GetType(), room:GetAwardSeed())
    if poolType == -1 then poolType = ItemPoolType.POOL_TREASURE end

    for i = 1, 100, 1 do
        local newCollectible = pool:GetCollectible(poolType, false)
        local conf = itemConfig:GetCollectible(newCollectible)
        if conf.Type == ItemType.ITEM_FAMILIAR then
            return newCollectible
        end
    end

    return CollectibleType.COLLECTIBLE_BROTHER_BOBBY
end

SomethingWicked:AddCallback(ModCallbacks.MC_USE_ITEM, this.UseItem, CollectibleType.SOMETHINGWICKED_ABANDONED_BOX)

this.EIDEntries = {
    [CollectibleType.SOMETHINGWICKED_ABANDONED_BOX] = {
        desc = "Spawns a random familiar from the current room's item pool",
        encycloDesc = SomethingWicked:UtilGenerateWikiDesc({"Spawns a random familiar from the current room's item pool.", "Will spawn brother bobby as a fallback familiar, if there are no available familiars in the current room's item pool"}),
        pools = {
            SomethingWicked.encyclopediaLootPools.POOL_SHOP,
            SomethingWicked.encyclopediaLootPools.POOL_GREED_SHOP
        }
    }
}
return this