local mod = SomethingWicked

function mod:UsePendulum(_, player)
    local ceffects = player:GetEffects()
    if ceffects:HasNullEffect(mod.NULL.PENDULUM) then
        ceffects:RemoveNullEffect(mod.NULL.PENDULUM) 
    else
        ceffects:AddNullEffect(mod.NULL.PENDULUM) 
    end

    return { ShowAnim = true, Discharge = false}
end

function mod:PendulumPlayerUpdate(player)
    if player:HasCollectible(mod.ITEMS.PENDULUM) then
        local ceffects = player:GetEffects()
        local consumeCharge = ceffects:HasNullEffect(mod.NULL.PENDULUM)
        local battery = player:HasCollectible(CollectibleType.COLLECTIBLE_BATTERY)

        local activeData = mod:GetAllActiveDatasOfType(player, mod.ITEMS.PENDULUM)
        for i = 0, 3, 1 do
            local itemsCharge = activeData[i]
            if itemsCharge ~= nil then
                if consumeCharge  then
                    if itemsCharge > 0 then
                        player:SetActiveCharge(itemsCharge - 1, i)
                        break
                    end
                elseif itemsCharge < 100 * (battery and 2 or 1) then
                    player:AddActiveCharge(1, i, false, true)
                    break
                end
            end
            if i == 3 and consumeCharge then
                ceffects:RemoveNullEffect(mod.NULL.PENDULUM) 
            end
        end
    end
end

mod:AddNewTearFlag(mod.CustomTearFlags.FLAG_PENDULUM, {
    ApplyLogic = function (_, player, tear)
        if player:HasCollectible(mod.ITEMS.PENDULUM) then
            return true
        end
    end,
})