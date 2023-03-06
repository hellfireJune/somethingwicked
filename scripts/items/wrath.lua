local this = {}
local mod = SomethingWicked
CollectibleType.SOMETHINGWICKED_WRATH = Isaac.GetItemIdByName("Wrath")
EffectVariant.SOMETHINGWICKED_WISP_TRAIL = Isaac.GetEntityVariantByName("Wisp Trail")

local durationTillSpeedUp=18
local lerpToZero = 0.2
local lerpToMaxSpeed = 0.1
local framesToSustainWithoutEnemy = 18
function this:TearFire(tear)
    local t_data = tear:GetData()

    if t_data.somethingWicked_trueHoming ~= nil 
    and t_data.somethingWicked_trueHoming.target ~= nil then
        local speed = t_data.sw_homingSpeed or 20
        local isSpedUp = tear.FrameCount > durationTillSpeedUp
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

        local rng = tear:GetDropRNG()
        SomethingWicked.EnemyHelpers:AngularMovementFunction(tear, t_data.somethingWicked_trueHoming.target, speed, variance * (1+rng:RandomFloat()*0.5), 0.4)

        t_data.sw_framesWithoutEnemy = t_data.sw_framesWithoutEnemy or 0
        if not t_data.somethingWicked_trueHoming.target:Exists() and isSpedUp then
            t_data.sw_framesWithoutEnemy = t_data.sw_framesWithoutEnemy + 1
            if framesToSustainWithoutEnemy < t_data.sw_framesWithoutEnemy then
                tear:Die()
            end
        end

        t_data.sw_trailFramesTable = t_data.sw_trailFramesTable or {}
        t_data.sw_trailFramesTable[tear.FrameCount] = tear.Position

        if not t_data.sw_wispTrail then
            t_data.sw_wispTrail = Isaac.Spawn(EntityType.ENTITY_EFFECT, EffectVariant.SOMETHINGWICKED_WISP_TRAIL, 0, tear.Position, Vector.Zero, tear)
            t_data.sw_wispTrail.Parent = tear
            t_data.sw_wispTrail.DepthOffset = -100
        end
        if t_data.sw_trailFramesTable[tear.FrameCount - 1] then
            t_data.sw_wispTrail.Position = t_data.sw_trailFramesTable[tear.FrameCount - 1]
        end
        t_data.sw_wispTrail.SpriteOffset = Vector(0, (tear.Height/2))
    end
        --[[local enemy = t_data.somethingWicked_trueHoming.target
        local enemypos = enemy.Position

        local angleToEnemy = (enemypos - tear.Position):GetAngleDegrees()
        local angleVel = tear.Velocity:GetAngleDegrees()

        local diff = math.abs(angleVel - angleToEnemy)
        local mult = (t_data.somethingWicked_trueHoming.angleVariance / diff)
        
        mult = 1 - math.min(math.max(mult, 0.1), 1) 
        local check = (diff < t_data.somethingWicked_trueHoming.angleVariance * mult 
        and diff or nil)
        local vectorA = Vector.FromAngle((angleVel - (check == nil and t_data.somethingWicked_trueHoming.angleVariance * mult or check)))
        local vectorB = Vector.FromAngle((angleVel + (check == nil and t_data.somethingWicked_trueHoming.angleVariance * mult or check)))

        local differenceA = (Vector.FromAngle(angleToEnemy) - vectorA):Length()
        local differenceB = (Vector.FromAngle(angleToEnemy) - vectorB):Length()
        
        local vectorToUse = differenceA > differenceB and vectorB or vectorA
        tear.Velocity = ((t_data.somethingWicked_trueHoming.usesShotspeed and SomethingWicked:UtilGetPlayerFromTear(tear) ~= nil) and SomethingWicked:UtilGetPlayerFromTear(tear).ShotSpeed * 10 or tear.Velocity:Length()) * vectorToUse]]
end

function this:TearOnHit(tear, collider, player, procChance)
    if player:HasCollectible(CollectibleType.SOMETHINGWICKED_WRATH) 
    and tear:GetData().somethingWicked_trueHoming == nil
    and tear.Parent and tear.Parent.Type == EntityType.ENTITY_PLAYER then
        local borkdHearts = player:GetBrokenHearts()
        local rng = player:GetCollectibleRNG(CollectibleType.SOMETHINGWICKED_WRATH)

        if borkdHearts > 0
        and rng:RandomFloat() <= procChance then
            local bonusAng = rng:RandomInt(60)
            local wisp = player:FireTear(player.Position, Vector.FromAngle(tear.Velocity:GetAngleDegrees() + 180 + bonusAng - 30):Resized(15), false, true, false, nil, 0.1 * borkdHearts)
            wisp:AddTearFlags(TearFlags.TEAR_SPECTRAL)
            wisp.Height = wisp.Height * 3
            wisp.Scale = wisp.Scale * 1.3
            
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

SomethingWicked:AddCallback(ModCallbacks.MC_POST_EFFECT_UPDATE, function (_, effect)
    if effect.Parent == nil or not effect.Parent:Exists() then
        effect:Remove()
    end
end, EffectVariant.SOMETHINGWICKED_WISP_TRAIL)

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

--SomethingWicked:AddPickupFunction(this.Pickup, CollectibleType.SOMETHINGWICKED_WRATH)
--Usually I'd use this instead, but Heartbreak also gives broken hearts upon rerolling into it, so idk

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