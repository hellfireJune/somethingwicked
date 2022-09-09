local this = {}
CollectibleType.SOMETHINGWICKED_CAT_FOOD = Isaac.GetItemIdByName("Cat Food")

function this:OnKill(enemy)
    for _, player in ipairs(SomethingWicked:UtilGetAllPlayers()) do
        if player:HasCollectible(CollectibleType.SOMETHINGWICKED_CAT_FOOD)
        and enemy:IsBoss() then
            local room = SomethingWicked.game:GetRoom(_, _, _)
            if (room:GetType() == RoomType.ROOM_BOSS or room:GetType() == RoomType.ROOM_BOSSRUSH) then
                local p_data = player:GetData()
                p_data.SomethingWickedPData.catFoodPosition = enemy.Position
            end
        end
    end
end

function this:DelayShit(player)
    local p_data = player:GetData()
    if p_data.SomethingWickedPData.catFoodPosition
    and Isaac.CountBosses() == 0 then
        for i = 1, 5, 1 do                    
            Isaac.Spawn(EntityType.ENTITY_PICKUP, PickupVariant.PICKUP_HEART, HeartSubType.HEART_HALF, p_data.SomethingWickedPData.catFoodPosition, RandomVector() * 5, player)
        end
        p_data.SomethingWickedPData.catFoodPosition = nil
    end
end

SomethingWicked:AddCallback(ModCallbacks.MC_POST_PEFFECT_UPDATE, this.DelayShit)
SomethingWicked:AddCallback(ModCallbacks.MC_POST_NPC_DEATH, this.OnKill)

this.EIDEntries = {
    [CollectibleType.SOMETHINGWICKED_CAT_FOOD] = {
        desc = "↑ +1 max health # Heals 2 hearts # Boss rooms drop 5 half red hearts upon defeating the boss",
        
        pools = {
            SomethingWicked.encyclopediaLootPools.POOL_TREASURE,
            SomethingWicked.encyclopediaLootPools.POOL_CRANE_GAME,
            SomethingWicked.encyclopediaLootPools.POOL_BEGGAR,
        },
        encycloDesc = SomethingWicked:UtilGenerateWikiDesc({"+1 max health","Heals 2 hearts","Boss rooms drop 5 half red hearts upon defeating the boss"}, "Not even fit for a horse!")
    }
}
return this