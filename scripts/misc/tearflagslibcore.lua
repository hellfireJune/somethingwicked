local this = {}
SomethingWicked.TearFlagCore = {}
SomethingWicked.TearFlagData = {}

--[[
    possible values for the initData:
    ApplyLogic: function
        if return true add the tear effect
        called for anything that should add the effect. takes a player argument and a tear argument
    EnemyHitEffect: function
    AnyHitEffect: function
        for where a tear would hit a wall, for example.
        
    OverrideGenericExplosion: function
    isBombExclusiveTearFlag: boolean
    bombSpritesheet:
    drFetusChance:

    OverrideTearUpdate: function
    OverrideLaserUpdate: function
    OverrideKnifeUpdate: function
    OverrideClubUpdate: function
    OverrideCreepUpdate: function, for aquarius
    OverrideBombUpdate: function

    TearVariant
    TearColor
    LaserColor
    AquariusSpritesheet
]]
function SomethingWicked.TearFlagCore:AddNewFlagData(enumeration, initData)
    SomethingWicked.TearFlagData[enumeration] = initData
end

local function GetTearFlagsToApply(player, tear)
    local flagsToReturn = 0
    for enum, value in pairs(SomethingWicked.TearFlagData) do
        if value:ApplyLogic(player, tear) then
            flagsToReturn = flagsToReturn | enum
        end
    end
    return flagsToReturn
end

local function GetTearVariantFromFlags(tflags)
    if tflags > 0 then
        for key, value in pairs(SomethingWicked.TearFlagData) do
            if value.TearVariant and tflags & key > 0 then
                return value.TearVariant
            end
        end
    end
    return nil
end

local function FireTear(_, tear)
    local player = SomethingWicked:UtilGetPlayerFromTear(tear)
    if player then
        local t_data = tear:GetData()
        local flags = GetTearFlagsToApply(player, tear)
        t_data.somethingWicked_customTearFlags = flags

        local t_variant = GetTearVariantFromFlags(flags)
        if t_variant then
            tear:ChangeVariant(t_variant)
        end
    end
end

SomethingWicked:AddCallback(ModCallbacks.MC_POST_FIRE_TEAR, FireTear)

local function TearRemove(_, tear)
    local t_data = tear:GetData()
    if t_data.somethingWicked_customTearFlags == nil then
        return
    end
    if t_data.somethingWicked_customTearFlags > 0 then
        for key, value in pairs(SomethingWicked.TearFlagData) do
            if value.AnyHitEffect and t_data.somethingWicked_customTearFlags & key > 0 then
                value:AnyHitEffect(tear, tear.Position)
            end
        end
    end
end

SomethingWicked:AddCallback(ModCallbacks.MC_POST_ENTITY_REMOVE, TearRemove, EntityType.ENTITY_TEAR)

function this:OnTearHit(tear, collider)
    collider = collider:ToNPC()
    if not collider
    or not collider:IsVulnerableEnemy() then
        return
    end

    if tear.StickTarget ~= nil then
        return
    end
    
    local t_data = tear:GetData()
    if t_data.somethingWicked_customTearFlags == nil then
        return
    end
    if t_data.somethingWicked_customTearFlags > 0 then
        for key, value in pairs(SomethingWicked.TearFlagData) do
            if value.EnemyHitEffect and t_data.somethingWicked_customTearFlags & key > 0 then
                value:EnemyHitEffect(tear, tear.Position, collider)
            end
        end
    end
end
SomethingWicked:AddCallback(ModCallbacks.MC_PRE_TEAR_COLLISION, this.OnTearHit)

function this:OnTearUpdate(tear)
    if tear.FrameCount == 0 then
        return
    end
    local t_data = tear:GetData()
    if t_data.somethingWicked_customTearFlags == nil then
        return
    end
    if t_data.somethingWicked_customTearFlags > 0 then
        for key, value in pairs(SomethingWicked.TearFlagData) do
            if value.OverrideTearUpdate and t_data.somethingWicked_customTearFlags & key > 0 then
                value:OverrideTearUpdate(tear)
            end
        end
    end
end
SomethingWicked:AddCallback(ModCallbacks.MC_POST_TEAR_UPDATE, this.OnTearUpdate)

local function absVector(vector)
    local X = math.abs(vector.X) local y = math.abs(vector.Y)
    --[[if X > 0 then
       X = math.ceil(X) 
    end
    if y > 0 then
        y = math.ceil(y) 
    end]]
    --return Vector(X, y)
    return vector
end
local laserWidth = 30
local shouldDoLaserTestStuff = true
function this:LaserUpdate(laser)
    if not shouldDoLaserTestStuff then
        return
    end
    local player = SomethingWicked:UtilGetPlayerFromTear(laser)
    if not player then
        return
    end
    local enemies = Isaac.FindInRadius(Vector.Zero, 80000, EntityPartition.ENEMY)
    
    local vector = Vector.FromAngle(laser.Angle)
    local lengthVector = vector:Normalized()
    local widthVector = lengthVector:Rotated(-90)
    local endPoint = laser:GetEndPoint()

    for _, enemy in ipairs(enemies) do
        if enemy.Type == 964 then
            
            local relativePos = enemy.Position - laser.Position
            local posRelativeHeight = (relativePos * lengthVector)
            local posRelativeWidth = relativePos * widthVector
            local poof = Isaac.Spawn(EntityType.ENTITY_EFFECT, EffectVariant.POOF01, 0, laser.Position + posRelativeHeight, Vector.Zero, nil)
            poof.Color = Color(1, 0, 0)
            local poof = Isaac.Spawn(EntityType.ENTITY_EFFECT, EffectVariant.POOF01, 0, laser.Position + posRelativeWidth, Vector.Zero, nil)
        
            local disHeight = (posRelativeHeight):Length()
            local disWidth = (posRelativeWidth):Length()
            --print(laser.Position*widthVector)
            local laserLength = laser.Position:Distance(endPoint)

            print(relativePos, "-", posRelativeHeight, "-", posRelativeWidth)
            print(disHeight, disWidth)
            print(lengthVector, widthVector)
            if disHeight > 0 and disHeight < laserLength
            and disWidth > -laserWidth and disWidth < laserWidth then
                print("found the enemies ^_^")
            end
        end
    end
end
--SomethingWicked:AddPriorityCallback(ModCallbacks.MC_POST_LASER_UPDATE, CallbackPriority.LATE, this.LaserUpdate)
