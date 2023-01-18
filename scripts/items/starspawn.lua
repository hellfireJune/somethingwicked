local this = {}
CollectibleType.SOMETHINGWICKED_STAR_SPAWN = Isaac.GetItemIdByName("Star Spawn")

this.TotalMult = 2.4
this.MinMult = 0.2
SomethingWicked:AddCallback(ModCallbacks.MC_ENTITY_TAKE_DMG, function (_, player)
    player = player:ToPlayer()
    if player and player:HasCollectible(CollectibleType.SOMETHINGWICKED_STAR_SPAWN) then
        local p_data = player:GetData()
        p_data.SomethingWickedPData.StarSpawnBuff = {Damage = 1, Tears = 1}

        local rng = player:GetCollectibleRNG(CollectibleType.SOMETHINGWICKED_STAR_SPAWN)
        local DMGTearsRatio = SomethingWicked:Clamp(rng:RandomFloat() * this.TotalMult, this.MinMult, this.TotalMult - this.MinMult)

        p_data.SomethingWickedPData.StarSpawnBuff.Damage = DMGTearsRatio
        p_data.SomethingWickedPData.StarSpawnBuff.Tears = this.TotalMult - DMGTearsRatio

        player:AddCacheFlags(CacheFlag.CACHE_ALL)
        player:EvaluateItems()
    end
end, EntityType.ENTITY_PLAYER)

SomethingWicked:AddCallback(ModCallbacks.MC_EVALUATE_CACHE, function (_, player, flags)
    if player:HasCollectible(CollectibleType.SOMETHINGWICKED_STAR_SPAWN) then
        local p_data = player:GetData()
        p_data.SomethingWickedPData.StarSpawnBuff = p_data.SomethingWickedPData.StarSpawnBuff or {Damage = 1.2, Tears = 1.2}

        if flags == CacheFlag.CACHE_DAMAGE then
            player.Damage = SomethingWicked.StatUps:DamageUp(player, 0, 0, p_data.SomethingWickedPData.StarSpawnBuff.Damage)
        end
        if flags == CacheFlag.CACHE_FIREDELAY then
            player.MaxFireDelay = SomethingWicked.StatUps:TearsUp(player, 0, 0, p_data.SomethingWickedPData.StarSpawnBuff.Tears)
        end
        if flags == CacheFlag.CACHE_TEARCOLOR then
            player.TearColor = player.TearColor * Color(1, 0.74, 0.74, 1, 0.5)
        end
    end
end)

this.EIDEntries = {
    [CollectibleType.SOMETHINGWICKED_STAR_SPAWN] = {
        desc = "↑ 1.2x damage#↑ 1.2x tears#On damage, applies a random multiplier to both tears and damage, to a total multiplier of 1.4x",
        encycloDesc = SomethingWicked:UtilGenerateWikiDesc({"1.2x damage, 1.2x tears","On damage, applies a random multiplier to both tears and damage, to a total multiplier of 1.4x"}),
        pools = {SomethingWicked.encyclopediaLootPools.POOL_TREASURE, SomethingWicked.encyclopediaLootPools.POOL_CRANE_GAME,
    SomethingWicked.encyclopediaLootPools.POOL_ULTRA_SECRET, SomethingWicked.encyclopediaLootPools.POOL_GREED_TREASURE}
    }
}
return this