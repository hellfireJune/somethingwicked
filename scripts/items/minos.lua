local this = {}
CollectibleType.SOMETHINGWICKED_MINOS_ITEM = Isaac.GetItemIdByName("Minos")
FamiliarVariant.SOMETHINGWICKED_MINOS_HEAD = Isaac.GetEntityVariantByName("Minos (Head)")
FamiliarVariant.SOMETHINGWICKED_MINOS_BODY = Isaac.GetEntityVariantByName("Minos (Body)")
this.angleVariance = 15
this.MoveSpeed = 7
this.MinimumReturnDistance = 100
this.FrameDifferences = 2
this.Flags = 1 | 8 | 16

this.AnimationEnum = {
    [Vector(0, 1)] = "IdleDown",
    [Vector(-1, 0)] = "IdleLeft",
    [Vector(0, -1)] = "IdleUpward",
    [Vector(1, 0)] = "IdleRight",
}

function this:HeadInit(familiar)
    familiar.Parent = familiar.Parent or familiar.Player
end

--https://cdn.discordapp.com/attachments/907577522403803197/973850950261420052/attachment.gif
function this:HeadUpdate(familiar)
    local f_data = familiar:GetData()
    if f_data.somethingWicked_AttackFrameOne == nil then
        f_data.somethingWicked_AttackFrameOne = true
    end
    f_data.somethingwicked_visFrame = 2

    local player = familiar.Player
    local f_sprite = familiar:GetSprite()
    if player:GetFireDirection() ~= Direction.NO_DIRECTION then
        local lastTarget = familiar.Target
        familiar:PickEnemyTarget(80000, 5, this.Flags, player:GetAimDirection(), 45)
        if familiar.Target == nil
        and lastTarget ~= nil then
            familiar.Target = lastTarget
        end
    end

    if familiar.State == 0 or familiar.State == 1 then
        familiar.State = ((familiar.Target ~= nil and familiar.Target:Exists()) and 2 or 1)
    elseif familiar.State == 3 then 
        familiar.State = ((familiar.Target ~= nil and familiar.Target:Exists()) and 2 or 3)
    end

    f_data.somethingWicked_FramesSpentInSpeedyMode = f_data.somethingWicked_FramesSpentInSpeedyMode or 0
    local mult = math.max(1, math.min(1 + (f_data.somethingWicked_FramesSpentInSpeedyMode / 30), 1.5))
    local moveSpeed = this.MoveSpeed * mult
    local variance = this.angleVariance * mult

    if familiar.State == 1 then
        f_data.somethingWicked_FramesSpentInSpeedyMode = math.max(f_data.somethingWicked_FramesSpentInSpeedyMode - 1, 0)
        if familiar.Position:Distance(familiar.Player.Position) < this.MinimumReturnDistance then
            f_data.somethingWicked_AttackFrameOne = true
        else
            this:AngularMovementFunction(familiar, familiar.Player, moveSpeed, variance)
            if not f_data.somethingWicked_AttackFrameOne then
                familiar.State = 3
            else
            end
        end
    else
        local lastTarget = familiar.Target
        familiar:PickEnemyTarget(80000, 0, this.Flags, familiar.Velocity, 90)
        if familiar.Target == nil then
            familiar.Target = lastTarget
        end

        if familiar.State == 2 then

            if  familiar.Target and familiar.Target:Exists() then

                f_data.somethingWicked_FramesSpentInSpeedyMode = math.min(f_data.somethingWicked_FramesSpentInSpeedyMode + 1, 60)
                this:AngularMovementFunction(familiar, familiar.Target, moveSpeed, variance)
                f_data.somethingWicked_AttackFrameOne = false
            else
                familiar.State = 3
            end
        end
        if familiar.State == 3 then
            if familiar.Position:Distance(familiar.Player.Position) > this.MinimumReturnDistance then

                f_data.somethingWicked_FramesSpentInSpeedyMode = math.max(f_data.somethingWicked_FramesSpentInSpeedyMode - 1, 0)
                this:AngularMovementFunction(familiar, familiar.Player, moveSpeed, variance)
            else
                familiar.State = 1
            end
        end
    end
    
    local direction = familiar.Velocity:Normalized()
    local anim = "IdleDown" local diff = 999
    for key, value in pairs(this.AnimationEnum) do
        local currentDiff = (direction - key):Length()
        if currentDiff < diff then
            diff = currentDiff
            anim = value
        end
    end
    f_sprite:Play(anim, false)
    
    --Should this go in init instead? Maybe.
    --...maybe not?
    local bodyParts = Isaac.FindByType(EntityType.ENTITY_FAMILIAR, FamiliarVariant.SOMETHINGWICKED_MINOS_BODY)

    for index, value in ipairs(bodyParts) do
        if value.Parent == nil or value.Parent:Exists() == false
        or value.Parent.Type ~= EntityType.ENTITY_FAMILIAR then        
            if index == 1 then
                value.Parent = familiar
            else
                value.Parent = bodyParts[index - 1]
            end
        end
    end

    this:HandlePositionFramesTable(familiar)
