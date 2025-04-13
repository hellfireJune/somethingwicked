local mod = SomethingWicked
local game = Game()
local sfx = SFXManager()

local angleVariance = 10
local MoveSpeed = 6
local MinimumReturnDistance = 100
local FrameDifferences = 1
local Flags = 1 | 8 | 16

local AnimationEnum = {
    [Vector(0, 1)] = "IdleDown",
    [Vector(-1, 0)] = "IdleLeft",
    [Vector(0, -1)] = "IdleUpward",
    [Vector(1, 0)] = "IdleRight",
}

local function HeadInit(familiar)
    familiar.Parent = familiar.Parent or familiar.Player
end


local function MinosHeadMovementFunc(familiar, state, target, player)
    local f_data = familiar:GetData()
    local f_rng = familiar:GetDropRNG()
    f_data.somethingWicked_SpeedMult = f_data.somethingWicked_SpeedMult or 1
    local moveSpeed = MoveSpeed * f_data.somethingWicked_SpeedMult
    local variance = angleVariance * (f_rng:RandomFloat() + 0.5) 
    state = state or 1
    if state == 1 then
        if familiar.Position:Distance(player.Position) > MinimumReturnDistance then
            mod:AngularMovementFunction(familiar, player, moveSpeed, variance * 3, 0.3)
        end
    else

        if state == 2 then
            if target and target:Exists() then

                local distance = target.Position:Distance(familiar.Position)
                local varMult = math.min((distance/10), 5)
                mod:AngularMovementFunction(familiar, target, moveSpeed, variance * (3.5 + varMult), 0.3)
            else
                state = 3
            end
        end
        if state == 3 and (familiar.Target == nil or not familiar.Target:Exists()) then
            if familiar.Position:Distance(player.Position) > MinimumReturnDistance then

                mod:AngularMovementFunction(familiar, player, moveSpeed, variance * 3, 0.3)
            else
                state = 1
            end
        end
    end

    local intendedMult = (state == 2 and 2 or 1)
    f_data.somethingWicked_SpeedMult = mod:Lerp(f_data.somethingWicked_SpeedMult, intendedMult, 0.1)

    return state
end

local CachedRoom = nil
if game:GetFrameCount() > 0 then
    local CachedRoom = game:GetRoom()
end

local function FollowPositionFramesTable(frameTable, familiar, roomFrame, frameDiff)
    if (roomFrame >= frameDiff
    and familiar.FrameCount - 5 >= frameDiff)
    and frameTable[roomFrame - frameDiff] then
        familiar.Velocity = frameTable[roomFrame - frameDiff] - familiar.Position
    else 
        familiar.Velocity = Vector.Zero
    end
end

local function HandlePositionFramesTable(familiar, roomFrame, fTable)
    fTable = fTable or {}
    if roomFrame == 0 then
        fTable = {}
    end
    fTable[roomFrame] = familiar.Position
    return fTable
end

--https://cdn.discordapp.com/attachments/907577522403803197/973850950261420052/attachment.gif
local function HeadUpdate(_, familiar)
    local f_data = familiar:GetData()
    f_data.somethingwicked_visFrame = 3

    local player = familiar.Player
    local f_sprite = familiar:GetSprite()
    familiar.State = MinosHeadMovementFunc(familiar, familiar.State, familiar.Target, player)
    if familiar.State == 0 or familiar.State == 1 then
        familiar.State = ((familiar.Target ~= nil and familiar.Target:Exists()) and 2 or 1)
    elseif familiar.State == 3 then 
        familiar.State = ((familiar.Target ~= nil and familiar.Target:Exists()) and 2 or 3)
    end
    if player:GetFireDirection() ~= Direction.NO_DIRECTION then
        local lastTarget = familiar.Target
        familiar:PickEnemyTarget(80000, 5, Flags, player:GetAimDirection(), 45)
        if familiar.Target == nil
        and lastTarget ~= nil then
            familiar.Target = lastTarget
        end
    end
    
    if familiar.State > 1 then
        
        local lastTarget = familiar.Target
        familiar:PickEnemyTarget(80000, 0, Flags, familiar.Velocity, 135)
        if familiar.Target == nil then
            familiar.Target = lastTarget
        end
    end

    local direction = familiar.Velocity:Normalized()
    local anim = "IdleDown" local diff = 999
    for key, value in pairs(AnimationEnum) do
        local currentDiff = math.abs(mod:GetAngleDifference(key, direction))
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
        familiar.Velocity = Vector(MoveSpeed, 0)
    end

    CachedRoom = CachedRoom or game:GetRoom()
    f_data.somethingWicked_PositionFramesTable = HandlePositionFramesTable(familiar, CachedRoom:GetFrameCount(), f_data.somethingWicked_PositionFramesTable or {})
