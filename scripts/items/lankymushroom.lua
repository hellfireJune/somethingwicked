local this = {}
local mod = SomethingWicked

SomethingWicked:AddCallback(ModCallbacks.MC_EVALUATE_CACHE, function (_, player, flags)
    local mult = player:GetCollectibleNum(CollectibleType.SOMETHINGWICKED_LANKY_MUSHROOM)
    if flags == CacheFlag.CACHE_FIREDELAY then
        player.MaxFireDelay = SomethingWicked.StatUps:TearsUp(player, mult * -0.4)
    end
    if flags == CacheFlag.CACHE_DAMAGE then
        player.Damage = SomethingWicked.StatUps:DamageUp(player, mult * 0.7)
    end
    if flags == CacheFlag.CACHE_RANGE then
        player.TearRange = player.TearRange + (40 * 0.75 * mult)
    end
    if flags == CacheFlag.CACHE_SIZE then
        player.SpriteScale = player.SpriteScale * (mult == 0 and Vector(1, 1) or Vector(0.75, 1.5))
    end
end)

this.EIDEntries = {
    [CollectibleType.SOMETHINGWICKED_LANKY_MUSHROOM] = {
        desc = "↑ {{Damage}} +0.7 Damage up#↓ {{Tears}} -0.4 Tears down#↑ {{Range}} 0.75 Range up#Makes Isaac 50% taller and 25% thinner",
        pools = { mod.encyclopediaLootPools.POOL_TREASURE, mod.encyclopediaLootPools.POOL_SECRET, mod.encyclopediaLootPools.POOL_GREED_TREASURE, mod.encyclopediaLootPools.POOL_GREED_BOSS}
    }
}
return this