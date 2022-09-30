local this = {}
CollectibleType.SOMETHINGWICKED_BALROGS_HEAD = Isaac.GetItemIdByName("Balrog's Head")
this.head = Isaac.GetEntityVariantByName("Balrog Head")

function this:ItemUse(_, _, player, flags)
    return SomethingWicked.HoldItemHelpers:HoldItemUseHelper(player, flags, CollectibleType.SOMETHINGWICKED_BALROGS_HEAD)
end

function  this:PlayerUpdate(player)
    if SomethingWicked.HoldItemHelpers:HoldItemUpdateHelper(player, CollectibleType.SOMETHINGWICKED_BALROGS_HEAD) then
        local tear = player:FireTear(player.Position, (SomethingWicked.HoldItemHelpers:GetUseDirection(player)), false, true, false)
        tear.Velocity = tear.Velocity:Resized(15)
        tear:ChangeVariant(this.head)
        local t_data = tear:GetData()
        t_data.somethingwicked_isTheBalrogsHead = true
    end
end

function this:TearCollision(tear) 
    local t_data = tear:GetData()
    if not t_data.somethingwicked_isTheBalrogsHead then
       return 
    end
    this:onTearHitsShit(tear)
end

function this:onTearHitsShit(tear)
    SomethingWicked.sfx:Play(SoundEffect.SOUND_EXPLOSION_WEAK, 1, 0)
    local theRNG = RNG()
    theRNG:SetSeed(Random() + 1, 1)
    Isaac.Spawn(EntityType.ENTITY_EFFECT, EffectVariant.BOMB_EXPLOSION, 0, tear.Position, Vector.Zero, tear)
    local bigFire = Isaac.Spawn(EntityType.ENTITY_EFFECT, EffectVariant.RED_CANDLE_FLAME, 0, tear.Position, Vector.Zero, tear)
    bigFire.CollisionDamage = 40
    bigFire.SpriteScale = Vector(1.25, 1.25)
    for i = 1, 4 do
        local thefloatingfire = Isaac.Spawn(EntityType.ENTITY_EFFECT, EffectVariant.RED_CANDLE_FLAME, 0, tear.Position, (RandomVector()) * 5, tear)
        thefloatingfire.CollisionDamage = 25
    end
end

function  this:OnWispDie(entity)
    if entity.Variant == FamiliarVariant.WISP and entity.SubType == CollectibleType.SOMETHINGWICKED_BALROGS_HEAD then
        local smolFire = Isaac.Spawn(EntityType.ENTITY_EFFECT, EffectVariant.RED_CANDLE_FLAME, 0, entity.Position, Vector.Zero, entity)
        smolFire.CollisionDamage = 15
        smolFire.SpriteScale = Vector(0.75, 0.75)
    end
end

SomethingWicked:AddCallback(ModCallbacks.MC_POST_PEFFECT_UPDATE, this.PlayerUpdate)
SomethingWicked:AddCallback(ModCallbacks.MC_USE_ITEM, this.ItemUse, CollectibleType.SOMETHINGWICKED_BALROGS_HEAD)
SomethingWicked:AddCallback(ModCallbacks.MC_POST_ENTITY_REMOVE, this.TearCollision, EntityType.ENTITY_TEAR)
SomethingWicked:AddCallback(ModCallbacks.MC_POST_ENTITY_KILL, this.OnWispDie, EntityType.ENTITY_FAMILIAR)

this.EIDEntries = {
    [CollectibleType.SOMETHINGWICKED_BALROGS_HEAD] = {
        desc = "Throwable fire bomb#Spawns 4 fires which do 23 damage, and 1 fire which does 50 damage",
        pools = {
            SomethingWicked.encyclopediaLootPools.POOL_TREASURE,
            SomethingWicked.encyclopediaLootPools.POOL_GREED_TREASURE
        },
        encycloDesc = SomethingWicked:UtilGenerateWikiDesc({"Throwable fire bomb","Spawns 4 fires which do 23 damage, and 1 fire which does 50 damage"})
    }
}
return this