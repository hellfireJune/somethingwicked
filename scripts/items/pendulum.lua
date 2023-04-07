local this = {}
local mod = SomethingWicked
CollectibleType.SOMETHINGWICKED_DD_ITEM = Isaac.GetItemIdByName("Pendulum")

mod:AddCustomCBack(mod.CustomCallbacks.SWCB_EVALUATE_DEVIL_CHANCE, function (_, player, p_data)
    p_data.sw_ddChance = player:GetCollectibleNum(CollectibleType.SOMETHINGWICKED_DD_ITEM) + p_data.sw_ddChance
end)

this.EIDEntries = {}
return this