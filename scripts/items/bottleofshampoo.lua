local this = {}

SomethingWicked:AddCallback(ModCallbacks.MC_EVALUATE_CACHE, function (_, player, flags)
    local mult = player:GetCollectibleNum(CollectibleType.SOMETHINGWICKED_BOTTLE_OF_SHAMPOO)
    if flags == CacheFlag.CACHE_FIREDELAY then
        player.MaxFireDelay = SomethingWicked.StatUps:TearsUp(player, 0.5 * mult)
    end
end)

this.EIDEntries = {}
return this