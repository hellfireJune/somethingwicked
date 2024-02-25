local mod = SomethingWicked

TearVariant.SOMETHINGWICKED_LIGHT_SHARD = 1
TearVariant.SOMETHINGWICKED_DARK_SHARD = 2

local shardDelay = 2/5
local angleVariance = 25
function this:UpdatePlayer(player)
    if not player:HasCollectible(mod.ITEMS.LIGHT_SHARD) and not player:HasCollectible(mod.ITEMS.DARK_SHARD) then
        return
    end
    local fireDirection = player:GetAimDirection()
    local p_data = player:GetData()

    p_data.sw_shardFireDelay = p_data.sw_shardFireDelay or 0
    if p_data.sw_shardFireDelay <= 0 and fireDirection:Length() ~= 0 then
        p_data.sw_shardFireDelay = player.MaxFireDelay*shardDelay

        local ang = math.sin(player.FrameCount/10)*angleVariance
        for i = -1, 2, 1 do
            local id = i == 1 and mod.ITEMS.LIGHT_SHARD or mod.ITEMS.DARK_SHARD
            local isLight = id == mod.ITEMS.LIGHT_SHARD

            local hearts = isLight and player:GetEffectiveMaxHearts() or 0
            if player:GetHearts() == hearts then
                local dir = fireDirection:Rotated(ang*i)
                local tear = player:FireTear(player.Position, mod:UtilGetFireVector(dir, player), true, false, false)
                tear:ChangeVariant(isLight and TearVariant.SOMETHINGWICKED_LIGHT_SHARD or TearVariant.SOMETHINGWICKED_DARK_SHARD)
                tear:AddTearFlags(TearFlags.TEAR_HOMING)
            end
        end
    end

    p_data.sw_shardFireDelay = p_data.sw_shardFireDelay - 1
end
mod:AddCallback(ModCallbacks.MC_POST_PEFFECT_UPDATE, this.UpdatePlayer)

mod:AddCustomCBack(mod.CustomCallbacks.SWCB_PICKUP_ITEM, function (_, player)
    player:AddEternalHearts(1)
end, mod.ITEMS.LIGHT_SHARD)

this.EIDEntries = {
    [mod.ITEMS.LIGHT_SHARD] = {
        Hide = true,
    },
    [mod.ITEMS.DARK_SHARD] = {
        Hide = true,
    }
}
return this