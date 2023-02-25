local this = {}
local mod = SomethingWicked
CollectibleType.SOMETHINGWICKED_CAT_TEASER = Isaac.GetItemIdByName("Cat Teaser")

local function TearUpdate(tear)
    local t_data = tear:GetData()
end

mod.TFCore:AddNewFlagData(mod.CustomTearFlags.FLAG_CAT_TEASER, {
    ApplyLogic = function (_, player, tear)
        if player:HasCollectible(CollectibleType.SOMETHINGWICKED_CAT_TEASER) then
            return true
        end
    end,
    OverrideTearUpdate = function (_, tear)
        TearUpdate(tear)
    end
})


this.EIDEntries = {[CollectibleType.SOMETHINGWICKED_CAT_TEASER] = {
    desc = "cat"
}}
return this