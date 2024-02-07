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


local function HeadMovementFunc(familiar, state, target, player)
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
local function HeadUpdate(familiar)
    local f_data = familiar:GetData()
    f_data.somethingwicked_visFrame = 3

    local player = familiar.Player
    local f_sprite = familiar:GetSprite()
    familiar.State = HeadMovementFunc(familiar, familiar.State, familiar.Target, player)
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

local function BodyUpdate(familiar)
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

local function OnCache(player)
    local stacks, rng, sourceItem = SomethingWicked.FamiliarHelpers:BasicFamiliarNum(player, CollectibleType.SOMETHINGWICKED_MINOS_ITEM)
    player:CheckFamiliar(FamiliarVariant.SOMETHINGWICKED_MINOS_HEAD, (player:HasCollectible(CollectibleType.SOMETHINGWICKED_MINOS_ITEM) and 1 or 0), rng, sourceItem)
    player:CheckFamiliar(FamiliarVariant.SOMETHINGWICKED_MINOS_BODY, (stacks * 2) + (stacks > 0 and 2 - stacks or 0), rng, sourceItem)
end

local function BodyInit(familiar)
    familiar.Visible = false
    familiar:ClearEntityFlags(EntityFlag.FLAG_APPEAR)
end

SomethingWicked:AddCallback(ModCallbacks.MC_EVALUATE_CACHE, OnCache, CacheFlag.CACHE_FAMILIARS)
SomethingWicked:AddCallback(ModCallbacks.MC_FAMILIAR_UPDATE, HeadUpdate, FamiliarVariant.SOMETHINGWICKED_MINOS_HEAD)
SomethingWicked:AddCallback(ModCallbacks.MC_FAMILIAR_INIT, HeadInit, FamiliarVariant.SOMETHINGWICKED_MINOS_HEAD)
SomethingWicked:AddCallback(ModCallbacks.MC_FAMILIAR_INIT, BodyInit, FamiliarVariant.SOMETHINGWICKED_MINOS_BODY)
SomethingWicked:AddCallback(ModCallbacks.MC_FAMILIAR_UPDATE, BodyUpdate, FamiliarVariant.SOMETHINGWICKED_MINOS_BODY)

