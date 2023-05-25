local this = {}
local mod = SomethingWicked
TrinketType.SOMETHINGWICKED_DICE_ROLLER = Isaac.GetTrinketIdByName("Dice Roller")
this.dice = { CollectibleType.COLLECTIBLE_D6, CollectibleType.COLLECTIBLE_D8,
CollectibleType.COLLECTIBLE_D12, CollectibleType.COLLECTIBLE_D10, CollectibleType.COLLECTIBLE_D20 }

function this:UseItem(id, _, player, flags)
    if flags & UseFlag.USE_CARBATTERY ~= 0 or flags & UseFlag.USE_OWNED == 0 then
        return
    end
    if not player:HasTrinket(TrinketType.SOMETHINGWICKED_DICE_ROLLER) then
        return
    end
    
    local p_data = player:GetData()
    local charge, slot = mod.ItemHelpers:CheckPlayerForActiveData(player, id)

    if slot ~= -1 and charge > 0 then
        local d = { slot = slot, charge = charge, id = id }
        p_data.sw_drData = d
    end
end
mod:AddCallback(ModCallbacks.MC_USE_ITEM, this.UseItem)

function this:PEffect(player)
    local p_data = player:GetData()
    if p_data.sw_drData then
        local d = p_data.sw_drData
        local consumed = not player:HasCollectible(d.id)
        if consumed or (player:GetActiveCharge(d.slot) < d.charge) then
            local charge = consumed and 4 or math.min(d.charge, 4)
            local mult = math.max(1, player:GetTrinketMultiplier(TrinketType.SOMETHINGWICKED_DICE_ROLLER))
            charge = (charge/4)*mult

            local t_rng = player:GetTrinketRNG(TrinketType.SOMETHINGWICKED_DICE_ROLLER)
            while t_rng:RandomFloat() < charge do
                charge = charge - 1
                
                local dice = mod:GetRandomElement(this.dice, t_rng)
                player:UseActiveItem(dice)
            end
        end
        
        p_data.sw_drData = nil
    end
end
mod:AddCallback(ModCallbacks.MC_POST_PEFFECT_UPDATE, this.PEffect)

this.EIDEntries = {
    [TrinketType.SOMETHINGWICKED_DICE_ROLLER] = {
        isTrinket = true,
        desc = "Using an active item has a chance to trigger one of these effects:#{{Collectible105}} D6#{{Collectible406}} D8#{{Collectible285}} D10#{{Collectible386}} D12#{{Collectible166}} D20#Chance scales with the charge of the item used"
    }
}
return this