end

local function HandleVisFrame(familiar, f_data, frame)
    if f_data.somethingwicked_visFrame and 
    f_data.somethingwicked_visFrame == frame then
        familiar.Visible = true
        return true
    end
end

local function BodyUpdate(_, familiar)
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

    CachedRoom = CachedRoom or game:GetRoom()
    local p_data = familiar.Parent:GetData()
    local f_data = familiar:GetData()
    local f_frame = familiar.FrameCount
    local roomFrame = CachedRoom:GetFrameCount()
    local f_sprite = familiar:GetSprite()
    p_data.somethingWicked_PositionFramesTable = p_data.somethingWicked_PositionFramesTable or {}
    if f_data.somethingwicked_visFrame == nil and p_data.somethingwicked_visFrame ~= nil then
        f_data.somethingwicked_visFrame = math.max(0, (p_data.somethingwicked_visFrame - familiar.Parent.FrameCount + 5)) + (FrameDifferences * 2)
    end
    FollowPositionFramesTable(p_data.somethingWicked_PositionFramesTable, familiar, roomFrame, FrameDifferences)

    f_data.somethingWicked_PositionFramesTable = HandlePositionFramesTable(familiar, roomFrame, f_data.somethingWicked_PositionFramesTable or {})
 
    if HandleVisFrame(familiar, f_data, f_frame) then
        Isaac.Spawn(EntityType.ENTITY_EFFECT, EffectVariant.POOF01, 0, familiar.Position, Vector.Zero, familiar)
        f_sprite:Play("Idle", true)
    end
end

local function BodyInit(_, familiar)
    familiar.Visible = false
    familiar:ClearEntityFlags(EntityFlag.FLAG_APPEAR)
end

SomethingWicked:AddCallback(ModCallbacks.MC_FAMILIAR_UPDATE, HeadUpdate, FamiliarVariant.SOMETHINGWICKED_MINOS_HEAD)
SomethingWicked:AddCallback(ModCallbacks.MC_FAMILIAR_INIT, HeadInit, FamiliarVariant.SOMETHINGWICKED_MINOS_HEAD)
SomethingWicked:AddCallback(ModCallbacks.MC_FAMILIAR_INIT, BodyInit, FamiliarVariant.SOMETHINGWICKED_MINOS_BODY)
SomethingWicked:AddCallback(ModCallbacks.MC_FAMILIAR_UPDATE, BodyUpdate, FamiliarVariant.SOMETHINGWICKED_MINOS_BODY)

SomethingWicked.SnakeTearType = {
    SNAKE_ITEM = 1,
    SNAKE_STANDALONE_PLAYER = 2,
    SNAKE_STANDALONE_NONPLAYER = 3,
}
--Hydrus
local function GetHead(tear)
    local nt = tear
    for j = 1, 50, 1 do
        if nt.Parent and nt.Parent:Exists() then
            nt = nt.Parent
        else
            return nt
        end
    end
    return tear
end
local function GetSnakeTearLength(tear, alsoGetHead)
    if alsoGetHead == nil then
        alsoGetHead = false
    end
    if alsoGetHead then
        tear = GetHead(tear)
    end

    local nt = tear
    for j = 1, 50, 1 do
        if nt.Child then
            nt = nt.Child
        else
            return j, nt
        end
    end
end

local function SnakeMovementFunc(tear, player)
    mod:WibbleWobbleTearUpdate(tear, true)
    local t_data = tear:GetData()
    tear.Velocity = tear.Velocity - t_data.sw_wobbleLastVector
    --print(tear.Velocity)
    if tear.Target ~= nil then
        
    else
        local oVec = mod:SmoothOrbitVec(tear, player.Position, 60, tear.Velocity:Length())
        mod:AngularMovementFunction(tear, player.Position+oVec, MoveSpeed*mod:GetAllMultipliedTearVelocity(tear), 30, 0.7)
    end
    tear.Velocity = tear.Velocity + t_data.sw_wobbleLastVector
end

