local this = {}
local mod = SomethingWicked
CollectibleType.SOMETHINGWICKED_RELIQUARY = Isaac.GetItemIdByName("Reliquary")

mod:AddCustomCBack(mod.CustomCallbacks.SWCB_PICKUP_ITEM, function (_, player, room, id)
    if not player:HasCollectible(CollectibleType.SOMETHINGWICKED_RELIQUARY) then
        return
    end

    local iconfig = Isaac.GetItemConfig()
    local conf = iconfig:GetCollectible(id)

    local hearts = conf.AddMaxHearts
    if hearts > 0 then
        mod.sfx:Play(SoundEffect.SOUND_HOLY)
        mod:UtilScheduleForUpdate(function ()
            player:AddSoulHearts(hearts)
            SomethingWicked.sfx:Play(SoundEffect.SOUND_VAMP_GULP, 1, 0)

            local p_data = player:GetData()
            p_data.SomethingWickedPData.reliqBuff = (p_data.SomethingWickedPData.reliqBuff or 0) + hearts
        end, 15, ModCallbacks.MC_POST_UPDATE)
    end
end)

function this:PEffectUpdate(player)
    local p_data = player:GetData()
    if player.QueuedItem.Item
    and not player.QueuedItem.Touched then
        if p_data.sw_hasResetReliquAnim ~= true then
            p_data.sw_hasResetReliquAnim = true

            player:AnimateCollectible(player.QueuedItem.Item.ID, "Pickup", "Idle")
        end
    else
        p_data.sw_hasResetReliquAnim = false
    end
end
mod:AddCallback(ModCallbacks.MC_POST_PEFFECT_UPDATE, this.PEffectUpdate)

local fireDelay = 0.25
mod:AddCallback(ModCallbacks.MC_EVALUATE_CACHE, function (_, player)
    local p_data = player:GetData()
    if p_data.SomethingWickedPData.reliqBuff then
        player.MaxFireDelay = mod.StatUps:TearsUp(player, 0, p_data.SomethingWickedPData.reliqBuff*fireDelay)
    end
end, CacheFlag.CACHE_FIREDELAY)

this.EIDEntries = {
    [CollectibleType.SOMETHINGWICKED_RELIQUARY] = {
        desc = "Even better items?",
        Hide = true,
    }
}
return this