local mod = SomethingWicked
local crashPreventer = 0

local function BossPoolEdit(_, collectible, itempooltype, decrease, seed)
    if itempooltype ~= ItemPoolType.POOL_BOSS
    --or SomethingWicked.game:GetFrameCount() == 0 
    then
        return
    end

    if mod:GlobalPlayerHasTrinket(mod.TRINKETS.DEMONIUM_PAGE) then
            while crashPreventer < 100 do
                local config = Isaac.GetItemConfig()
                local itempool = SomethingWicked.game:GetItemPool()
                local iConf = config:GetCollectible(collectible)
                crashPreventer = crashPreventer + 1
                if iConf.CacheFlags & CacheFlag.CACHE_DAMAGE ~= 0 then
                    crashPreventer = -1
                    return collectible
                end
                collectible = itempool:GetCollectible(ItemPoolType.POOL_BOSS)
            end
        end
    end

SomethingWicked:AddCallback(ModCallbacks.MC_POST_GET_COLLECTIBLE, BossPoolEdit)