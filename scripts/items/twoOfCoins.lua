local mod = SomethingWicked
local sfx = SFXManager()

local heartMults = {
    [HeartSubType.HEART_FULL] = 1,
    [HeartSubType.HEART_HALF] = 0.5,
    [HeartSubType.HEART_SCARED] = 1,
    [HeartSubType.HEART_DOUBLEPACK] = 2,
    [HeartSubType.HEART_BLENDED] = 1,
}

local function PickupCollision(heart, player)
    if heartMults[heart.SubType] == nil
    or (heart.SubType == HeartSubType.HEART_BLENDED and player:GetHearts() >= player:GetEffectiveMaxHearts()) then
        return
    end

    player = player:ToPlayer()
    if player and mod:WillHeartBePickedUp(heart, player) then
        local t_mult = player:GetTrinketMultiplier(TrinketType.SOMETHINGWICKED_TWO_OF_COINS)
        if t_mult <= 0 then
            return
        end
        local t_rng = player:GetTrinketRNG(TrinketType.SOMETHINGWICKED_TWO_OF_COINS)

        t_mult = t_mult*heartMults[heart.SubType]
        for _ = 1, (1 + t_rng:RandomInt(4))*t_mult, 1 do
            Isaac.Spawn(EntityType.ENTITY_PICKUP, PickupVariant.PICKUP_COIN, 0, player.Position, RandomVector() * 3, player)
            
            local poof = Isaac.Spawn(EntityType.ENTITY_EFFECT, EffectVariant.POOF01, 0, heart.Position, Vector.Zero, player)
            poof.Color = mod.CONST.ColourGold
            poof.SpriteScale = Vector(0.5, 0.5)

            local crater = Isaac.Spawn(EntityType.ENTITY_EFFECT, EffectVariant.BOMB_CRATER, 0, heart.Position, Vector.Zero, player)
            crater.Color = mod.CONST.ColourGold
            crater.SpriteScale = Vector(0.5, 0.5)

            sfx:Play(SoundEffect.SOUND_ULTRA_GREED_COIN_DESTROY)
        end
    end
end
 
mod:AddCallback(ModCallbacks.MC_PRE_PICKUP_COLLISION, PickupCollision, PickupVariant.PICKUP_HEART)