local this = {}
TrinketType.SOMETHINGWICKED_GIFT_CARD = Isaac.GetTrinketIdByName("Gift Card")

function this:PEffectUpdate(player)
    if player:HasTrinket(TrinketType.SOMETHINGWICKED_GIFT_CARD) then
        local p_data = player:GetData()
        p_data.somethingWicked_giftCardCountdown = p_data.somethingWicked_giftCardCountdown or 0

        if player:GetNumCoins() < 3 then
            
            if p_data.somethingWicked_giftCardCountdown > 0 then
                p_data.somethingWicked_giftCardCountdown = p_data.somethingWicked_giftCardCountdown - 1
            else
                player:AddCoins(1)
                p_data.somethingWicked_giftCardCountdown = 8

                local rng = player:GetDropRNG()
                local f = rng:RandomFloat()
                if f <= 0.06 then
                    player:TryRemoveTrinket(TrinketType.SOMETHINGWICKED_GIFT_CARD)
                    SomethingWicked.sfx:Play(SoundEffect.SOUND_DIMEPICKUP)
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
        desc = "While held, your coins can never fall below 3 coins"..
        "#!!! 4% chance for the trinket to break upon refilling coins",
        isTrinket = true
    }
}
return this