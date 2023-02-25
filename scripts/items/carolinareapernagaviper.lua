local this = {}
CollectibleType.SOMETHINGWICKED_NAGA_VIPER = Isaac.GetItemIdByName("Naga Viper")
CollectibleType.SOMETHINGWICKED_CAROLINA_REAPER = Isaac.GetItemIdByName("Carolina Reaper")
this.wickedFire = 23

function this:FirePure(shooter, vector, scalar, player)
    if not player:HasCollectible(CollectibleType.SOMETHINGWICKED_NAGA_VIPER)
    and not player:HasCollectible(CollectibleType.SOMETHINGWICKED_CAROLINA_REAPER) then
        return
    end

    vector = SomethingWicked:UtilGetFireVector(vector, player)
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
    fire.SpriteScale = Vector(1, 1) * (scalar/2 + 0.5)
end

function this:FireViper(player, vector, shooter, scalar)
    local fire = Isaac.Spawn(EntityType.ENTITY_EFFECT, EffectVariant.RED_CANDLE_FLAME, this.wickedFire, shooter.Position, vector, player):ToEffect()
    fire:SetTimeout(100)
    fire.CollisionDamage = (player.Damage + (40 * SomethingWicked.StatUps:GetCurrentDamageMultiplier(player))) * scalar
    fire.SpriteScale = Vector(1, 1) * (scalar/2 + 0.5)
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
SomethingWicked:AddPriorityCallback(ModCallbacks.MC_ENTITY_TAKE_DMG, CallbackPriority.LATE, this.OnEnemyTakeDMG)
this.EIDEntries = {
    [CollectibleType.SOMETHINGWICKED_CAROLINA_REAPER] = {
        desc = "Chance to shoot a cursing purple fire, which gives enemies the cursed status effect#Cursed enemies take 1.5x damage#50% chance to fire at 10 luck",
        encycloDesc = SomethingWicked:UtilGenerateWikiDesc({"Chance to shoot a cursing purple fire, which gives enemies the cursed status effect","50% chance to fire at 10 luck"}),
        pools = { SomethingWicked.encyclopediaLootPools.POOL_TREASURE, SomethingWicked.encyclopediaLootPools.POOL_GREED_TREASURE}
    },
    [CollectibleType.SOMETHINGWICKED_NAGA_VIPER] = {
        desc = "Chance to shoot green fires, which explode on contact#50% chance to fire at 10 luck",
        encycloDesc = SomethingWicked:UtilGenerateWikiDesc({"Chance to shoot green fires, which explodes on contact, doing the player's damage + 40 damage","#50% chance to fire at 10 luck"}),
        pools = { SomethingWicked.encyclopediaLootPools.POOL_TREASURE, SomethingWicked.encyclopediaLootPools.POOL_GREED_TREASURE, SomethingWicked.encyclopediaLootPools.POOL_RED_CHEST}
    }
}
return this