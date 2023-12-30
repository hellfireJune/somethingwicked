local mod = SomethingWicked

local durationTillSpeedUp=18
local lerpToZero = 0.2
local lerpToMaxSpeed = 0.1
local framesToSustainWithoutEnemy = 18
local trailLength = 2
local forceTrailDistanceMult = 1
function this:TearFire(tear)
    local t_data = tear:GetData()
    if t_data.somethingWicked_trueHoming ~= nil then
        local speed = t_data.sw_homingSpeed or 20
        local isSpedUp = tear.FrameCount > durationTillSpeedUp
        if tear.FrameCount == durationTillSpeedUp then
            mod.sfx:Play(SoundEffect.SOUND_BEAST_GHOST_DASH, 0.8, 0)
        end
        if isSpedUp then
            t_data.sw_homingSpeed = mod.EnemyHelpers:Lerp(speed, 30, lerpToMaxSpeed)
        else
            t_data.sw_homingSpeed = mod.EnemyHelpers:Lerp(speed, 0, lerpToZero)
        end
        if t_data.WallStickerData  then
            if t_data.WallStickerData.WallStickerInit then
                
                t_data.somethingWicked_trueHoming.target = nil
                tear.Height = tear.Height / 3
                return
            end
        end
        local variance = (isSpedUp and t_data.somethingWicked_trueHoming.angleVariance or 1)*(speed/10)
        if not t_data.somethingWicked_trueHoming.target then
            t_data.somethingWicked_trueHoming.backupPos = t_data.somethingWicked_trueHoming.backupPos or tear.Position + RandomVector()*160
            if tear.Position:Distance(t_data.somethingWicked_trueHoming.backupPos) < speed*1.2 then
                tear:Die()
            end
        else
            t_data.sw_framesWithoutEnemy = t_data.sw_framesWithoutEnemy or 0
            if not t_data.somethingWicked_trueHoming.target:Exists() and isSpedUp then
                t_data.sw_framesWithoutEnemy = t_data.sw_framesWithoutEnemy + 1
                if framesToSustainWithoutEnemy < t_data.sw_framesWithoutEnemy then
                    tear:Die()
                end
            end
        end

        local rng = tear:GetDropRNG()
        SomethingWicked.EnemyHelpers:AngularMovementFunction(tear, t_data.somethingWicked_trueHoming.target or t_data.somethingWicked_trueHoming.backupPos, speed, variance * (1+rng:RandomFloat()*0.5), 0.4)

    end
end

