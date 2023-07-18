local this = {}

function this:OnNewRoom()
    for _, v in ipairs(SomethingWicked:UtilGetAllPlayers()) do
        local room = SomethingWicked.game:GetRoom()
        if room:IsFirstVisit() 
        and room:GetType() == RoomType.ROOM_TREASURE
        and (v:GetCard(0) == Card.SOMETHINGWICKED_MAGPIE_EYE_BOON or v:GetCard(1) == Card.SOMETHINGWICKED_MAGPIE_EYE_BOON) then
        
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

function this:UseMagpieEye(_, player, useflags)
    SomethingWicked.cardCore:UseBoonCard(Card.SOMETHINGWICKED_MAGPIE_EYE, Card.SOMETHINGWICKED_MAGPIE_EYE_BOON, player, useflags)
end

SomethingWicked:AddCallback(ModCallbacks.MC_USE_CARD, this.UseMagpieEye, Card.SOMETHINGWICKED_MAGPIE_EYE)
SomethingWicked:AddCallback(ModCallbacks.MC_POST_NEW_ROOM, this.OnNewRoom)

SomethingWicked:AddBoon(Card.SOMETHINGWICKED_MAGPIE_EYE_BOON)
this.EIDEntries = {
    [Card.SOMETHINGWICKED_MAGPIE_EYE] = {
        desc = "Upon using this card, this card will become undroppable, and cannot be swapped out#While holding the used card, all item rooms will be a More Options item room#Using the card again will remove it"
    },
    [Card.SOMETHINGWICKED_MAGPIE_EYE_BOON] = {
        desc = "All item rooms will be a More Options item room while held#Cannot be dropped or swapped out"
    }
}
return this