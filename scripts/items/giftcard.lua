local this = {}

function this:PEffectUpdate(player)
    if player:HasTrinket(TrinketType.SOMETHINGWICKED_GIFT_CARD) then
        local p_data = player:GetData()
        p_data.somethingWicked_giftCardCountdown = p_data.somethingWicked_giftCardCountdown or 4

        if player:GetNumCoins() < 6 then
            
            if p_data.somethingWicked_giftCardCountdown > 0 then
                p_data.somethingWicked_giftCardCountdown = p_data.somethingWicked_giftCardCountdown - 1
            else
                player:AddCoins(1)
                p_data.somethingWicked_giftCardCountdown = 4

                local rng = player:GetDropRNG()
                local f = rng:RandomFloat()
                if f <= 0.05 then
                    player:TryRemoveTrinket(TrinketType.SOMETHINGWICKED_GIFT_CARD)
                    SomethingWicked.sfx:Play(SoundEffect.SOUND_DIMEPICKUP)

                    local giftCard = Isaac.Spawn(EntityType.ENTITY_PICKUP, PickupVariant.PICKUP_TRINKET, TrinketType.SOMETHINGWICKED_GIFT_CARD, player.Position, RandomVector()*2, player)
                    giftCard:Die()
                    giftCard.EntityCollisionClass = 0

                    SomethingWicked:UtilScheduleForUpdate(function ()
                        if not giftCard or not giftCard:Exists() then
                            return
                        end
                        Isaac.Spawn(EntityType.ENTITY_EFFECT, EffectVariant.POOF01, 0, giftCard.Position, Vector.Zero, nil)
                        giftCard:Remove()
                        SomethingWicked.sfx:Play(SoundEffect.SOUND_THUMBS_DOWN, 1, 0)
                    end, 45, ModCallbacks.MC_POST_UPDATE)
                else
                    SomethingWicked.sfx:Play(SoundEffect.SOUND_PENNYPICKUP)
                end
            end
        end
    end
end

SomethingWicked:AddCallback(ModCallbacks.MC_POST_PEFFECT_UPDATE, this.PEffectUpdate)
this.EIDEntries = {
    [TrinketType.SOMETHINGWICKED_GIFT_CARD] = {
        desc = "While held, your coins can never fall below 6 coins"..
        "#!!! 5% chance for the trinket to break upon refilling coins",
        isTrinket = true,
    }
}
return this