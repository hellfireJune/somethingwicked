local this = {}
CollectibleType.SOMETHINGWICKED_PHOBOS_AND_DEIMOS = Isaac.GetItemIdByName("Phobos and Deimos")
FamiliarVariant.SOMETHINGWICKED_PHOBOS = Isaac.GetEntityVariantByName("Phobos Familiar")
FamiliarVariant.SOMETHINGWICKED_DEIMOS = Isaac.GetEntityVariantByName("Deimos Familiar")

this.offSet = Vector(30, 30)
function this:UpdateFamiliar(familiar)
    local isLeft = familiar.Variant == FamiliarVariant.SOMETHINGWICKED_PHOBOS and -1 or 1

    local player = familiar.Player
    local shouldFire = true
    local direction = player:GetAimDirection()

    if direction:Length() == 0 then
        shouldFire = false
        direction = Vector(0, 1)
    end

    local playerPos = player.Position
    direction = (direction:Rotated(90)) * isLeft
    local vector = playerPos + (this.offSet * direction)
    familiar.Velocity = SomethingWicked.EnemyHelpers:Lerp(familiar.Velocity, (vector - familiar.Position), 0.2)

    if familiar.FireCooldown > 0 then
        familiar.FireCooldown = familiar.FireCooldown - 1
    end
    if shouldFire and familiar.FireCooldown <= 0 then
        local f_rng = familiar:GetDropRNG()
        local dmgNSCaleMult = 0.8 + (f_rng:RandomFloat() * 0.4)
        local randomAngle = f_rng:RandomInt(60) - 30

        local fireDirection = direction:Rotated(randomAngle)
        local tear = familiar:FireProjectile(fireDirection)
        
        tear.CollisionDamage = 0.8 * dmgNSCaleMult
        tear.Scale = tear.Scale * dmgNSCaleMult
        tear:AddTearFlags(TearFlags.TEAR_FEAR)
        tear:ChangeVariant(TearVariant.DARK_MATTER)
        familiar.FireCooldown = 8
    end
end

function this:CacheEval(player, flags)
    local stacks, rng, sourceItem = SomethingWicked.FamiliarHelpers:BasicFamiliarNum(player, CollectibleType.SOMETHINGWICKED_PHOBOS_AND_DEIMOS)
    player:CheckFamiliar(FamiliarVariant.SOMETHINGWICKED_PHOBOS, stacks, rng, sourceItem)
    player:CheckFamiliar(FamiliarVariant.SOMETHINGWICKED_DEIMOS, stacks, rng, sourceItem)
end

SomethingWicked:AddCallback(ModCallbacks.MC_EVALUATE_CACHE, this.CacheEval, CacheFlag.CACHE_FAMILIARS)
SomethingWicked:AddCallback(ModCallbacks.MC_FAMILIAR_UPDATE, this.UpdateFamiliar, FamiliarVariant.SOMETHINGWICKED_PHOBOS)
SomethingWicked:AddCallback(ModCallbacks.MC_FAMILIAR_UPDATE, this.UpdateFamiliar, FamiliarVariant.SOMETHINGWICKED_DEIMOS)

this.EIDEntries = {}
return this