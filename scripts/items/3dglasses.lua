local this = {}
CollectibleType.SOMETHINGWICKED_3D_GLASSES = Isaac.GetItemIdByName(" 3D Glasses ")
this.procChance = 0.25
this.damageMult = 0.5
this.angle = 10
this.Colors = {
    [-this.angle] = Color(0.5, 0, 0, 0.75),
    [this.angle] = Color(0, 0, 0.5, 0.75)
}
this.LaserColors = {
    [-this.angle] = Color(1, 1, 1, 0.75, 0.5),
    [this.angle] = Color(1, 1, 1, 0.75, 0, 0, 0.5)
}

function this:SplitTearsSometimes(tear)
    local player = SomethingWicked:UtilGetPlayerFromTear(tear)
    if player
    and player:HasCollectible(CollectibleType.SOMETHINGWICKED_3D_GLASSES)
    and tear.FrameCount == 1 then
        local t_data = tear:GetData()
        if t_data.somethingwicked_3DglassesChecked == nil then
            local rng = tear:GetDropRNG()
            local proc = rng:RandomFloat()
            if proc < this.procChance then
                for i = -this.angle, this.angle, this.angle * 2 do
                    local newAngle = tear.Velocity:Rotated(i)
                    local damagemult = this.damageMult * math.min(1, (tear.CollisionDamage / player.Damage)) 
                    local new = player:FireTear(tear.Position - tear.Velocity, newAngle, false, false, false, nil, this.damageMult)
                    new.Color = this.LaserColors[i]

                    local n_data = new:GetData()
                    n_data.somethingwicked_3DglassesChecked = true
                end
            end
            t_data.somethingwicked_3DglassesChecked = true
        end
    end
end

this.isFiringMoreLasers = false
function this:SplitLasersToo(laser, player)
    if this.isFiringMoreLasers then
        return
    end
    if player 
    and player:HasCollectible(CollectibleType.SOMETHINGWICKED_3D_GLASSES) then
        local rng = laser:GetDropRNG()
        local proc = rng:RandomFloat()
        if proc < this.procChance then
            this.isFiringMoreLasers = true
            for i = -this.angle, this.angle, this.angle * 2 do
                local newAngle = Vector.FromAngle(laser.Angle + i)
                local new
                if laser.Variant == SomethingWicked.LaserVariant.TECH then
                    new = player:FireTechLaser(player.Position, LaserOffset.LASER_TECH1_OFFSET, newAngle, true, false, nil, this.damageMult)
                else
                    new = player:FireBrimstone(newAngle, nil, this.damageMult)
                end
                new.Color = this.LaserColors[i]
            end
            this.isFiringMoreLasers = false
        end
    end
end

SomethingWicked:AddCallback(ModCallbacks.MC_POST_TEAR_UPDATE, this.SplitTearsSometimes)
SomethingWicked:AddCustomCBack(SomethingWicked.CustomCallbacks.SWCB_ON_LASER_FIRED, this.SplitLasersToo)

this.EIDEntries = {
    [CollectibleType.SOMETHINGWICKED_3D_GLASSES] = {
        desc = "↑ 25% chance to shoot out 2 more tears that deal "..this.damageMult.." of your damage upon fire",
        encycloDesc = SomethingWicked:UtilGenerateWikiDesc({"25% chance to shoot out 2 more tears that deal "..this.damageMult.." of your damage upon tear fire"}),
        pools = {
            SomethingWicked.encyclopediaLootPools.POOL_TREASURE,
            SomethingWicked.encyclopediaLootPools.POOL_CRANE_GAME,
            SomethingWicked.encyclopediaLootPools.POOL_GREED_TREASURE,
        }
    }
}
return this
