local mod = SomethingWicked
local dice = { CollectibleType.COLLECTIBLE_D6, CollectibleType.COLLECTIBLE_D8,
CollectibleType.COLLECTIBLE_D12, CollectibleType.COLLECTIBLE_D10, CollectibleType.COLLECTIBLE_D20 }

local function UseItem(_, id, _, player, flags)
    if flags & UseFlag.USE_CARBATTERY ~= 0 or flags & UseFlag.USE_OWNED == 0 then
        return
    end
    if not player:HasTrinket(TrinketType.SOMETHINGWICKED_DICE_ROLLER) then
        return
    end
    
    local p_data = player:GetData()
    local charge, slot = mod.ItemHelpers:CheckPlayerForActiveData(player, id)

    if slot ~= -1 then
        local iconfig = Isaac.GetItemConfig()
        local cc = iconfig:GetCollectible(id)

        if cc.ChargeType == ItemConfig.CHARGE_TIMED then
            charge = 0.8
        elseif cc.ChargeType == ItemConfig.CHARGE_SPECIAL then
            charge = 4
        end

        local d = { slot = slot, charge = charge, id = id }
        d.coins = player:GetNumCoins()
        d.bombs = player:GetNumBombs()
        d.keys = player:GetNumKeys() 
        d.hearts = player:GetHearts()
        d.shearts = player:GetSoulHearts()

        p_data.sw_drData = d
    end
end
mod:AddCallback(ModCallbacks.MC_USE_ITEM, UseItem)

local function PEffect(_, player)
    local p_data = player:GetData()
    if p_data.sw_drData then
        local d = p_data.sw_drData
        local consumed = not player:HasCollectible(d.id)
        local chargeDown = (player:GetActiveCharge(d.slot) < d.charge)

        local usedThing = false
        if d.charge == 0 then
            if d.coins > player:GetNumCoins() then
                usedThing = true
            elseif d.bombs > player:GetNumBombs() then
                usedThing = true
            elseif d.keys > player:GetNumKeys() then
                usedThing = true
            elseif d.hearts > player:GetHearts() then
                usedThing = true
            elseif d.shearts > player:GetSoulHearts() then
                usedThing = true
            end
        end

        if consumed or chargeDown or usedThing then
            local charge = consumed and 4 or mod:Clamp(d.charge, 4, 1)
            local mult = math.max(1, player:GetTrinketMultiplier(TrinketType.SOMETHINGWICKED_DICE_ROLLER))
            charge = (charge/4)*mult

            local t_rng = player:GetTrinketRNG(TrinketType.SOMETHINGWICKED_DICE_ROLLER)
            while t_rng:RandomFloat() < charge do
                charge = charge - 1
                
                local dice = mod:GetRandomElement(dice, t_rng)
                player:UseActiveItem(dice)
            end
        end
        
        p_data.sw_drData = nil
    end
end
mod:AddCallback(ModCallbacks.MC_POST_PEFFECT_UPDATE, PEffect)