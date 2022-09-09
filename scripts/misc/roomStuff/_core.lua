print("loaded core!")
local this = {}
this.roomFolderDirectory = "scripts/misc/roomStuff/"

SomethingWicked.roomStuff = {}
SomethingWicked.roomStuff.SmokeShop = include(this.roomFolderDirectory.."smokeshop")

function this:NewLevel()
    local level = SomethingWicked.game:GetLevel()
    local rng = RNG()
    if SomethingWicked.RedKeyRoomHelpers:RoomTypeCurrentlyExists(RoomType.ROOM_SECRET, level, rng) then
        local sroomIndex = level:QueryRoomTypeIndex(RoomType.ROOM_SECRET, true, rng)
        SomethingWicked.RedKeyRoomHelpers:ReplaceRoomFromDataset(SomethingWicked.roomStuff.SmokeShop.roomData, sroomIndex, rng)
    end
end

SomethingWicked:AddCallback(ModCallbacks.MC_POST_NEW_LEVEL, this.NewLevel)

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