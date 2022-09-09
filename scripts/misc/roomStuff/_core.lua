local this = {}
this.roomFolderDirectory = "scripts/misc/roomStuff/"

SomethingWicked.roomStuff = {}
SomethingWicked.roomStuff.SmokeShop = include(this.roomFolderDirectory.."smokeshop")

function this:NewLevel()
    SomethingWicked.roomStuff.SmokeShop:Init()

    local level = SomethingWicked.game:GetLevel()
    local rng = RNG()
    if SomethingWicked.RedKeyRoomHelpers:RoomTypeCurrentlyExists(RoomType.ROOM_SECRET, level, rng) then
        local sroomIndex = level:QueryRoomTypeIndex(RoomType.ROOM_SECRET, true, rng)
        --SomethingWicked.RedKeyRoomHelpers:ReplaceRoomFromDataset(SomethingWicked.roomStuff.SmokeShop.roomData, sroomIndex, rng)
    end
end

SomethingWicked:AddCallback(ModCallbacks.MC_POST_NEW_LEVEL, this.NewLevel)

function this:IsRoom(table, roomdesc)
    if table == nil then
        return false
    end

    if roomdesc and roomdesc.Data and roomdesc.Data.Type == table.roomType and roomdesc.Data.Variant >= table.minvariant and roomdesc.Data.Variant <= table.maxvariant then
        return true
    end
    return false
end

if StageAPI then
    SomethingWicked.roomStuff.SmokeShop.backdrop = StageAPI.BackdropHelper({
        Walls = { "smokeshopbackdrop",
                 "smokeshopbackdrop02"} 
    }, "gfx/backdrops/", ".png")
    --i will add my own custom rocks, and run away to the foreign legion

    SomethingWicked.roomStuff.SmokeShop.tileGFX = StageAPI.GridGfx()
    SomethingWicked.roomStuff.SmokeShop.tileGFX:AddDoors("gfx/grid/smokeshop_door.png", {RequireEither = {RoomType.ROOM_SECRET, RoomType.ROOM_SUPERSECRET}})

    SomethingWicked.roomStuff.SmokeShop.roomGFX = StageAPI.RoomGfx(SomethingWicked.roomStuff.SmokeShop.backdrop, SomethingWicked.roomStuff.SmokeShop.tileGFX)
end

function this:EnterRoom()
    local roomDesc = SomethingWicked.game:GetLevel():GetCurrentRoomDesc()
    if this:IsRoom(SomethingWicked.roomStuff.SmokeShop, roomDesc)
    and SomethingWicked.roomStuff.SmokeShop.roomGFX ~= nil then
        StageAPI.ChangeRoomGfx(SomethingWicked.roomStuff.SmokeShop.roomGFX)
    end
end

SomethingWicked:AddCallback(ModCallbacks.MC_POST_NEW_ROOM, this.EnterRoom)

--old original branch smokeshop era code
--[[if StageAPI then
    SomethingWicked.RoomBackdrops = {
        SmokeShop = StageAPI.BackdropHelper({
            Walls = { "smokeshopbackdrop"} 
        }, "gfx/backdrops/", ".png")
    }

    SomethingWicked.RoomGFX = {
        SmokeShop = StageAPI.RoomGfx(SomethingWicked.RoomBackdrops.SmokeShop, nil, nil, nil)
    }
end

--99% of my StageAPI understanding comes from looking at fiendfolio code, TY fiendfolio devs]]