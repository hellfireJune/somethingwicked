local this = {}
SomethingWicked.defaultPickupTable = {PickupVariant.PICKUP_HEART, PickupVariant.PICKUP_COIN, PickupVariant.PICKUP_TRINKET, 
                    PickupVariant.PICKUP_BOMB, PickupVariant.PICKUP_KEY, PickupVariant.PICKUP_GRAB_BAG, 
                    PickupVariant.PICKUP_PILL, PickupVariant.PICKUP_LIL_BATTERY, PickupVariant.PICKUP_TAROTCARD}

function this:OnEnemyKill(entity)
    if entity == nil then
        return
    end
    
    if entity:IsEnemy() and entity:ToNPC():IsChampion() then
        local e_Rng =  entity:GetDropRNG()
        for _, player in ipairs(SomethingWicked.ItemHelpers:AllPlayersWithCollectible(CollectibleType.SOMETHINGWICKED_FITUS_FORTUNUS)) do
            if e_Rng:RandomFloat() <= 0.33 then
                local pickupToCreate = SomethingWicked.defaultPickupTable[e_Rng:RandomInt(#SomethingWicked.defaultPickupTable) + 1]
                Isaac.Spawn(EntityType.ENTITY_PICKUP, pickupToCreate, 0, entity.Position, Vector.Zero, entity)
            end
        end
    end
end

SomethingWicked:AddCallback(ModCallbacks.MC_POST_ENTITY_KILL, this.OnEnemyKill)

this.EIDEntries = {
    [CollectibleType.SOMETHINGWICKED_FITUS_FORTUNUS] = {
        desc = "↑ 33% chance to spawn a random pickup upon killing a champion",
        pools = {
            SomethingWicked.encyclopediaLootPools.POOL_SHOP,
            SomethingWicked.encyclopediaLootPools.POOL_GREED_SHOP,
        },
        encycloDesc = SomethingWicked:UtilGenerateWikiDesc({"33% chance to spawn a random pickup upon killing a champion enemy", "This pickup can be a random heart, coin, trinket, bomb, key, sack, pill, battery, or card"})
    }
}
return this