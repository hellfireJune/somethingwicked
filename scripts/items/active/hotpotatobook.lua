local mod = SomethingWicked
local sfx = SFXManager()

local function used(_, id, rng, player, flags)
    local p_data = player:GetData()
    p_data.WickedPData.hotPotatoBuff = (p_data.WickedPData.hotPotatoBuff or 1) + 0.1
    sfx:Play(SoundEffect.SOUND_POWERUP1, 1, 0)
    return true
end
mod:AddCallback(ModCallbacks.MC_USE_ITEM, used, mod.ITEMS.HOT_POTATO_BOOK)

local function updateItem()
    local players = mod:AllPlayersWithCollectible(mod.ITEMS.HOT_POTATO_BOOK)

    for _, player in ipairs(players) do
        local charge, slot = mod:CheckPlayerForActiveData(player, mod.ITEMS.HOT_POTATO_BOOK)
        player:RemoveCollectible(mod.ITEMS.HOT_POTATO_BOOK)
        player:AddCollectible(mod.ITEMS.HOT_POTATO_BOOK, charge, false, slot)
    end
end

local function onRoomClear()
    local ic = Isaac.GetItemConfig()
    local i = ic:GetCollectible(mod.ITEMS.HOT_POTATO_BOOK)
    i.ChargeType = ItemConfig.CHARGE_SPECIAL
    updateItem()
    
end
mod:AddPriorityCallback(ModCallbacks.MC_PRE_PLAYER_TRIGGER_ROOM_CLEAR, 200, onRoomClear)

function mod:BeforeChargeItem()
    local ic = Isaac.GetItemConfig()
    local i = ic:GetCollectible(mod.ITEMS.HOT_POTATO_BOOK)
    i.ChargeType = ItemConfig.CHARGE_NORMAL
    updateItem()
    
    local players = mod:AllPlayersWithCollectible(mod.ITEMS.HOT_POTATO_BOOK)

    for _, player in ipairs(players) do
        if player:HasTrinket(TrinketType.TRINKET_WATCH_BATTERY) then
            local t_rng = player:GetTrinketRNG(TrinketType.TRINKET_WATCH_BATTERY)
            if t_rng:RandomFloat() < 0.05 then
                mod:ChargeFirstActiveOfType(player, mod.ITEMS.HOT_POTATO_BOOK)
            end
        end
    end
end