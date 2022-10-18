local this = {}
TrinketType.SOMETHINGWICKED_CATS_EYE = Isaac.GetTrinketIdByName("Cat's Eye")

function  this:EnterRoom()
    local room = SomethingWicked.game:GetRoom()
    if SomethingWicked.ItemHelpers:GlobalPlayerHasTrinket(TrinketType.SOMETHINGWICKED_CATS_EYE) and (room:GetType() == RoomType.ROOM_SECRET or room:GetType() == RoomType.ROOM_SUPERSECRET) 
    and room:IsFirstVisit() then
        for i = 1, SomethingWicked.ItemHelpers:GlobalGetTrinketNum(TrinketType.SOMETHINGWICKED_CATS_EYE) do
            Isaac.Spawn(EntityType.ENTITY_PICKUP, PickupVariant.PICKUP_GRAB_BAG, 0, room:FindFreePickupSpawnPosition(room:GetCenterPos()), Vector.Zero, nil)                
        end
    end
end

SomethingWicked:AddCallback(ModCallbacks.MC_POST_NEW_ROOM, this.EnterRoom)

this.EIDEntries = {
    [TrinketType.SOMETHINGWICKED_CATS_EYE] = {
        isTrinket = true,
        desc = "Spawns 1 sack upon entering a {{SecretRoom}} Secret Room",
        metadataFunction = function (item)
            EID:addGoldenTrinketMetadata(item, nil, 1)
        end,
        encycloDesc = SomethingWicked:UtilGenerateWikiDesc({"Spawns 1 sack upon entering a secret room"}, "We believe...")
    }
}
return this