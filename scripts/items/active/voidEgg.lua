local mod = SomethingWicked
local sfx = SFXManager()

local HeartValues = {
    [HeartSubType.HEART_FULL] = 3,
    [HeartSubType.HEART_SCARED] = 3,
    [HeartSubType.HEART_HALF] = 1,
    [HeartSubType.HEART_DOUBLEPACK] = 6,
    [HeartSubType.HEART_BLENDED] = 3,
}

local function PickupCollision(_, entity, player)
    if entity.SubType ~= HeartSubType.HEART_FULL 
    and entity.SubType ~= HeartSubType.HEART_HALF 
    and entity.SubType ~= HeartSubType.HEART_SCARED
    and entity.SubType ~= HeartSubType.HEART_DOUBLEPACK 
    and entity.SubType ~= HeartSubType.HEART_BLENDED then
        return
    end

    player = player:ToPlayer()
    if player then
        local charge, slot = mod:CheckPlayerForActiveData(player, mod.ITEMS.VOID_EGG)
        if slot ~= -1 and charge < (player:HasCollectible(CollectibleType.COLLECTIBLE_BATTERY) and 6 or 3) then
            player:SetActiveCharge(charge + HeartValues[entity.SubType], slot)
            entity:Remove()
            
            local poof = Isaac.Spawn(EntityType.ENTITY_EFFECT, EffectVariant.POOF01, 0, entity.Position, Vector.Zero, entity)
            poof.Color = Color(0.1, 0.1, 0.1)
            Isaac.Spawn(EntityType.ENTITY_EFFECT, EffectVariant.BATTERY, 0, entity.Position - Vector(0, 60), Vector.Zero, entity)
            sfx:Play(SoundEffect.SOUND_BLACK_POOF, 1, 0)
            sfx:Play(SoundEffect.SOUND_BEEP)

            return true
        end
    end
end

SomethingWicked:AddCallback(ModCallbacks.MC_PRE_PICKUP_COLLISION, PickupCollision, PickupVariant.PICKUP_HEART)

local function WispTearUpdate(_, tear)
    if tear.SpawnerType ~= EntityType.ENTITY_FAMILIAR
    or tear.SpawnerVariant ~= FamiliarVariant.WISP
    or tear.SpawnerEntity.SubType ~= mod.ITEMS.VOID_EGG then
        return
    end

    local rng = tear:GetDropRNG()
    if #Isaac.FindByType(EntityType.ENTITY_FAMILIAR, FamiliarVariant.BLUE_FLY) < #Isaac.FindByType(EntityType.ENTITY_FAMILIAR, FamiliarVariant.WISP, mod.ITEMS.VOID_EGG) then
        local subtype = rng:RandomInt(5) + 1
        for ii = 1, 1 + (subtype == LocustSubtypes.LOCUST_OF_CONQUEST and rng:RandomInt(3) or 0), 1 do
            Isaac.Spawn(EntityType.ENTITY_FAMILIAR, FamiliarVariant.BLUE_FLY, subtype, tear.Position, Vector.Zero, tear)
        end
    end
    tear:Remove()
end

SomethingWicked:AddCallback(ModCallbacks.MC_POST_TEAR_INIT, WispTearUpdate)