local mod = SomethingWicked
local sfx = SFXManager()

local CurseDuration = 15
local WispCurseRadius = 100
local function OnCurse(ent)
    
    if ent:HasEntityFlags(EntityFlag.FLAG_NO_STATUS_EFFECTS) ~= true then
        mod:UtilAddCurse(ent, CurseDuration)
            
        local poof = Isaac.Spawn(EntityType.ENTITY_EFFECT, EffectVariant.POOF01, 0, ent.Position, Vector.Zero, ent)
        poof.Color = Color(0.4, 0.1, 0.4)
    end
end

local function UseItem(_, rng, player, flags)
    sfx:Play(SoundEffect.SOUND_VAMP_GULP, 1, 0)

    local allEnemies = Isaac.FindInRadius(Vector.Zero, 80000, 8)
    for key, ent in pairs(allEnemies) do
        OnCurse(ent)
    end
    
    return true
end


local function OnWispDie(_, entity)
    if entity.Variant == FamiliarVariant.WISP and entity.SubType == CollectibleType.SOMETHINGWICKED_CURSED_MUSHROOM then
        local nearbyEnemies = Isaac.FindInRadius(entity.Position, WispCurseRadius, 8)
        for key, ent in pairs(nearbyEnemies) do
            OnCurse(ent)
        end

        local poof = Isaac.Spawn(EntityType.ENTITY_EFFECT, EffectVariant.POOF02, 1, entity.Position, Vector.Zero, entity)
        local poof2 = Isaac.Spawn(EntityType.ENTITY_EFFECT, EffectVariant.POOF02, 2, entity.Position, Vector.Zero, entity)
        poof.Color = Color(0.4, 0.1, 0.4)
        poof2.Color = Color(0.4, 0.1, 0.4)
    end
end

local function LocustDidDamage(_, ent, amount, flags, source, dmgCooldown)
    
    local e_data = ent:GetData()
    local locust = source.Entity

    if locust ~= nil
    and locust.Type == EntityType.ENTITY_FAMILIAR
    and locust.Variant == FamiliarVariant.ABYSS_LOCUST
    and locust.SubType == CollectibleType.SOMETHINGWICKED_CURSED_MUSHROOM then
        if not ent:HasEntityFlags(EntityFlag.FLAG_NO_STATUS_EFFECTS) then
            mod:UtilAddCurse(ent, 1)
        end 
    end
end

SomethingWicked:AddPriorityCallback(ModCallbacks.MC_ENTITY_TAKE_DMG, CallbackPriority.LATE, LocustDidDamage)
SomethingWicked:AddCallback(ModCallbacks.MC_POST_ENTITY_KILL, OnWispDie, EntityType.ENTITY_FAMILIAR)
SomethingWicked:AddCallback(ModCallbacks.MC_USE_ITEM, UseItem, CollectibleType.SOMETHINGWICKED_CURSED_MUSHROOM)