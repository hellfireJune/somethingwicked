local mod = SomethingWicked

local otherSpeedMult = 0.15
mod:AddNewTearFlag(mod.CustomTearFlags.FLAG_DARKNESS, {
    ApplyLogic = function (_, player, tear)
        if player:HasCollectible(CollectibleType.SOMETHINGWICKED_DARKNESS) then
            return true
        end
    end,
    OverrideTearUpdate = function (_, tear)
        local player = mod:UtilGetPlayerFromTear(tear)
        if not player then
            return  
        end

        local t_data = tear:GetData()
        t_data.sw_drknessLastMult = t_data.sw_drknessLastMult or 1
        
        local phase = player:GetFireDirection() == Direction.NO_DIRECTION
        local expMult = phase and 1 or otherSpeedMult
        expMult = mod:Lerp(t_data.sw_drknessLastMult, expMult, 0.7)
        local frames = math.max(0, tear.FrameCount-3)
        expMult = math.max(1-((0.25*frames^2)/12.5), expMult)

        t_data.sw_drknessLastMult = mod:MultiplyTearVelocity(tear, "sw_darkness", expMult)
        t_data.sw_drknessPhase = phase
         
    end,
    OverrideTearCollision = function (_,tear,other)
        local t_data = tear:GetData()
        if not t_data.sw_drknessPhase then
            if tear.FrameCount % 2 == 0 then
                other:TakeDamage(tear.CollisionDamage/5, 0, EntityRef(tear), 1)
            end

            return true
        end
    end
})

--[[this.EIDEntries = {
    [CollectibleType.SOMETHINGWICKED_DARKNESS] = {
        desc = "",
        Hide = true,
    }
}
return this]]