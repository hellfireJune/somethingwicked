local this = {}
TrinketType.SOMETHINGWICKED_TREASURERS_KEY = Isaac.GetTrinketIdByName("Treasurer's Key")
TrinketType.SOMETHINGWICKED_CURSED_KEY = Isaac.GetTrinketIdByName("Cursed Key")

--this.CurseList = {}
this.RooomTypeBlackList = { RoomType.ROOM_SECRET_EXIT } 
--Maybe do smth with these instead of just blacklisting 'em. Cursed key leading to ascent is awesome but i dont like how its free

this.DoorSprites = {
    [RoomType.ROOM_TREASURE] = "curse_treasure_door",
    [RoomType.ROOM_LIBRARY] = "curse_library_door",
    [RoomType.ROOM_SHOP] = "curse_shop_door",
    [RoomType.ROOM_PLANETARIUM] = "curse_planetarium_door",
    [RoomType.ROOM_DICE] = "curse_dice_door",
    [RoomType.ROOM_CHEST] = "curse_chest_door",
}

function this:NewRoom()
    local room = SomethingWicked.game:GetRoom()
    local level = SomethingWicked.game:GetLevel()

    if level:GetStartingRoomIndex() == level:GetCurrentRoomDesc().GridIndex
    and room:IsFirstVisit() then
        SomethingWicked.save.runData.CurseList = {}
    end
    
    SomethingWicked.save.runData.CurseList = SomethingWicked.save.runData.CurseList or {}

    for i = 0, DoorSlot.NUM_DOOR_SLOTS - 1, 1 do
        local door = room:GetDoor(i)
        if door 
        and SomethingWicked:UtilTableHasValue(this.RooomTypeBlackList, door.TargetRoomType) == false then     
            --Treasurer's Key
            if (door:IsRoomType(RoomType.ROOM_TREASURE)
            or door:IsRoomType(RoomType.ROOM_PLANETARIUM))
            and door:GetVariant() == DoorVariant.DOOR_LOCKED then
                if SomethingWicked.ItemHelpers:GlobalPlayerHasTrinket(TrinketType.SOMETHINGWICKED_TREASURERS_KEY) then
                    door:SetLocked(false)
                    break
                end
            end

            --Cursed Key
            local containsIndex = (SomethingWicked:UtilTableHasValue(SomethingWicked.save.runData.CurseList, door.TargetRoomIndex)
            or SomethingWicked:UtilTableHasValue(SomethingWicked.save.runData.CurseList, level:GetCurrentRoomDesc().GridIndex))
            local isLocked = (door:GetVariant() == DoorVariant.DOOR_LOCKED 
            or door:GetVariant() == DoorVariant.DOOR_LOCKED_DOUBLE)


            if isLocked
            or containsIndex then
                if SomethingWicked.ItemHelpers:GlobalPlayerHasTrinket(TrinketType.SOMETHINGWICKED_CURSED_KEY) or containsIndex then
                        local roomType
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

                        if roomType
                        and this.DoorSprites[roomType] then
                            local sprite = door:GetSprite()
                            for ii = 1, 4 do
                                sprite:ReplaceSpritesheet(ii, "gfx/grid/"..this.DoorSprites[roomType]..".png")
                            end
                            sprite:LoadGraphics()
                        end

                        break
                    end
                end
            end
        end
    end 

SomethingWicked:AddCallback(ModCallbacks.MC_POST_NEW_ROOM, this.NewRoom)

this.EIDEntries = {
    [TrinketType.SOMETHINGWICKED_TREASURERS_KEY] = {
        isTrinket = true,
        desc = "Treasure rooms and planetariums will spawn unlocked",
        encycloDesc = SomethingWicked:UtilGenerateWikiDesc({"Treasure rooms and planetariums will spawn unlocked if this trinket is held"})
    },
    [TrinketType.SOMETHINGWICKED_CURSED_KEY] = {
        isTrinket = true,
        desc = "All locked doors will spawn as unlocked curse doors",
        encycloDesc = SomethingWicked:UtilGenerateWikiDesc({"All locked doors will spawn as unlocked curse doors if this trinket is held"})
    }
}
return this