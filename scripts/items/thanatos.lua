local this = {}
CollectibleType.SOMETHINGWICKED_MTRBITEM = Isaac.GetItemIdByName("more troll bomb item")
local mod = SomethingWicked

local function procChance(player)
    return 1
end
mod:AddCallback(ModCallbacks.MC_POST_ENTITY_KILL, function (_, ent)
    if ent:IsEnemy() then
        local flag, player = mod.ItemHelpers:GlobalPlayerHasCollectible(CollectibleType.SOMETHINGWICKED_MTRBITEM)
        if flag and player then
            local c_rng = player:GetCollectibleRNG(CollectibleType.SOMETHINGWICKED_MTRBITEM)
            if procChance(player) > c_rng:RandomFloat() then
                Isaac.Spawn(EntityType.ENTITY_BOMB, BombVariant.BOMB_TROLL, 0, ent.Position, Vector.Zero, player)
            end
        end
    end
end)

mod:AddCustomCBack(mod.CustomCallbacks.SWCB_PICKUP_ITEM, function (_, player, room)
    local pos = room:FindFreePickupSpawnPosition(player.Position)
    Isaac.Spawn(EntityType.ENTITY_BOMB, BombVariant.BOMB_TROLL, 0, pos, Vector.Zero, nil)
end, CollectibleType.SOMETHINGWICKED_MTRBITEM)

this.EIDEntries = {
    [CollectibleType.SOMETHINGWICKED_MTRBITEM] = {
        desc = "",
    }
}
return this