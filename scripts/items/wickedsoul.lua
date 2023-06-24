local this = {}

this.AvailableCurses = {
    LevelCurse.CURSE_OF_DARKNESS,
    LevelCurse.CURSE_OF_THE_LOST,
    LevelCurse.CURSE_OF_THE_UNKNOWN,
    LevelCurse.CURSE_OF_MAZE,
    LevelCurse.CURSE_OF_BLIND,
}

function this:OnCache(player, flags)
    local mult = player:GetCollectibleNum(CollectibleType.SOMETHINGWICKED_WICKED_SOUL)

    if flags == CacheFlag.CACHE_DAMAGE then
        player.Damage = SomethingWicked.StatUps:DamageUp(player, 0.5 * mult, 0, 1 + (mult > 1 and 0.3 or 0)) end
    if flags == CacheFlag.CACHE_LUCK then
        player.Luck = player.Luck + (1 * mult) end
    if flags == CacheFlag.CACHE_SPEED then
        player.MoveSpeed = player.MoveSpeed + (0.25 * mult) end
    if flags == CacheFlag.CACHE_SHOTSPEED then
        player.ShotSpeed = player.ShotSpeed + (0.05 * mult) end
    if flags == CacheFlag.CACHE_RANGE then
        player.TearRange = player.TearRange + (1.2 * mult * 40)
    end
end

function this:onNewLevel()
    for _, player in ipairs(SomethingWicked:UtilGetAllPlayers()) do
        for i = 1, player:GetCollectibleNum(CollectibleType.SOMETHINGWICKED_WICKED_SOUL), 1 do
            this:OnPickup(player)
        end
    end
end

function this:OnPickup(player)
    local level = SomethingWicked.game:GetLevel()
    local rng = player:GetCollectibleRNG(CollectibleType.SOMETHINGWICKED_WICKED_SOUL)
    local possibleCurses = {}
    for index, value in ipairs(this.AvailableCurses) do
        if level:GetCurses() & value == 0 then
            table.insert(possibleCurses, value)
        end
    end
    if #possibleCurses >= 1 then
        local curse = possibleCurses[rng:RandomInt(#possibleCurses) + 1]
        level:AddCurse(curse, false)
    end
end

SomethingWicked:AddCustomCBack(SomethingWicked.CustomCallbacks.SWCB_PICKUP_ITEM, this.OnPickup, CollectibleType.SOMETHINGWICKED_WICKED_SOUL)
SomethingWicked:AddCallback(ModCallbacks.MC_POST_NEW_LEVEL, this.onNewLevel)
SomethingWicked:AddCallback(ModCallbacks.MC_EVALUATE_CACHE, this.OnCache)

this.EIDEntries = {
    [CollectibleType.SOMETHINGWICKED_WICKED_SOUL] = {
        desc = "↑ +30% damage Multiplier#↑ +0.5 damage#↑ +1 luck#↑ +0.25 speed#↑ +0.05 shot speed#↑ +1.2 range#!!! A bonus curse will be added every floor",
        pools = {
            SomethingWicked.encyclopediaLootPools.POOL_TREASURE,
            SomethingWicked.encyclopediaLootPools.POOL_ULTRA_SECRET,
            SomethingWicked.encyclopediaLootPools.POOL_GREED_TREASURE,
        },
        encycloDesc = SomethingWicked:UtilGenerateWikiDesc({"+30% Damage Multiplier","+0.5 Damage","+1 Luck","+0.25 Speed","+0.05 Shot Speed","+1.2 Range","A bonus curse will be added every floor"})
    }
}
return this