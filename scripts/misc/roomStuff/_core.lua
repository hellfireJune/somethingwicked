local this = {}
this.roomFolderDirectory = "scripts/misc/roomStuff/"

SomethingWicked.roomStuff = {}
SomethingWicked.roomStuff.SmokeShop = include(this.roomFolderDirectory.."smokeshop")

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