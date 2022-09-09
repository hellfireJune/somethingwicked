local this = {}
TrinketType.SOMETHINGWICKED_STONE_KEY = Isaac.GetTrinketIdByName("Stone Key")

function this:PickupCollision(chest, entity)
    local playerEntity = entity:ToPlayer()
    if playerEntity and playerEntity:HasTrinket(TrinketType.SOMETHINGWICKED_STONE_KEY) and chest.SubType == ChestSubType.CHEST_CLOSED then
        chest:TryOpenChest()
    end
end

SomethingWicked:AddCallback(ModCallbacks.MC_PRE_PICKUP_COLLISION, this.PickupCollision, PickupVariant.PICKUP_BOMBCHEST)

this.EIDEntries = {
    [TrinketType.SOMETHINGWICKED_STONE_KEY] = {
        isTrinket = true,
        desc = "Walking into bomb chests opens them for free",
        encycloDesc = SomethingWicked:UtilGenerateWikiDesc({"While held, walking into bomb chests opens them for free"})
    }
}
return this