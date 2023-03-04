local this = {}
CollectibleType.SOMETHINGWICKED_WRATH = Isaac.GetItemIdByName("Wrath")

function this:TearFire(tear)
    local t_data = tear:GetData()

    if t_data.somethingWicked_trueHoming ~= nil 
    and t_data.somethingWicked_trueHoming.target ~= nil then
        local speed = 15
        if t_data.WallStickerData  then
            if t_data.WallStickerData.WallStickerInit then
                
                t_data.somethingWicked_trueHoming.target = nil
                tear.Height = tear.Height / 3
                return
            end
        end
        local variance = t_data.somethingWicked_trueHoming.angleVariance

        local rng = tear:GetDropRNG()
        SomethingWicked.EnemyHelpers:AngularMovementFunction(tear, t_data.somethingWicked_trueHoming.target, speed, variance * (1+rng:RandomFloat()*0.5), 0.2)
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
    local ot_data = tear:GetData()
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

this.RemoveTheseFlags = TearFlags.TEAR_ORBIT_ADVANCED | TearFlags.TEAR_ORBIT
| TearFlags.TEAR_SPLIT | TearFlags.TEAR_QUADSPLIT | TearFlags.TEAR_BONE | TearFlags.TEAR_BURSTSPLIT | TearFlags.TEAR_LASERSHOT

function SomethingWicked:UtilAddTrueHoming(tear, target, angleVariance, usesShotspeed, redirectOthers)
    redirectOthers = redirectOthers or false
    tear:ClearTearFlags(this.RemoveTheseFlags)
    local t_data = tear:GetData()
    t_data.somethingWicked_trueHoming = {}
    t_data.somethingWicked_trueHoming.target = target
    t_data.somethingWicked_trueHoming.angleVariance = angleVariance
    t_data.somethingWicked_trueHoming.usesShotspeed = usesShotspeed

    if redirectOthers then
        local otherTears = Isaac.FindByType(EntityType.ENTITY_TEAR)
        for _, v in ipairs(otherTears) do
            local v_data = v:GetData()
            if v_data.somethingWicked_trueHoming
            and v_data.somethingWicked_trueHoming.target
            and v_data.somethingWicked_trueHoming.target:Exists() == false then
                v_data.somethingWicked_trueHoming.target = target
            end
        end
    end
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