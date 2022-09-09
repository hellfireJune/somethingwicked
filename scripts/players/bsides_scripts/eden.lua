local this = {}
this.DoingEdenSwap = false

function this:SwapToBSideFunction(player)
    this.DoingEdenSwap = true
    player:UseActiveItem(CollectibleType.COLLECTIBLE_D4, UseFlag.USE_NOANIM | UseFlag.USE_REMOVEACTIVE)
    this.DoingEdenSwap = false
    return true
end

--SomethingWicked:AddCallback(ModCallbacks.MC_POST_GET_COLLECTIBLE)

return this