local this = {}
local mod = SomethingWicked
CollectibleType.SOMETHINGWICKED_UNNAMED_TECH_ITEM = Isaac.GetItemIdByName("idk tech thing??")

local function FirePerpendicularLasers(_, player, tear, dmgmult)
    if not player:HasCollectible(CollectibleType.SOMETHINGWICKED_UNNAMED_TECH_ITEM) then
        return
    end
    local vel = tear.Velocity
    --local _, pos = room:CheckLine(shooter.Position, shooter.Position + vel, 0)
    mod:DoHitscan(tear.Position, vel, player, function (position)
        for i = -1, 1, 2 do
            local ang = vel:Normalized():Rotated(90*i)
            local laser = player:FireTechLaser(position - (ang*27), 4, ang, true, false, nil, (dmgmult*0.5))
            laser.Parent = nil
        end
    end)

end

--mod:AddCustomCBack(mod.CustomCallbacks.SWCB_ON_FIRE_PURE, FirePerpendicularLasers)
mod:AddCallback(ModCallbacks.MC_POST_FIRE_TEAR, function (_, tear)
    local player = mod:UtilGetPlayerFromTear(tear)
    if not player and tear.Parent and tear.Parent.Type == EntityType.ENTITY_PLAYER then
        return
    end
    FirePerpendicularLasers(_,player,tear, tear.CollisionDamage/player.Damage)
end)

this.EIDEntries = {
    [CollectibleType.SOMETHINGWICKED_UNNAMED_TECH_ITEM] = {
        desc = "boogie",
        Hide = true,
    }
}
return this