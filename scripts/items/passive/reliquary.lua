local mod = SomethingWicked
local sfx = SFXManager()

mod:AddCustomCBack(mod.CustomCallbacks.SWCB_PICKUP_ITEM, function (_, player, room, id)
    if not player:HasCollectible(mod.ITEMS.RELIQUARY) then
        return
    end

    local iconfig = Isaac.GetItemConfig()
    local conf = iconfig:GetCollectible(id)

    local hearts = conf.AddMaxHearts
    if hearts > 0 then
        sfx:Play(SoundEffect.SOUND_HOLY)
            player:AddSoulHearts(hearts)

            local p_data = player:GetData()
            p_data.WickedPData.reliqBuff = (p_data.WickedPData.reliqBuff or 0) + hearts
    end
end)