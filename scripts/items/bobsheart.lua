local this = {}
TrinketType.SOMETHINGWICKED_BOBS_HEART = Isaac.GetTrinketIdByName("Bob's Heart")

function this:PickupInit(entity)
    if entity.SubType ~= HeartSubType.HEART_FULL 
    and entity.SubType ~= HeartSubType.HEART_HALF 
    and entity.SubType ~= HeartSubType.HEART_SCARED then
        return
    end

    local players = SomethingWicked:UtilGetAllPlayers()

    for _, player in ipairs(players) do
        if player:HasTrinket(TrinketType.SOMETHINGWICKED_BOBS_HEART) then
            entity:Morph(EntityType.ENTITY_PICKUP, PickupVariant.PICKUP_HEART, HeartSubType.HEART_ROTTEN, true)
            break
        end
    end
end

SomethingWicked:AddCallback(ModCallbacks.MC_POST_PICKUP_INIT, this.PickupInit, PickupVariant.PICKUP_HEART)

this.EIDEntries = {
    [TrinketType.SOMETHINGWICKED_BOBS_HEART] = {
        isTrinket = true,
        desc = "Turns all red hearts into rotten hearts.",
        encycloDesc = SomethingWicked:UtilGenerateWikiDesc({"While held, all red hearts turn into rotten hearts"})
    }
}
return this