local mod = SomethingWicked

local function getSplitPos(pos, vel)
    
end

mod:AddNewTearFlag(mod.CustomTearFlags.FLAG_ULTRASPLIT, {
    ApplyLogic = function (_, player, tear)
        if player:HasCollectible(mod.ITEMS.MY_DOOM) then
            --local c_rng = player:GetCollectibleRNG(mod.ITEMS.MY_DOOM)
            if tear.Parent and tear.Parent.Type == EntityType.ENTITY_PLAYER then
                local p_data = player:GetData()
                p_data.WickedPData.splitCount = (p_data.WickedPData.splitCount or 1) + 1
                if p_data.WickedPData.splitCount >= 3 then
                    p_data.WickedPData.splitCount = 0
                    return true
                end
            end
        end
    end,
    EndHitEffect = function (_, tear, pos, player)
        if not tear:HasTearFlags(TearFlags.TEAR_BURSTSPLIT) then
            pos = getSplitPos(pos, tear.Velocity)
            for i = 1, 6, 1 do
                local vec = Vector.FromAngle(i*60)*player.ShotSpeed*10
                local nt = mod:SpawnTearSplit(tear, player, pos, vec, 0.5)
            end
        end
    end
})