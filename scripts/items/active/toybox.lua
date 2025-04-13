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
    tempEffects:AddCollectibleEffect(mod.ITEMS.TOYBOX, true, 3)
    return { Remove = true}
end

function mod:toyboxTick(player)
    if not player:IsExtraAnimationFinished() then
        return
    end
    local tempEffects = player:GetEffects()
    local p_data = player:GetData()
    local stacks = tempEffects:GetCollectibleEffect(mod.ITEMS.TOYBOX) 

    if stacks ~= nil and stacks.Count > 0
    and (p_data.WickedPData.toyboxTrinket == nil) then
        local trinket = game:GetItemPool():GetTrinket()
        p_data.WickedPData.toyboxTrinket = trinket
        player:AnimateTrinket(trinket, "UseItem")
        tempEffects:RemoveCollectibleEffect(mod.ITEMS.TOYBOX)
        
        sfx:Play(SoundEffect.SOUND_SHELLGAME, 1, 0)
        game:GetHUD():ShowItemText(player, Isaac.GetItemConfig():GetTrinket(trinket))
    end
    if p_data.WickedPData.toyboxTrinket ~= nil then
        player:AddSmeltedTrinket(p_data.WickedPData.toyboxTrinket)
        p_data.WickedPData.toyboxTrinket = nil
    end
end

SomethingWicked:AddCallback(ModCallbacks.MC_USE_ITEM, UseItem, mod.ITEMS.TOYBOX)
SomethingWicked:AddCallback(ModCallbacks.MC_POST_PEFFECT_UPDATE, mod.toyboxTick)