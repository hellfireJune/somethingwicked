this.MinFailUse = 5
this.MaxSucceedUse = 9
this.framesAfter = 12

function this:UseItem(_, rng, player, flags)
    if flags & UseFlag.USE_CARBATTERY ~= 0 then
        player:AddHearts(1)
        return
    end
    local p_data = player:GetData()

    if p_data.SomethingWickedPData.chaosHeart_MarkedForDetonate then
        return
    end

    p_data.SomethingWickedPData.chaosHeart_TimesUsed = (p_data.SomethingWickedPData.chaosHeart_TimesUsed or 0) + 1

    local fail = rng:RandomInt(this.MaxSucceedUse - this.MinFailUse) + this.MinFailUse
    if p_data.SomethingWickedPData.chaosHeart_TimesUsed < fail then
        --succeed
        player:AddHearts(2)
        SomethingWicked.sfx:Play(SoundEffect.SOUND_VAMP_GULP, 1, 0)
        return true
    end
    p_data.SomethingWickedPData.chaosHeart_MarkedForDetonate = player.FrameCount
    player:AnimateCollectible(CollectibleType.SOMETHINGWICKED_CHAOS_HEART , "LiftItem", "PlayerPickupSparkle")
    --fail
end

function this:PlayerUpdate(player)
    local p_data = player:GetData()

    if p_data.SomethingWickedPData.chaosHeart_MarkedForDetonate == nil then
        return
    end

    local frameDifference = player.FrameCount - p_data.SomethingWickedPData.chaosHeart_MarkedForDetonate
    --print(frameDifference) 
    if frameDifference >= this.framesAfter then
        local room = SomethingWicked.game:GetRoom()
        player:RemoveCollectible(CollectibleType.SOMETHINGWICKED_CHAOS_HEART)
        room:MamaMegaExplosion(player.Position)
        
        local wisps = Isaac.FindByType(EntityType.ENTITY_FAMILIAR, FamiliarVariant.WISP, CollectibleType.SOMETHINGWICKED_CHAOS_HEART)
        if wisps ~= nil and #wisps > 0 then
            for _, wisp in ipairs(wisps) do
                wisp:Kill()
            end
        end

        if not player:IsExtraAnimationFinished()  then
            player:PlayExtraAnimation("HideItem")
        end

        p_data.SomethingWickedPData.chaosHeart_TimesUsed = 0
        p_data.SomethingWickedPData.chaosHeart_MarkedForDetonate = nil
    end
end

SomethingWicked:AddCallback(ModCallbacks.MC_USE_ITEM, this.UseItem, CollectibleType.SOMETHINGWICKED_CHAOS_HEART)
SomethingWicked:AddCallback(ModCallbacks.MC_POST_PEFFECT_UPDATE, this.PlayerUpdate)

this.EIDEntries = {
    [CollectibleType.SOMETHINGWICKED_CHAOS_HEART] = {
        desc = "Heal 1 red heart#After "..this.MinFailUse.." uses, has a chance to do a Mama Mega explosion, and remove the item#Guaranteed to explode at "..this.MaxSucceedUse.." uses",
        pools = {
            SomethingWicked.encyclopediaLootPools.POOL_TREASURE,
            SomethingWicked.encyclopediaLootPools.POOL_ULTRA_SECRET,
            SomethingWicked.encyclopediaLootPools.POOL_GREED_TREASURE,
        },
        encycloDesc = SomethingWicked:UtilGenerateWikiDesc({"Heals 1 red heart on use","After "..this.MinFailUse.." uses, has a chance to do a Mama Mega explosion, and remove the item","Guaranteed to explode at "..this.MaxSucceedUse.." uses"})
    }
}
return this