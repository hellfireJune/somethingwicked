local this = {}
CollectibleType.SOMETHINGWICKED_MINOS_ITEM = Isaac.GetItemIdByName("Minos")
FamiliarVariant.SOMETHINGWICKED_MINOS_HEAD = Isaac.GetEntityVariantByName("Minos (Head)")
FamiliarVariant.SOMETHINGWICKED_MINOS_BODY = Isaac.GetEntityVariantByName("Minos (Body)")
this.angleVariance = 10
this.MoveSpeed = 6
this.MinimumReturnDistance = 100
this.FrameDifferences = 1
this.Flags = 1 | 8 | 16

CollectibleType.SOMETHINGWICKED_HYDRA = Isaac.GetItemIdByName("Hydra")

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
    f_data.somethingwicked_visFrame = 2

    local player = familiar.Player
    local f_sprite = familiar:GetSprite()
    familiar.State = this:HeadMovementFunc(familiar, familiar.State, familiar.Target, player)
    if player:GetFireDirection() ~= Direction.NO_DIRECTION then
        local lastTarget = familiar.Target
        familiar:PickEnemyTarget(80000, 5, this.Flags, player:GetAimDirection(), 45)
        if familiar.Target == nil
        and lastTarget ~= nil then
            familiar.Target = lastTarget
        end
    end
    
    if familiar.State > 1 then
        
        local lastTarget = familiar.Target
        familiar:PickEnemyTarget(80000, 0, this.Flags, familiar.Velocity, 135)
        if familiar.Target == nil then
            familiar.Target = lastTarget
        end
    end

    local direction = familiar.Velocity:Normalized()
    local anim = "IdleDown" local diff = 999
    for key, value in pairs(this.AnimationEnum) do
        local currentDiff = math.abs(SomethingWicked.EnemyHelpers:GetAngleDifference(key, direction))
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

    if familiar.Velocity.X == Vector.Zero.X
    and familiar.Velocity.Y == Vector.Zero.Y then
        familiar.Velocity = Vector(this.MoveSpeed, 0)
    end

    f_data.somethingWicked_PositionFramesTable = this:HandlePositionFramesTable(familiar, SomethingWicked.game:GetRoom():GetFrameCount(), f_data.somethingWicked_PositionFramesTable and f_data.somethingWicked_PositionFramesTable or {})
end

function this:HeadMovementFunc(familiar, state, target, player)
    local f_data = familiar:GetData()
    f_data.somethingWicked_SpeedMult = f_data.somethingWicked_SpeedMult or 1
    local moveSpeed = this.MoveSpeed * f_data.somethingWicked_SpeedMult
    local variance = this.angleVariance 

    if state == 0 or state == 1
    or state == nil then
        state = ((familiar.Target ~= nil and familiar.Target:Exists()) and 2 or 1)
    elseif state == 3 then 
        state = ((familiar.Target ~= nil and familiar.Target:Exists()) and 2 or 3)
    end
    if state == 1 then
        if familiar.Position:Distance(player.Position) > this.MinimumReturnDistance then
            SomethingWicked.EnemyHelpers:AngularMovementFunction(familiar, player, moveSpeed, variance * 3, 0.3)
        end
    else

        if state == 2 then

            if  target and target:Exists() then

                local distance = target.Position:Distance(familiar.Position)
                local varMult = math.min((distance/10), 5)
                SomethingWicked.EnemyHelpers:AngularMovementFunction(familiar, target, moveSpeed, variance * (3.5 + varMult), 0.3)
            else
                state = 3
            end
        end
        if state == 3 and (familiar.Target == nil or not familiar.Target:Exists()) then
            if familiar.Position:Distance(player.Position) > this.MinimumReturnDistance then

                SomethingWicked.EnemyHelpers:AngularMovementFunction(familiar, player, moveSpeed, variance * 3, 0.3)
            else
                state = 1
            end
        end
    end

    local intendedMult = (state == 2 and 2 or 1)
    f_data.somethingWicked_SpeedMult = SomethingWicked.EnemyHelpers:Lerp(f_data.somethingWicked_SpeedMult, intendedMult, 0.1)

    return state
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
    p_data.somethingWicked_PositionFramesTable = p_data.somethingWicked_PositionFramesTable or {}
    if f_data.somethingwicked_visFrame == nil and p_data.somethingwicked_visFrame ~= nil then
        f_data.somethingwicked_visFrame = math.max(0, (p_data.somethingwicked_visFrame - familiar.Parent.FrameCount + 5)) + (this.FrameDifferences * 2)
    end
    this:FollowPositionFramesTable(p_data.somethingWicked_PositionFramesTable, familiar, roomFrame, this.FrameDifferences)

    if f_data.somethingwicked_visFrame and 
    f_data.somethingwicked_visFrame == familiarFrame then
        Isaac.Spawn(EntityType.ENTITY_EFFECT, EffectVariant.POOF01, 0, familiar.Position, Vector.Zero, familiar)
        familiar.Visible = true
        f_sprite:Play("Idle", true)
    end

    f_data.somethingWicked_PositionFramesTable = this:HandlePositionFramesTable(familiar, roomFrame, f_data.somethingWicked_PositionFramesTable and f_data.somethingWicked_PositionFramesTable or {})
end

function this:GenerateVisFrame(parent, oldVisFrame)
    return math.max(0, (oldVisFrame - parent.FrameCount + 5)) + (this.FrameDifferences * 2)
