local mod = SomethingWicked

local function FirePerpendicularLasers(_, player, tear, dmgmult, dir)
    if not player:HasCollectible(mod.ITEMS.TECH_MODULO) then
        return
    end
    local vel = dir:Normalized()*10
    --local _, pos = room:CheckLine(shooter.Position, shooter.Position + vel, 0)

    local stacks = math.max(player:GetCollectibleNum(mod.ITEMS.TECH_MODULO), 1)
    mod:DoHitscan(tear.Position, vel, player, function (position)
        for i = -1, 1, 2 do
            local ang = vel:Normalized():Rotated(90*i)
            local laser = player:FireTechLaser(position - (ang*27), 4, ang, true, false, nil, (dmgmult*0.5*stacks))
            laser.Parent = nil
        end
    end)

end

local function fire(tear, dir)
    local player = mod:UtilGetPlayerFromTear(tear)
    if not player or not tear.Parent or tear.Parent.Type ~= EntityType.ENTITY_PLAYER then
        return
    end
    FirePerpendicularLasers(_,player, tear, tear.CollisionDamage/player.Damage, dir)
end
mod:AddCallback(ModCallbacks.MC_POST_FIRE_TEAR, function (_, tear)
    fire(tear, tear.Velocity)
end)
mod:AddCustomCBack(mod.CustomCallbacks.SWCB_ON_LASER_FIRED, function (_, tear)
    fire(tear, Vector.FromAngle(tear.Angle))
end)
mod:AddCallback(ModCallbacks.MC_POST_BOMB_UPDATE, function (_, bomb)
    if bomb.FrameCount ~= 1 then
        return
    end
    local player = mod:UtilGetPlayerFromTear(bomb)
    if not bomb or not bomb.IsFetus or not bomb.Parent or bomb.Parent.Type ~= EntityType.ENTITY_PLAYER then
        return
    end
    FirePerpendicularLasers(_,player,bomb, bomb.ExplosionDamage/player.Damage, bomb.Position-player.Position)
end)