local this = {}
EffectVariant.SOMETHINGWICKED_DREAD_POOF = Isaac.GetEntityVariantByName("Dread Poof")

this.baseProcChance = 0.15
function this:OnHitFunc(tear, collider, player, proc)
    local t_data = tear:GetData()
    if t_data.somethingWicked_applyingDread then
        SomethingWicked:UtilAddDread(collider, 1)
    end
end

local function ProcChance(player)
    return (player.Luck >= 0 and (this.baseProcChance * ((player.Luck + 0.5) / 2)) or (this.baseProcChance / math.abs(player.Luck)))
end

function this:FireTear(tear)
    local player = SomethingWicked:UtilGetPlayerFromTear(tear)
    if player and player:HasCollectible(CollectibleType.SOMETHINGWICKED_CRYING_MINOTAUR) then 
        local c_rng = player:GetCollectibleRNG(CollectibleType.SOMETHINGWICKED_CRYING_MINOTAUR)
        local procChance = ProcChance(player)
        if c_rng:RandomFloat() < procChance then
            tear.Color = this.DreadStatusColor
            local t_data = tear:GetData()
            t_data.somethingWicked_applyingDread = true
        end
    end
end

function this:FireLaser(laser, player, pure)
    if not pure then
        return
    end
    if player and player:HasCollectible(CollectibleType.SOMETHINGWICKED_CRYING_MINOTAUR) then 
        local c_rng = player:GetCollectibleRNG(CollectibleType.SOMETHINGWICKED_CRYING_MINOTAUR)
        local procChance = ProcChance(player)
        if c_rng:RandomFloat() < procChance then
            laser.Color = this.DreadStatusColor
            local p_data = player:GetData()
            p_data.somethingWicked_applyingDread = true

            local l_data = laser:GetData()
            l_data.somethingWicked_dreadLaser = true
        end
    end
end

SomethingWicked:AddCallback(ModCallbacks.MC_POST_ENTITY_REMOVE, function (_, laser)
    local l_data = laser:GetData()
    if l_data.somethingWicked_dreadLaser
    and laser.Parent then
        laser.Parent:GetData().somethingWicked_applyingDread = false
        
    end
end, EntityType.ENTITY_LASER)

SomethingWicked:AddCustomCBack(SomethingWicked.CustomCallbacks.SWCB_ON_ENEMY_HIT, this.OnHitFunc)
SomethingWicked:AddCustomCBack(SomethingWicked.CustomCallbacks.SWCB_ON_LASER_FIRED, this.FireLaser)
SomethingWicked:AddCallback(ModCallbacks.MC_POST_FIRE_TEAR, this.FireTear)

this.EIDEntries = {}
return this