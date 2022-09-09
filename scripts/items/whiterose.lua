local this = {}
CollectibleType.SOMETHINGWICKED_WHITE_ROSE = Isaac.GetItemIdByName("White Rose")

function this:TearsCache(player)
    player.MaxFireDelay = SomethingWicked.StatUps:GetFireDelay(SomethingWicked.StatUps:GetTears(player.MaxFireDelay) * (1 + (0.15 * player:GetCollectibleNum(CollectibleType.SOMETHINGWICKED_WHITE_ROSE))))
end

function this:OnPickup(player, room)
    for i = 1, 4, 1 do
        local wisp = Isaac.Spawn(EntityType.ENTITY_FAMILIAR, FamiliarVariant.WISP, 0, player.Position, Vector.Zero, player)
        wisp.Parent = player
    end
end

SomethingWicked:AddCallback(ModCallbacks.MC_EVALUATE_CACHE, this.TearsCache, CacheFlag.CACHE_FIREDELAY)
SomethingWicked:AddPickupFunction(this.OnPickup, CollectibleType.SOMETHINGWICKED_WHITE_ROSE)

this.EIDEntries = {
    [CollectibleType.SOMETHINGWICKED_WHITE_ROSE] = {
        desc = "↑ +15% Tears multiplier#1 soul heart#Spawns four Book of Virtues wisps on pickup",
        pools = {
            SomethingWicked.encyclopediaLootPools.POOL_BOSS,
            SomethingWicked.encyclopediaLootPools.POOL_GREED_BOSS
        },
        encycloDesc = SomethingWicked:UtilGenerateWikiDesc({"+15% tears multiplier, adds 1 soul heart and four Book of Virtues wisps on pickup"})
    }
}
return this
