local mod = SomethingWicked
local game = Game()

local function CheckForDealDoors()
    if not SomethingWicked:GlobalPlayerHasTrinket(TrinketType.SOMETHINGWICKED_ZZZZZZ_MAGNET) then
        return
    end
    local room = game:GetRoom()

    for i = 0, DoorSlot.NUM_DOOR_SLOTS - 1, 1 do
        local door = room:GetDoor(i)
        if door then
            mod:ZZZZZZConvertDoor(door)
        end
    end
end
mod:AddCallback(ModCallbacks.MC_PRE_SPAWN_CLEAN_AWARD, function ()
    mod:UtilScheduleForUpdate(CheckForDealDoors, 0, ModCallbacks.MC_POST_UPDATE)
end)

function mod:ZZZZZZConvertDoor(door)
    if not door.TargetRoomIndex == GridRooms.ROOM_DEVIL_IDX then
        return
    end
    door.TargetRoomIndex = GridRooms.ROOM_ERROR_IDX
    local sprite = door:GetSprite()
    for ii = 1, 4 do
        sprite:ReplaceSpritesheet(ii, "gfx/grid/soymundswildride.png")
    end
    sprite:LoadGraphics()
end
--[[    [TrinketType.SOMETHINGWICKED_ZZZZZZ_MAGNET] = {
        desc = "!!! Turns all doors to Devil Rooms and Angel Rooms into doors to the Error Room",
        isTrinket = true,
    }]]