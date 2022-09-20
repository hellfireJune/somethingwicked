local this = {}
CollectibleType.SOMETHINGWICKED_MINOS_ITEM = Isaac.GetItemIdByName("Minos")
FamiliarVariant.SOMETHINGWICKED_MINOS_HEAD = Isaac.GetEntityVariantByName("Minos (Head)")
FamiliarVariant.SOMETHINGWICKED_MINOS_BODY = Isaac.GetEntityVariantByName("Minos (Body)")
this.angleVariance = 10
this.MoveSpeed = 6
this.MinimumReturnDistance = 100
this.FrameDifferences = 1
this.Flags = 1 | 8 | 16

CollectibleType.SOMETHINGWICKED_HYDRUS = Isaac.GetItemIdByName("Hydrus")
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
    if familiar.State == 0 or familiar.State == 1 then
        familiar.State = ((familiar.Target ~= nil and familiar.Target:Exists()) and 2 or 1)
    elseif familiar.State == 3 then 
        familiar.State = ((familiar.Target ~= nil and familiar.Target:Exists()) and 2 or 3)
    end
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

    local fLength = familiar.Velocity:Length()
    if fLength == 0 then
        familiar.Velocity = Vector(this.MoveSpeed, 0)
    end

    f_data.somethingWicked_PositionFramesTable = this:HandlePositionFramesTable(familiar, this.CachedRoom:GetFrameCount(), f_data.somethingWicked_PositionFramesTable or {})
end

function this:HeadMovementFunc(familiar, state, target, player)
    local f_data = familiar:GetData()
    f_data.somethingWicked_SpeedMult = f_data.somethingWicked_SpeedMult or 1
    local moveSpeed = this.MoveSpeed * f_data.somethingWicked_SpeedMult
    local variance = this.angleVariance 
    state = state or 1
    if state == 1 then
        if familiar.Position:Distance(player.Position) > this.MinimumReturnDistance then
            SomethingWicked.EnemyHelpers:AngularMovementFunction(familiar, player, moveSpeed, variance * 3, 0.3)
        end
    else

        if state == 2 then
            if target and target:Exists() then

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
    local f_frame = familiar.FrameCount
    local roomFrame = this.CachedRoom:GetFrameCount()
    local f_sprite = familiar:GetSprite()
    p_data.somethingWicked_PositionFramesTable = p_data.somethingWicked_PositionFramesTable or {}
    if f_data.somethingwicked_visFrame == nil and p_data.somethingwicked_visFrame ~= nil then
        f_data.somethingwicked_visFrame = math.max(0, (p_data.somethingwicked_visFrame - familiar.Parent.FrameCount + 5)) + (this.FrameDifferences * 2)
    end
    this:FollowPositionFramesTable(p_data.somethingWicked_PositionFramesTable, familiar, roomFrame, this.FrameDifferences)

    f_data.somethingWicked_PositionFramesTable = this:HandlePositionFramesTable(familiar, roomFrame, f_data.somethingWicked_PositionFramesTable or {})

    if this:HandleVisFrame(familiar, f_data, f_frame) then
        f_sprite:Play("Idle", true)
    end
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

function this:HandleVisFrame(familiar, f_data, frame)
    if f_data.somethingwicked_visFrame and 
    f_data.somethingwicked_visFrame == frame then
        Isaac.Spawn(EntityType.ENTITY_EFFECT, EffectVariant.POOF01, 0, familiar.Position, Vector.Zero, familiar)
        familiar.Visible = true
        return true
    end
end

SomethingWicked:AddCallback(ModCallbacks.MC_EVALUATE_CACHE, this.OnCache, CacheFlag.CACHE_FAMILIARS)
SomethingWicked:AddCallback(ModCallbacks.MC_FAMILIAR_UPDATE, this.HeadUpdate, FamiliarVariant.SOMETHINGWICKED_MINOS_HEAD)
SomethingWicked:AddCallback(ModCallbacks.MC_FAMILIAR_INIT, this.HeadInit, FamiliarVariant.SOMETHINGWICKED_MINOS_HEAD)
SomethingWicked:AddCallback(ModCallbacks.MC_FAMILIAR_INIT, this.BodyInit, FamiliarVariant.SOMETHINGWICKED_MINOS_BODY)
SomethingWicked:AddCallback(ModCallbacks.MC_FAMILIAR_UPDATE, this.BodyUpdate, FamiliarVariant.SOMETHINGWICKED_MINOS_BODY)

SomethingWicked.enums.SnakeTearType = {
    SNAKE_HYDRUS = 1,
    SNAKE_HYDRA = 2,
}
--Hydrus

this.CachedRoom = nil
if SomethingWicked.game:GetFrameCount() > 0 then
    this.CachedRoom = SomethingWicked.game:GetRoom()
