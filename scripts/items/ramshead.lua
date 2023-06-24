local this = {}

function this:TearsCache(player)
    player.MaxFireDelay = SomethingWicked.StatUps:TearsUp(player, player:GetCollectibleNum(CollectibleType.SOMETHINGWICKED_RAMS_HEAD) * 0.7)
end

function this:DamageCache(player)
    player.Damage = SomethingWicked.StatUps:DamageUp(player, 1.3 * player:GetCollectibleNum(CollectibleType.SOMETHINGWICKED_RAMS_HEAD))
end

SomethingWicked:AddCallback(ModCallbacks.MC_EVALUATE_CACHE, this.TearsCache, CacheFlag.CACHE_FIREDELAY)
SomethingWicked:AddCallback(ModCallbacks.MC_EVALUATE_CACHE, this.DamageCache, CacheFlag.CACHE_DAMAGE)

this.EIDEntries = {
    [CollectibleType.SOMETHINGWICKED_RAMS_HEAD] = {
        desc = "↑ +0.7 tears#↑ {{Damage}} +1.3 Damage up",
        encycloDesc = SomethingWicked:UtilGenerateWikiDesc({"+25% fire rate", "+1.3 damage up"}),
        pools = {
            SomethingWicked.encyclopediaLootPools.POOL_TREASURE,
            SomethingWicked.encyclopediaLootPools.POOL_CRANE_GAME,
            SomethingWicked.encyclopediaLootPools.POOL_GREED_TREASURE,
            SomethingWicked.encyclopediaLootPools.POOL_GREED_BOSS,
        }
    }
}
return this
