local this = {}
CollectibleType.SOMETHINGWICKED_ONYX_CHARM = Isaac.GetItemIdByName("Onyx Charm")

function this:DMGCache(player, flags)
    player.Damage = SomethingWicked.StatUps:DamageUp(player, 0, 1.5*player:GetCollectibleNum(CollectibleType.SOMETHINGWICKED_ONYX_CHARM))
end

SomethingWicked:AddCallback(ModCallbacks.MC_EVALUATE_CACHE, this.DMGCache, CacheFlag.CACHE_DAMAGE)

this.EIDEntries = {
    [CollectibleType.SOMETHINGWICKED_ONYX_CHARM] = {
        desc = "↑ +1.5 flat damage up"
    }
}
return this