SomethingWicked:AddCallback(ModCallbacks.MC_POST_TEAR_RENDER, function (_, tear)
    
    local t_data = tear:GetData()
    if tear.Variant == TearVariant.SOMETHINGWICKED_WISP then
        tear.Scale = 1
        tear.SpriteScale = Vector(1, 1)

        t_data.sw_trailFramesTable = t_data.sw_trailFramesTable or {}
        t_data.sw_trailFramesTable[tear.FrameCount] = tear.Position

        t_data.sw_trails = t_data.sw_trails or {}
        t_data.sw_extantTrails = t_data.sw_extantTrails or {}
        for i = 1, trailLength, 1 do
            local trail = t_data.sw_trails[i]
            if not trail then
                trail = Isaac.Spawn(EntityType.ENTITY_EFFECT, EffectVariant.SOMETHINGWICKED_WISP_TRAIL, 0, tear.Position, Vector.Zero, tear)
                trail.Parent = tear
                t_data.sw_trails[i] = trail

                trail:GetSprite():Play("Idle"..i)
            end

            trail.Color = tear.Color
            trail.SpriteOffset = tear.PositionOffset*0.655
            local lastPos = t_data.sw_trailFramesTable[tear.FrameCount-1]
            if lastPos then
                local pos = mod.EnemyHelpers:Lerp(lastPos, (tear.Position), ((trailLength-i)/trailLength*forceTrailDistanceMult)+0.66)
                trail.Velocity = pos - trail.Position
            end

            local extrail = t_data.sw_extantTrails[i]
            if not extrail then
                extrail = Isaac.Spawn(EntityType.ENTITY_EFFECT, EffectVariant.SOMETHINGWICKED_WISP_TRAIL, 0, tear.Position, Vector.Zero, tear)
                extrail.Parent = tear
                t_data.sw_extantTrails[i] = extrail

                local sprite = extrail:GetSprite()
                sprite:Load("gfx/effect_wisp_trail_extant.anm2", true)
                sprite:Play("Idle"..i)
                extrail.DepthOffset = 10
            end
            extrail.Velocity = (trail.Position + trail.Velocity) - extrail.Position
            extrail.SpriteOffset = trail.SpriteOffset
            extrail.Color = tear.Color
        end

        local extrail = t_data.sw_extantRenderer
        if not extrail then
            extrail = Isaac.Spawn(EntityType.ENTITY_EFFECT, EffectVariant.SOMETHINGWICKED_WISP_TRAIL, 0, tear.Position, Vector.Zero, tear)
            extrail.Parent = tear
            t_data.sw_extantRenderer = extrail

            local sprite = extrail:GetSprite()
            sprite:Load("gfx/effect_wisp_trail_extant.anm2", true)
            sprite:Play("Idle0")
            extrail.DepthOffset = 10
        end
        extrail.Velocity = (tear.Position + tear.Velocity) - extrail.Position
        extrail.SpriteOffset = tear.PositionOffset*0.655
        extrail.Color = tear.Color
    end

end)

function this:TearOnHit(tear, collider, player, procChance)
    if player:HasCollectible(CollectibleType.SOMETHINGWICKED_WRATH) 
    and tear:GetData().somethingWicked_trueHoming == nil
    and ((tear.Parent and tear.Parent.Type == EntityType.ENTITY_PLAYER) or tear.Type == EntityType.ENTITY_PLAYER) then
        local borkdHearts = player:GetBrokenHearts()
        local rng = player:GetCollectibleRNG(CollectibleType.SOMETHINGWICKED_WRATH)

        if borkdHearts > 0
        and rng:RandomFloat() <= procChance then
            local bonusAng = rng:RandomInt(60)
            local wisp = player:FireTear(player.Position, Vector.FromAngle(tear.Velocity:GetAngleDegrees() + 180 + bonusAng - 30):Resized(15), false, true, false, nil, 0.13 * borkdHearts)
            wisp:ChangeVariant(TearVariant.SOMETHINGWICKED_WISP)
            wisp:AddTearFlags(TearFlags.TEAR_SPECTRAL)
            wisp.Height = wisp.Height * 3
            wisp.Scale = wisp.Scale * 1.15
            wisp.Parent = nil
            
			local colour = Color(1, 1, 1, 1)
			colour:SetColorize(2, 0, 0, 0.5)
            wisp.Color = colour

            SomethingWicked:UtilAddTrueHoming(wisp, collider, 35, false)
        end
    end
end

function this:PEffectUpdate(player)
    local p_data = player:GetData()
    p_data.SomethingWickedPData.wrathOwned = p_data.SomethingWickedPData.wrathOwned or player:GetCollectibleNum(CollectibleType.SOMETHINGWICKED_WRATH) 

    if p_data.SomethingWickedPData.wrathOwned < player:GetCollectibleNum(CollectibleType.SOMETHINGWICKED_WRATH)  then
        player:AddBrokenHearts(3)
        p_data.SomethingWickedPData.wrathOwned = player:GetCollectibleNum(CollectibleType.SOMETHINGWICKED_WRATH)
    end
end

SomethingWicked:AddCallback(ModCallbacks.MC_POST_TEAR_UPDATE, this.TearFire)
SomethingWicked:AddCustomCBack(SomethingWicked.CustomCallbacks.SWCB_ON_ENEMY_HIT, this.TearOnHit)
SomethingWicked:AddCallback(ModCallbacks.MC_POST_PEFFECT_UPDATE, this.PEffectUpdate)

