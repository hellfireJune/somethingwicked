local this = {}
local mod = SomethingWicked
CollectibleType.SOMETHINGWICKED_UNNAMED_TECH_ITEM = Isaac.GetItemIdByName("idk tech thing??")

local function FirePerpendicularLasers(_, shooter, vector, scalar, player)
    if not player:HasCollectible(CollectibleType.SOMETHINGWICKED_UNNAMED_TECH_ITEM) then
        return
    end

    local vel = mod:UtilGetFireVector(vector, player)
    vel = vel:Normalized():Resized(player.TearRange)

    local room = mod.game:GetRoom()
    local _, pos = room:CheckLine(shooter.Position, shooter.Position + vel, 0)

    for i = -1, 1, 2 do
        local ang = vel:Normalized():Rotated(90*i)
        player:FireTechLaser(pos, 6, ang, true, false, nil, scalar)
    end
end

mod:AddCustomCBack(mod.CustomCallbacks.SWCB_ON_FIRE_PURE, FirePerpendicularLasers)

this.EIDEntries = {
    [CollectibleType.SOMETHINGWICKED_UNNAMED_TECH_ITEM] = {
        desc = "boogie"
    }
}
return this