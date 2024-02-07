local mod = SomethingWicked
local head = Isaac.GetEntityVariantByName("Balrog Head")
local sfx = SFXManager()

local function PlayerUpdate(_, player)
    if mod:HoldItemUpdateHelper(player, CollectibleType.SOMETHINGWICKED_BALROGS_HEAD) then
        local tear = player:FireTear(player.Position, (mod:GetUseDirection(player)), false, true, false)
        tear.Velocity = tear.Velocity * 1.5
        tear:ChangeVariant(head)
        local t_data = tear:GetData()
        t_data.somethingwicked_isTheBalrogsHead = true
    end
end

local function onTearHitsShit(tear)
    sfx:Play(SoundEffect.SOUND_EXPLOSION_WEAK, 1, 0)
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
local function TearCollision(_, tear) 
    local t_data = tear:GetData()
    if not t_data.somethingwicked_isTheBalrogsHead then
       return 
    end
    if tear.StickTarget ~= nil then
        return
    end
    onTearHitsShit(tear)
end


local function OnWispDie(entity)
    if entity.Variant == FamiliarVariant.WISP and entity.SubType == CollectibleType.SOMETHINGWICKED_BALROGS_HEAD then
        local smolFire = Isaac.Spawn(EntityType.ENTITY_EFFECT, EffectVariant.RED_CANDLE_FLAME, 0, entity.Position, Vector.Zero, entity)
        smolFire.CollisionDamage = 15
        smolFire.SpriteScale = Vector(0.75, 0.75)
    end
end

SomethingWicked:AddCallback(ModCallbacks.MC_POST_PEFFECT_UPDATE, PlayerUpdate)
SomethingWicked:AddCallback(ModCallbacks.MC_POST_ENTITY_REMOVE, TearCollision, EntityType.ENTITY_TEAR)
SomethingWicked:AddCallback(ModCallbacks.MC_POST_ENTITY_KILL, OnWispDie, EntityType.ENTITY_FAMILIAR)