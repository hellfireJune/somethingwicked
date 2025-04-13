local mod = SomethingWicked
--MAKE THIS ABLE TO HIT ENEMIES MULTIPLE TIMES

local rot = 180
local function GetFunkyVelocityAngle(tearPos, tearVel, enemyPos)
    local perpVel = enemyPos-tearPos
    perpVel = perpVel:Normalized()
    
    local angularDiff = mod:GetAngleDifference(perpVel, tearVel)
    local diffSign = -mod:MathSign(angularDiff)

    perpVel = perpVel:Rotated(rot*diffSign)
    return mod:GetAngleDifference(perpVel, tearVel)
end

local homingRadius = 100
local permBonusSpeed, maxNewSpeed = 0.3, 2.1
local variance, lerp = 15, 0.9
local returnMult, cleanupRadius = 0.8, 26
local rngAddRandom, rngMin = 1, 0.5
local function TearUpdate(tear)
    local rng = tear:GetDropRNG()
    local t_data = tear:GetData()
    local target = tear.Target

    local hitEnemies = t_data.sw_collideMap or {}

    if target then
        if hitEnemies[""..target.InitSeed] then
            tear.Target = nil
            target = nil
        else
            if t_data.sw_lightHomingFrames == nil then
                t_data.sw_lightHomingFrames = -1

                if not t_data.sw_strayStartPos then
                    local tearPos = tear.Position
                    local funnyRotated = GetFunkyVelocityAngle(tearPos, tear.Velocity, target.Position)
                    t_data.sw_totalStrayAngle = tear.Velocity
                    t_data.sw_strayStartPos = target.Position
                    tear.Velocity = tear.Velocity:Rotated(funnyRotated)
                end
            end
            t_data.sw_lightHomingFrames = t_data.sw_lightHomingFrames + 1
            --local speed = EasySpeedFunction(t_data.sw_lightHomingFrames, FramesToGoRealFast, permBonusSpeed, tempBonusSpeed)
            local speed = permBonusSpeed+(math.min(maxNewSpeed, t_data.sw_lightHomingFrames/8))
            t_data.sw_lightLastMult = mod:MultiplyTearVelocity(tear, "sw_boltOfLight", speed, true)

            local variance = variance+(speed*10)
            variance = variance * (rngMin + rng:RandomFloat()*rngAddRandom)
            mod:AngularMovementFunction(tear, target.Position + target.Velocity, tear.Velocity:Length(), variance, lerp)
        end
    end
    if not target then
        if tear.FrameCount % 2 == 0 then
            local newTarget, dis = nil, 999
            local possibleTargets = Isaac.FindInRadius(tear.Position, homingRadius, 8)

            for index, value in ipairs(possibleTargets) do
                if value:IsVulnerableEnemy() and not hitEnemies[""..value.InitSeed] then
                    local newDis = value.Position:Distance(tear.Position)
                    if newDis < dis then
                        newTarget = value dis = newDis
                    end
                end
            end
            if newTarget then
                --found new target
                tear.Target = newTarget
            else
                if t_data.sw_lightHomingFrames then
                    t_data.sw_strayStartPos=t_data.sw_strayStartPos+(t_data.sw_totalStrayAngle*4)
                    --[[here would be where i set the move speed to be normal again, set the velocity to be unrotated by the stray angle 
                    and return to the position at the stray start pos, plus a very rough estimate of how much it wouldve travelled

                    im thinking having it angular move to an estimated position it should be, constantly updating in length only after the tear is done homing,
                    then if it reaches a rough radius around said position, quickly remove any left over stray angle variance]]--
                    t_data.sw_lightHomingFrames = nil
                end

                if t_data.sw_totalStrayAngle then
                    t_data.sw_strayCleanupFrames = (t_data.sw_strayCleanupFrames or 0 )

                    t_data.sw_totalStrayAngle = t_data.sw_totalStrayAngle:Resized(tear.Velocity:Length())
                    t_data.sw_strayStartPos = t_data.sw_strayStartPos+(t_data.sw_totalStrayAngle)

                    mod:AngularMovementFunction(tear, t_data.sw_strayStartPos, tear.Velocity:Length(), variance*2, lerp)
                    if tear.Position:Distance(t_data.sw_strayStartPos) < cleanupRadius then
                        tear.Velocity = tear.Velocity:Rotated(-mod:GetAngleDifference(tear.Velocity, t_data.sw_totalStrayAngle))

                        t_data.sw_totalStrayAngle = nil
                        t_data.sw_strayStartPos = nil
                    end
                else
                    t_data.sw_lightLastMult = mod:MultiplyTearVelocity(tear, "sw_boltOfLight", mod:Lerp(1, t_data.sw_lightLastMult or 1, 0.2), true)
                end
            end
        end
    end
end

mod:AddNewTearFlag(mod.CustomTearFlags.FLAG_ULTRAHOMING, {
    PostApply = function (_, player, tear)
        if tear.Type == EntityType.ENTITY_TEAR then
            tear:ClearTearFlags(TearFlags.TEAR_HOMING)
        else
            tear:AddTearFlags(TearFlags.TEAR_HOMING)
        end
        tear:AddTearFlags(TearFlags.TEAR_PIERCING | TearFlags.TEAR_SPECTRAL)
    end,
    OverrideTearUpdate = function (_, tear)
        TearUpdate(tear)
    end,
    ApplyLogic = function (_, player)
        if player:HasCollectible(mod.ITEMS.BOLTS_OF_LIGHT) then
            return true
        end
    end
})