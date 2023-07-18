local this = {}
local mod = SomethingWicked--[]

local prismOffset = 20
local durationTillMega = 47
local wishwoshDuration = 30
local initialLasers = 6
function this:PostPEffectUpdate(player)
    local p_data = player:GetData()

    local effects = player:GetEffects()
    if not effects:HasCollectibleEffect(CollectibleType.SOMETHINGWICKED_LAST_PRISM) then
        if p_data.somethingWicked_lastPrism then
            --cleanup
            p_data.somethingWicked_usingLastPrism = false
            p_data.somethingWicked_lastPrism:Remove()
            p_data.somethingWicked_lastPrism = nil
        end
        return
    end
    player.FireDelay = player.MaxFireDelay
    
    local prism = p_data.somethingWicked_lastPrism
    if not prism or not prism:Exists() then
        prism = Isaac.Spawn(EntityType.ENTITY_FAMILIAR, FamiliarVariant.SOMETHINGWICKED_PRISM_HELPER, 0, player.Position, Vector.Zero, player)
        prism:ClearEntityFlags(EntityFlag.FLAG_APPEAR)
        p_data.somethingWicked_lastPrism = prism
        
        p_data.somethingWicked_usingLastPrism = true
    end

    local direction = player:GetAimDirection()
    local shouldFire = true
    if direction:Length() == 0 then
        shouldFire = false
        direction = Vector(0, 1)
    end

    local angle =  mod.EnemyHelpers:GetAngleDegreesButGood(direction)
    local lastAngle = p_data.sw_prismLastAngle or angle
    angle = mod.EnemyHelpers:Lerp(angle, lastAngle, 0.25)

    direction = Vector.FromAngle(angle)

    prism.Position = player.Position + (direction*prismOffset)

    local lasers = p_data.somethingWicked_lastPrismLasers
    if lasers == nil or lasers[1] == nil or not lasers[1]:Exists() then
        if shouldFire then
            lasers = {}
            for i = 1, initialLasers, 1 do
                local laser = EntityLaser.ShootAngle(1, prism.Position, angle, 7, Vector.Zero, player)

                p_data.sw_prismFramesSpentFiring = 0
                p_data.sw_prismSkip = false
                table.insert(lasers, laser)
            end
            p_data.somethingWicked_lastPrismLasers = lasers
        end
    end
    shouldFire = shouldFire and (not p_data.sw_prismSkip)
    if lasers ~= nil then
        for index, laser in pairs(lasers) do
            if not laser:Exists() then
                p_data.somethingWicked_lastPrismLasers[index] = nil
            else
                if shouldFire and (p_data.sw_prismFramesSpentFiring < durationTillMega - 7 or index == 1) then
                    laser.Timeout = 7
                else
                    --laser:Remove()
                end
                local varianceMult = (wishwoshDuration - (p_data.sw_prismFramesSpentFiring/1.25))/(wishwoshDuration)
                varianceMult = math.max(0, varianceMult)
                laser.Angle = angle + varianceMult*(math.sin((laser.FrameCount+(index*8))/10)*30)
                laser.Position = prism.Position
            end
        end
    end
    if p_data.sw_prismFramesSpentFiring == durationTillMega then
        local laser = EntityLaser.ShootAngle(11, prism.Position, angle, 7, Vector.Zero, player)
        table.insert(p_data.somethingWicked_lastPrismLasers, 1, laser)
    end
    if not shouldFire then
        p_data.sw_prismSkip = true
    else
        p_data.sw_prismFramesSpentFiring = p_data.sw_prismFramesSpentFiring + 1
    end
    p_data.sw_prismLastAngle = angle
end
SomethingWicked:AddCallback(ModCallbacks.MC_POST_PEFFECT_UPDATE, this.PostPEffectUpdate)

this.EIDEntries = {
    [CollectibleType.SOMETHINGWICKED_LAST_PRISM] = {
        Hide = true
    }
}
return this
