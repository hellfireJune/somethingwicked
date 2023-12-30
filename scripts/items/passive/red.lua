local mod = SomethingWicked

mod.UltraSecretRoomsSet = {}
local hasInit = false
function Init()
    if hasInit then
        return
    end
    hasInit = true
    mod:InitializeRoomData("ultrasecret", 0, 8, mod.UltraSecretRoomsSet)
end

local rBlacklist = {
    RoomType.ROOM_SECRET,
    RoomType.ROOM_SUPERSECRET,
    RoomType.ROOM_ULTRASECRET,
    RoomType.ROOM_BOSS
}


local function GetTargetIDX(deadend, roomdesc, rslot)
    --print(rslot, roomdesc.Data.Shape)
    return deadend.roomidx + (SomethingWicked.adjindexes[roomdesc.Data.Shape][deadend.Slot])
    + (SomethingWicked.adjindexes[RoomShape.ROOMSHAPE_1x1][rslot])
end
local function redRoomExists(lvel)
    for i = 1, 169 do
        local redRoom = lvel:GetRoomByIdx(i)
            
        if redRoom.Data 
        and redRoom.Data.Type == RoomType.ROOM_ULTRASECRET 
        and redRoom.DisplayFlags & 1 << 2 == 0 then
            redRoom.DisplayFlags = (redRoom.DisplayFlags or 0) | 1 << 2
            return true
        end
    end
end
function mod:RedGenerate(game, level, player)
    Init()
    if mod.HasGenerateRedThisFloor
    or not redRoomExists(level) then
        return
    end
    mod.HasGenerateRedThisFloor = true

    local deadends = mod:GetAllDeadEndsRed()
    local availableIDXs = {}
    local unavailableIDXs = {}

    for _, deadend in ipairs(deadends) do
        --print(deadend.roomidx)
        local roomdesc = level:GetRoomByIdx(deadend.roomidx)
        if roomdesc and roomdesc.Data
        and not mod:UtilTableHasValue(rBlacklist, roomdesc.Data.Type) then 
            --print(roomdesc.Data.Type, SomethingWicked:UtilTableHasValue(rBlacklist, roomdesc.Data.Type))
            --print(rBlacklist[1], rBlacklist[2], rBlacklist[3], rBlacklist[4])
            for i = 1, 3, 1 do
                local rslot = deadend.Slot - 2 + i
                if rslot < 0 then rslot = 3 end
                if rslot >= 4 then rslot = 0 end
                local targetIDX = GetTargetIDX(deadend, roomdesc, rslot)

                if not SomethingWicked:UtilTableHasValue(unavailableIDXs, targetIDX) then
                    local flag = mod:IsValidUSRSpot(targetIDX, game)
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
	local oldchallenge = game.Challenge
	game.Challenge = Challenge.CHALLENGE_RED_REDEMPTION
    local flag = false local currWeight = heighestWeight
    while not flag and currWeight > 0 do
        if currentTable[currWeight] then
            currentTable[currWeight] = SomethingWicked:UtilShuffleTable(currentTable[currWeight], collectibleRNG)
            
            for _, value in pairs(currentTable[currWeight]) do
                local roomdesc = level:GetRoomByIdx(value)
                if not roomdesc.Data then
                    
                level:MakeRedRoomDoor(value-13, DoorSlot.DOWN0)
                local roomdesc = level:GetRoomByIdx(value)
                local nflag = roomdesc ~= nil and roomdesc.Flags & RoomDescriptor.FLAG_RED_ROOM ~= 0
                flag = flag or nflag

                if flag then
                    mod:ReplaceRoomFromDataset(mod.UltraSecretRoomsSet, value, collectibleRNG)
                    break
                end
                end
            end
        end
        currWeight = currWeight - 1
    end
	game.Challenge = oldchallenge
    level:UpdateVisibility()
end

function mod:IsValidUSRSpot(idx, game)
    local level = game:GetLevel()

    for j = 1, 4, 1 do
        j = j - 1
        local RRidx = idx + mod.adjindexes[RoomShape.ROOMSHAPE_1x1][j]
        local validRedRoomFunc = function (level, realroom)
            return mod:UtilTableHasValue(rBlacklist, realroom.Data.Type)
        end
        if not mod:IsValidRedRoomSpot(level, RRidx, validRedRoomFunc) then
            return false
        end
    end
    return true
end

local function OnPickup(_, player, room)
    local rng = player:GetCollectibleRNG(CollectibleType.SOMETHINGWICKED_RED_NIGHTMARE)
    for _ = 1, 1 + rng:RandomInt(2), 1 do
        Isaac.Spawn(EntityType.ENTITY_PICKUP, PickupVariant.PICKUP_TAROTCARD, Card.CARD_CRACKED_KEY, room:FindFreePickupSpawnPosition(player.Position), Vector.Zero, player)  
    end
end

mod:AddCustomCBack(mod.CustomCallbacks.SWCB_PICKUP_ITEM, OnPickup, CollectibleType.SOMETHINGWICKED_RED_NIGHTMARE)