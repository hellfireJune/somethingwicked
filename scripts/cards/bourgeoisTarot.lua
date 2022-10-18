local this = {}
Card.SOMETHINGWICKED_KNIGHT_OF_DIAMONDS = Isaac.GetCardIdByName("KnightOfDiamonds")
Card.SOMETHINGWICKED_KNIGHT_OF_HEARTS = Isaac.GetCardIdByName("KnightOfHearts")
Card.SOMETHINGWICKED_KNIGHT_OF_SPADES = Isaac.GetCardIdByName("KnightOfSpades")
Card.SOMETHINGWICKED_KNIGHT_OF_CLUBS = Isaac.GetCardIdByName("KnightOfClubs")
Card.SOMETHINGWICKED_THE_GAME = Isaac.GetCardIdByName("TheGame") --that you just lost

this.PlayingCards = {
    Card.CARD_SPADES_2,
    Card.CARD_SUICIDE_KING,
    Card.CARD_CLUBS_2,
    Card.CARD_DIAMONDS_2,
    Card.CARD_HEARTS_2,
    Card.CARD_ACE_OF_CLUBS,
    Card.CARD_ACE_OF_DIAMONDS,
    Card.CARD_ACE_OF_SPADES,
    Card.CARD_ACE_OF_HEARTS,
    Card.CARD_JOKER,
    Card.CARD_QUEEN_OF_HEARTS,
    Card.SOMETHINGWICKED_KNIGHT_OF_DIAMONDS,
    Card.SOMETHINGWICKED_KNIGHT_OF_HEARTS,
    Card.SOMETHINGWICKED_KNIGHT_OF_SPADES,
    Card.SOMETHINGWICKED_KNIGHT_OF_CLUBS
}

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
    end
end

function this:UseGame(_, player)
    local rng = player:GetDropRNG()
    local itemPool = SomethingWicked.game:GetItemPool()
    for i = 1, 3, 1 do
        local card = -1
        for antiSoftlock = 1, 500, 1 do
            card = itemPool:GetCard(Random() + 1, true)
            if SomethingWicked:UtilTableHasValue(this.PlayingCards, card) then
                break
            end
        end
        Isaac.Spawn(EntityType.ENTITY_PICKUP, PickupVariant.PICKUP_TAROTCARD, card, player.Position, SomethingWicked.SlotHelpers:GetPayoutVector(rng), player)
    end
end

SomethingWicked:AddCallback(ModCallbacks.MC_USE_CARD, this.UseKnights)
SomethingWicked:AddCallback(ModCallbacks.MC_USE_CARD, this.UseGame, Card.SOMETHINGWICKED_THE_GAME)

this.otherModsCards = {
    --fiendfolio
    "3 of Clubs",
    "Jack of Clubs",
    "Queen of Clubs",
    "King of Clubs",

    "3 of Diamonds",
    "Jack of Diamonds",
    "Queen of Diamonds",
    "King of Diamonds",

    "3 of Spades",
    "Jack of Spades",
    "Queen of Spades",
    "King of Spades",

    "3 of Hearts",
    "Jack of Hearts",

    "Misprinted Joker",

    --REP+
    "Joker?",
    "Bedside Queen",

    --Ipecac
    "AceOfCups",
    "AceOfWands",
    "AceOfPentacles",
    "AceOfSwords",

}

this.hasInitOtherModsPlayingCards = false
function this:RunStart()
    if not this.hasInitOtherModsPlayingCards then
        this:InitModCards()
    end
end
SomethingWicked:AddCallback(ModCallbacks.MC_POST_GAME_STARTED, this.RunStart)

function this:InitModCards()
    this.hasInitOtherModsPlayingCards = true
    for _, cardHud in ipairs(this.otherModsCards) do
        local card = Isaac.GetCardIdByName(cardHud)
        if card ~= -1 then
            table.insert(this.PlayingCards, card)
        end
    end
end
if SomethingWicked.game:GetFrameCount() > 0 then
    this:InitModCards()
end
return this