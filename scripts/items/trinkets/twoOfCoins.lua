local mod = SomethingWicked
local sfx = SFXManager()

local heartMults = {
    [HeartSubType.HEART_FULL] = 1,
    [HeartSubType.HEART_HALF] = 0.5,
    [HeartSubType.HEART_SCARED] = 1,
    [HeartSubType.HEART_DOUBLEPACK] = 2,
    [HeartSubType.HEART_BLENDED] = 1,
}

local function PickupCollision(_, heart, player)
    if heartMults[heart.SubType] == nil then
        return
    end

    player = player:ToPlayer()
    if player and mod:WillHeartBePickedUp(heart, player)
    and (heart.SubType ~ HeartSubType.HEART_BLENDED or player:GetHearts() >= player:GetEffectiveMaxHearts()) then
        local t_mult = player:GetTrinketMultiplier(mod.TRINKETS.TWO_OF_COINS)
        if t_mult <= 0 then
            return
        end
        local t_rng = player:GetTrinketRNG(mod.TRINKETS.TWO_OF_COINS)

        t_mult = t_mult*heartMults[heart.SubType]
        for _ = 1, math.max(1, (1 + t_rng:RandomInt(4))*t_mult), 1 do
            Isaac.Spawn(EntityType.ENTITY_PICKUP, PickupVariant.PICKUP_COIN, 0, player.Position, RandomVector() * 3, player)
        end
            
        local poof = Isaac.Spawn(EntityType.ENTITY_EFFECT, EffectVariant.POOF01, 0, heart.Position, Vector.Zero, player)
        poof.Color = mod.ColourGold
        poof.SpriteScale = Vector(0.5, 0.5)

        local crater = Isaac.Spawn(EntityType.ENTITY_EFFECT, EffectVariant.BOMB_CRATER, 0, heart.Position, Vector.Zero, player)
        crater.Color = mod.ColourGold
        crater.SpriteScale = Vector(0.5, 0.5)

        sfx:Play(SoundEffect.SOUND_ULTRA_GREED_COIN_DESTROY)
    end
end
 
mod:AddCallback(ModCallbacks.MC_PRE_PICKUP_COLLISION, PickupCollision, PickupVariant.PICKUP_HEART)