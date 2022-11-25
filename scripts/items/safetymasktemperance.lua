local this = {}
CollectibleType.SOMETHINGWICKED_TEMPERANCE = Isaac.GetItemIdByName("Temperance")
TrinketType.SOMETHINGWICKED_SURGICAL_MASK = Isaac.GetTrinketIdByName("Surgical Mask")

function this:OnBloodDMG(player, amount, flags, source, dmgCooldown)
    local sourceEnt = source.Entity
    if not sourceEnt then
        return
    end

    player = player:ToPlayer()
    if not player then
        return
    end

    if sourceEnt.Type == EntityType.ENTITY_SLOT
    and (sourceEnt.Variant == SomethingWicked.MachineVariant.MACHINE_BLOOD
    or sourceEnt.Variant == SomethingWicked.MachineVariant.MACHINE_DEVIL_BEGGAR) then
        if player:HasTrinket(TrinketType.SOMETHINGWICKED_SURGICAL_MASK) then
            local t_rng = player:GetTrinketRNG(TrinketType.SOMETHINGWICKED_SURGICAL_MASK)
            if t_rng:RandomFloat() < 0.33 then
                local color = Color(1, 1, 1, 1, 0.5)
                player:SetColor(color, 8, 3, true, false)
                return false
            end
        end
    end
end

SomethingWicked:AddCallback(ModCallbacks.MC_ENTITY_TAKE_DMG, this.OnBloodDMG, EntityType.ENTITY_PLAYER)

this.EIDEntries = {
    [TrinketType.SOMETHINGWICKED_SURGICAL_MASK] = {
        isTrinket = true,
        desc = "33% chance to not take damage when using a blood donation machine"
    }
}
return this