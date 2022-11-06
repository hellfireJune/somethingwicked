local this = {}
TrinketType.SOMETHINGWICKED_ZZZZZZ_MAGNET = Isaac.GetTrinketIdByName("ZZZZZZ Magnet")

SomethingWicked:AddCallback(ModCallbacks.MC_PRE_SPAWN_CLEAN_AWARD, function ()
    if SomethingWicked.ItemHelpers:GlobalPlayerHasTrinket(TrinketType.SOMETHINGWICKED_ZZZZZZ_MAGNET) then
        SomethingWicked:UtilScheduleForUpdate(this.CheckForDealDoors, 2, ModCallbacks.MC_POST_UPDATE)
    end
end)

function this:CheckForDealDoors()
    local room = SomethingWicked.game:GetRoom()

    for i = 0, DoorSlot.NUM_DOOR_SLOTS - 1, 1 do
        local door = room:GetDoor(i)
        if door
        and door.TargetRoomIndex == GridRooms.ROOM_DEVIL_IDX then
            door.TargetRoomIndex = GridRooms.ROOM_ERROR_IDX
        end
    end
end

this.EIDEntries = {}
return this