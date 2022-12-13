local this = {}
CollectibleType.SOMETHINGWICKED_SAINTS_HEAD = Isaac.GetItemIdByName("Saint's Head")

function this:EnemyDeath(entity)
    local flag, player = SomethingWicked.ItemHelpers:GlobalPlayerHasCollectible(CollectibleType.SOMETHINGWICKED_SAINTS_HEAD)
    if flag and player then
        
    end
end
SomethingWicked:AddCallback(ModCallbacks.MC_POST_NPC_DEATH, this.EnemyDeath)