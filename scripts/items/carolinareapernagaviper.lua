local this = {}
CollectibleType.SOMETHINGWICKED_NAGA_VIPER = Isaac.GetItemIdByName("Naga Viper")
CollectibleType.SOMETHINGWICKED_CAROLINA_REAPER = Isaac.GetItemIdByName("Carolina Reaper")
this.wickedFire = 23

function this:FirePure(shooter, vector, scalar, player)
    if not player:HasCollectible(CollectibleType.SOMETHINGWICKED_NAGA_VIPER)
    and not player:HasCollectible(CollectibleType.SOMETHINGWICKED_CAROLINA_REAPER) then
        return
    end

    vector = SomethingWicked.HoldItemHelpers:GetUseDirection(player):Resized(15)
    local rng = player:GetCollectibleRNG(CollectibleType.SOMETHINGWICKED_NAGA_VIPER)
    local ifReaper = rng:RandomInt(2) == 1
    local procChance = 1/(math.max(10 - player.Luck, 1))
    if procChance > rng:RandomFloat() then
        if ifReaper then
            if player:HasCollectible(CollectibleType.SOMETHINGWICKED_CAROLINA_REAPER) then
                this:FireReaper(player, vector, shooter, scalar)
            end
        else
            if player:HasCollectible(CollectibleType.SOMETHINGWICKED_NAGA_VIPER) then
                this:FireViper(player, vector, shooter, scalar)
            end
        end
    end
end

function this:FireReaper(player, vector, shooter, scalar)
    local fire = Isaac.Spawn(EntityType.ENTITY_EFFECT, EffectVariant.BLUE_FLAME, this.wickedFire, shooter.Position, vector, player):ToEffect()
    fire.Timeout = 20
    fire.CollisionDamage = 5
    fire.SpriteScale = Vector(1, 1) * scalar
end

function this:FireViper(player, vector, shooter, scalar)
    local fire = Isaac.Spawn(EntityType.ENTITY_EFFECT, EffectVariant.RED_CANDLE_FLAME, this.wickedFire, shooter.Position, vector, player):ToEffect()
    fire:SetTimeout(100)
    fire.CollisionDamage = (player.Damage + (40 * SomethingWicked.StatUps:GetCurrentDamageMultiplier(player))) * scalar
    fire.SpriteScale = Vector(1, 1) * scalar
end

function this:OnEnemyTakeDMG(ent, amount, flags, source, dmgCooldown)
    local fire = source.Entity

    if fire ~= nil
    and fire.Type == EntityType.ENTITY_EFFECT
    and fire.Variant == EffectVariant.RED_CANDLE_FLAME
    and fire.SubType == this.wickedFire 
    and fire.CollisionDamage ~= -1 then
        Isaac.Explode(fire.Position, fire.SpawnerEntity, fire.CollisionDamage)
        fire.CollisionDamage = -1
        fire:Kill()
    end
end

SomethingWicked:AddCustomCBack(SomethingWicked.CustomCallbacks.SWCB_ON_FIRE_PURE, this.FirePure)
SomethingWicked:AddCallback(ModCallbacks.MC_ENTITY_TAKE_DMG, this.OnEnemyTakeDMG)
this.EIDEntries = {}
return this