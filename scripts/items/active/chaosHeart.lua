local mod = SomethingWicked
local game = Game()
local sfx = SFXManager()

local MinFailUse, MaxSucceedUse, framesAfter = 5, 9, 12 -- i learnt this trick from ~~fiendfolio~~ erfly
local function UseItem(_, _, rng, player, flags)
    if flags & UseFlag.USE_CARBATTERY ~= 0 then
        player:AddHearts(1)
        return
    end
    local p_data = player:GetData()

    if p_data.WickedPData.chaosHeart_MarkedForDetonate then
        return
    end

    p_data.WickedPData.chaosHeart_TimesUsed = (p_data.WickedPData.chaosHeart_TimesUsed or 0) + 1

    local fail = rng:RandomInt(MaxSucceedUse - MinFailUse) + MinFailUse
    if p_data.WickedPData.chaosHeart_TimesUsed < fail then
        --succeed
        player:AddHearts(2)
        sfx:Play(SoundEffect.SOUND_VAMP_GULP, 1, 0)
        return true
    end
    p_data.WickedPData.chaosHeart_MarkedForDetonate = player.FrameCount
    player:AnimateCollectible(mod.ITEMS.CHAOS_HEART , "LiftItem", "PlayerPickupSparkle")
    --fail
end

local function PlayerUpdate(_, player)
    local p_data = player:GetData()

    if p_data.WickedPData.chaosHeart_MarkedForDetonate == nil then
        return
    end

    local frameDifference = player.FrameCount - p_data.WickedPData.chaosHeart_MarkedForDetonate
    --print(frameDifference) 
    if frameDifference >= framesAfter then
        local room = game:GetRoom()
        player:RemoveCollectible(mod.ITEMS.CHAOS_HEART)
        room:MamaMegaExplosion(player.Position)
        
        local wisps = Isaac.FindByType(EntityType.ENTITY_FAMILIAR, FamiliarVariant.WISP, mod.ITEMS.CHAOS_HEART)
        if wisps ~= nil and #wisps > 0 then
            for _, wisp in ipairs(wisps) do
                wisp:Kill()
            end
        end

        if not player:IsExtraAnimationFinished()  then
            player:PlayExtraAnimation("HideItem")
        end

        p_data.WickedPData.chaosHeart_TimesUsed = 0
        p_data.WickedPData.chaosHeart_MarkedForDetonate = nil
    end
end

SomethingWicked:AddCallback(ModCallbacks.MC_USE_ITEM, UseItem, mod.ITEMS.CHAOS_HEART)
SomethingWicked:AddCallback(ModCallbacks.MC_POST_PEFFECT_UPDATE, PlayerUpdate)