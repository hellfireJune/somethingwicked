local this = {}
CollectibleType.SOMETHINGWICKED_BABY_MANDRAKE = Isaac.GetItemIdByName("Baby Mandrake")
EffectVariant.SOMETHINGWICKED_MANDRAKE_SCREAM_LARGE = Isaac.GetEntityVariantByName("Mandrake Scream (Large)")

function this:UseItem(_, _, player, flags)
    Isaac.Spawn(EntityType.ENTITY_EFFECT, EffectVariant.SOMETHINGWICKED_MANDRAKE_SCREAM_LARGE, 0, player.Position, Vector.Zero, player)
    
    local nearbyEnemies = Isaac.FindInRadius(player.Position, 140, 8)
    for key, ent in pairs(nearbyEnemies) do
        if not ent:HasEntityFlags(EntityFlag.FLAG_NO_STATUS_EFFECTS) then
            ent:AddFreeze(EntityRef(player), 90)
        end
        ent:TakeDamage(25, 0, EntityRef(player), 1)
    end
    SomethingWicked.sfx:Play(SoundEffect.SOUND_MULTI_SCREAM)

    return true
end

SomethingWicked:AddCallback(ModCallbacks.MC_USE_ITEM, this.UseItem, CollectibleType.SOMETHINGWICKED_BABY_MANDRAKE)
this.EIDEntries = {
    [CollectibleType.SOMETHINGWICKED_BABY_MANDRAKE] = {
        desc = "im women",
        Hide = true,
    }
}
return this