end
function this:HydrusTearUpdate(tear)
    local t_data = tear:GetData()
    if t_data.snakeTearData == nil then
        return
    end
    local s = tear.SpawnerEntity
    local s_data = s:GetData()

    if tear.Parent == nil
    and not t_data.snakeTearData.isHead then
        if not tear.Visible then
            tear:Remove()
            return
        end
        t_data.snakeTearData.isHead = true

        if t_data.snakeTearData.type == SomethingWicked.enums.SnakeTearType.SNAKE_HYDRUS then
            local c = tear.Color
            tear:AddTearFlags(TearFlags.TEAR_HOMING)
            tear.Color = tear.Color
        else
            if #s_data.somethingwicked_HydraTears > this.maxHydraSnakes then
                tear:Remove()
            end
            table.insert(s_data.somethingwicked_HydraTears, tear)
        end
    end

    local rf = this.CachedRoom:GetFrameCount()
    if t_data.snakeTearData.isHead then
        t_data.snakeTearData.state = this:HeadMovementFunc(tear, t_data.snakeTearData.state, tear.Target, tear.SpawnerEntity)
        if tear.Velocity:Length() == 0 then
            tear.Velocity = Vector(0,1)
        end
        tear.Velocity = tear.Velocity:Resized(this.MoveSpeed)

        if t_data.snakeTearData.type == SomethingWicked.enums.SnakeTearType.SNAKE_HYDRA then
            if t_data.snakeTearData.cachedLength
            and t_data.snakeTearData.cachedLastTear and t_data.snakeTearData.cachedLastTear:Exists() then
                t_data.snakeTearData.hydraRegenCooldown = t_data.snakeTearData.hydraRegenCooldown or 0
                if t_data.snakeTearData.cachedLength < this.hydraLength
                and t_data.snakeTearData.hydraRegenCooldown == 0 then
                    t_data.snakeTearData.hydraRegenCooldown = 15
                    t_data.snakeTearData.cachedLength = nil

                    this:MakeTearSnake(s:ToPlayer(), s_data, SomethingWicked.enums.SnakeTearType.SNAKE_HYDRA, 0.5, 1, t_data.snakeTearData.cachedLastTear)
                end

                if t_data.snakeTearData.hydraRegenCooldown > 0 then
                    t_data.snakeTearData.hydraRegenCooldown = t_data.snakeTearData.hydraRegenCooldown - 1 
                end
            else
                local length, lt = this:GetSnakeTearLength(tear)
                t_data.snakeTearData.cachedLength = length
                t_data.snakeTearData.cachedLastTear = lt
            end
        end
    else
        local p_data = tear.Parent:GetData()
        if p_data.snakeTearData and p_data.snakeTearData.posFramesTable then
            this:FollowPositionFramesTable(p_data.snakeTearData.posFramesTable, tear, rf, this.FrameDifferences)
        end
    end
    t_data.snakeTearData.posFramesTable = this:HandlePositionFramesTable(tear, rf, t_data.snakeTearData.posFramesTable)

    if not tear.Visible then
        local tf = tear.FrameCount
        this:HandleVisFrame(tear, t_data, tf)
    end
    tear.FallingSpeed = 0
    tear.Height = -20
end

function this:GetSnakeTearLength(tear)
    local nt = tear
    for j = 1, 10, 1 do
        if nt.Child then
            nt = nt.Child
        else
            return j, nt
        end
    end
end

this.minHydraSnakes = 1
this.maxHydraSnakes = 4
this.hydraLength = 7
this.flagsToClearIfOnBody = TearFlags.TEAR_WIGGLE | TearFlags.TEAR_SPIRAL | TearFlags.TEAR_ORBIT| TearFlags.TEAR_SQUARE| TearFlags.TEAR_BIG_SPIRAL|
 TearFlags.TEAR_ORBIT_ADVANCED | TearFlags.TEAR_TURN_HORIZONTAL| TearFlags.TEAR_LUDOVICO
function this:HydrusPlayerUpdate(player)
    local p_data = player:GetData()
    if player:HasCollectible(CollectibleType.SOMETHINGWICKED_HYDRUS) then
        p_data.somethingwicked_HydrusTearRespawnTime = p_data.somethingwicked_HydrusTearRespawnTime or 0

        if (not p_data.somethingwicked_HydrusTear or
        not p_data.somethingwicked_HydrusTear:Exists())
        and p_data.somethingwicked_HydrusTearRespawnTime == 0 then
            this:MakeTearSnake(player, p_data, SomethingWicked.enums.SnakeTearType.SNAKE_HYDRUS, 1.1, 6)
            p_data.somethingwicked_HydrusTearMaxRespawnTime = 300
        end

        if p_data.somethingwicked_HydrusTearRespawnTime > 0 then
           p_data.somethingwicked_HydrusTearRespawnTime = p_data.somethingwicked_HydrusTearRespawnTime - 1
        end
    end

    if player:HasCollectible(CollectibleType.SOMETHINGWICKED_HYDRA) then
        p_data.somethingwicked_HydraTearRespawnTime = p_data.somethingwicked_HydraTearRespawnTime or 0
        p_data.somethingwicked_HydraTears = p_data.somethingwicked_HydraTears or {}

        if #p_data.somethingwicked_HydraTears < this.minHydraSnakes
        and p_data.somethingwicked_HydraTearRespawnTime == 0  then
            this:MakeTearSnake(player, p_data, SomethingWicked.enums.SnakeTearType.SNAKE_HYDRA, 0.5, this.hydraLength)
            p_data.somethingwicked_HydraTearRespawnTime = 15
        end

        local nt = {}
        for index, value in ipairs(p_data.somethingwicked_HydraTears) do
            if value and value:Exists() then
                table.insert(nt, value)
            end
        end
        p_data.somethingwicked_HydraTears = nt
        
        if p_data.somethingwicked_HydraTearRespawnTime > 0 then
            p_data.somethingwicked_HydraTearRespawnTime = p_data.somethingwicked_HydraTearRespawnTime - 1
         end
    end
