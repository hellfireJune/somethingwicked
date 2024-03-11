local mod = SomethingWicked
local wickedFire = 23

local function FireReaper(player, vector, shooter, scalar)
    local fire = Isaac.Spawn(EntityType.ENTITY_EFFECT, EffectVariant.BLUE_FLAME, wickedFire, shooter.Position, vector, player):ToEffect()
    fire.Timeout = 20
    fire.CollisionDamage = 5
    fire.SpriteScale = Vector(1, 1) * (scalar/2 + 0.5)
end

local function FireViper(player, vector, shooter, scalar)
    local fire = Isaac.Spawn(EntityType.ENTITY_EFFECT, EffectVariant.RED_CANDLE_FLAME, wickedFire, shooter.Position, vector, player):ToEffect()
    fire:SetTimeout(100)
    fire.CollisionDamage = (player.Damage + (40 * mod:GetCurrentDamageMultiplier(player))) * scalar
    fire.SpriteScale = Vector(1, 1) * (scalar/2 + 0.5)
end
local function FirePure(_, shooter, vector, scalar, player)
    if not player:HasCollectible(mod.ITEMS.NAGA_VIPER)
    and not player:HasCollectible(mod.ITEMS.CAROLINA_REAPER) then
        return
    end

    vector = SomethingWicked:UtilGetFireVector(vector, player)
    local rng = player:GetCollectibleRNG(mod.ITEMS.NAGA_VIPER)
    local ifReaper = rng:RandomInt(2) == 1
    local procChance = 1/(math.max(10 - player.Luck, 1))
    if procChance > rng:RandomFloat() then
        if ifReaper then
            if player:HasCollectible(mod.ITEMS.CAROLINA_REAPER) then
                FireReaper(player, vector, shooter, scalar)
            end
        else
            if player:HasCollectible(mod.ITEMS.NAGA_VIPER) then
                FireViper(player, vector, shooter, scalar)
            end
        end
    end
end

local function OnEnemyTakeDMG(_, ent, amount, flags, source, dmgCooldown)
    local fire = source.Entity

    if fire ~= nil
    and fire.Type == EntityType.ENTITY_EFFECT
    and fire.Variant == EffectVariant.RED_CANDLE_FLAME
    and fire.SubType == wickedFire 
    and fire.CollisionDamage ~= -1 then
        Isaac.Explode(fire.Position, fire.SpawnerEntity, fire.CollisionDamage)
        fire.CollisionDamage = -1
        fire:Kill()
    end
end

SomethingWicked:AddCustomCBack(SomethingWicked.CustomCallbacks.SWCB_ON_FIRE_PURE, FirePure)
SomethingWicked:AddPriorityCallback(ModCallbacks.MC_ENTITY_TAKE_DMG, CallbackPriority.LATE, OnEnemyTakeDMG)
--[[this.EIDEntries = {
}
--return this]]