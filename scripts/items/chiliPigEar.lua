local this = {}
CollectibleType.SOMETHINGWICKED_CHILI = Isaac.GetItemIdByName("Chili")
CollectibleType.SOMETHINGWICKED_PIG_EAR = Isaac.GetItemIdByName("Pig Ear")

function this:damageCache(player)
    player.Damage = SomethingWicked.StatUps:DamageUp(player, 0.7 * (player:GetCollectibleNum(CollectibleType.SOMETHINGWICKED_CHILI) + player:GetCollectibleNum(CollectibleType.SOMETHINGWICKED_PIG_EAR)))
end

SomethingWicked:AddCallback(ModCallbacks.MC_EVALUATE_CACHE, this.damageCache, CacheFlag.CACHE_DAMAGE)

this.EIDEntries = {
    [CollectibleType.SOMETHINGWICKED_CHILI] = {
        desc = "↑ +0.7 Damage Up "
    },
    [CollectibleType.SOMETHINGWICKED_PIG_EAR] = {
        desc = "↑ +0.7 Damage Up "
    }
}
return this