end

function this:AngularMovementFunction(familiar, target, speed, variance)
    local enemypos = target.Position
        
    local angleToEnemy = (enemypos - familiar.Position):GetAngleDegrees()
    local angleVel = familiar.Velocity:GetAngleDegrees()

    local mult = math.max(math.min(math.abs(angleVel - angleToEnemy) / (5 * variance), 1), 0.5)
    local check = (math.abs(angleVel - angleToEnemy) < variance * mult and math.abs(angleVel - angleToEnemy) or nil)
    local vectorA = Vector.FromAngle((angleVel - (check == nil and variance * mult or check)))
    local vectorB = Vector.FromAngle((angleVel + (check == nil and variance * mult or check)))

    local differenceA = (Vector.FromAngle(angleToEnemy) - vectorA):Length()
    local differenceB = (Vector.FromAngle(angleToEnemy) - vectorB):Length()

    local vectorToUse = differenceA > differenceB and vectorB or vectorA
    familiar.Velocity = vectorToUse * speed
end

function this:BodyUpdate(familiar)
    local heads = Isaac.FindByType(EntityType.ENTITY_FAMILIAR, FamiliarVariant.SOMETHINGWICKED_MINOS_HEAD)
    if heads[1] == nil or not heads[1]:Exists() then
        familiar:Kill()
        local player = familiar.Player
        if player then
            
            player:AddCacheFlags(CacheFlag.CACHE_FAMILIARS)
            player:EvaluateItems()
        end
        return
    end

    if familiar.Parent == nil or familiar.Parent:Exists() == false then
        return
    end

    local p_data = familiar.Parent:GetData()
    local f_data = familiar:GetData()
    local roomFrame = SomethingWicked.game:GetRoom():GetFrameCount()
    local familiarFrame = familiar.FrameCount - 5
    local f_sprite = familiar:GetSprite()
    
    f_data.somethingWicked_PositionFramesTable = f_data.somethingWicked_PositionFramesTable or {}
    p_data.somethingWicked_PositionFramesTable = p_data.somethingWicked_PositionFramesTable or {}
    if f_data.somethingwicked_visFrame == nil and p_data.somethingwicked_visFrame ~= nil then
        f_data.somethingwicked_visFrame = p_data.somethingwicked_visFrame + (this.FrameDifferences * 2)
    end
    if (roomFrame >= this.FrameDifferences
    and familiarFrame >= this.FrameDifferences)
    and p_data.somethingWicked_PositionFramesTable[roomFrame - this.FrameDifferences] then
        familiar.Velocity = p_data.somethingWicked_PositionFramesTable[roomFrame - this.FrameDifferences] - familiar.Position
    else 
        familiar.Velocity = Vector.Zero
    end

    if f_data.somethingwicked_visFrame and 
    f_data.somethingwicked_visFrame == familiarFrame then
        local poof = Isaac.Spawn(EntityType.ENTITY_EFFECT, EffectVariant.POOF01, 0, familiar.Position, Vector.Zero, familiar)
        familiar.Visible = true
        f_sprite:Play("Idle", true)
    end

    this:HandlePositionFramesTable(familiar)
