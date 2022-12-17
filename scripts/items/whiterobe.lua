local this = {}
CollectibleType.SOMETHINGWICKED_WHITE_ROBE = Isaac.GetItemIdByName("White Robe")
this.ProcChance = 0.09

function this:OnDamage(entity, amount, flag)
    local player = entity:ToPlayer()
    if player:HasCollectible(CollectibleType.SOMETHINGWICKED_WHITE_ROBE) then
        if player:GetDropRNG():RandomFloat() <= this.ProcChance then
            local room = SomethingWicked.game:GetRoom()
            Isaac.Spawn(EntityType.ENTITY_PICKUP, PickupVariant.PICKUP_HEART, HeartSubType.HEART_ETERNAL, room:FindFreePickupSpawnPosition(player.Position), Vector.Zero, player)
        end
    end
end

SomethingWicked:AddPriorityCallback(ModCallbacks.MC_ENTITY_TAKE_DMG, CallbackPriority.LATE, this.OnDamage, EntityType.ENTITY_PLAYER)

this.EIDEntries = {
    [CollectibleType.SOMETHINGWICKED_WHITE_ROBE] = {
        desc = "↑ 9% chance to drop an eternal heart upon damage",
        encycloDesc = SomethingWicked:UtilGenerateWikiDesc({"9% chance to spawn an eternal heart upon taking damage"}),
        pools = {
            SomethingWicked.encyclopediaLootPools.POOL_ANGEL,
            SomethingWicked.encyclopediaLootPools.POOL_GREED_ANGEL,
            SomethingWicked.encyclopediaLootPools.POOL_GREED_TREASURE
        }
    }
}
return this