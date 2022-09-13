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
        local m = (angularDiff > 180 and -1 or 1)
        newAng = variance * m
    end
    familiar.Velocity = SomethingWicked.EnemyHelpers:Lerp(minosVel, minosVel:Rotated(newAng), lerpMult):Resized(speed)
end