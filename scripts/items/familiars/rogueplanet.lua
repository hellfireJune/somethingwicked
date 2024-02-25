local mod = SomethingWicked

local function ShootTear(_, tear)
    local player = mod:UtilGetPlayerFromTear(tear)
    if tear.FrameCount == 1
    and player and player:HasCollectible(mod.ITEMS.ROGUE_PLANET_ITEM) then
        
        local planets = Isaac.FindByType(EntityType.ENTITY_FAMILIAR, FamiliarVariant.SOMETHINGWICKED_ROGUE_PLANET)
        for _, planet in ipairs(planets) do
            planet = planet:ToFamiliar()
            if planet
            and GetPtrHash(planet.Player) == GetPtrHash(tear.SpawnerEntity)  then
                tear.SpawnerEntity = planet
            end
        end
    end
end

local validLasers = {
    LaserVariant.THICK_RED, LaserVariant.BRIM_TECH, LaserVariant.THICKER_RED, LaserVariant.THICKER_BRIM_TECH, --brimmies
    2,  --techos
}
local function ShootLaser(_, laser)
    if not SomethingWicked:UtilTableHasValue(validLasers, laser.Variant)then
        return
    end

    local player = SomethingWicked:UtilGetPlayerFromTear(laser)

    local l_data = laser:GetData()
    if laser.SubType ~= LaserSubType.LASER_SUBTYPE_RING_LUDOVICO
    and (laser.SubType ~= 3 or l_data.somethingwicked_rogueplanetlaser) --i need it to run the update thing twice. dont ask why. i forgot and dont want to remember.
    and (laser.FrameCount <= 1)
    and player and player:HasCollectible(mod.ITEMS.ROGUE_PLANET_ITEM) then
        
        local planets = Isaac.FindByType(EntityType.ENTITY_FAMILIAR, FamiliarVariant.SOMETHINGWICKED_ROGUE_PLANET)
        for _, planet in ipairs(planets) do
            planet = planet:ToFamiliar()
            if planet
            and GetPtrHash(planet.Player) == GetPtrHash(laser.SpawnerEntity) then
                local timeout = 52
                if laser.SubType ~= 1 and laser.Variant == 2
                and laser.Timeout < 2 then
                    timeout = 14 
                    laser.CollisionDamage = player.Damage / 5
                end
                laser:SetTimeout(timeout)


                laser.GridCollisionClass = 0
                laser.EntityCollisionClass = 4
                laser.SubType = 3
                laser.Position = planet.Position
                laser.Velocity = Vector.Zero
                laser.SpawnerEntity = planet
                laser.Radius = 70

                laser.Parent = player
                laser.DisableFollowParent = true

                laser.ParentOffset = Vector.Zero
                laser.TearFlags = laser.TearFlags | TearFlags.TEAR_PULSE

                l_data.somethingwicked_rogueplanetlaser = true
                break
            end
        end
    elseif laser.SubType == 3
    and l_data.somethingwicked_rogueplanetlaser
    and laser.SpawnerEntity then
        laser.Velocity = laser.SpawnerEntity.Position - laser.Position
    end
end

local function FamiliarInit(_, familiar)
    familiar:AddToOrbit(295)
    familiar.OrbitDistance = Vector(100, 100)
	familiar.OrbitSpeed = 0.05
end

local function FamiliarUpdate(_, familiar)
    local player = familiar.Player

    familiar.OrbitDistance = Vector(100, 100)
	familiar.OrbitSpeed = 0.05

    familiar.Velocity = familiar:GetOrbitPosition(player.Position + player.Velocity) - familiar.Position

    familiar.CollisionDamage = player.Damage
end

SomethingWicked:AddCallback(ModCallbacks.MC_FAMILIAR_UPDATE, FamiliarUpdate, FamiliarVariant.SOMETHINGWICKED_ROGUE_PLANET)
SomethingWicked:AddCallback(ModCallbacks.MC_FAMILIAR_INIT, FamiliarInit, FamiliarVariant.SOMETHINGWICKED_ROGUE_PLANET)
SomethingWicked:AddCallback(ModCallbacks.MC_POST_TEAR_UPDATE, ShootTear)
SomethingWicked:AddCallback(ModCallbacks.MC_POST_LASER_UPDATE, ShootLaser)
SomethingWicked:AddCallback(ModCallbacks.MC_POST_LASER_INIT, ShootLaser)