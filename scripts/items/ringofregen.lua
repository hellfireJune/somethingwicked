local this = {}
CollectibleType.SOMETHINGWICKED_REGEN_RING = Isaac.GetItemIdByName("Ring of Regeneration")

local roomsNeedToHeal = 2
local healAmount = 1
SomethingWicked:AddPriorityCallback(ModCallbacks.MC_ENTITY_TAKE_DMG, CallbackPriority.LATE, function (_, player)
    local p_data = player:GetData()
    p_data.somethingWicked_RegenRingDamagedThisRoom = true
end, EntityType.ENTITY_PLAYER)

SomethingWicked:AddCustomCBack(SomethingWicked.CustomCallbacks.SWCB_ON_ITEM_SHOULD_CHARGE, function (_, charges2add)
    local allPlayers = SomethingWicked.ItemHelpers:AllPlayersWithCollectible(CollectibleType.SOMETHINGWICKED_LANTERN_BATTERY)
    for _, player in ipairs(allPlayers) do
        local p_data = player:GetData()
        if p_data.somethingWicked_RegenRingDamagedThisRoom then
            p_data.SomethingWickedPData.ringOfRegenCharges = (p_data.SomethingWickedPData.ringOfRegenCharges or 0) + charges2add
            p_data.somethingWicked_RegenRingDamagedThisRoom = false

            if p_data.SomethingWickedPData.ringOfRegenCharges >= roomsNeedToHeal then
                p_data.SomethingWickedPData.ringOfRegenCharges = 0
                player:AddHearts(healAmount)
                SomethingWicked.sfx:Play(SoundEffect.SOUND_VAMP_GULP, 1, 0)
                Isaac.Spawn(EntityType.ENTITY_EFFECT, EffectVariant.HEART, 0, player.Position - Vector(0, 60), Vector.Zero, player)
                --HEART
            end
        end
    end
end)

this.EIDEntries = {
    [CollectibleType.SOMETHINGWICKED_REGEN_RING] = {
        desc = "Regenerates",
        Hide = true,
    }
}
return this