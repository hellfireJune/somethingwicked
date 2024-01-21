local mod = SomethingWicked

local procChance = 0.25
local damageMult = 0.5
local angle = 10
local Colors = {
    [-angle] = Color(0.5, 0, 0, 0.75),
    [angle] = Color(0, 0, 0.5, 0.75)
}
local LaserColors = {
    [-angle] = Color(1, 1, 1, 0.75, 0.5),
    [angle] = Color(1, 1, 1, 0.75, 0, 0, 0.5)
}

local function SplitTearsSometimes(tear)
    local player = SomethingWicked:UtilGetPlayerFromTear(tear)
    if player
    and player:HasCollectible(CollectibleType.SOMETHINGWICKED_3D_GLASSES)
    and tear.FrameCount == 1
    and tear.Parent then
        local t_data = tear:GetData()
        local ret = Retribution
        if t_data.somethingwicked_3DglassesChecked == nil
        and (not ret or not ret.pauseMilkTeeth) then
            if ret then
                ret.pauseMilkTeeth = true
            end
            local rng = tear:GetDropRNG()
            local proc = rng:RandomFloat()
            if proc < procChance then
                for i = -angle, angle, angle * 2 do
                    local newAngle = tear.Velocity:Rotated(i)
                    local damagemult = damageMult * math.min(0.1, (tear.CollisionDamage / player.Damage)) 
                    local new = player:FireTear(tear.Position - tear.Velocity, newAngle, false, false, false, nil, damagemult)
                    new.Color = LaserColors[i]

                    local n_data = new:GetData()
                    n_data.somethingwicked_3DglassesChecked = true

                    n_data.somethingWicked_trueHoming = t_data.somethingWicked_trueHoming
                    new.TearFlags = tear.TearFlags
                end
            end
            t_data.somethingwicked_3DglassesChecked = true
            if ret then
                ret.pauseMilkTeeth = false
            end
        end
    end
end

local isFiringMoreLasers = false
local function SplitLasersToo(laser, player, pure)
    if isFiringMoreLasers or not pure then
        return
    end
    if player 
    and player:HasCollectible(CollectibleType.SOMETHINGWICKED_3D_GLASSES) then
        local rng = laser:GetDropRNG()
        local proc = rng:RandomFloat()
        if proc < procChance then
            isFiringMoreLasers = true
            for i = -angle, angle, angle * 2 do
                local newAngle = Vector.FromAngle(laser.Angle + i)
                local new
                if laser.Variant == LaserVariant.THIN_RED then
                    new = player:FireTechLaser(player.Position, LaserOffset.LASER_TECH1_OFFSET, newAngle, true, false, nil, damageMult)
                else
                    new = player:FireBrimstone(newAngle, laser, damageMult)
                end
                new.Color = LaserColors[i]
                new:GetData().sw_laserParent = laser
                new:GetData().sw_angleOffset = i
            end
            isFiringMoreLasers = false
        end
    end
end

SomethingWicked:AddCallback(ModCallbacks.MC_POST_LASER_UPDATE, function (_, laser)
    local pl = laser:GetData().sw_laserParent
    if not pl then
        return
    end

    if not pl:Exists() then
        laser:Remove()
    else
        laser.Timeout = pl.Timeout
        laser.Angle = pl.Angle + laser:GetData().sw_angleOffset
        laser.Position = pl.Position
        laser.ParentOffset = pl.ParentOffset
    end
end)

local function SplitBombsAswell(_, bomb)
    if not bomb.IsFetus
    or bomb.FrameCount ~= 1 then
        return
    end

    local player = SomethingWicked:UtilGetPlayerFromTear(bomb)
    if not player
    or not player:HasCollectible(CollectibleType.SOMETHINGWICKED_3D_GLASSES) then
        return
    end

    if (bomb.Parent and bomb.Parent.Type == EntityType.ENTITY_PLAYER) then
        local c_rng = player:GetCollectibleRNG(CollectibleType.SOMETHINGWICKED_3D_GLASSES)

        if c_rng:RandomFloat() < procChance then
            local vel = bomb.Velocity
            for i = -angle, angle, angle * 2 do
                local newAngle = vel:Rotated(i)
                local new = player:FireBomb(bomb.Position - vel, newAngle, nil)
                new.Color = Colors[i]
                new.Parent = nil
            end
        end
    end
end

SomethingWicked:AddCallback(ModCallbacks.MC_POST_TEAR_UPDATE, SplitTearsSometimes)
SomethingWicked:AddCustomCBack(SomethingWicked.CustomCallbacks.SWCB_ON_LASER_FIRED, SplitLasersToo)
SomethingWicked:AddCallback(ModCallbacks.MC_POST_BOMB_UPDATE, SplitBombsAswell)