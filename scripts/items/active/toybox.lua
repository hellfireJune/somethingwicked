local mod = SomethingWicked
local sfx = SFXManager()
local game = Game()

local function UseItem(_, _, _, player)
    --[[for i = 1, 4, 1 do
        local trinket = SomethingWicked.game:GetItemPool():GetTrinket()
        AMostWickedCollectionPt1:UtilAddSmeltedTrinket(trinket, player)
    end]]

    sfx:Play(SoundEffect.SOUND_CHOIR_UNLOCK, 1, 0)
    local tempEffects = player:GetEffects()
    tempEffects:AddCollectibleEffect(CollectibleType.SOMETHINGWICKED_TOYBOX, true, 3)
    return { Remove = true}
end

local function PEffectUpdate(_, player)
    if not player:IsExtraAnimationFinished() then
        return
    end
    local tempEffects = player:GetEffects()
    local p_data = player:GetData()
    local stacks = tempEffects:GetCollectibleEffect(CollectibleType.SOMETHINGWICKED_TOYBOX) 

    if stacks ~= nil and stacks.Count > 0
    and (p_data.SomethingWickedPData.toyboxTrinket == nil) then
        local trinket = SomethingWicked.game:GetItemPool():GetTrinket()
        p_data.SomethingWickedPData.toyboxTrinket = trinket
        player:AnimateTrinket(trinket, "UseItem")
        tempEffects:RemoveCollectibleEffect(CollectibleType.SOMETHINGWICKED_TOYBOX)
        
        sfx:Play(SoundEffect.SOUND_SHELLGAME, 1, 0)
        game:GetHUD():ShowItemText(player, Isaac.GetItemConfig():GetTrinket(trinket))
    end
    if p_data.SomethingWickedPData.toyboxTrinket ~= nil then
        mod:UtilAddSmeltedTrinket(p_data.SomethingWickedPData.toyboxTrinket, player)
        p_data.SomethingWickedPData.toyboxTrinket = nil
    end
end

SomethingWicked:AddCallback(ModCallbacks.MC_USE_ITEM, UseItem, CollectibleType.SOMETHINGWICKED_TOYBOX)
SomethingWicked:AddCallback(ModCallbacks.MC_POST_PEFFECT_UPDATE, PEffectUpdate)