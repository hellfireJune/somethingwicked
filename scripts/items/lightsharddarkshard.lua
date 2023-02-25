local this = {}
local mod = SomethingWicked
CollectibleType.SOMETHINGWICKED_LIGHT_SHARD = Isaac.GetItemIdByName("Light Shard")
CollectibleType.SOMETHINGWICKED_DARK_SHARD = Isaac.GetItemIdByName("Dark Shard")

TearVariant.SOMETHINGWICKED_LIGHT_SHARD = 1
TearVariant.SOMETHINGWICKED_LIGHT_SHARD = 2

function this:UpdatePlayer(player)
    
end
mod:AddCallback(ModCallbacks.MC_POST_PEFFECT_UPDATE, this.UpdatePlayer)