end
--Hydrus: dmg 1.1, length 6

function this:MakeTearSnake(player, p_data, type, dmgMult, length, lastTear)
    local lastTearData = nil
    if lastTear then
        lastTearData = lastTear:GetData()
    end
    for _ = 1, length, 1 do
        local nt = player:FireTear(player.Position, Vector(1, 0), false, false, false, nil, dmgMult)
        nt.Scale = nt.Scale * 1.25
        nt:AddTearFlags(TearFlags.TEAR_SPECTRAL)
        nt:ClearTearFlags(TearFlags.TEAR_PIERCING)

        local ntd = nt:GetData()
        ntd.snakeTearData = {}
        ntd.snakeTearData.type = type
        if lastTear then
            nt.Position = nt.Position - lastTear.Velocity
            nt.Parent = lastTear
            ntd.somethingwicked_visFrame = this:GenerateVisFrame(lastTearData.somethingwicked_visFrame)
            lastTear.Child = nt
            nt:ClearTearFlags(this.flagsToClearIfOnBody)

            nt.Visible = false
        else
            ntd.snakeTearData.isHead = true
            ntd.somethingwicked_visFrame = 2
            if type == SomethingWicked.enums.SnakeTearType.SNAKE_HYDRUS then
                p_data.somethingwicked_HydrusTear = nt 
                nt:AddTearFlags(TearFlags.TEAR_HOMING)
            else
                table.insert(p_data.somethingwicked_HydraTears, nt) 
            end
        end
        lastTear = nt
        lastTearData = ntd
    end
end
function this:GenerateVisFrame(oldVisFrame)
    return (oldVisFrame) + (this.FrameDifferences * 2)
end

function this:HydrusTearRemove(tear)
    local t_data = tear:GetData()
    if t_data.snakeTearData == nil then
        return
    end
    local spwnr = tear.SpawnerEntity
    if spwnr == nil then
        return
    end
    local s_data = spwnr:GetData()
    if tear.Child then
        s_data.somethingwicked_HydrusTear = tear.Child
        return
    else
        local allTears = Isaac.FindByType(EntityType.ENTITY_TEAR)
        for _, nt in ipairs(allTears) do
            if GetPtrHash(spwnr) == GetPtrHash(nt.SpawnerEntity)
            and nt:Exists() then
                local n_data = nt:GetData()
                if n_data.snakeTearData
                and n_data.snakeTearData.type == SomethingWicked.enums.SnakeTearType.SNAKE_HYDRUS then
                    s_data.somethingwicked_HydrusTear = nt
                    return
                end
            end
        end
    end

    s_data.somethingwicked_HydrusTearRespawnTime = s_data.somethingwicked_HydrusTearMaxRespawnTime
end

function this:NewRoom()
    this.CachedRoom = SomethingWicked.game:GetRoom()
    for _, p in ipairs(SomethingWicked.ItemHelpers:AllPlayersWithCollectible(CollectibleType.SOMETHINGWICKED_HYDRUS)) do
        local p_data = p:GetData()
        p_data.somethingwicked_HydrusTearRespawnTime = 0
    end
    
    for _, p in ipairs(SomethingWicked.ItemHelpers:AllPlayersWithCollectible(CollectibleType.SOMETHINGWICKED_HYDRA)) do
        local p_data = p:GetData()
        p_data.somethingwicked_HydraTearRespawnTime = 0
        p_data.somethingwicked_HydraTears = {}
    end
end

SomethingWicked:AddCallback(ModCallbacks.MC_POST_PEFFECT_UPDATE, this.HydrusPlayerUpdate)
SomethingWicked:AddCallback(ModCallbacks.MC_POST_TEAR_UPDATE, this.HydrusTearUpdate)
SomethingWicked:AddCallback(ModCallbacks.MC_POST_ENTITY_REMOVE, this.HydrusTearRemove, EntityType.ENTITY_TEAR)
SomethingWicked:AddCallback(ModCallbacks.MC_POST_NEW_ROOM, this.NewRoom)

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