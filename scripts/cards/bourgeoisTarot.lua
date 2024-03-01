local mod = SomethingWicked
local sfx = SFXManager()
local game = Game()

local variants = {
    [mod.CARDS.KNIGHT_OF_DIAMONDS] = {PickupVariant.PICKUP_COIN, 12},
    [mod.CARDS.KNIGHT_OF_HEARTS] = {PickupVariant.PICKUP_HEART, 6},
    [mod.CARDS.KNIGHT_OF_SPADES] = {PickupVariant.PICKUP_KEY, 4},
    [mod.CARDS.KNIGHT_OF_CLUBS] = {PickupVariant.PICKUP_BOMB, 4},
}

local function UseKnights(_, card, player)
    local data = variants[card]
    if data ~= nil then
    local rng = player:GetDropRNG()
       local variant = data[1] local mult = data[2]
       mod:SpawnPickupShmorgabord(mult, variant, rng, player.Position, player, function (pickup)
           pickup.Velocity = mod:GetPayoutVector(rng)
       end)
       sfx:Play(SoundEffect.SOUND_DIMEPICKUP)
    end
end

local function UseGame(_, _, player)
    local rng = player:GetDropRNG()
    local itemPool = game:GetItemPool()
    for i = 1, 3, 1 do
        local card = -1
        for antiSoftlock = 1, 500, 1 do
            card = itemPool:GetCard(Random() + 1, true)
            local cardConf = Isaac.GetItemConfig():GetCard(card)
            if cardConf.CardType == ItemConfig.CARDTYPE_SUIT or cardConf.ID == Card.CARD_JOKER then
                break
            end
        end
        Isaac.Spawn(EntityType.ENTITY_PICKUP, PickupVariant.PICKUP_TAROTCARD, card, player.Position, mod:GetPayoutVector(rng), player)
    end
end

SomethingWicked:AddCallback(ModCallbacks.MC_USE_CARD, UseKnights)
SomethingWicked:AddCallback(ModCallbacks.MC_USE_CARD, UseGame, mod.CARDS.THE_GAME)