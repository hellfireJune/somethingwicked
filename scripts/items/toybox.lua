local this = {}
CollectibleType.SOMETHINGWICKED_TOYBOX = Isaac.GetItemIdByName("Toybox")

function this:UseItem(_, _, player)
    --[[for i = 1, 4, 1 do
        local trinket = SomethingWicked.game:GetItemPool():GetTrinket()
        AMostWickedCollectionPt1:UtilAddSmeltedTrinket(trinket, player)
    end

    SomethingWicked.sfx:Play(SoundEffect.SOUND_CHOIR_UNLOCK, 1, 0)]]
    local tempEffects = player:GetEffects()
    tempEffects:AddCollectibleEffect(CollectibleType.SOMETHINGWICKED_TOYBOX, true, 3)
    return { Remove = true}
end

function this:PEffectUpdate(player)
    local tempEffects = player:GetEffects()
    local p_data = player:GetData()
    local stacks = tempEffects:GetCollectibleEffect(CollectibleType.SOMETHINGWICKED_TOYBOX) 

    if stacks ~= nil and stacks.Count > 0
    and (p_data.SomethingWickedPData.toyboxTrinket == nil) then
        local trinket = SomethingWicked.game:GetItemPool():GetTrinket()
        p_data.SomethingWickedPData.toyboxTrinket = trinket
        player:AnimateTrinket(trinket, "UseItem")
        tempEffects:RemoveCollectibleEffect(CollectibleType.SOMETHINGWICKED_TOYBOX)
        
        SomethingWicked.sfx:Play(SoundEffect.SOUND_SHELLGAME, 1, 0)
        SomethingWicked.game:GetHUD():ShowItemText(player, Isaac.GetItemConfig():GetTrinket(trinket))
    end
    if p_data.SomethingWickedPData.toyboxTrinket ~= nil
    and player:IsExtraAnimationFinished() then
        SomethingWicked:UtilAddSmeltedTrinket(p_data.SomethingWickedPData.toyboxTrinket, player)
        p_data.SomethingWickedPData.toyboxTrinket = nil
    end
end

SomethingWicked:AddCallback(ModCallbacks.MC_USE_ITEM, this.UseItem, CollectibleType.SOMETHINGWICKED_TOYBOX)
SomethingWicked:AddCallback(ModCallbacks.MC_POST_PEFFECT_UPDATE, this.PEffectUpdate)

this.EIDEntries = {
    [CollectibleType.SOMETHINGWICKED_TOYBOX] = {
        desc = "Smelts four random trinkets onto you",
        pools = {
            SomethingWicked.encyclopediaLootPools.POOL_SHOP,
            SomethingWicked.encyclopediaLootPools.POOL_GOLDEN_CHEST,
            SomethingWicked.encyclopediaLootPools.POOL_KEY_MASTER,
            SomethingWicked.encyclopediaLootPools.POOL_GREED_SHOP,
        },
        encycloDesc = SomethingWicked:UtilGenerateWikiDesc({"Smelts four random trinkets onto you on use"})
    }
}
return this