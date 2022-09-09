local this = {}
CollectibleType.SOMETHINGWICKED_AVENGER_EMBLEM = Isaac.GetItemIdByName("Avenger Emblem")

function this:damageCache(player)
    player.Damage = SomethingWicked.StatUps:DamageUp(player, 1 * player:GetCollectibleNum(CollectibleType.SOMETHINGWICKED_AVENGER_EMBLEM))
end

SomethingWicked:AddCallback(ModCallbacks.MC_EVALUATE_CACHE, this.damageCache, CacheFlag.CACHE_DAMAGE)

this.EIDEntries = {
    [CollectibleType.SOMETHINGWICKED_AVENGER_EMBLEM] = {
        desc = "↑ +1 damage up",
        encycloDesc = SomethingWicked:UtilGenerateWikiDesc({"Damage up by 1"}),
        pools = {
            SomethingWicked.encyclopediaLootPools.POOL_BOSS,
            SomethingWicked.encyclopediaLootPools.POOL_GREED_BOSS
        }
    }
}
return this
