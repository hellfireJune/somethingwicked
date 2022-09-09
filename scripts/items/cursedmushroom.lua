local this = {}
CollectibleType.SOMETHINGWICKED_CURSED_MUSHROOM = Isaac.GetItemIdByName("Cursed Mushroom")
this.CurseDuration = 18
this.WispCurseRadius = 100

function this:UseItem(_, rng, player, flags)
    SomethingWicked.sfx:Play(SoundEffect.SOUND_VAMP_GULP, 1, 0)

    local allEnemies = Isaac.FindInRadius(Vector.Zero, 8000, 8)
    for key, ent in pairs(allEnemies) do
        this:OnCurse(ent)
    end
    
    return true
end

function this:OnCurse(ent)
    
    if ent:HasEntityFlags(EntityFlag.FLAG_NO_STATUS_EFFECTS) ~= true then
        SomethingWicked:UtilAddCurse(ent, this.CurseDuration)
            
        local poof = Isaac.Spawn(EntityType.ENTITY_EFFECT, EffectVariant.POOF01, 0, ent.Position, Vector.Zero, ent)
        poof.Color = Color(0.4, 0.1, 0.4)
    end
end

function this:OnWispDie(entity)
    if entity.Variant == FamiliarVariant.WISP and entity.SubType == CollectibleType.SOMETHINGWICKED_CURSED_MUSHROOM then
        local nearbyEnemies = Isaac.FindInRadius(entity.Position, 100, 8)
        for key, ent in pairs(nearbyEnemies) do
            this:OnCurse(ent)
        end

        local poof = Isaac.Spawn(EntityType.ENTITY_EFFECT, EffectVariant.POOF02, 1, entity.Position, Vector.Zero, entity)
        local poof2 = Isaac.Spawn(EntityType.ENTITY_EFFECT, EffectVariant.POOF02, 2, entity.Position, Vector.Zero, entity)
        poof.Color = Color(0.4, 0.1, 0.4)
        poof2.Color = Color(0.4, 0.1, 0.4)
    end
end

SomethingWicked:AddCallback(ModCallbacks.MC_POST_ENTITY_KILL, this.OnWispDie, EntityType.ENTITY_FAMILIAR)
SomethingWicked:AddCallback(ModCallbacks.MC_USE_ITEM, this.UseItem, CollectibleType.SOMETHINGWICKED_CURSED_MUSHROOM)

this.EIDEntries = {
    [CollectibleType.SOMETHINGWICKED_CURSED_MUSHROOM] = {
        desc = "Upon use, gives all enemies in the room a curse debuff#Cursed enemies will take 1.5x damage, and the curse effect will last for "..this.CurseDuration.." seconds",
        pools = {
            SomethingWicked.encyclopediaLootPools.POOL_TREASURE,
            SomethingWicked.encyclopediaLootPools.POOL_CRANE_GAME,
            SomethingWicked.encyclopediaLootPools.POOL_GREED_TREASURE,
        },
        encycloDesc = SomethingWicked:UtilGenerateWikiDesc({"Upon use, gives all enemies in the room a curse debuff","Cursed enemies will take 1.5x damage, and the curse effect will last for "..this.CurseDuration.." seconds"})
    }
}
return this