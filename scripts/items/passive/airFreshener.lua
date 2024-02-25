local mod = SomethingWicked
--tear color 0, 221, 100
local color = Color(0, 0.62, 0.24, 0.5)
local dis = 60

local maxSpeed = 6
local visWait = 12
local radius = 180
local function AirFreshUpdate(_, tear)
    local t_data = tear:GetData()
        local activeLerp = tear.FrameCount/visWait
        activeLerp = mod:Clamp(activeLerp, 0, 1)
        tear.Color = Color.Lerp(Color(0, 0, 0, 0), color, activeLerp*(t_data.sw_randomColorMult or 0))

        local nearestFoe = mod:FindNearestVulnerableEnemy(tear.Position, radius)
        local targetVel = tear.Velocity:Normalized()/4
        local dontFall = true

        if t_data.sw_airFreshTarget ~= nil and t_data.sw_airFreshTarget:Exists()
         and nearestFoe and GetPtrHash(t_data.sw_airFreshTarget) ~= GetPtrHash(nearestFoe.InitSeed) then
            local newDis = nearestFoe.Position:Distance(tear.Position)
            local oldDis = t_data.sw_airFreshTarget.Position:Distance(tear.Position)
            if newDis < oldDis then
                t_data.sw_airFreshTarget = nearestFoe
            end
        else
            if t_data.sw_airFreshTarget == nil then
                t_data.sw_airFreshTarget = nearestFoe
            end
        end

        local target = t_data.sw_airFreshTarget
        if target and activeLerp > 0.5 then
            local trgtdis = target.Position:Distance(tear.Position)
                local d = (1-(math.min(radius-30, trgtdis)/radius))
                local spd = d*maxSpeed
                targetVel = (target.Position-tear.Position):Resized(spd)
        elseif tear.FrameCount > 12*30 then
            dontFall = false
        end

        tear.Velocity = mod:Lerp(tear.Velocity, targetVel, 0.3*activeLerp)
        if dontFall then
            tear.Height = -20
        end
end

local dps = 8
local damagePerTear = 15.5
mod:AddCallback(ModCallbacks.MC_POST_PEFFECT_UPDATE, function (_, player)
    if not player:HasCollectible(mod.ITEMS.AIR_FRESHENER) then
        return
    end

    local r = Game():GetRoom()
    if r:GetAliveEnemiesCount() == 0 then
        return
    end

    local dpsMult = player:GetCollectibleNum(mod.ITEMS.AIR_FRESHENER)*dps
    local p_data = player:GetData()
    p_data.sw_airFreshenerTick = (p_data.sw_airFreshenerTick or 0) + (dpsMult/30)

    local c_rng = player:GetCollectibleRNG(mod.ITEMS.AIR_FRESHENER)
    local spawnMult = 0.75 + 0.5*c_rng:RandomFloat()
    if p_data.sw_airFreshenerTick > damagePerTear then
        p_data.sw_airFreshenerTick = p_data.sw_airFreshenerTick - damagePerTear
        local spawnVector = RandomVector()*dis*spawnMult
        spawnVector = player.Position+spawnVector

        local tear = Isaac.Spawn(EntityType.ENTITY_TEAR, 0, 0, spawnVector, (spawnVector-player.Position):Normalized()/4, player):ToTear()
        tear.CollisionDamage = damagePerTear
        tear.Scale = 1+(0.2*spawnMult)
        tear.Color = Color(0, 0, 0, 0)
        tear:GetData().sw_randomColorMult = spawnMult
        mod:AddToTearUpdateList("sw_airFreshener", tear, AirFreshUpdate)
        tear:AddTearFlags(TearFlags.TEAR_SPECTRAL)
    end
end)