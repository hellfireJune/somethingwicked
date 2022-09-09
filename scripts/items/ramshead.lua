local this = {}
CollectibleType.SOMETHINGWICKED_RAMS_HEAD = Isaac.GetItemIdByName("Ram's Head")

function this:TearsCache(player)
    player.MaxFireDelay = SomethingWicked.StatUps:GetFireDelay(SomethingWicked.StatUps:GetTears(player.MaxFireDelay) * (1 + (0.25 * player:GetCollectibleNum(CollectibleType.SOMETHINGWICKED_RAMS_HEAD))))
end

function this:DamageCache(player)
    player.Damage = SomethingWicked.StatUps:DamageUp(player, 1.3 * player:GetCollectibleNum(CollectibleType.SOMETHINGWICKED_RAMS_HEAD))
end

SomethingWicked:AddCallback(ModCallbacks.MC_EVALUATE_CACHE, this.TearsCache, CacheFlag.CACHE_FIREDELAY)
SomethingWicked:AddCallback(ModCallbacks.MC_EVALUATE_CACHE, this.DamageCache, CacheFlag.CACHE_DAMAGE)

this.EIDEntries = {
    [CollectibleType.SOMETHINGWICKED_RAMS_HEAD] = {
        desc = "↑ +25% tears multiplier#↑ +1.3 damage up",
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
