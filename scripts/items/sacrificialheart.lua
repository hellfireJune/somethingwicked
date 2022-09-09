local this = {}
CollectibleType.SOMETHINGWICKED_SACRIFICIAL_EFFIGY = Isaac.GetItemIdByName("Sacrificial Effigy")
this.heartsToSpawn = 2

function this:NewLevel()
    local game = SomethingWicked.game
    local level = game:GetLevel()

    if SomethingWicked.RedKeyRoomHelpers:GenericShouldGenerateRoom(level, game) then
        local flag, player = SomethingWicked.ItemHelpers:GlobalPlayerHasCollectible(CollectibleType.SOMETHINGWICKED_SACRIFICIAL_EFFIGY)
        if flag and player then
            local rng = player:GetCollectibleRNG(CollectibleType.SOMETHINGWICKED_SACRIFICIAL_EFFIGY)
            if not SomethingWicked.RedKeyRoomHelpers:RoomTypeCurrentlyExists(RoomType.ROOM_SACRIFICE, level, rng) then
                SomethingWicked.RedKeyRoomHelpers:GenerateSpecialRoom("sacrifice", 1, 5, true, rng)
            end
        end
    end
end

function this:OnPickup(player, room)
    local rng = player:GetCollectibleRNG(CollectibleType.SOMETHINGWICKED_SACRIFICIAL_EFFIGY)
    SomethingWicked.ItemHelpers:SpawnPickupShmorgabord(this.heartsToSpawn * 2, PickupVariant.PICKUP_HEART, rng, player.Position, player, function (pickup)
        pickup.Position = room:FindFreePickupSpawnPosition(pickup.Position)
    end)
end

SomethingWicked:AddCallback(ModCallbacks.MC_POST_NEW_LEVEL, this.NewLevel)
SomethingWicked:AddPickupFunction(this.OnPickup, CollectibleType.SOMETHINGWICKED_SACRIFICIAL_EFFIGY)

this.EIDEntries = {
    [CollectibleType.SOMETHINGWICKED_SACRIFICIAL_EFFIGY] = {
        desc = "↑ Every floor will spawn a sacrifice room if possible#Spawns 2 health points worth of red hearts on pickup",
        encycloDesc = SomethingWicked:UtilGenerateWikiDesc({"Every floor will spawn a sacrifice room if possible","Spawns 2 health points worth of red hearts on pickup"}),
        pools = {
            SomethingWicked.encyclopediaLootPools.POOL_SHOP,
            SomethingWicked.encyclopediaLootPools.POOL_CRANE_GAME
        }
    }
}
return this