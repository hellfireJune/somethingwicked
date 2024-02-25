local this = {}

local roomsNeedToHeal = 2
local healAmount = 1
SomethingWicked:AddPriorityCallback(ModCallbacks.MC_ENTITY_TAKE_DMG, CallbackPriority.LATE, function (_, player)
    local p_data = player:GetData()
    p_data.somethingWicked_RegenRingDamagedThisRoom = true
end, EntityType.ENTITY_PLAYER)

SomethingWicked:AddCustomCBack(SomethingWicked.CustomCallbacks.SWCB_ON_ITEM_SHOULD_CHARGE, function (_, charges2add)
    local allPlayers = SomethingWicked.ItemHelpers:AllPlayersWithCollectible(mod.ITEMS.LANTERN_BATTERY)
    for _, player in ipairs(allPlayers) do
        local p_data = player:GetData()
        if p_data.somethingWicked_RegenRingDamagedThisRoom then
            p_data.WickedPData.ringOfRegenCharges = (p_data.WickedPData.ringOfRegenCharges or 0) + charges2add
            p_data.somethingWicked_RegenRingDamagedThisRoom = false

            if p_data.WickedPData.ringOfRegenCharges >= roomsNeedToHeal then
                p_data.WickedPData.ringOfRegenCharges = 0
                player:AddHearts(healAmount)
                SomethingWicked.sfx:Play(SoundEffect.SOUND_VAMP_GULP, 1, 0)
                Isaac.Spawn(EntityType.ENTITY_EFFECT, EffectVariant.HEART, 0, player.Position - Vector(0, 60), Vector.Zero, player)
                --HEART
            end
        end
    end
end)

this.EIDEntries = {
    [mod.ITEMS.REGEN_RING] = {
        desc = "↑ Clearing a room after taking damage in two seperate rooms will heal for 1 red heart#{{Heart}} Full health",
        pools = {SomethingWicked.encyclopediaLootPools.POOL_TREASURE,
    SomethingWicked.encyclopediaLootPools.POOL_ULTRA_SECRET, SomethingWicked.encyclopediaLootPools.POOL_GREED_TREASURE}
    }
}
return this