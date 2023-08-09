local this = {}

this.variants = {
    [Card.SOMETHINGWICKED_KNIGHT_OF_DIAMONDS] = {PickupVariant.PICKUP_COIN, 12},
    [Card.SOMETHINGWICKED_KNIGHT_OF_HEARTS] = {PickupVariant.PICKUP_HEART, 6},
    [Card.SOMETHINGWICKED_KNIGHT_OF_SPADES] = {PickupVariant.PICKUP_KEY, 4},
    [Card.SOMETHINGWICKED_KNIGHT_OF_CLUBS] = {PickupVariant.PICKUP_BOMB, 4},
}

this.EIDEntries = {
    [Card.SOMETHINGWICKED_KNIGHT_OF_CLUBS] = {
        desc = "Spawns 4 bombs worth of pickups on use"
    },
    [Card.SOMETHINGWICKED_KNIGHT_OF_HEARTS] = {
        desc = "Spawns 6 hearts worth of pickups on use"
    },
    [Card.SOMETHINGWICKED_KNIGHT_OF_SPADES] = {
        desc = "Spawns 4 keys worth of pickups on use"
    },
    [Card.SOMETHINGWICKED_KNIGHT_OF_DIAMONDS] = {
        desc = "Spawns 12 coins worth of pickups on use"
    },
    [Card.SOMETHINGWICKED_THE_GAME] = {
        desc = "Spawns 3 playing cards on use"
    }
}

function this:UseKnights(card, player)
    local data = this.variants[card]
    if data ~= nil then
    local rng = player:GetDropRNG()
       local variant = data[1] local mult = data[2]
       SomethingWicked.ItemHelpers:SpawnPickupShmorgabord(mult, variant, rng, player.Position, player, function (pickup)
           pickup.Velocity = SomethingWicked.SlotHelpers:GetPayoutVector(rng)
       end)
       SomethingWicked.sfx:Play(SoundEffect.SOUND_DIMEPICKUP)
    end
end

function this:UseGame(_, player)
    local rng = player:GetDropRNG()
    local itemPool = SomethingWicked.game:GetItemPool()
    for i = 1, 3, 1 do
        local card = -1
        for antiSoftlock = 1, 500, 1 do
            card = itemPool:GetCard(Random() + 1, true)
            local cardConf = Isaac.GetItemConfig():GetCard(card)
            if cardConf.CardType == ItemConfig.CARDTYPE_SUIT then
                break
            end
        end
        Isaac.Spawn(EntityType.ENTITY_PICKUP, PickupVariant.PICKUP_TAROTCARD, card, player.Position, SomethingWicked.SlotHelpers:GetPayoutVector(rng), player)
    end
end

SomethingWicked:AddCallback(ModCallbacks.MC_USE_CARD, this.UseKnights)
SomethingWicked:AddCallback(ModCallbacks.MC_USE_CARD, this.UseGame, Card.SOMETHINGWICKED_THE_GAME)

return this