end

function this:FollowPositionFramesTable(frameTable, familiar, roomFrame, frameDiff)
    if (roomFrame >= frameDiff
    and familiar.FrameCount - 5 >= frameDiff)
    and frameTable[roomFrame - frameDiff] then
        familiar.Velocity = frameTable[roomFrame - frameDiff] - familiar.Position
    else 
        familiar.Velocity = Vector.Zero
    end
end

function this:HandlePositionFramesTable(familiar, roomFrame, fTable)
    fTable = fTable or {}
    if roomFrame == 0 then
        fTable = {}
    end
    fTable[roomFrame] = familiar.Position
    return fTable
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

SomethingWicked.enums.SnakeTearType = {
    SNAKE_HYDRA = 1,
    SNAKE_HYDRUS = 2,
}
--Hydra
function this:HydraTearUpdate(tear)
    local t_data = tear:GetData()
    if t_data.snakeTearData == nil then
        return
    end

    if tear.Parent == nil then
        t_data.snakeTearData.isHead = true

        if t_data.snakeTearData.type == SomethingWicked.enums.SnakeTearType.SNAKE_HYDRA then
            local c = tear.Color
            tear:AddTearFlags(TearFlags.TEAR_HOMING)
            tear.Color = tear.Color
        end
    end

    local rf = SomethingWicked.game:GetRoom():GetFrameCount()
    if t_data.snakeTearData.isHead then
        t_data.snakeTearData.state = this:HeadMovementFunc(tear, t_data.snakeTearData.state, tear.Target, tear.SpawnerEntity)
        tear.Velocity = tear.Velocity:Resized(this.MoveSpeed)
    else
        local p_data = tear.Parent:GetData()
        if p_data.snakeTearData and p_data.snakeTearData.posFramesTable then
            this:FollowPositionFramesTable(p_data.snakeTearData.posFramesTable, tear, rf, this.FrameDifferences)
        end
    end
    t_data.snakeTearData.posFramesTable = this:HandlePositionFramesTable(tear, rf, t_data.snakeTearData.posFramesTable)

    tear.FallingSpeed = 0
    tear.Height = -20
end

this.flagsToClearIfOnBody = TearFlags.TEAR_WIGGLE | TearFlags.TEAR_SPIRAL | TearFlags.TEAR_ORBIT| TearFlags.TEAR_SQUARE| TearFlags.TEAR_BIG_SPIRAL| TearFlags.TEAR_ORBIT_ADVANCED | TearFlags.TEAR_TURN_HORIZONTAL| TearFlags.TEAR_LUDOVICO
function this:HydraPlayerUpdate(player)
    if player:HasCollectible(CollectibleType.SOMETHINGWICKED_HYDRA) then
        local p_data = player:GetData()
        if not p_data.somethingwicked_HydraTear or
        not p_data.somethingwicked_HydraTear:Exists()then
            local lastTear = nil
            local lastTearData = nil
            for i = 1, 10, 1 do
                local nt = player:FireTear(player.Position, Vector(1, 0), false, false, false, nil, 2)
                nt:AddTearFlags(TearFlags.TEAR_SPECTRAL)
                nt:ClearTearFlags(TearFlags.TEAR_PIERCING)

                local ntd = nt:GetData()
                ntd.snakeTearData = {}
                ntd.snakeTearData.type = SomethingWicked.enums.SnakeTearType.SNAKE_HYDRA
                if lastTear then
                    nt.Parent = lastTear
                    ntd.snakeTearData.visFrame = this:GenerateVisFrame(lastTear, lastTearData.snakeTearData.visFrame)
                    lastTear.Child = nt
                    nt:ClearTearFlags(this.flagsToClearIfOnBody)
                else
                    ntd.snakeTearData.isHead = true
                    ntd.snakeTearData.visFrame = 2
                    p_data.somethingwicked_HydraTear = nt 
                    nt:AddTearFlags(TearFlags.TEAR_HOMING)
                end
                lastTear = nt
                lastTearData = ntd
            end
        end
    end
end

function this:HydraTearRemove(tear)
    local t_data = tear:GetData()
    if t_data.snakeTearData == nil
    or t_data.snakeTearData.type ~= SomethingWicked.enums.SnakeTearType.SNAKE_HYDRA then
        return
    end

    local spwnr = tear.SpawnerEntity
    if spwnr == nil then
        return
    end
    local s_data = spwnr:GetData()
    if tear.Child then
        s_data.somethingwicked_HydraTear = tear.Child
    else
        local allTears = Isaac.FindByType(EntityType.ENTITY_TEAR)
        for index, nt in ipairs(allTears) do
            if GetPtrHash(spwnr) == GetPtrHash(nt.SpawnerEntity) then
                local n_data = nt:GetData()
                if n_data.snakeTearData
                and n_data.snakeTearData.type == SomethingWicked.enums.SnakeTearType.SNAKE_HYDRA then
                    s_data.somethingwicked_HydraTear = nt
                    break
                end
            end
        end
    end
end

SomethingWicked:AddCallback(ModCallbacks.MC_POST_PEFFECT_UPDATE, this.HydraPlayerUpdate)
SomethingWicked:AddCallback(ModCallbacks.MC_POST_TEAR_UPDATE, this.HydraTearUpdate)
SomethingWicked:AddCallback(ModCallbacks.MC_POST_ENTITY_REMOVE, this.HydraTearRemove, EntityType.ENTITY_TEAR)

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