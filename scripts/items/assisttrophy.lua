local this = {}
local mod = SomethingWicked
local game = mod.game

local bList = { CollectibleType.COLLECTIBLE_PLAN_C, CollectibleType.COLLECTIBLE_CLICKER, CollectibleType.COLLECTIBLE_R_KEY }
local rList = { [CollectibleType.COLLECTIBLE_DEATH_CERTIFICATE] = 0.15, [CollectibleType.COLLECTIBLE_GENESIS] = 0.25 }

mod:AddCallback(ModCallbacks.MC_USE_ITEM, function (_, _, _, player)
    
    local tempEffects = player:GetEffects()
    tempEffects:AddCollectibleEffect(CollectibleType.SOMETHINGWICKED_ASSIST_TROPHY, true, 3)
    player:GetData().sw_assistWisps = {}
    mod.sfx:Play(SoundEffect.SOUND_POWERUP1, 1, 0)
end, CollectibleType.SOMETHINGWICKED_ASSIST_TROPHY)

mod:AddCallback(ModCallbacks.MC_POST_PEFFECT_UPDATE, function (_, player)

    local p_data = player:GetData()
    if not player:IsExtraAnimationFinished() then
        return
    end
    local tempEffects = player:GetEffects()
    local s = tempEffects:GetCollectibleEffect(CollectibleType.SOMETHINGWICKED_ASSIST_TROPHY)

    if s ~= nil and s.Count > 0 then
        tempEffects:RemoveCollectibleEffect(CollectibleType.SOMETHINGWICKED_ASSIST_TROPHY)
        local c_rng = player:GetCollectibleRNG(CollectibleType.SOMETHINGWICKED_ASSIST_TROPHY)

        local c = -1
        while c < 0 or mod:UtilTableHasValue(bList) or (rList[c] and rList[c] < c_rng:RandomFloat()) do
            local pool = c_rng:RandomInt(ItemPoolType.NUM_ITEMPOOLS)
            c = game:GetItemPool():GetCollectible(pool, false)
        end

        local iconfig = Isaac.GetItemConfig()
        local ic = iconfig:GetCollectible(c)
        game:GetHUD():ShowItemText(player, ic)

        if ic.Type == ItemType.ITEM_ACTIVE then
            player:UseActiveItem(c)
        else
            p_data.sw_assistWisps = p_data.sw_assistWisps or {}
            p_data.sw_assistWisps[c] = (p_data.sw_assistWisps[c] or 0) + 1
        end

        mod.sfx:Play(SoundEffect.SOUND_SHELLGAME, 1, 0)
        if player:IsExtraAnimationFinished() then
            player:AnimateCollectible(c, "UseItem")
        end
    end
end)

mod:AddCustomCBack(mod.CustomCallbacks.SWCB_EVALUATE_TEMP_WISPS, function (_, player, data)
    if data.sw_assistWisps then
        for key, value in pairs(data.sw_assistWisps) do
            mod:AddItemWispForEval(player, key, value)
        end
    end
end)
mod:AddCallback(ModCallbacks.MC_POST_NEW_ROOM, function ()
    for index, player in ipairs(mod:UtilGetAllPlayers()) do
        local p_data = player:GetData()
        p_data.sw_assistWisps = {}
        mod:EvalutePWisps(player)
    end
end)
this.EIDEntries = {
    [CollectibleType.SOMETHINGWICKED_ASSIST_TROPHY] = {
        desc = "\1 Grants the effect of 4 random items for the current room",
        pools = { mod.encyclopediaLootPools.POOL_TREASURE, mod.encyclopediaLootPools.POOL_GREED_TREASURE }
    }
}
return this