local headFlags = TearFlags.TEAR_HOMING-- | TearFlags.TEAR_WIGGLE
local function HydrusTearUpdate(_, tear)
    local t_data = tear:GetData()
    local s = tear.SpawnerEntity
    local ret = Retribution
    if ret and ret.HasRetributionTearFlags(tear, ret.TEARFLAG.MILK_TOOTH) then
        ret.ClearRetributionTearFlags(tear, ret.TEARFLAG.MILK_TOOTH)
        tear:AddTearFlags(TearFlags.TEAR_BURSTSPLIT)
    end

    if tear.Parent == nil
    and not t_data.snakeTearData.isHead then
        if not tear.Visible then
            tear:Remove()
            return
        end
        t_data.snakeTearData.isHead = true

        if t_data.snakeTearData.type == SomethingWicked.SnakeTearType.SNAKE_ITEM then
            tear:AddTearFlags(headFlags)
        end
    end
    if tear.FrameCount >= 2 then
        t_data.snakeTearData.render = true
    end

    CachedRoom = CachedRoom or game:GetRoom()
    local rf = CachedRoom:GetFrameCount()
    if t_data.snakeTearData.isHead then
        SnakeMovementFunc(tear, s)
        if tear.Velocity:Length() == 0 then
            tear.Velocity = Vector(0,1)
        end

        --[[if t_data.snakeTearData.type == SomethingWicked.SnakeTearType.SNAKE_HYDRA then
            local length, lastTear = GetSnakeTearLength(tear)
            if lastTear ~= nil then
                t_data.snakeTearData.hydraRegenCooldown = (t_data.snakeTearData.hydraRegenCooldown or 15) - 1
                if length < hydraLength
                and t_data.snakeTearData.hydraRegenCooldown <= 0 then
                    t_data.snakeTearData.hydraRegenCooldown = nil

                    mod:MakeTearSnake(s:ToPlayer(), s_data, SomethingWicked.SnakeTearType.SNAKE_HYDRA, 0.5, length + 1, lastTear)
                end

            end
        end]]
    else
        local p_data = tear.Parent:GetData()
        if p_data.snakeTearData and p_data.snakeTearData.posFramesTable then
            FollowPositionFramesTable(p_data.snakeTearData.posFramesTable, tear, rf, FrameDifferences)
        end
    end
    t_data.snakeTearData.posFramesTable = HandlePositionFramesTable(tear, rf, t_data.snakeTearData.posFramesTable)

    if t_data.snakeTearData.queueFrames then
        t_data.snakeTearData.queueFrames = t_data.snakeTearData.queueFrames - 1
        if t_data.snakeTearData.queueFrames == 0 then
            t_data.snakeTearData.queueFrames = nil
            if t_data.snakeTearData.makeOrder then
                local order = t_data.snakeTearData.makeOrder
                mod:MakeTearSnake(order.p, order.p_data, t_data.snakeTearData.type, order.dmgMult, order.l, tear, order.currL)
            end
        end
    end

    --[[if tear.FrameCount == 1 then
        local poof = Isaac.Spawn(EntityType.ENTITY_EFFECT, EffectVariant.POOF01, 0, tear.Position, Vector.Zero, tear)
        poof.Color = Color(0, 0.2, 1)
        poof.SpriteScale = Vector(0.5, 0.5)
    end]]
    tear.FallingSpeed = 0
    tear.Height = -20
end

local flagsToClearIfOnBody = TearFlags.TEAR_WIGGLE | TearFlags.TEAR_SPIRAL | TearFlags.TEAR_ORBIT| TearFlags.TEAR_SQUARE| TearFlags.TEAR_BIG_SPIRAL|
 TearFlags.TEAR_ORBIT_ADVANCED | TearFlags.TEAR_TURN_HORIZONTAL| TearFlags.TEAR_LUDOVICO
