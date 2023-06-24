local this = {}
local mod = SomethingWicked

mod:AddCallback(ModCallbacks.MC_PRE_PICKUP_COLLISION, function ()
    
end)

mod:AddCallback(ModCallbacks.MC_EVALUATE_CACHE, function (_, player, flags)
    local mult = player:GetCollectibleNum(CollectibleType.SOMETHINGWICKED_GOLDEN_WATCH)

    if flags == CacheFlag.CACHE_FIREDELAY then
        player.MaxFireDelay = mod.StatUps:TearsUp(player, 0.6*mult) end
    if flags == CacheFlag.CACHE_LUCK then
        player.Luck = player.Luck + (1 * mult) end
    if flags == CacheFlag.CACHE_SPEED then
        player.MoveSpeed = player.MoveSpeed + (0.2 * mult) end
    if flags == CacheFlag.CACHE_SHOTSPEED then
        player.ShotSpeed = player.ShotSpeed + (0.1 * mult) end
    if flags == CacheFlag.CACHE_RANGE then
        player.TearRange = player.TearRange + (0.8 * mult * 40)
    end
end)

this.EIDEntries = {
    [CollectibleType.SOMETHINGWICKED_GOLDEN_WATCH] = {
        desc = "all stats up :) but dont spend money ):"
    }
}
return this