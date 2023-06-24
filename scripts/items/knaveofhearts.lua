local this = {}
TearVariant.SOMETHINGWICKED_JOKER_HEARTS = Isaac.GetEntityVariantByName("Joker Baby Hearts")

local function procChance(player)
    return 1
end
function this:FireTear(tear)
    local player = SomethingWicked:UtilGetPlayerFromTear(tear)
    if player and player:HasCollectible(CollectibleType.SOMETHINGWICKED_KNAVE_OF_HEARTS) then
        local c_rng = player:GetCollectibleRNG(CollectibleType.SOMETHINGWICKED_KNAVE_OF_HEARTS)
        if c_rng:RandomFloat() > procChance(player) then
            return
        end

        local t_data = tear:GetData()
        t_data.somethingWicked_isKnaveOfHeartsTear = true
    end
end
SomethingWicked:AddCallback(ModCallbacks.MC_POST_FIRE_TEAR, this.FireTear)

function this:UpdateTear(tear)
    local t_data = tear:GetData()
    if t_data.somethingWicked_isKnaveOfHeartsTear then
        if tear.FrameCount % 4 ~= 0 then
            return
        end
        local creepMult = 1

        local player = SomethingWicked:UtilGetPlayerFromTear(tear)
        if player then
            local p_data = player:GetData()
            if p_data.SomethingWickedPData.knaveOfHeartsCardsUsed then
                creepMult = creepMult * (1 + (p_data.SomethingWickedPData.knaveOfHeartsCardsUsed /2)) 
            end
        end
        local creep = Isaac.Spawn(EntityType.ENTITY_EFFECT, EffectVariant.PLAYER_CREEP_RED, 0, tear.Position, Vector.Zero, tear.SpawnerEntity.SpawnerEntity):ToEffect()
        creep.CollisionDamage = tear.CollisionDamage / 3
        creep.Scale = creepMult
        creep:Update()
    end
end
SomethingWicked:AddCallback(ModCallbacks.MC_POST_TEAR_UPDATE, this.UpdateTear)

SomethingWicked:AddCallback(ModCallbacks.MC_USE_CARD, function (_, id, player)
    if player:HasCollectible(CollectibleType.SOMETHINGWICKED_KNAVE_OF_HEARTS) then
        local cardConf = Isaac.GetItemConfig():GetCard(id)
        if cardConf.CardType ~= ItemConfig.CARDTYPE_SUIT then return end
        local p_data = player:GetData()
        p_data.SomethingWickedPData.knaveOfHeartsCardsUsed = (p_data.SomethingWickedPData.knaveOfHeartsCardsUsed or 0) + 1
    end
end)

SomethingWicked:AddCallback(ModCallbacks.MC_POST_NEW_ROOM, function ()
    for index, value in ipairs(SomethingWicked.ItemHelpers:AllPlayersWithCollectible(CollectibleType.SOMETHINGWICKED_KNAVE_OF_HEARTS)) do
        local p_data = value:GetData()
        p_data.SomethingWickedPData.knaveOfHeartsCardsUsed = 0
    end
end)

this.EIDEntries = {}
return this