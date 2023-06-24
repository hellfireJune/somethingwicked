local this = {}

function this:damageCache(player)
    player.Damage = SomethingWicked.StatUps:DamageUp(player, 0.5 * player:GetCollectibleNum(CollectibleType.SOMETHINGWICKED_WOODEN_HORN))
end

SomethingWicked:AddCallback(ModCallbacks.MC_EVALUATE_CACHE, this.damageCache, CacheFlag.CACHE_DAMAGE)

this.EIDEntries = {
    [CollectibleType.SOMETHINGWICKED_WOODEN_HORN] = {
        desc = "↑ {{Damage}} +0.5 Damage up#+1 Black heart",
        pools = {
            SomethingWicked.encyclopediaLootPools.POOL_BOSS,
            SomethingWicked.encyclopediaLootPools.POOL_GREED_BOSS,
            SomethingWicked.encyclopediaLootPools.POOL_WOODEN_CHEST
        },
        encycloDesc = SomethingWicked:UtilGenerateWikiDesc({"Grants one black heart", "+0.5 damage"})
    }
}
return this
