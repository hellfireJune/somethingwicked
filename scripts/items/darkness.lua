local this = {}
local mod = SomethingWicked
CollectibleType.SOMETHINGWICKED_DARKNESS = Isaac.GetItemIdByName("Darkness")

local otherSpeedMult = 0.25
mod.TFCore:AddNewFlagData(mod.CustomTearFlags.FLAG_DARKNESS, {
    ApplyLogic = function (_, player, tear)
        if player:HasCollectible(CollectibleType.SOMETHINGWICKED_DARKNESS) then
            return true
        end
    end,
    PostTearUpdate = function (_, tear)
        local player = mod:UtilGetPlayerFromTear(tear)
        if not player then
            return  
        end

        local t_data = tear:GetData()
        t_data.sw_drknessLastMult = t_data.sw_drknessLastMult or 1
        
        local phase = player:GetFireDirection() ~= Direction.NO_DIRECTION
        local expMult = phase and 1 or otherSpeedMult
        expMult = mod.EnemyHelpers:Lerp(t_data.sw_drknessLastMult, expMult, 0.4)
        expMult = math.max(1-((0.25*tear.FrameCount^2)/100), expMult)

        tear.Velocity = tear.Velocity * ((1 / t_data.sw_drknessLastMult) * expMult)
        t_data.sw_drknessLastMult = expMult
        t_data.sw_drknessPhase = phase
    end,
    OverrideTearCollision = function (_,tear,other)
        local t_data = tear:GetData()
        if t_data.sw_drknessPhase then
            if tear.FrameCount % 2 == 0 then
                other:TakeDamage(tear.CollisionDamage/5)
            end

            return true
        end
    end
})

this.EIDEntries = {
    [CollectibleType.SOMETHINGWICKED_DARKNESS] = {
        desc = "",
        Hide = true,
    }
}
return this