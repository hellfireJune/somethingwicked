local this = {}

function this:PickupCollision(chest, player)
    player = player:ToPlayer()
    if player and player:HasTrinket(TrinketType.SOMETHINGWICKED_STONE_KEY) and chest.SubType == ChestSubType.CHEST_CLOSED then
        chest:TryOpenChest()
    end
end

SomethingWicked:AddCallback(ModCallbacks.MC_PRE_PICKUP_COLLISION, this.PickupCollision, PickupVariant.PICKUP_BOMBCHEST)

function this:Update()
    
end
SomethingWicked:AddCallback(ModCallbacks.MC_POST_UPDATE, this.Update)

this.EIDEntries = {
    [TrinketType.SOMETHINGWICKED_STONE_KEY] = {
        isTrinket = true,
        desc = "↑ Opening a secret room will refund one bomb#Walking into bomb chests opens them for free",
    }
}
return this