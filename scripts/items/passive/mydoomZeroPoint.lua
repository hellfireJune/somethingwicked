local mod = SomethingWicked
local game = Game()

local function getSplitPos(pos, vel, tear)
    local room = game:GetRoom()
    local gridAtPos = room:GetGridEntityFromPos(pos)
    if gridAtPos and gridAtPos.CollisionClass > GridCollisionClass.COLLISION_PIT then
        local gridPos = gridAtPos.Position
        pos = gridPos + ((pos-gridPos) - vel:Normalized()*24)
    end
    return pos
end

--why did i call this that LOL
local function edge(tear, nt)
    local easeEdge = tear.PositionOffset-nt.PositionOffset
    nt:GetData().sw_edgingOffset = easeEdge
end
local function endHitSplit(flag, tear, pos, player)
    pos = getSplitPos(pos, tear.Velocity, tear)
    if flag == mod.CustomTearFlags.FLAG_ULTRASPLIT then
        if not tear:HasTearFlags(TearFlags.TEAR_BURSTSPLIT) then
            for i = 1, 6, 1 do
                local vec = Vector.FromAngle(i*60)*player.ShotSpeed*10
                local nt = mod:SpawnTearSplit(tear, player, pos, vec, 0.5)
                edge(tear, nt)
            end
        end
    elseif flag == mod.CustomTearFlags.FLAG_ORBITSPLIT and not tear:GetData().sw_isHaemoSplitShot then
        local nt = mod:SpawnTearSplit(tear, player, pos, tear.Velocity:Rotated(180), 0.8)
        mod:addWickedTearFlag(nt, mod.CustomTearFlags.FLAG_ORBITSPLIT)
        nt:AddTearFlags(TearFlags.TEAR_ORBIT_ADVANCED | TearFlags.TEAR_SPECTRAL)
        nt.Color = nt.Color * Color(-1,-1,-1,1,1,0,0)
        edge(tear, nt)
    end
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
        endHitSplit(mod.CustomTearFlags.FLAG_ULTRASPLIT, tear, pos, player)
    end
})
mod:AddNewTearFlag(mod.CustomTearFlags.FLAG_ORBITSPLIT, {
    ApplyLogic = function (_, player, tear)
        if player:HasCollectible(mod.ITEMS.ZERO_POINT_REACTOR) then
            if tear.Parent and tear.Parent.Type == EntityType.ENTITY_PLAYER then
                return true
            end
        end
    end,
    EndHitEffect = function (_, tear, pos, player)
        if tear.Parent and tear.Parent.Type == EntityType.ENTITY_PLAYER then
            endHitSplit(mod.CustomTearFlags.FLAG_ORBITSPLIT, tear, pos, player)
        end
    end,
    OverrideTearUpdate = function (_, tear)
        if not tear.Parent then
            mod:MultiplyTearFall(tear, "sw_zeroPoint", 0.5)
        end
    end,
})