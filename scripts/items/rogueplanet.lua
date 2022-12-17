local this = {}
CollectibleType.SOMETHINGWICKED_ROGUE_PLANET_ITEM = Isaac.GetItemIdByName("Rogue planet")
FamiliarVariant.SOMETHINGWICKED_ROGUE_PLANET = Isaac.GetEntityVariantByName("Rogue planet")

function this:ShootTear(tear)
    local player = SomethingWicked:UtilGetPlayerFromTear(tear)
    if tear.FrameCount == 1
    and player and player:HasCollectible(CollectibleType.SOMETHINGWICKED_ROGUE_PLANET_ITEM) then
        
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

this.validLasers = {
    LaserVariant.THICK_RED, LaserVariant.BRIM_TECH, LaserVariant.THICKER_RED, LaserVariant.THICKER_BRIM_TECH, --brimmies
    2,  --techos
}
function this:ShootLaser(laser)
    if not SomethingWicked:UtilTableHasValue(this.validLasers, laser.Variant)then
        return
    end

    local player = SomethingWicked:UtilGetPlayerFromTear(laser)

    local l_data = laser:GetData()
    if laser.SubType ~= LaserSubType.LASER_SUBTYPE_RING_LUDOVICO
    and (laser.SubType ~= 3 or l_data.somethingwicked_rogueplanetlaser) --i need it to run the update thing twice. dont ask why. i forgot and dont want to remember.
    and (laser.FrameCount <= 1)
    and player and player:HasCollectible(CollectibleType.SOMETHINGWICKED_ROGUE_PLANET_ITEM) then
        
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

function this:FamiliarInit(familiar)
    familiar:AddToOrbit(295)
    familiar.OrbitDistance = Vector(100, 100)
	familiar.OrbitSpeed = 0.05
end

function this:FamiliarUpdate(familiar)
    local player = familiar.Player

    familiar.OrbitDistance = Vector(100, 100)
	familiar.OrbitSpeed = 0.05

    familiar.Velocity = familiar:GetOrbitPosition(player.Position + player.Velocity) - familiar.Position

    familiar.CollisionDamage = player.Damage
end

function this:OnCache(player, flags)
    if flags == CacheFlag.CACHE_FAMILIARS then
        local rng = player:GetCollectibleRNG(CollectibleType.SOMETHINGWICKED_ROGUE_PLANET_ITEM)
        local sourceItem = Isaac.GetItemConfig():GetCollectible(CollectibleType.SOMETHINGWICKED_ROGUE_PLANET_ITEM)
        player:CheckFamiliar(FamiliarVariant.SOMETHINGWICKED_ROGUE_PLANET, player:HasCollectible(CollectibleType.SOMETHINGWICKED_ROGUE_PLANET_ITEM) and 1 or 0, rng, sourceItem)
    end

    if flags == CacheFlag.CACHE_RANGE then
        local hasTheFuckinThing = player:HasCollectible(CollectibleType.SOMETHINGWICKED_ROGUE_PLANET_ITEM)
        player.TearRange = (player.TearRange * (hasTheFuckinThing and this.rangeMult or 1)) + (hasTheFuckinThing and 10*40 or 0)
    end
    
    if flags == CacheFlag.CACHE_FIREDELAY and player:HasCollectible(CollectibleType.SOMETHINGWICKED_ROGUE_PLANET_ITEM)
    and player:HasWeaponType(WeaponType.WEAPON_LASER | WeaponType.WEAPON_BRIMSTONE | WeaponType.WEAPON_TECH_X) == false then
        player.MaxFireDelay = SomethingWicked.StatUps:TearsUp(player, 0, 1)
    end

    if flags == CacheFlag.CACHE_TEARFLAG and player:HasCollectible(CollectibleType.SOMETHINGWICKED_ROGUE_PLANET_ITEM) then
        player.TearFlags = player.TearFlags | (TearFlags.TEAR_ORBIT_ADVANCED | TearFlags.TEAR_SPECTRAL)
    end
end

this.rangeMult = 2
SomethingWicked:AddCallback(ModCallbacks.MC_EVALUATE_CACHE, this.OnCache)
SomethingWicked:AddCallback(ModCallbacks.MC_FAMILIAR_UPDATE, this.FamiliarUpdate, FamiliarVariant.SOMETHINGWICKED_ROGUE_PLANET)
SomethingWicked:AddCallback(ModCallbacks.MC_FAMILIAR_INIT, this.FamiliarInit, FamiliarVariant.SOMETHINGWICKED_ROGUE_PLANET)
SomethingWicked:AddCallback(ModCallbacks.MC_POST_TEAR_UPDATE, this.ShootTear)
SomethingWicked:AddCallback(ModCallbacks.MC_POST_LASER_UPDATE, this.ShootLaser)
SomethingWicked:AddCallback(ModCallbacks.MC_POST_LASER_INIT, this.ShootLaser)

this.EIDEntries = {
    [CollectibleType.SOMETHINGWICKED_ROGUE_PLANET_ITEM] = {
        desc = "↑ "..this.rangeMult.."x Range#↑ +1 flat tears up#Spawns a planetoid orbital that your tears will orbit",
        pools = {
            SomethingWicked.encyclopediaLootPools.POOL_TREASURE,
            SomethingWicked.encyclopediaLootPools.POOL_BABY_SHOP,
            SomethingWicked.encyclopediaLootPools.POOL_GREED_TREASURE
        },
        encycloDesc = SomethingWicked:UtilGenerateWikiDesc({this.rangeMult.."x range, +1 flat tears up", "Spawns a planetoid orbital that your tears will orbit"})
    }
}
return this