local this = {}

function this:damageCache(player)
    player.Damage = SomethingWicked.StatUps:DamageUp(player, 1 * player:GetCollectibleNum(CollectibleType.SOMETHINGWICKED_AVENGER_EMBLEM))
end

SomethingWicked:AddCallback(ModCallbacks.MC_EVALUATE_CACHE, this.damageCache, CacheFlag.CACHE_DAMAGE)

this.EIDEntries = {
    [CollectibleType.SOMETHINGWICKED_AVENGER_EMBLEM] = {
        desc = "↑ {{Damage}} +1 Damage up",
        encycloDesc = SomethingWicked:UtilGenerateWikiDesc({"Damage up by 1"}),
        pools = {
            SomethingWicked.encyclopediaLootPools.POOL_BOSS,
            SomethingWicked.encyclopediaLootPools.POOL_GREED_BOSS
        }
    }
}
return this