end

function this:HandlePositionFramesTable(familiar)
    local f_data = familiar:GetData()
    local room = SomethingWicked.game:GetRoom()
    local roomFrame = room:GetFrameCount()

    f_data.somethingWicked_PositionFramesTable = f_data.somethingWicked_PositionFramesTable or {}
    if roomFrame == 0 then
        f_data.somethingWicked_PositionFramesTable = {}
    end
    f_data.somethingWicked_PositionFramesTable[roomFrame] = familiar.Position
end

function this:OnCache(player)
    local rng = player:GetCollectibleRNG(CollectibleType.SOMETHINGWICKED_MINOS_ITEM)
    local sourceItem = Isaac.GetItemConfig():GetCollectible(CollectibleType.SOMETHINGWICKED_MINOS_ITEM)
    player:CheckFamiliar(FamiliarVariant.SOMETHINGWICKED_MINOS_HEAD, (player:HasCollectible(CollectibleType.SOMETHINGWICKED_MINOS_ITEM) and 1 or 0), rng, sourceItem)
    local boxEffect = player:GetEffects():GetCollectibleEffect(CollectibleType.COLLECTIBLE_BOX_OF_FRIENDS)
    local stacks = 0
    if boxEffect ~= nil then
        stacks = boxEffect.Count
    end

    stacks = (stacks + 1) * player:GetCollectibleNum(CollectibleType.SOMETHINGWICKED_MINOS_ITEM)
    player:CheckFamiliar(FamiliarVariant.SOMETHINGWICKED_MINOS_BODY, (stacks * 2) + (stacks > 0 and 2 - stacks or 0), rng, sourceItem)
end

function this:BodyInit(familiar)
    familiar.Visible = false
    familiar:ClearEntityFlags(EntityFlag.FLAG_APPEAR)
end

SomethingWicked:AddCallback(ModCallbacks.MC_EVALUATE_CACHE, this.OnCache, CacheFlag.CACHE_FAMILIARS)
SomethingWicked:AddCallback(ModCallbacks.MC_FAMILIAR_UPDATE, this.HeadUpdate, FamiliarVariant.SOMETHINGWICKED_MINOS_HEAD)
SomethingWicked:AddCallback(ModCallbacks.MC_FAMILIAR_INIT, this.HeadInit, FamiliarVariant.SOMETHINGWICKED_MINOS_HEAD)
SomethingWicked:AddCallback(ModCallbacks.MC_FAMILIAR_INIT, this.BodyInit, FamiliarVariant.SOMETHINGWICKED_MINOS_BODY)
SomethingWicked:AddCallback(ModCallbacks.MC_FAMILIAR_UPDATE, this.BodyUpdate, FamiliarVariant.SOMETHINGWICKED_MINOS_BODY)

this.EIDEntries = {
    [CollectibleType.SOMETHINGWICKED_MINOS_ITEM] = {
        desc = "Spawns a snake familiar which charges at enemies you fire in the direction of",
        pools = {
            SomethingWicked.encyclopediaLootPools.POOL_DEVIL,
            SomethingWicked.encyclopediaLootPools.POOL_BABY_SHOP,
            SomethingWicked.encyclopediaLootPools.POOL_GREED_DEVIL,
            SomethingWicked.encyclopediaLootPools.POOL_ULTRA_SECRET
        },
        encycloDesc = SomethingWicked:UtilGenerateWikiDesc({"Spawns a snake familiar which charges at enemies you fire in the direction of"})
    }
}
return this