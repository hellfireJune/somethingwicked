local mod = SomethingWicked

function mod:UsePendulum(_, player)
    --if not owned, make it give the player a stack of the temporary effect so itd work with like dead sea scrolls (item) and stuff
    local ceffects = player:GetEffects()
    if ceffects:HasNullEffect(mod.NULL.PENDULUM) then
        ceffects:RemoveNullEffect(mod.NULL.PENDULUM) 
    else
        ceffects:AddNullEffect(mod.NULL.PENDULUM) 
    end

    return { ShowAnim = true, Discharge = false}
end

function mod:PendulumPlayerUpdate(player)
    local p_data = player:GetData()
    p_data.sw_pendulumMe = nil
    if player:HasCollectible(mod.ITEMS.PENDULUM) then
        local ceffects = player:GetEffects()
        local consumeCharge = ceffects:HasNullEffect(mod.NULL.PENDULUM)
        if consumeCharge then
            p_data.sw_pendulumMe = true
        end
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

local chargeTime = 30
mod:AddNewTearFlag(mod.CustomTearFlags.FLAG_PENDULUM, {
    ApplyLogic = function (_, player, tear)
        if player:HasCollectible(mod.ITEMS.PENDULUM) then
            return true
        end
    end,
    OverrideTearUpdate = function (_, tear)
        local t_data = tear:GetData()
        local cachedPlayer = t_data.sw_cachedPendulumPlayer
        local p_data = cachedPlayer:GetData()
        if p_data.sw_pendulumMe then
            t_data.sw_pendulumCharge = (t_data.sw_pendulumCharge or 0) + 1
            if t_data.sw_pendulumCharge > chargeTime then
                if not t_data.sw_pendulumMega then
                    t_data.sw_pendulumMega = true
                    tear.Damage = tear.Damage * 2
                end
            else
                
            end
            t_data.sw_drknessLastMult = mod:MultiplyTearVelocity(tear, "sw_pendulum", 0.01, true)
        else
            if t_data.sw_pendulumCharge ~= nil and t_data.sw_pendulumCharge > 0 then
                
            end
            t_data.sw_drknessLastMult = mod:MultiplyTearVelocity(tear, "sw_pendulum", 1, true)
            t_data.sw_pendulumCharge = 0
        end
    end,
    PostApply = function (_, player, tear)
        tear:GetData().sw_cachedPendulumPlayer = mod:UtilGetPlayerFromTear(player)
    end
})