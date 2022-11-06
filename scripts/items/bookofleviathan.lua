local this = {}
CollectibleType.SOMETHINGWICKED_BOOK_OF_LEVIATHAN = Isaac.GetItemIdByName("  Book of Leviathan  ")

function this:UseItem(_, _, player)
    player:AddBlackHearts(2)
    return true
end

function this:CacheFlag(player)
    local effect = player:GetEffects():GetCollectibleEffect(CollectibleType.SOMETHINGWICKED_BOOK_OF_LEVIATHAN)
    if effect then
        player.Damage = SomethingWicked.StatUps:DamageUp(player, 1 * effect.Count)
    end
end

local maxCharge = 4
function this:OnRoomClear()
    for key, value in pairs(SomethingWicked.ItemHelpers:AllPlayersWithCollectible(CollectibleType.SOMETHINGWICKED_BOOK_OF_LEVIATHAN)) do
        local charge, slot = SomethingWicked.ItemHelpers:CheckPlayerForActiveData(value, CollectibleType.SOMETHINGWICKED_BOOK_OF_LEVIATHAN)
        local newMaxCharge = maxCharge * (value:HasCollectible(CollectibleType.COLLECTIBLE_BATTERY) and 2 or 1)
        if charge < newMaxCharge then
            local currentRoom = SomethingWicked.game:GetLevel():GetCurrentRoomDesc()
            local chargeToAdd = currentRoom.Data.Shape > 7 and 2 or 1

            value:SetActiveCharge(math.min(charge + (chargeToAdd), newMaxCharge), slot)
        end
    end
end

SomethingWicked:AddCallback(ModCallbacks.MC_USE_ITEM, this.UseItem, CollectibleType.SOMETHINGWICKED_BOOK_OF_LEVIATHAN)
SomethingWicked:AddCallback(ModCallbacks.MC_EVALUATE_CACHE, this.CacheFlag, CacheFlag.CACHE_DAMAGE)
SomethingWicked:AddCallback(ModCallbacks.MC_PRE_SPAWN_CLEAN_AWARD, this.OnRoomClear)

this.EIDEntries = {
    [CollectibleType.SOMETHINGWICKED_BOOK_OF_LEVIATHAN] = {
        desc = ""
    }
}
return this