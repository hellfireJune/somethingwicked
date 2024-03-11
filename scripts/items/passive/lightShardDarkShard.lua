local mod = SomethingWicked

local shardDelay = 2/3
local angleVariance = 35
local dmgMult = 1/3
local function UpdatePlayer(_, player)
    if not player:HasCollectible(mod.ITEMS.LIGHT_SHARD) and not player:HasCollectible(mod.ITEMS.DARK_SHARD) then
        return
    end
    local fireDirection = player:GetAimDirection()
    local p_data = player:GetData()

    p_data.sw_shardFireDelay = p_data.sw_shardFireDelay or 0
    if p_data.sw_shardFireDelay <= 0 and fireDirection:Length() ~= 0 then
        p_data.sw_shardFireDelay = player.MaxFireDelay*shardDelay

        local ang = math.sin(player.FrameCount/15)*angleVariance
        for i = -1, 1, 2 do
            local id = i == 1 and mod.ITEMS.LIGHT_SHARD or mod.ITEMS.DARK_SHARD
            local isLight = id == mod.ITEMS.LIGHT_SHARD

            local hearts = isLight and player:GetEffectiveMaxHearts() or 0
            if player:GetHearts() == hearts and player:HasCollectible(id) then
                local dir = fireDirection:Rotated(ang*i)
                local tear = player:FireTear(player.Position, mod:UtilGetFireVector(dir, player), true, false, false, nil, dmgMult)
                mod:ChangeTearVariant(tear, TearVariant.SOMETHINGWICKED_LIGHT_SHARD)
                tear:AddTearFlags(TearFlags.TEAR_HOMING)

                if not isLight then
                    tear.Color = tear.Color * Color(0.2, 0.2, 0.2)
                end
            end
        end
    end

    p_data.sw_shardFireDelay = p_data.sw_shardFireDelay - 1
end
mod:AddCallback(ModCallbacks.MC_POST_PEFFECT_UPDATE, UpdatePlayer)

mod:AddCustomCBack(mod.CustomCallbacks.SWCB_PICKUP_ITEM, function (_, player)
    player:AddEternalHearts(1)
end, mod.ITEMS.LIGHT_SHARD)