local mod = SomethingWicked
--tear color 0, 221, 100
local color = Color(0, 0.62, 0.24, 0.5)
local dis = 80


local maxSpeed = 6
local visWait = 12
local function AirFreshUpdate(tear)
    local t_data = tear:GetData()
    if t_data.sw_airFreshTear then
        local activeLerp = tear.FrameCount/visWait
        activeLerp = mod:Clamp(activeLerp, 0, 1)
        tear.Color = Color.Lerp(Color(0, 0, 0, 0), color, activeLerp*t_data.sw_randomColorMult)

        local nearestFoe = mod:FindNearestVulnerableEnemy(tear.Position, 120)
        local targetVel = tear.Velocity:Normalized()/4
        local dontFall = true
        if nearestFoe then
            local trgtdis = nearestFoe.Position:Distance(tear.Position)
            if trgtdis < 120 then
                local spd = (1-(trgtdis/120))*maxSpeed
                targetVel = (nearestFoe.Position-tear.Position):Resized(spd)
            end
        elseif tear.FrameCount > 12*30 then
            dontFall = false
        end

        tear.Velocity = mod:Lerp(tear.Velocity, targetVel, 0.3*activeLerp)
        if dontFall then
            tear.Height = -20
        end
    end
end

local dps = 8
local damagePerTear = 10.5
mod:AddCallback(ModCallbacks.MC_POST_PEFFECT_UPDATE, function (_, player)
    if not player:HasCollectible(CollectibleType.SOMETHINGWICKED_AIR_FRESHENER) then
        return
    end

    local dpsMult = player:GetCollectibleNum(CollectibleType.SOMETHINGWICKED_AIR_FRESHENER)*dps
    local p_data = player:GetData()
    p_data.sw_airFreshenerTick = (p_data.sw_airFreshenerTick or 0) + (dpsMult/30)

    local c_rng = player:GetCollectibleRNG(CollectibleType.SOMETHINGWICKED_AIR_FRESHENER)
    local spawnMult = 1 + 0.5*math.sin(c_rng:RandomFloat()*5)
    if p_data.sw_airFreshenerTick > damagePerTear then
        p_data.sw_airFreshenerTick = p_data.sw_airFreshenerTick - damagePerTear
        local spawnVector = RandomVector()*dis*spawnMult
        spawnVector = player.Position+spawnVector

        local tear = Isaac.Spawn(EntityType.ENTITY_TEAR, 0, 0, spawnVector, (spawnVector-player.Position):Normalized()/4, player):ToTear()
        tear.CollisionDamage = 7
        tear.Scale = 1+(0.2*spawnMult)
        tear.Color = Color(0, 0, 0, 0)
        tear:GetData().sw_randomColorMult = spawnMult
        mod:AddToTearUpdateList("sw_airFreshener", tear, AirFreshUpdate)
        tear:AddTearFlags(TearFlags.TEAR_SPECTRAL)
    end
end)