local this = {}
CollectibleType.SOMETHINGWICKED_VOID_EGG = Isaac.GetItemIdByName("Void Egg")
this.HeartValues = {
    [HeartSubType.HEART_FULL] = 3,
    [HeartSubType.HEART_SCARED] = 3,
    [HeartSubType.HEART_HALF] = 1,
    [HeartSubType.HEART_DOUBLEPACK] = 6,
    [HeartSubType.HEART_BLENDED] = 3,
}

function this:UseItem(_, rng, player)
    SomethingWicked.FamiliarHelpers:AddLocusts(player, rng:RandomInt(2) + 1, rng)

    return true
end

function this:PickupCollision(entity, player)
    if entity.SubType ~= HeartSubType.HEART_FULL 
    and entity.SubType ~= HeartSubType.HEART_HALF 
    and entity.SubType ~= HeartSubType.HEART_SCARED
    and entity.SubType ~= HeartSubType.HEART_DOUBLEPACK 
    and entity.SubType ~= HeartSubType.HEART_BLENDED then
        return
    end

    player = player:ToPlayer()
    if player then
        local charge, slot = SomethingWicked.ItemHelpers:CheckPlayerForActiveData(player, CollectibleType.SOMETHINGWICKED_VOID_EGG)
        if slot ~= -1 and charge < (player:HasCollectible(CollectibleType.COLLECTIBLE_BATTERY) and 6 or 3) then
            player:SetActiveCharge(charge + this.HeartValues[entity.SubType], slot)
            entity:Remove()
            
            local sfx = SomethingWicked.sfx
            local poof = Isaac.Spawn(EntityType.ENTITY_EFFECT, EffectVariant.POOF01, 0, entity.Position, Vector.Zero, entity)
            poof.Color = Color(0.1, 0.1, 0.1)
            Isaac.Spawn(EntityType.ENTITY_EFFECT, EffectVariant.BATTERY, 0, entity.Position - Vector(0, 60), Vector.Zero, entity)
            sfx:Play(SoundEffect.SOUND_BLACK_POOF, 1, 0)
            sfx:Play(SoundEffect.SOUND_BEEP)

            return true
        end
    end
end

SomethingWicked:AddCallback(ModCallbacks.MC_USE_ITEM, this.UseItem, CollectibleType.SOMETHINGWICKED_VOID_EGG)
SomethingWicked:AddCallback(ModCallbacks.MC_PRE_PICKUP_COLLISION, this.PickupCollision, PickupVariant.PICKUP_HEART)

function this:WispTearUpdate(tear)
    if tear.SpawnerType ~= EntityType.ENTITY_FAMILIAR
    or tear.SpawnerVariant ~= FamiliarVariant.WISP
    or tear.SpawnerEntity.SubType ~= CollectibleType.SOMETHINGWICKED_VOID_EGG then
        return
    end

    local rng = tear:GetDropRNG()
    if #Isaac.FindByType(EntityType.ENTITY_FAMILIAR, FamiliarVariant.BLUE_FLY) < #Isaac.FindByType(EntityType.ENTITY_FAMILIAR, FamiliarVariant.WISP, CollectibleType.SOMETHINGWICKED_VOID_EGG) then
        local subtype = rng:RandomInt(5) + 1
        for ii = 1, 1 + (subtype == LocustSubtypes.LOCUST_OF_CONQUEST and rng:RandomInt(3) or 0), 1 do
            Isaac.Spawn(EntityType.ENTITY_FAMILIAR, FamiliarVariant.BLUE_FLY, subtype, tear.Position, Vector.Zero, tear)
        end
    end
    tear:Remove()
end

SomethingWicked:AddCallback(ModCallbacks.MC_POST_TEAR_INIT, this.WispTearUpdate)

this.EIDEntries = {
    [CollectibleType.SOMETHINGWICKED_VOID_EGG] = {
        desc = "Spawns 1-3 locusts on use# !!! Picking up a red heart while this item is uncharged will instead charge this item",
        pools = {
            SomethingWicked.encyclopediaLootPools.POOL_DEVIL,
            SomethingWicked.encyclopediaLootPools.POOL_CURSE,
            SomethingWicked.encyclopediaLootPools.POOL_GREED_DEVIL,
            SomethingWicked.encyclopediaLootPools.POOL_DEMON_BEGGAR,
            SomethingWicked.encyclopediaLootPools.POOL_GREED_CURSE,
            SomethingWicked.encyclopediaLootPools.POOL_CRANE_GAME
        },
        encycloDesc = SomethingWicked:UtilGenerateWikiDesc({"Spawns 1-3 locust companions on use", "Picking up a red heart while this item is uncharged will consume the heart and instead charge this item"}, "INFINITY, YES!")
    }
}
return this