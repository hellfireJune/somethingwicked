local mod = SomethingWicked
local dummyItem = mod.CONST.DUMMYITEMS.BLANKBOOK_BOOKWORM
local gDummy = mod.CONST.DUMMYITEMS.BLANKBOOK_GOLDEN

local function itemCheck(player, hasItem, hasTrinket, item)
    if hasItem ~= hasTrinket then
        if not hasTrinket then
            player:RemoveCollectible(item)
        else
            player:AddCollectible(item)
        end
    end
end

local function PlayerUpdate(player)
    local hasTrinket = player:HasTrinket(TrinketType.SOMETHINGWICKED_EMPTY_BOOK)
    local hasItem = player:HasCollectible(dummyItem)
    itemCheck(player, hasItem, hasTrinket, dummyItem)

    local hasGoldenTrinket = player:HasTrinket(TrinketType.SOMETHINGWICKED_EMPTY_BOOK + TrinketType.TRINKET_GOLDEN_FLAG)
    local hasGoldenItem = player:HasCollectible(gDummy)
    itemCheck(player, hasGoldenItem, hasGoldenTrinket, gDummy)
end

mod:AddCallback(ModCallbacks.MC_POST_PEFFECT_UPDATE, PlayerUpdate)