SomethingWicked:AddCallback(ModCallbacks.MC_POST_ENTITY_REMOVE, function (_, tear)
    if tear.Variant == TearVariant.SOMETHINGWICKED_WISP then
        local explode = Isaac.Spawn(EntityType.ENTITY_EFFECT, EffectVariant.SOMETHINGWICKED_WISP_EXPLODE, 0, tear.Position + tear.PositionOffset, Vector.Zero, tear)
        explode.DepthOffset = 20
        mod.sfx:Play(SoundEffect.SOUND_EXPLOSION_WEAK, 0.8, 0)
        mod.sfx:Play(SoundEffect.SOUND_MEATY_DEATHS, 0.6, 0)
        local poof = Isaac.Spawn(EntityType.ENTITY_EFFECT, EffectVariant.POOF01, 0, tear.Position+tear.PositionOffset, Vector.Zero, tear)
        poof.Color = Color(0.2, 0.2, 0.2) * tear.Color
        poof.SpriteScale = Vector(0.5, 0.5)

        local t_data = tear:GetData()
        local blood = Isaac.Spawn(EntityType.ENTITY_EFFECT, 2, 0, tear.Position + tear.PositionOffset, Vector.Zero, tear)
        if t_data.sw_isChrisWisp then
            blood.Color = Color(1, 1, 1, 0.5, 2, 2, 2)
        else
            blood.Color = tear.Color
        end
    end
end, EntityType.ENTITY_TEAR)

SomethingWicked:AddCallback(ModCallbacks.MC_POST_EFFECT_UPDATE, function (_, effect)
    if effect.Parent == nil or not effect.Parent:Exists() then
        effect:Remove()
    end
end, EffectVariant.SOMETHINGWICKED_WISP_TRAIL)
mod:AddCallback(ModCallbacks.MC_POST_EFFECT_UPDATE, function (_, effect)
    local sprite = effect:GetSprite()
    if sprite:IsFinished("Appear") then
        effect:Remove()
    end
end, EffectVariant.SOMETHINGWICKED_WISP_EXPLODE)

this.RemoveTheseFlags = TearFlags.TEAR_ORBIT_ADVANCED | TearFlags.TEAR_ORBIT
| TearFlags.TEAR_SPLIT | TearFlags.TEAR_QUADSPLIT | TearFlags.TEAR_BONE | TearFlags.TEAR_BURSTSPLIT | TearFlags.TEAR_LASERSHOT

function SomethingWicked:UtilAddTrueHoming(tear, target, angleVariance, usesShotspeed)
    tear:ClearTearFlags(this.RemoveTheseFlags)
    local t_data = tear:GetData()
    t_data.somethingWicked_trueHoming = {}
    t_data.somethingWicked_trueHoming.target = target
    t_data.somethingWicked_trueHoming.angleVariance = angleVariance
    t_data.somethingWicked_trueHoming.usesShotspeed = usesShotspeed
end

this.EIDEntries = {
    [CollectibleType.SOMETHINGWICKED_WRATH] = {
        desc = "↑ 3 broken hearts#Damaging an enemy will send out a tear that homes onto that enemy#The tear deals damage equal to 10% of your number of broken hearts",
        pools = {
            SomethingWicked.encyclopediaLootPools.POOL_DEVIL,
            SomethingWicked.encyclopediaLootPools.POOL_GREED_DEVIL,
            SomethingWicked.encyclopediaLootPools.POOL_CURSE,
            SomethingWicked.encyclopediaLootPools.POOL_GREED_CURSE,
            SomethingWicked.encyclopediaLootPools.POOL_ULTRA_SECRET,
        },
        encycloDesc = SomethingWicked:UtilGenerateWikiDesc({"Grants three broken hearts", "Damaging an enemy will send out a tear that homes onto that enemy","The tear deals damage equal to 10% of your number of broken hearts"})
    }
}
return this