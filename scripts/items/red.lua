local this = {}
CollectibleType.SOMETHINGWICKED_RED_NIGHTMARE = Isaac.GetItemIdByName("Red")

SomethingWicked:AddCallback(ModCallbacks.MC_POST_NEW_LEVEL, function ()
    if SomethingWicked.ItemHelpers:GlobalPlayerHasCollectible(CollectibleType.SOMETHINGWICKED_RED_NIGHTMARE) then
        this:ProcessNewUltraSecretRoom()
    end
end)

local rBlacklist = {
    RoomType.ROOM_SECRET,
    RoomType.ROOM_SUPERSECRET,
    RoomType.ROOM_ULTRASECRET,
    RoomType.ROOM_BOSS
}

local function ShouldMake()
    
end

local function MakeUSR()
    
end

function this:ProcessNewUltraSecretRoom()
    local deadends = SomethingWicked.RedKeyRoomHelpers:GetAllDeadEndsRed()
    local availableIDXs = {}
    local unavailableIDXs = {}

    local level = SomethingWicked.game:GetLevel()

    for _, deadend in ipairs(deadends) do
        --print(deadend.roomidx)
        local roomdesc = level:GetRoomByIdx(deadend.roomidx)
        if roomdesc and roomdesc.Data
        and not SomethingWicked:UtilTableHasValue(rBlacklist, roomdesc.Data.Type) then 
            --print(roomdesc.Data.Type, SomethingWicked:UtilTableHasValue(rBlacklist, roomdesc.Data.Type))
            --print(rBlacklist[1], rBlacklist[2], rBlacklist[3], rBlacklist[4])
            for i = 1, 3, 1 do
                local rslot = deadend.Slot - 2 + i
                if rslot < 0 then rslot = 3 end
                if rslot >= 4 then rslot = 0 end
                local targetIDX = this:GetTargetIDX(deadend, roomdesc, rslot)

                if not SomethingWicked:UtilTableHasValue(unavailableIDXs, targetIDX) then
                    local flag = this:IsValidUSRSpot(targetIDX)
                    if flag then
                        availableIDXs[targetIDX] = (availableIDXs[targetIDX] or 0) + 1
                    else
                        table.insert(unavailableIDXs, targetIDX)
                        --do removal stuff
                        availableIDXs[targetIDX] = nil
                    end
                end
            end
        end
    end

    local heighestWeight = -1 local currentTable = {}
    for IDXs, weight in pairs(availableIDXs) do
        if weight > heighestWeight then
            heighestWeight = weight
        end

        currentTable[weight] = currentTable[weight] or {}
        table.insert(currentTable[weight], IDXs)
    end

    local collectibleRNG = Isaac.GetPlayer(0):GetCollectibleRNG(CollectibleType.SOMETHINGWICKED_RED_NIGHTMARE) --bad
    
    --nabbed from segmented mausoleum
	local oldchallenge = SomethingWicked.game.Challenge
	SomethingWicked.game.Challenge = Challenge.CHALLENGE_RED_REDEMPTION
    local flag = false local currWeight = heighestWeight
    while not flag and currWeight > 0 do
        if currentTable[currWeight] then
            currentTable[currWeight] = SomethingWicked:UtilShuffleTable(currentTable[currWeight], collectibleRNG)
            
            for _, value in pairs(currentTable[currWeight]) do
                level:MakeRedRoomDoor(value - 13, DoorSlot.DOWN0)
                local roomdesc = level:GetRoomByIdx(value)
                local nflag = roomdesc ~= nil and roomdesc.Flags & RoomDescriptor.FLAG_RED_ROOM ~= 0
                flag = flag or nflag

                if flag then
                    break
                end
            end
        end
        currWeight = currWeight - 1
    end
	SomethingWicked.game.Challenge = oldchallenge
    level:UpdateVisibility()
end

function this:IsValidUSRSpot(idx)
    local level = SomethingWicked.game:GetLevel()
    local uavailableRR = {}

    for j = 1, 4, 1 do
        j = j - 1
        local RRidx = idx + SomethingWicked.RedKeyRoomHelpers.adjindexes[RoomShape.ROOMSHAPE_1x1][j]
        local roomDesc = level:GetRoomByIdx(RRidx)
        if not roomDesc or roomDesc.GridIndex <= 0 then
            for i = 1, 3, 1 do
                local rslot = j - 2 + i
                if rslot < 0 then rslot = 3 end
                if rslot >= 4 then rslot = 0 end
                local oslot = SomethingWicked.RedKeyRoomHelpers:GetOppositeDoorSlot(rslot)
                
                local trIDX = RRidx + SomethingWicked.RedKeyRoomHelpers.adjindexes[RoomShape.ROOMSHAPE_1x1][rslot]
                local realRoom = level:GetRoomByIdx(trIDX)

                if realRoom and realRoom.GridIndex > 0 then
                    if realRoom.Data.Doors & 1 << oslot == 0
                    or SomethingWicked:UtilTableHasValue(rBlacklist, realRoom.Data.Type) then
                        table.insert(uavailableRR, RRidx)
                    end
                end
            end
        else
            table.insert(uavailableRR, RRidx)
        end
    end
    return #uavailableRR < 1
end

function this:GetTargetIDX(deadend, roomdesc, rslot)
    --print(rslot, roomdesc.Data.Shape)
    return deadend.roomidx + (SomethingWicked.RedKeyRoomHelpers.adjindexes[roomdesc.Data.Shape][deadend.Slot])
    + (SomethingWicked.RedKeyRoomHelpers.adjindexes[RoomShape.ROOMSHAPE_1x1][rslot])
end

this.EIDEntries = {}
return this