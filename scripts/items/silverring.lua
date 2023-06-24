local this = {}

function this:damageCache(player)
    player.Damage = SomethingWicked.StatUps:DamageUp(player, 0.3 * player:GetCollectibleNum(CollectibleType.SOMETHINGWICKED_SILVER_RING), 0, 1 + 0.1 * player:GetCollectibleNum(CollectibleType.SOMETHINGWICKED_SILVER_RING))
end

SomethingWicked:AddCallback(ModCallbacks.MC_EVALUATE_CACHE, this.damageCache, CacheFlag.CACHE_DAMAGE)

this.EIDEntries = {
    [CollectibleType.SOMETHINGWICKED_SILVER_RING] = {
        desc = "↑ {{Damage}}  +0.3 Damage up#↑ +10% Damage Multiplier",
        pools = {
            SomethingWicked.encyclopediaLootPools.POOL_GOLDEN_CHEST,
            SomethingWicked.encyclopediaLootPools.POOL_CRANE_GAME,
        },
        encycloDesc = SomethingWicked:UtilGenerateWikiDesc({"+0.3 damage, +10% damage multiplier"})
    }
}
return this