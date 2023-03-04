SomethingWicked.EnemyHelpers = {} --really this is just like, a velocity helper

--praise be fiendfolio
function SomethingWicked.EnemyHelpers:Lerp(first, second, percent, smoothIn, smoothOut)
    if smoothIn then
        percent = percent ^ smoothIn
    end

    if smoothOut then
        percent = 1 - percent
        percent = percent ^ smoothOut
        percent = 1 - percent
    end

	return (first + (second - first)*percent)
end

--praise be fiendfolio, again.
function SomethingWicked.EnemyHelpers:GetAngleDegreesButGood(vec)
    local angle = (vec):GetAngleDegrees()
    if angle < 0 then
        return 360 + angle
    else
        return angle
    end
end

--"From Dead"
function SomethingWicked.EnemyHelpers:GetAngleDifference(a1, a2)
    a1 = SomethingWicked.EnemyHelpers:GetAngleDegreesButGood(a1)
    a2 = SomethingWicked.EnemyHelpers:GetAngleDegreesButGood(a2)
    local sub = a1 - a2
    return (sub + 180) % 360 - 180
end

function SomethingWicked.EnemyHelpers:AngularMovementFunction(familiar, target, speed, variance, lerpMult)
    local enemypos = target.Position
        
    local velToEnemy = (enemypos - familiar.Position)
    local minosVel = familiar.Velocity

    local newAng = 0
    local angularDiff = SomethingWicked.EnemyHelpers:GetAngleDifference(velToEnemy, minosVel)
    if angularDiff < variance and angularDiff > -variance then
        newAng = angularDiff
    else
        local m = (angularDiff < 0 and -1 or 1)
        newAng = variance * m
    end
    familiar.Velocity = SomethingWicked.EnemyHelpers:Lerp(minosVel, minosVel:Rotated(newAng), lerpMult):Resized(speed)
end

function SomethingWicked.EnemyHelpers:FluctuatingOrbitFunc(familiar, player, lerp)
    lerp = lerp or 0.25
    local position = (familiar:GetOrbitPosition(player.Position + player.Velocity))
    position = player.Position + player.Velocity + ((player.Position + player.Velocity) - position) * math.sin(0.1 * familiar.FrameCount)
    if SomethingWicked.game:GetRoom():GetFrameCount() == 0 then
        familiar.Velocity = Vector.Zero
        familiar.Position = position
        --we stan a weird ass fuckin visual glitch
    else
        local velocity = (position) - familiar.Position
        familiar.Velocity = SomethingWicked.EnemyHelpers:Lerp(familiar.Velocity, velocity, lerp)
    end
end