SomethingWicked.SnakeTearType = {
    SNAKE_HYDRUS = 1,
    SNAKE_HYDRA = 2,
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

local minHydraSnakes = 1
local maxHydraSnakes = 4
local hydraLength = 5
local flagsToClearIfOnBody = TearFlags.TEAR_WIGGLE | TearFlags.TEAR_SPIRAL | TearFlags.TEAR_ORBIT| TearFlags.TEAR_SQUARE| TearFlags.TEAR_BIG_SPIRAL|
 TearFlags.TEAR_ORBIT_ADVANCED | TearFlags.TEAR_TURN_HORIZONTAL| TearFlags.TEAR_LUDOVICO
local function MakeTearSnake(player, p_data, type, dmgMult, length, lastTear)
    local pos = player.Position
    if lastTear then
        if not lastTear:Exists() then
            return
        end
        pos = lastTear.Position
    else
        if type == SomethingWicked.SnakeTearType.SNAKE_HYDRA and #p_data.somethingwicked_HydraTears > maxHydraSnakes then
            return
        end 
    end
    local newLength = 0
    
    local nt = player:FireTear(pos, Vector(1, 0), false, false, false, nil, dmgMult)
    nt.Scale = nt.Scale * 1.25
    nt:AddTearFlags(TearFlags.TEAR_SPECTRAL)
    nt:ClearTearFlags(TearFlags.TEAR_PIERCING)

    local ntd = nt:GetData()
    ntd.snakeTearData = {}
    ntd.snakeTearData.type = type
    if lastTear then
        nt.Position = nt.Position - lastTear.Velocity
        nt.Parent = lastTear
        lastTear.Child = nt
        nt:ClearTearFlags(flagsToClearIfOnBody)
        if type == SomethingWicked.SnakeTearType.SNAKE_HYDRUS then
            nt:AddTearFlags(TearFlags.TEAR_SHIELDED)
        end
    else
        nt.Parent = nil
        ntd.snakeTearData.isHead = true
        if type == SomethingWicked.SnakeTearType.SNAKE_HYDRUS then
            p_data.somethingwicked_HydrusTear = nt 
            nt:AddTearFlags(TearFlags.TEAR_HOMING)
        else
            table.insert(p_data.somethingwicked_HydraTears, nt) 
            nt:AddTearFlags(TearFlags.TEAR_ORBIT_ADVANCED)
        end
    end

    newLength = GetSnakeTearLength(nt, true)
    if newLength < length then
        SomethingWicked:UtilScheduleForUpdate(function ()
            MakeTearSnake(player, p_data, type, dmgMult, length, nt)
        end, 3, ModCallbacks.MC_POST_UPDATE)
    end
end
local function HydrusTearUpdate(tear)
    local t_data = tear:GetData()
    if t_data.snakeTearData == nil then
        return
    end
    local s = tear.SpawnerEntity
    local s_data = s:GetData()
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

        if t_data.snakeTearData.type == SomethingWicked.SnakeTearType.SNAKE_HYDRUS then
            tear:AddTearFlags(TearFlags.TEAR_HOMING)
        else
            if #s_data.somethingwicked_HydraTears > maxHydraSnakes then
                tear:Remove()
            end
            table.insert(s_data.somethingwicked_HydraTears, tear)
        end
    end

    CachedRoom = CachedRoom or game:GetRoom()
    local rf = CachedRoom:GetFrameCount()
    if t_data.snakeTearData.isHead then
        t_data.snakeTearData.state = HeadMovementFunc(tear, t_data.snakeTearData.state, tear.Target, tear.SpawnerEntity)
        if tear.Velocity:Length() == 0 then
            tear.Velocity = Vector(0,1)
        end
        tear.Velocity = tear.Velocity:Resized(MoveSpeed)

        if t_data.snakeTearData.type == SomethingWicked.SnakeTearType.SNAKE_HYDRA then
            local length, lastTear = GetSnakeTearLength(tear)
            if lastTear ~= nil then
                t_data.snakeTearData.hydraRegenCooldown = (t_data.snakeTearData.hydraRegenCooldown or 15) - 1
                if length < hydraLength
                and t_data.snakeTearData.hydraRegenCooldown <= 0 then
                    t_data.snakeTearData.hydraRegenCooldown = nil

                    MakeTearSnake(s:ToPlayer(), s_data, SomethingWicked.SnakeTearType.SNAKE_HYDRA, 0.5, length + 1, lastTear)
                end

            end
        end
    else
        local p_data = tear.Parent:GetData()
        if p_data.snakeTearData and p_data.snakeTearData.posFramesTable then
            FollowPositionFramesTable(p_data.snakeTearData.posFramesTable, tear, rf, FrameDifferences)
        end
    end
    t_data.snakeTearData.posFramesTable = HandlePositionFramesTable(tear, rf, t_data.snakeTearData.posFramesTable)

    if tear.FrameCount == 1 then
        local poof = Isaac.Spawn(EntityType.ENTITY_EFFECT, EffectVariant.POOF01, 0, tear.Position, Vector.Zero, tear)
        poof.Color = Color(0, 0.2, 1)
        poof.SpriteScale = Vector(0.5, 0.5)
    end
    tear.FallingSpeed = 0
    tear.Height = -20
end

local function HydrusPlayerUpdate(player)
    local p_data = player:GetData()
    if player:HasCollectible(CollectibleType.SOMETHINGWICKED_HYDRUS) then
        p_data.somethingwicked_HydrusTearRespawnTime = p_data.somethingwicked_HydrusTearRespawnTime or 0

        if (not p_data.somethingwicked_HydrusTear or
        not p_data.somethingwicked_HydrusTear:Exists())
        and p_data.somethingwicked_HydrusTearRespawnTime == 0 then
            MakeTearSnake(player, p_data, SomethingWicked.SnakeTearType.SNAKE_HYDRUS, 1.1, 7)
            p_data.somethingwicked_HydrusTearMaxRespawnTime = 300
        end

        if p_data.somethingwicked_HydrusTearRespawnTime > 0 then
           p_data.somethingwicked_HydrusTearRespawnTime = p_data.somethingwicked_HydrusTearRespawnTime - 1
        end
    end

    if player:HasCollectible(CollectibleType.SOMETHINGWICKED_HYDRA) then
        p_data.somethingwicked_HydraTearRespawnTime = p_data.somethingwicked_HydraTearRespawnTime or 0
        p_data.somethingwicked_HydraTears = p_data.somethingwicked_HydraTears or {}

        if #p_data.somethingwicked_HydraTears < minHydraSnakes
        and p_data.somethingwicked_HydraTearRespawnTime == 0  then
            MakeTearSnake(player, p_data, SomethingWicked.SnakeTearType.SNAKE_HYDRA, 0.5, hydraLength)
            p_data.somethingwicked_HydraTearRespawnTime = 30
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
local function GenerateVisFrame(oldVisFrame)
    return (oldVisFrame) + (FrameDifferences * 2)
end

local function HydrusTearRemove(tear)
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
        if t_data.snakeTearData.type == SomethingWicked.SnakeTearType.SNAKE_HYDRUS then
            --[[if Retribution and Retribution.HasRetributionTearFlags(tear, Retribution.TEARFLAG.MILK_TOOTH) then
                local player = spwnr:ToPlayer()
                local fireVector = (player and player:HasTrinket(Retribution.TRINKETS.HEART_WORM)) and tear.Velocity:Resized(player.ShotSpeed * 10) or tear.Velocity
				local amount = math.max(1, player and player:GetCollectibleNum(Retribution.ITEMS.MILK_TEETH) or 0)
				local anglePer = 90 / (5 * amount + 1)

                local tears = {}
				for i = 1, 5 * amount do
					local angleModifier = i * anglePer - 45
                    local positionToCheckForChild = tear.Position + fireVector:Rotated(angleModifier)
					if amount >= 3 and i % 2 == 1 then
						positionToCheckForChild = positionToCheckForChild - fireVector:Resized(15)
					end

                    for index, value in ipairs(Isaac.FindInRadius(positionToCheckForChild, 3, EntityPartition.TEAR)) do
                        if not Retribution.HasRetributionTearFlags(value, Retribution.TEARFLAG.MILK_TOOTH)
                        and value.FrameCount <= 1 then
                            table.insert(tears, value)
                        end
                    end
                end

                s_data.somethingWicked_hydraMilkSplits = tears

                local parent = tear.Parent
                local n_parents = nil
                if parent then
                    local p_data = parent:GetData()
                    if p_data.somethingWicked_hydraMilkSplits then
                        n_parents = p_data.somethingWicked_hydraMilkSplits
                    end
                end

                for idx, nt in pairs(tears) do
                    local ntd = nt:GetData()
                    ntd.snakeTearData = {}
                    ntd.type = SomethingWicked.SnakeTearType.SNAKE_HYDRUS
                    if n_parents and n_parents[idx] then
                        nt.Parent = n_parents[idx]
                    else
                        nt.Parent = nil
                        ntd.snakeTearData.isHead = true
                        table.insert(s_data.somethingwicked_HydraTears, tear)
                    end
                end
            end
        else]]
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
                and n_data.snakeTearData.type == SomethingWicked.SnakeTearType.SNAKE_HYDRUS then
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
    for _, p in ipairs(mod:AllPlayersWithCollectible(CollectibleType.SOMETHINGWICKED_HYDRUS)) do
        local p_data = p:GetData()
        p_data.somethingwicked_HydrusTearRespawnTime = 0
    end
    
    for _, p in ipairs(mod:AllPlayersWithCollectible(CollectibleType.SOMETHINGWICKED_HYDRA)) do
        local p_data = p:GetData()
        p_data.somethingwicked_HydraTearRespawnTime = 0
        p_data.somethingwicked_HydraTears = {}
    end
end

SomethingWicked:AddCallback(ModCallbacks.MC_POST_PEFFECT_UPDATE, HydrusPlayerUpdate)
SomethingWicked:AddCallback(ModCallbacks.MC_POST_TEAR_UPDATE, HydrusTearUpdate)
SomethingWicked:AddCallback(ModCallbacks.MC_POST_ENTITY_REMOVE, HydrusTearRemove, EntityType.ENTITY_TEAR)
SomethingWicked:AddCallback(ModCallbacks.MC_POST_NEW_ROOM, NewRoom)

function SomethingWicked:DebugSpliceHydraTears()
    local player = Isaac.GetPlayer(0)
    local p_data = player:GetData()
    for key, value in pairs(p_data.somethingwicked_HydraTears) do
        local length = GetSnakeTearLength(value)
        length = math.floor(length / 2)

        local tearToKill = value
        for i = 1, length, 1 do
            tearToKill = tearToKill.Child
        end
        tearToKill:Die()
    end
end
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