local this = {}
CollectibleType.SOMETHINGWICKED_MAMMONS_TOOTH = Isaac.GetItemIdByName("Mammon's Tooth")

function this:damageCache(player)
    player.Damage = SomethingWicked.StatUps:DamageUp(player, 0.7 * player:GetCollectibleNum(CollectibleType.SOMETHINGWICKED_MAMMONS_TOOTH))
end

function this:OnPickup(player, room)
    Isaac.Spawn(EntityType.ENTITY_PICKUP, PickupVariant.PICKUP_COIN, 0, room:FindFreePickupSpawnPosition(player.Position), Vector.Zero, player)  
end

SomethingWicked:AddCustomCBack(SomethingWicked.enums.CustomCallbacks.SWCB_PICKUP_ITEM, this.OnPickup, CollectibleType.SOMETHINGWICKED_MAMMONS_TOOTH)
SomethingWicked:AddCallback(ModCallbacks.MC_EVALUATE_CACHE, this.damageCache, CacheFlag.CACHE_DAMAGE)

this.EIDEntries = {
    [CollectibleType.SOMETHINGWICKED_MAMMONS_TOOTH] = {
        desc = "↑ +0.7 damage up#Spawns 1 coin on pickup",--[[
        encycloDesc = SomethingWicked:UtilGenerateWikiDesc({"+0.7 damage up", "Spawns 1 random coin on pickup"}),
        pools = {
            SomethingWicked.encyclopediaLootPools.POOL_BOSS
        }]]
    }
}
return this
