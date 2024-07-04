local mod = SomethingWicked
local game = Game()
local sfx = SFXManager()

local bList = { CollectibleType.COLLECTIBLE_PLAN_C, CollectibleType.COLLECTIBLE_CLICKER, CollectibleType.COLLECTIBLE_R_KEY }
local rList = { [CollectibleType.COLLECTIBLE_DEATH_CERTIFICATE] = 0.15, [CollectibleType.COLLECTIBLE_GENESIS] = 0.25 }

mod.AssistTrophyBlacklist = {
    CollectibleType.COLLECTIBLE_LITTLE_CHAD,
    CollectibleType.COLLECTIBLE_LOST_SOUL,
    CollectibleType.COLLECTIBLE_BUM_FRIEND,
    CollectibleType.COLLECTIBLE_CHARGED_BABY,
    CollectibleType.COLLECTIBLE_DARK_BUM,
}

mod:AddCallback(ModCallbacks.MC_USE_ITEM, function (_, _, _, player)
    local tempEffects = player:GetEffects()
    tempEffects:AddCollectibleEffect(mod.ITEMS.ITEM_BOX, true, 3)
    player:GetData().sw_mysteryWisps = {}
    sfx:Play(SoundEffect.SOUND_POWERUP1, 1, 0)

    return true
end, mod.ITEMS.ITEM_BOX)

mod:AddCallback(ModCallbacks.MC_POST_PEFFECT_UPDATE, function (_, player)
    local p_data = player:GetData()
    local tempEffects = player:GetEffects()
    local s = tempEffects:GetCollectibleEffect(mod.ITEMS.ITEM_BOX)

    while s ~= nil and s.Count > 0 do
        tempEffects:RemoveCollectibleEffect(mod.ITEMS.ITEM_BOX)
        local c_rng = player:GetCollectibleRNG(mod.ITEMS.ITEM_BOX)

        local c = -1
        while c < 0 or mod:UtilTableHasValue(bList) or (rList[c] and rList[c] < c_rng:RandomFloat()) do
            local pool = mod:GetRandomPool(c_rng)
            c = game:GetItemPool():GetCollectible(pool, false)
        end

        local iconfig = Isaac.GetItemConfig()
        local ic = iconfig:GetCollectible(c)
        game:GetHUD():ShowItemText(player, ic)

        if ic.Type == ItemType.ITEM_ACTIVE then
            player:UseActiveItem(c)
        else
            p_data.sw_mysteryWisps = p_data.sw_mysteryWisps or {}
            p_data.sw_mysteryWisps[c] = (p_data.sw_mysteryWisps[c] or 0) + 1
        end

        --[[sfx:Play(SoundEffect.SOUND_SHELLGAME, 1, 0)
        if player:IsExtraAnimationFinished() then
            player:AnimateCollectible(c, "UseItem")
        end]]
    end
end)

mod:AddCallback(ModCallbacks.MC_USE_ITEM, function (_, _, c_rng, player)
    local c = -1
    local ipool = game:GetItemPool()
    local iconfig = Isaac.GetItemConfig()

    local ic = nil
    while c < 0 or mod:UtilTableHasValue(mod.AssistTrophyBlacklist) or ic == nil or ic.Type == ItemType.ITEM_ACTIVE do
        c = ipool:GetCollectible(ItemPoolType.POOL_BABY_SHOP, false)
        ic = iconfig:GetCollectible(c)
    end

    local p_data = player:GetData()
    p_data.sw_assistItem = c

    sfx:Play(SoundEffect.SOUND_POWERUP1, 1, 0)
    player:AnimateCollectible(c, "UseItem")
    
    mod:EvalutePWisps(player)
end, mod.ITEMS.ASSIST_TROPHY)

mod:AddCustomCBack(mod.CustomCallbacks.SWCB_EVALUATE_TEMP_WISPS, function (_, player, data)
    if data.sw_mysteryWisps then
        for key, value in pairs(data.sw_mysteryWisps) do
            mod:AddItemWispForEval(player, key, value)
        end
    end
    if data.sw_assistItem and data.sw_assistItem > 0 then
        mod:AddItemWispForEval(player, data.sw_assistItem, 1)
    end
end)
mod:AddCallback(ModCallbacks.MC_POST_NEW_ROOM, function ()
    for index, player in ipairs(mod:UtilGetAllPlayers()) do
        local p_data = player:GetData()
        p_data.sw_mysteryWisps = {}
        p_data.sw_assistItem = -1
        mod:EvalutePWisps(player)
    end
end)