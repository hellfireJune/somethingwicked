local this = {}
TrinketType.SOMETHINGWICKED_FLOATING_POINT_BUG = Isaac.GetTrinketIdByName("Floating Point Bug")
TrinketType.SOMETHINGWICKED_BAG_OF_MUGWORTS = Isaac.GetTrinketIdByName("Bag of Mugworts")

this.PossibleCorruptions = {
    [0] = {
    },
    [-1] = {

        function ()
            SomethingWicked.game:ShowFortune()
        end,
        function ()
            Isaac.GetPlayer(0):UseActiveItem(CollectibleType.COLLECTIBLE_MEAT_CLEAVER, false)
        end,
        function (pos)
            local enemiesInRadius = Isaac.FindInRadius(pos, 40, EntityPartition.ENEMY)
            for key, value in pairs(enemiesInRadius) do
                if value:ToNPC() and value:ToNPC():CanReroll() then
                    SomethingWicked.game:RerollEnemy(value)
                end
            end
        end,
        function ()
            SomethingWicked.game:ShowRule()
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
                    SomethingWicked.game:RerollEnemy(value)
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
            for index, value in ipairs(SomethingWicked:UtilGetAllPlayers()) do
                Isaac.GetPlayer(0):UseActiveItem(CollectibleType.COLLECTIBLE_CURSED_EYE)
            end
        end,
        function (pos)
            Isaac.Spawn(EntityType.ENTITY_GURGLING, 0, 0, pos, Vector.Zero, nil)
        end
    },
    [-5] = {
    }
}

local function SpawnLocusts(trinket, locust)
    local allPlayers = SomethingWicked.ItemHelpers:AllPlayersWithTrinket(trinket)
    for _, player in ipairs(allPlayers) do
        for i = 1, player:GetTrinketMultiplier(trinket), 1 do
            local wf = Isaac.Spawn(EntityType.ENTITY_FAMILIAR, FamiliarVariant.BLUE_FLY, LocustSubtypes.SOMETHINGWICKED_LOCUST_OF_WORMWOOD, player.Position, Vector.Zero, player)
            wf.Parent = player
        end
    end
end
function this:NewRoom()
    local room = SomethingWicked.game:GetRoom()
    if room:IsClear() and not room:IsAmbushActive() then
        return
    end
    SpawnLocusts(TrinketType.SOMETHINGWICKED_BAG_OF_MUGWORTS, LocustSubtypes.SOMETHINGWICKED_LOCUST_OF_WORMWOOD)
    SpawnLocusts(TrinketType.SOMETHINGWICKED_FLOATING_POINT_BUG, LocustSubtypes.SOMETHINGWICKED_GLITCH_LOCUST)
end
SomethingWicked:AddCallback(ModCallbacks.MC_POST_NEW_ROOM, this.NewRoom)
SomethingWicked:AddCustomCBack(SomethingWicked.CustomCallbacks.SWCB_NEW_WAVE_SPAWNED, this.NewRoom)


this.EIDEntries = {
    [TrinketType.SOMETHINGWICKED_FLOATING_POINT_BUG] = {
        desc = "sucks",
        isTrinket = true,
        Hide = true,
    }
}
return this