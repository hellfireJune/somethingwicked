local mod = SomethingWicked
local blacklist = { 577, 585, 622, 628, 127, 297, 347, 475, 483, 490, 515}

local function ItemUse(_, id, _, player, flags)
    if flags & UseFlag.USE_CARBATTERY ~= 0 or flags & UseFlag.USE_OWNED == 0 then
        return
    end
    local charge, slot = mod:CheckPlayerForActiveData(player, id)
    if charge == 0 or slot == -1
    or SomethingWicked:UtilTableHasValue(blacklist, id) then
        return
    end

    local timesToUseBonus = 0
    if player:HasCollectible(mod.ITEMS.ELECTRIC_DICE) then
        timesToUseBonus = timesToUseBonus + player:GetCollectibleRNG(mod.ITEMS.ELECTRIC_DICE):RandomInt(3)
    end
    if player:HasTrinket(mod.TRINKETS.BUSTED_BATTERY) then
        local t_rng = player:GetTrinketRNG(mod.TRINKETS.BUSTED_BATTERY)
        if t_rng:RandomFloat() < 0.33 * player:GetTrinketMultiplier(mod.TRINKETS.BUSTED_BATTERY) then
            timesToUseBonus = timesToUseBonus + 1
        end
    end
                
    local offset = Vector(0,-30)
    for i = 1, timesToUseBonus, 1 do
        player:UseActiveItem(id, flags | UseFlag.USE_CARBATTERY)

        local effect =  Isaac.Spawn(EntityType.ENTITY_EFFECT, EffectVariant.BATTERY, 0, player.Position + offset + ((i + 0.5) * Vector(0, -20)), Vector.Zero, player)
        effect.DepthOffset = 500
    end
end

mod:AddCallback(ModCallbacks.MC_USE_ITEM, ItemUse)