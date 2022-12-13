local this = {}
CollectibleType.SOMETHINGWICKED_DUDAEL = Isaac.GetItemIdByName("Dudael")

function this:OnEnemyDMGGeneric(tear, collider, player, proc)
    if not player:HasCollectible(CollectibleType.SOMETHINGWICKED_DUDAEL) then
        return
    end
end
SomethingWicked:AddCustomCBack(SomethingWicked.CustomCallbacks.SWCB_ON_ENEMY_HIT, this.OnEnemyDMGGeneric)

this.EIDEntries = {}
return this