local this = {}
Card.SOMETHINGWICKEDTHOTH_LUST = Isaac.GetCardIdByName("Lust")
this.helperEffect = Isaac.GetItemIdByName("lust dummy helper")

this.SpeedDown = 0.4

function this:UseCard(_, player, flags)
    if player:GetPlayerType() == PlayerType.PLAYER_KEEPER
    or player:GetPlayerType() == PlayerType.PLAYER_KEEPER_B then
        Isaac.Spawn(EntityType.ENTITY_PICKUP, PickupVariant.PICKUP_COIN, CoinSubType.COIN_GOLDEN, SomethingWicked.game:GetRoom():FindFreePickupSpawnPosition(player.Position), Vector.Zero, player) 
        return 
    end

    if flags & UseFlag.USE_CARBATTERY == 0 then
        player:GetEffects():AddCollectibleEffect(this.helperEffect)
        SomethingWicked.sfx:Play(SoundEffect.SOUND_THUMBS_DOWN)
        Isaac.Spawn(EntityType.ENTITY_EFFECT, EffectVariant.POOF01, 0, player.Position, Vector.Zero, player)
    end
end

function this:PEffectUpdate(player)
    local p_data = player:GetData()
    local hasEffect = player:GetEffects():HasCollectibleEffect(this.helperEffect)
    if p_data.SomethingWickedPData.lustLastSavedHas == nil then p_data.SomethingWickedPData.lustLastSavedHas = false end
    if hasEffect ~= p_data.SomethingWickedPData.lustLastSavedHas then
        p_data.SomethingWickedPData.lustLastSavedHas = hasEffect
        if hasEffect then
            player:AddMaxHearts(6, true)
            player:AddHearts(6)
        else
            local maxhearts, soulhearts = player:GetMaxHearts(), player:GetSoulHearts()
            player:AddMaxHearts(soulhearts > 0 and -6 or -math.min(6, maxhearts - 2))
        end
    end
end

function this:CacheUpdate(player)
    player.MoveSpeed = player.MoveSpeed - (player:GetEffects():HasCollectibleEffect(this.helperEffect) and 0.4 or 0)
end

SomethingWicked:AddCallback(ModCallbacks.MC_EVALUATE_CACHE, this.CacheUpdate, CacheFlag.CACHE_SPEED)
SomethingWicked:AddCallback(ModCallbacks.MC_POST_PEFFECT_UPDATE, this.PEffectUpdate)
SomethingWicked:AddCallback(ModCallbacks.MC_USE_CARD, this.UseCard, Card.SOMETHINGWICKEDTHOTH_LUST)


this.EIDEntries = {
    [Card.SOMETHINGWICKEDTHOTH_LUST] = {
        desc = "Gives three full heart containers for the current room#Speed down by ".. this.SpeedDown .. "#{{Player14}} Spawns a Golden Penny instead as Keeper"
    }
}
return this