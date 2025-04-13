local mod = SomethingWicked
local sfx = SFXManager()
local copiesToAdd = 2

local function zanyVFX(items, player)
    sfx:Play(SoundEffect.SOUND_POWERUP1, 1, 0)
    for i = 1, 2, 1 do
        local item = items[i]
        local effect = mod:SpawnStandaloneItemPopup(item, mod.ItemPopupSubtypes.STANDALONE_WITH_VEL, player.Position, player)
        effect.Velocity = Vector((i == 1 and i or -1)/100, 0)
    end
end
local function UseItem(_, id, rng, player, flags)
    local iConf = Isaac.GetItemConfig()
    local allItemIds = iConf:GetCollectibles().Size - 1

    local allFamiliars = {}
    for i = 1, allItemIds, 1 do
        local item = iConf:GetCollectible(i)
        if item ~= nil and not item.Hidden and not item:HasTags(ItemConfig.TAG_QUEST) and item.Type == ItemType.ITEM_FAMILIAR then
            for ii = 1, player:GetCollectibleNum(i), 1 do
                table.insert(allFamiliars, i)
            end
        end
    end

    local pType = player:GetPlayerType()
    if pType == PlayerType.PLAYER_LILITH then
        table.insert(allFamiliars, CollectibleType.COLLECTIBLE_INCUBUS)
    end

    if #allFamiliars > 0 then
        local p_data = player:GetData()

        local items = {}
        for i = 1, copiesToAdd, 1 do
            local item = mod:GetRandomElement(allFamiliars, rng)
            table.insert(items, item)
        end

        p_data.WickedPData.dupedFamiliars = p_data.WickedPData.dupedFamiliars or {}
        table.insert(p_data.WickedPData.dupedFamiliars, items)
        player:AddCollectible(mod.ITEMS.SEED_OF_EDEN_PASSIVE)
        zanyVFX(items, player)
        return { Remove = true, ShowAnim = true }
    else
        return { Discharge = false, ShowAnim = true }
    end
end

mod:AddCallback(ModCallbacks.MC_USE_ITEM, UseItem, mod.ITEMS.SEED_OF_EDEN)

mod:AddCallback(ModCallbacks.MC_POST_TRIGGER_COLLECTIBLE_REMOVED, function (_, player)
    local p_data = player:GetData()
    if p_data.WickedPData.dupedFamiliars then
        table.remove(p_data.WickedPData.dupedFamiliars, 1)
    end
end, mod.ITEMS.SEED_OF_EDEN_PASSIVE)

mod:AddCustomCBack(mod.CustomCallbacks.SWCB_EVALUATE_TEMP_WISPS, function (_, player, data)
    if data.WickedPData.dupedFamiliars then
        for _, pair in ipairs(data.WickedPData.dupedFamiliars) do
            
            for _, value in pairs(pair) do
                mod:AddItemWispForEval(player, value)
            end
        end
    end
end)