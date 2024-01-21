local mod = SomethingWicked
local game = Game()
local sfx = SFXManager()

this.PossibleCorruptions = {
    [0] = {
    },
    [-1] = {

        function ()
            game:ShowFortune()
        end,
        function ()
            Isaac.GetPlayer(0):UseActiveItem(CollectibleType.COLLECTIBLE_MEAT_CLEAVER, false)
        end,
        function (pos)
            local enemiesInRadius = Isaac.FindInRadius(pos, 40, EntityPartition.ENEMY)
            for key, value in pairs(enemiesInRadius) do
                if value:ToNPC() and value:ToNPC():CanReroll() then
                    game:RerollEnemy(value)
                end
            end
        end,
        function ()
            game:ShowRule()
        end
    },
    [-2] = {

        function ()
            Isaac.GetPlayer(0):UseCard(Card.CARD_TOWER)
        end,
        function (pos)
            --Isaac.GetPlayer(0):UseActiveItem(CollectibleType.COLLECTIBLE_D10, false)
            local enemiesInRadius = Isaac.FindInRadius(pos, 80000, EntityPartition.ENEMY)
            for key, value in pairs(enemiesInRadius) do
                if value:ToNPC() and value:ToNPC():CanReroll() then
                    game:RerollEnemy(value)
                end
            end
        end,
        function (pos)
            Isaac.Spawn(EntityType.ENTITY_BOMB, BombVariant.BOMB_TROLL, 0, pos, Vector.Zero, nil)
        end,
    },
    [-3] = {
        function (pos)
            local pickups = Isaac.FindByType(EntityType.ENTITY_PICKUP)
            for key, value in pairs(pickups) do
                value = value:ToPickup()
                if value and value:CanReroll()
                and value.Variant ~= PickupVariant.PICKUP_COLLECTIBLE then
                    value:Morph(EntityType.ENTITY_GAPER, 0, 0)
                end
            end
    
            Isaac.Spawn(EntityType.ENTITY_GAPER, 0, 0, pos, Vector.Zero, nil)
        end,
        function (pos)
            Isaac.Spawn(EntityType.ENTITY_BOMB, BombVariant.BOMB_GIGA, 0, pos, Vector.Zero, nil)
        end,
        function (pos)
            Isaac.Spawn(EntityType.ENTITY_BOMB, BombVariant.BOMB_GOLDENTROLL, 0, pos, Vector.Zero, nil)
        end
    },
    [-4] = {
        function ()
            Isaac.GetPlayer(0):UseCard(Card.CARD_REVERSE_HIGH_PRIESTESS)
        end,
        function ()
            for index, value in ipairs(mod:UtilGetAllPlayers()) do
                Isaac.GetPlayer(0):UseActiveItem(CollectibleType.COLLECTIBLE_CURSED_EYE)
            end
        end,
        function (pos)
            Isaac.Spawn(EntityType.ENTITY_GURGLING, 0, 0, pos, Vector.Zero, nil)
        end
    },
    [-5] = {
        function ()
            Isaac.DebugString("Fall")
            while true do
                for i = 1, 10, 1 do
                    
                end
            end
        end
    }
}

function SomethingWicked:UtilDoCorruption(pos, strength)
    strength = strength or 0
    local rng = RNG()
    rng:SetSeed(Random() + 1, 1)

    strength = strength + (strength * ((rng:RandomFloat() * 2) - 1))

    if strength % 1 < 0.5 then
        strength = math.floor(strength)
    else
        strength = math.ceil(strength)
    end
    strength = mod:Clamp(strength, -5, 0)
    local func = mod:GetRandomElement(this.PossibleCorruptions[strength], rng)
    func(pos)

    sfx:Play(SoundEffect.SOUND_EDEN_GLITCH)
    game:ShakeScreen(1)
end

local function SpawnLocusts(trinket, locust)
    local allPlayers = mod:AllPlayersWithTrinket(trinket)
    for _, player in ipairs(allPlayers) do
        for i = 1, player:GetTrinketMultiplier(trinket), 1 do
            local wf = Isaac.Spawn(EntityType.ENTITY_FAMILIAR, FamiliarVariant.BLUE_FLY, LocustSubtypes.SOMETHINGWICKED_LOCUST_OF_WORMWOOD, player.Position, Vector.Zero, player)
            wf.Parent = player
        end
    end
end


this.EIDEntries = {
    [TrinketType.SOMETHINGWICKED_FLOATING_POINT_BUG] = {
        desc = "sucks",
        isTrinket = true,
        Hide = true,
    }
}
return this