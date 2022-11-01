local this = {}
CollectibleType.SOMETHINGWICKED_CRYING_MINOTAUR = Isaac.GetItemIdByName("Crying Minotaur")
this.dreadColor = Color(1, 1, 1, 1, 0.4)

this.baseProcChance = 0.15
function this:OnHitFunc(tear, collider, player, proc)
    local t_data = tear:GetData()
    if t_data.somethingWicked_applyingDread then
        SomethingWicked:UtilAddDread(collider, 1)
    end
end

local function ProcChance(player)
    return (player.Luck >= 0 and (this.baseProcChance * (player.Luck / 2)) or (this.baseProcChance / math.abs(player.Luck)))
end

function this:FireTear(tear)
    local player = SomethingWicked:UtilGetPlayerFromTear(tear)
    if player and player:HasCollectible(CollectibleType.SOMETHINGWICKED_CRYING_MINOTAUR) then 
        local c_rng = player:GetCollectibleRNG(CollectibleType.SOMETHINGWICKED_CRYING_MINOTAUR)
        local procChance = ProcChance(player)
        if c_rng:RandomFloat() < procChance then
            tear.Color = this.dreadColor
            local t_data = tear:GetData()
            t_data.somethingWicked_applyingDread = true
        end
    end
end

function this:FireLaser(laser, player)
    if player and player:HasCollectible(CollectibleType.SOMETHINGWICKED_CRYING_MINOTAUR) then 
        local c_rng = player:GetCollectibleRNG(CollectibleType.SOMETHINGWICKED_CRYING_MINOTAUR)
        local procChance = ProcChance(player)
        if c_rng:RandomFloat() < procChance then
            laser.Color = this.dreadColor
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

function SomethingWicked:UtilAddDread(ent, stacks)
    local e_data = ent:GetData()
    
    e_data.somethingWicked_dreadStacks = (e_data.somethingWicked_dreadStacks or 0) + stacks

    e_data.somethingWicked_dreadDelay = 1
end

this.takingDreadDMG = false
function this:OnEnemyTakeDMG(ent, amount, flags, source, dmgCooldown)
    local e_data = ent:GetData()
    e_data.somethingWicked_dreadStacks = e_data.somethingWicked_dreadStacks or 0
    e_data.somethingWicked_dreadDelay = e_data.somethingWicked_dreadDelay or 0
    if e_data.somethingWicked_dreadDelay > 0
    and e_data.somethingWicked_dreadStacks <= 1 then
        return
    end
    if e_data.somethingWicked_dreadStacks > 0
    and not this.takingDreadDMG then
        this.takingDreadDMG = true
        ent:TakeDamage(amount * 2, flags, EntityRef(ent), dmgCooldown)
        this.takingDreadDMG = false

        e_data.somethingWicked_dreadStacks = e_data.somethingWicked_dreadStacks - 1
        return false
    end
end

function this:NPCUpdate(ent)
    local e_data = ent:GetData()
    e_data.somethingWicked_dreadDelay = e_data.somethingWicked_dreadDelay or 0
    if e_data.somethingWicked_dreadDelay > 0 then 
        e_data.somethingWicked_dreadDelay = e_data.somethingWicked_dreadDelay - 1
    end

    e_data.somethingWicked_dreadStacks = e_data.somethingWicked_dreadStacks or 0
    if e_data.somethingWicked_dreadStacks > 0 then
        ent:SetColor(this.dreadColor, 2, 1, false, false)
    end
end

SomethingWicked:AddCustomCBack(SomethingWicked.CustomCallbacks.SWCB_ON_ENEMY_HIT, this.OnHitFunc)
SomethingWicked:AddCustomCBack(SomethingWicked.CustomCallbacks.SWCB_ON_LASER_FIRED, this.FireLaser)
SomethingWicked:AddCallback(ModCallbacks.MC_ENTITY_TAKE_DMG, this.OnEnemyTakeDMG)
SomethingWicked:AddCallback(ModCallbacks.MC_NPC_UPDATE, this.NPCUpdate)
SomethingWicked:AddCallback(ModCallbacks.MC_POST_FIRE_TEAR, this.FireTear)

this.EIDEntries = {}
return this