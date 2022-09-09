local this = {}
Card.SOMETHINGWICKED_BOON_OF_THE_MAGPIE_EYE = Isaac.GetCardIdByName("MagpieEye")
Card.SOMETHINGWICKED_BOON_OF_THE_MAGPIE_EYE_REAL = Isaac.GetCardIdByName("MagpieEyeBoon")

function this:OnNewRoom()
    for _, v in ipairs(SomethingWicked:UtilGetAllPlayers()) do
        local room = SomethingWicked.game:GetRoom()
        if room:IsFirstVisit() 
        and room:GetType() == RoomType.ROOM_TREASURE
        and (v:GetCard(0) == Card.SOMETHINGWICKED_BOON_OF_THE_MAGPIE_EYE_REAL or v:GetCard(1) == Card.SOMETHINGWICKED_BOON_OF_THE_MAGPIE_EYE_REAL) then
        
            for _, i in ipairs(Isaac.FindByType(EntityType.ENTITY_PICKUP, PickupVariant.PICKUP_COLLECTIBLE)) do
                i = i:ToPickup()
                local position = i.Position
                i.Position = room:FindFreePickupSpawnPosition(Vector(position.X - 40, position.Y))

                local item = Isaac.Spawn(EntityType.ENTITY_PICKUP, PickupVariant.PICKUP_COLLECTIBLE, 0, room:FindFreePickupSpawnPosition(Vector(position.X + 40, position.Y)), Vector.Zero, nil):ToPickup()

                if i.OptionsPickupIndex == 0 then
                    i.OptionsPickupIndex = i.Index
                    item.OptionsPickupIndex = i.Index
                else 
                    item.OptionsPickupIndex = i.OptionsPickupIndex
                end

                local poof = Isaac.Spawn(EntityType.ENTITY_EFFECT, EffectVariant.POOF01, 0, item.Position, Vector.Zero, item)
                poof.Color = Color(0.1, 0.1, 0.1)
            end
        end
    end
end

function this:UseMagpieEye(_, player)
    player:AddCard(Card.SOMETHINGWICKED_BOON_OF_THE_MAGPIE_EYE_REAL)
end

function this:PreventCardPickup(pickup, collider)
    if collider.Type == EntityType.ENTITY_PLAYER then
        if collider:ToPlayer():GetCard(0) == Card.SOMETHINGWICKED_BOON_OF_THE_MAGPIE_EYE_REAL then
            return false
        end
    end
end

function this:PreventCardDropping(card)
    if card.SubType == Card.SOMETHINGWICKED_BOON_OF_THE_MAGPIE_EYE_REAL
    and card.SpawnerType == EntityType.ENTITY_PLAYER
    and card.SpawnerEntity ~= nil and card.SpawnerEntity:ToPlayer() ~= nil
    and card.FrameCount == 1 then
        local player = card.SpawnerEntity:ToPlayer()
        player:AddCard(Card.SOMETHINGWICKED_BOON_OF_THE_MAGPIE_EYE_REAL)
        card:Remove()
    end
end

SomethingWicked:AddCallback(ModCallbacks.MC_POST_PICKUP_UPDATE, this.PreventCardDropping, PickupVariant.PICKUP_TAROTCARD)
SomethingWicked:AddCallback(ModCallbacks.MC_PRE_PICKUP_COLLISION, this.PreventCardPickup, PickupVariant.PICKUP_TAROTCARD)
SomethingWicked:AddCallback(ModCallbacks.MC_PRE_PICKUP_COLLISION, this.PreventCardPickup, PickupVariant.PICKUP_PILL)
SomethingWicked:AddCallback(ModCallbacks.MC_USE_CARD, this.UseMagpieEye, Card.SOMETHINGWICKED_BOON_OF_THE_MAGPIE_EYE)
SomethingWicked:AddCallback(ModCallbacks.MC_POST_NEW_ROOM, this.OnNewRoom)

SomethingWicked:AddBoon(Card.SOMETHINGWICKED_BOON_OF_THE_MAGPIE_EYE_REAL)
this.EIDEntries = {
    [Card.SOMETHINGWICKED_BOON_OF_THE_MAGPIE_EYE] = {
        desc = "Upon using this card, this card will become undroppable, and cannot be swapped out#While holding the used card, all item rooms will be a More Options item room#Using the card again will remove it"
    },
    [Card.SOMETHINGWICKED_BOON_OF_THE_MAGPIE_EYE_REAL] = {
        desc = "All item rooms will be a More Options item room while held#Cannot be dropped or swapped out"
    }
}
return this