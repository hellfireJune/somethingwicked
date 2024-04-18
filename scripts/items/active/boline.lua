local mod = SomethingWicked
local sfx = SFXManager()

local function ItemUse(_, _, _, player, flags)
    return mod:HoldItemUseHelper(player, flags, mod.ITEMS.BOLINE)
end
SomethingWicked:AddCallback(ModCallbacks.MC_USE_ITEM, ItemUse, mod.ITEMS.BOLINE)

local scaleMult = 1.4
local function PlayerUpdate(_, player)
    if mod:HoldItemUpdateHelper(player, mod.ITEMS.BOLINE) then
        local direction = mod:GetFireVector(player) * 4
        local effect = Isaac.Spawn(EntityType.ENTITY_EFFECT, EffectVariant.SOMETHINGWICKED_MOTV_HELPER, 1, player.Position, direction, player)
        local void = Isaac.Spawn(EntityType.ENTITY_LASER, 1, LaserSubType.LASER_SUBTYPE_RING_FOLLOW_PARENT, player.Position, Vector.Zero, player):ToLaser()
        effect.Visible = false
        void.Parent = effect
        void.Radius = 80
        void.Timeout = 76 
        void:AddTearFlags(TearFlags.TEAR_PULSE)
        void.CollisionDamage = player.Damage * 2
        
        void.Size = void.Size*scaleMult
        void:Update()
        void.SpriteScale = Vector(scaleMult, scaleMult)
        void.SizeMulti = Vector(scaleMult, scaleMult)

        sfx:Play(SoundEffect.SOUND_MAW_OF_VOID, 1, 0)
    end
end
SomethingWicked:AddCallback(ModCallbacks.MC_POST_PEFFECT_UPDATE, PlayerUpdate)

local function EffectUpdate(_, effect)
    if effect.SubType == 1 then
        effect.Velocity = mod:Lerp(effect.Velocity, Vector.Zero, 0.2)
    end
end
SomethingWicked:AddCallback(ModCallbacks.MC_POST_EFFECT_UPDATE, EffectUpdate, EffectVariant.SOMETHINGWICKED_MOTV_HELPER)

function mod:BolineTakeDMG(player)
    if player:HasCollectible(mod.ITEMS.BOLINE) then
        SomethingWicked:ChargeFirstActiveOfType(player, mod.ITEMS.BOLINE, 2, false)
    end
end


function mod:PostBolineWispTakeDamage(wisp, collectible)
    if collectible ~= mod.ITEMS.BOLINE then
        return
    end

    local void = Isaac.Spawn(EntityType.ENTITY_LASER, 1, LaserSubType.LASER_SUBTYPE_RING_FOLLOW_PARENT, wisp.Position, Vector.Zero, wisp):ToLaser()
    if wisp:HasMortalDamage() then    
        local effect = Isaac.Spawn(EntityType.ENTITY_EFFECT, EffectVariant.SOMETHINGWICKED_MOTV_HELPER, 0, wisp.Position, Vector.Zero, wisp)
        effect.Visible = false
        void.Parent = effect
    else
        void.Parent = wisp
    end
    void.Radius = 40
    void.Timeout = 46
    void:AddTearFlags(TearFlags.TEAR_PULSE)
    void.CollisionDamage = 7
    --SomethingWicked.sfx:Play(SoundEffect.SOUND_MAW_OF_VOID, 1, 0)
    
    local spl = Isaac.Spawn(1000, 2, 1, wisp.Position + Vector(0, 1), Vector.Zero, wisp)
    spl.Color = Color(0, 0, 0)
end