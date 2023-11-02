local mod = SomethingWicked

--this.CurseList = {}
local RooomTypeBlackList = { RoomType.ROOM_SECRET_EXIT } 
--Maybe do smth with these instead of just blacklisting 'em. Cursed key leading to ascent is awesome but i dont like how its free

local DoorSprites = {
    [RoomType.ROOM_TREASURE] = "curse_treasure_door",
    [RoomType.ROOM_LIBRARY] = "curse_library_door",
    [RoomType.ROOM_SHOP] = "curse_shop_door",
    [RoomType.ROOM_PLANETARIUM] = "curse_planetarium_door",
    [RoomType.ROOM_DICE] = "curse_dice_door",
    [RoomType.ROOM_CHEST] = "curse_chest_door",
}

function mod:CurseKeyTreasurersKeyDoorChecks(door, gridIndex)
if door and not mod:UtilTableHasValue(RooomTypeBlackList, door.TargetRoomType) then     
            --Treasurer's Key
    if (door:IsRoomType(RoomType.ROOM_TREASURE) or door:IsRoomType(RoomType.ROOM_PLANETARIUM))
    and door:GetVariant() == DoorVariant.DOOR_LOCKED then
        if mod:GlobalPlayerHasTrinket(TrinketType.SOMETHINGWICKED_TREASURERS_KEY) then
            door:SetLocked(false)
        end
    end
    
    mod.save.runData.CurseList = mod.save.runData.CurseList or {}

            --Cursed Key
    local containsIndex = (mod:UtilTableHasValue(SomethingWicked.save.runData.CurseList, door.TargetRoomIndex)
    or SomethingWicked:UtilTableHasValue(SomethingWicked.save.runData.CurseList, gridIndex))
    local isLocked = (door:GetVariant() == DoorVariant.DOOR_LOCKED 
    or door:GetVariant() == DoorVariant.DOOR_LOCKED_DOUBLE)

        if (isLocked and mod:GlobalPlayerHasTrinket(TrinketType.SOMETHINGWICKED_CURSED_KEY))
        or containsIndex then
            local roomType = nil
            if SomethingWicked:UtilTableHasValue(SomethingWicked.save.runData.CurseList, door.TargetRoomIndex) 
            or isLocked then
                roomType = door.TargetRoomType
                door:SetRoomTypes(door.CurrentRoomType, RoomType.ROOM_CURSE)
                door:SetLocked(false)
                table.insert(SomethingWicked.save.runData.CurseList, door.TargetRoomIndex)
            else
                roomType = door.CurrentRoomType
                door:SetRoomTypes(RoomType.ROOM_CURSE, door.TargetRoomType)
            end

            if roomType and DoorSprites[roomType] then
                local sprite = door:GetSprite()
                for ii = 1, 4 do
                    sprite:ReplaceSpritesheet(ii, "gfx/grid/"..DoorSprites[roomType]..".png")
                end
                sprite:LoadGraphics()
            end
        end
    end
end