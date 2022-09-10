local this = {}
this.DoingEdenSwap = false

function this:SwapToBSideFunction(player)
    this.DoingEdenSwap = true
    player:UseActiveItem(CollectibleType.COLLECTIBLE_D8, UseFlag.USE_NOANIM)
    player:UseActiveItem(CollectibleType.COLLECTIBLE_D4, UseFlag.USE_NOANIM)
    this.DoingEdenSwap = false
    this.crashPreventer = -1
    --return true
end
    
this.crashPreventer = 0
function this:ItemReroll(collectible, itempooltype, decrease, seed)
        if this.DoingEdenSwap then
            while this.crashPreventer < 100 do
                local config = Isaac.GetItemConfig()
                local itempool = SomethingWicked.game:GetItemPool()
                local iConf = config:GetCollectible(collectible)
                this.crashPreventer = this.crashPreventer + 1
                if SomethingWicked:UtilTableHasValue(SomethingWicked.addedCollectibles, collectible)
                and iConf.Type ~= ItemType.ITEM_ACTIVE then
                    this.crashPreventer = -1
                    return collectible
                end
                collectible = itempool:GetCollectible(itempooltype)
            end
        end
    end

SomethingWicked:AddCallback(ModCallbacks.MC_POST_GET_COLLECTIBLE, this.ItemReroll)

return this