function mod:MakeTearSnake(player, p_data, type, dmgMult, length, lastTear, currLength)
    local pos = player.Position
    if lastTear then
        if not lastTear:Exists() then
            return
        end
        pos = lastTear.Position
    end
    if currLength ~= nil and currLength >= length then
        return
    end
    currLength = (currLength or 0) + 1
    
    local nt = player:FireTear(pos, Vector(1, 0), false, false, false, nil, dmgMult)
    nt.Scale = nt.Scale * 1.25
    nt:AddTearFlags(TearFlags.TEAR_SPECTRAL)
    nt:ClearTearFlags(TearFlags.TEAR_PIERCING)
    nt:SetColor(Color(1,1,1,-2), 10, 20, true, false)

    local ntd = nt:GetData()
    ntd.snakeTearData = {}
    ntd.snakeTearData.type = type
    nt:AddTearFlags(TearFlags.TEAR_SHIELDED)
    if lastTear then
        nt.Position = nt.Position - lastTear.Velocity
        nt.Parent = lastTear
        lastTear.Child = nt
        nt:ClearTearFlags(flagsToClearIfOnBody)
    else
        nt.Parent = nil
        ntd.snakeTearData.isHead = true
        nt:AddTearFlags(headFlags)
        if type == SomethingWicked.SnakeTearType.SNAKE_ITEM then
            p_data.somethingwicked_HydrusTear = nt
        end
    end
    mod:AddToTearUpdateList("sw_snakeTear", nt, HydrusTearUpdate)
    ntd.snakeTearData.makeOrder = {
        currL = currLength,
        l = length,
        p = player,
        p_data = p_data,
        dmgMult = dmgMult
    }
    ntd.snakeTearData.queueFrames = 3
    --nt:Update()
end

function mod:HydrusPlayerUpdate(player)
    local p_data = player:GetData()
    if player:HasCollectible(mod.ITEMS.HYDRUS) then
        p_data.somethingwicked_HydrusTearRespawnTime = p_data.somethingwicked_HydrusTearRespawnTime or 0

        if (not p_data.somethingwicked_HydrusTear or
        not p_data.somethingwicked_HydrusTear:Exists())
        and p_data.somethingwicked_HydrusTearRespawnTime == 0 then
            mod:MakeTearSnake(player, p_data, SomethingWicked.SnakeTearType.SNAKE_ITEM, 1.1, 7)
            p_data.somethingwicked_HydrusTearMaxRespawnTime = 300
        end

        if p_data.somethingwicked_HydrusTearRespawnTime > 0 then
           p_data.somethingwicked_HydrusTearRespawnTime = p_data.somethingwicked_HydrusTearRespawnTime - 1
        end
    end
end

local function HydrusTearRemove(_, tear)
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
        if t_data.snakeTearData.type == SomethingWicked.SnakeTearType.SNAKE_ITEM then
            s_data.somethingwicked_HydrusTear = tear.Child
        end
        return
    else
        local allTears = Isaac.FindByType(EntityType.ENTITY_TEAR)
        for _, nt in ipairs(allTears) do
            if nt and GetPtrHash(spwnr) == GetPtrHash(nt.SpawnerEntity)
            and nt:Exists() then
                local n_data = nt:GetData()
                if n_data.snakeTearData
                and n_data.snakeTearData.type == SomethingWicked.SnakeTearType.SNAKE_ITEM then
                    s_data.somethingwicked_HydrusTear = nt
                    return
                end
            end
        end
    end

    s_data.somethingwicked_HydrusTearRespawnTime = s_data.somethingwicked_HydrusTearMaxRespawnTime
end

local function NewRoom()
    CachedRoom = game:GetRoom()
    for _, p in ipairs(mod:AllPlayersWithCollectible(mod.ITEMS.HYDRUS)) do
        local p_data = p:GetData()
        p_data.somethingwicked_HydrusTearRespawnTime = 0
    end
end

mod:AddPeffectCheck(function (player)
    return player:HasCollectible(mod.ITEMS.HYDRUS)
end, mod.HydrusPlayerUpdate)
SomethingWicked:AddCallback(ModCallbacks.MC_POST_ENTITY_REMOVE, HydrusTearRemove, EntityType.ENTITY_TEAR)
SomethingWicked:AddCallback(ModCallbacks.MC_POST_NEW_ROOM, NewRoom)

function SomethingWicked:DebugSpliceHydrusTears()
    local player = Isaac.GetPlayer(0)
    local p_data = player:GetData()
    
    local value = p_data.somethingwicked_HydrusTear

        local length = GetSnakeTearLength(value)
        length = math.floor(length / 2)

        local tearToKill = value
        for i = 1, length, 1 do
            tearToKill = tearToKill.Child
        end
        tearToKill:Die()
end

mod:AddCallback(ModCallbacks.MC_PRE_TEAR_RENDER, function (_, tear)
    local t_data = tear:GetData()
    if t_data.snakeTearData and not t_data.snakeTearData.render then
        return false
    end
end)