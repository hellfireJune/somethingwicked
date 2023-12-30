local this = {}
local mod = SomethingWicked
SomethingWicked.TearFlagData = {}

--[[
    possible values for the initData:
    
    ApplyLogic: function
    EnemyHitEffect: function
    AnyHitEffect: function
    PostApply: function

    OverrideGenericExplosion: function
    isBombExclusiveTearFlag: boolean
    bombSpritesheet:
    drFetusChance:

    OverrideTearUpdate: function
        OverrideTearCollision: function
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
function SomethingWicked:AddNewTearFlag(enumeration, initData)
    SomethingWicked.TearFlagData[enumeration] = initData
end
function SomethingWicked:AddTearFlag(tear, flag)
    local t_data = tear:GetData()
    t_data.somethingWicked_customTearFlags = (t_data.somethingWicked_customTearFlags or 0) | flag
end
function mod:GetDMGFromTearLike(ent)
    local bomb = ent:ToBomb()
    if bomb then
        return bomb.ExplosionDamage
    end
    return ent.CollisionDamage
end
function mod:HasFlags(ent, flag)
    local t_data = ent:GetData()
    return t_data.somethingWicked_customTearFlags and t_data.somethingWicked_customTearFlags & flag > 0
end

local tearsWithFlags = {}
local tearRefs = {}

local function PostApply(player, tear, flag)
    tearsWithFlags[tear.Index] = (tearsWithFlags[tear.Index] or {})
    table.insert(tearsWithFlags[tear.Index], flag)

    tearRefs[tear.Index] = tear
end

local function GetTearFlagsToApply(player, tear)
    local flagsToReturn = 0
    for enum, value in pairs(SomethingWicked.TearFlagData) do
        if value:ApplyLogic(player, tear) then
            flagsToReturn = flagsToReturn | enum

            if value.PostApply then
                value:PostApply(player, tear)
            end
            PostApply(player, tear, enum)
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

local function GetTearColorFromFlags(tflags)
    local color = Color(1, 1, 1)
    if tflags > 0 then
        for key, value in pairs(SomethingWicked.TearFlagData) do
            if value.TearColor and tflags & key > 0 then
                color = color * value.TearColor
            end
        end
    end
    return color
end

local variantBlacklist = { TearVariant.BALLOON, TearVariant.BALLOON_BRIMSTONE, TearVariant.BALLOON_BOMB}
local function FireTear(_, tear)
    if tear.FrameCount ~= 1 then
        return
    end
    if tear:HasTearFlags(TearFlags.TEAR_CHAIN) then
        return
    end
    local t_data = tear:GetData()
    if not t_data.sw_wasFired then
        return
    end
    local player = SomethingWicked:UtilGetPlayerFromTear(tear)
    if player then
        local oldFlags = t_data.somethingWicked_customTearFlags
        local flags = GetTearFlagsToApply(player, tear)
        t_data.somethingWicked_customTearFlags = flags
        if oldFlags then flags = flags | oldFlags end

        local t_variant = GetTearVariantFromFlags(flags)
        if not mod:UtilTableHasValue(variantBlacklist, tear.Variant) and t_variant then
            tear:ChangeVariant(t_variant)
        end
        local t_color = GetTearColorFromFlags(flags)
        if t_color then
            tear.Color = tear.Color * t_color
        end
    end
end

SomethingWicked:AddCallback(ModCallbacks.MC_POST_TEAR_UPDATE, FireTear)
--probably a better way to do this
SomethingWicked:AddCallback(ModCallbacks.MC_POST_FIRE_TEAR, function (_, tear)
    local t_data = tear:GetData()
    t_data.sw_wasFired = true
end)

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
    if tear:ToTear():HasTearFlags(TearFlags.TEAR_BURSTSPLIT) then
        for index, value in ipairs(Isaac.FindByType(2)) do
            local v_data = value:GetData()
            local player = mod:UtilGetPlayerFromTear(value)
            if value.FrameCount == 0 and value.Parent == nil and v_data.somethingWicked_customTearFlags == nil and player then
                v_data.somethingWicked_customTearFlags = t_data.somethingWicked_customTearFlags

                for key, flag in pairs(SomethingWicked.TearFlagData) do
                
                    if t_data.somethingWicked_customTearFlags & key > 0 and flag.PostApply then
                        flag:PostApply(player, tear)
                    end
                    PostApply(player, tear, key)
                end
            end
        end
    end

    if tearsWithFlags[tear.Index] or tearRefs[tear.Index] then
        tearsWithFlags[tear.Index] = nil
        tearRefs[tear.Index] = nil
    end
end

SomethingWicked:AddCallback(ModCallbacks.MC_POST_ENTITY_REMOVE, TearRemove, EntityType.ENTITY_TEAR)

function mod:__callStatusEffects(collider, tear)
    if not tear or tear.Type ~= EntityType.ENTITY_TEAR then
        return
    end
    local t_data = tear:GetData()
    if t_data.somethingWicked_customTearFlags == nil then
        return
    end
    if t_data.somethingWicked_customTearFlags > 0 then
        for key, value in pairs(SomethingWicked.TearFlagData) do
            if value.EnemyHitEffect and t_data.somethingWicked_customTearFlags & key > 0 then
                value:EnemyHitEffect(tear, tear.Position, collider, mod:UtilGetPlayerFromTear(tear))
            end
        end
    end
end

function this:OnTearHit(tear, collider)
    local t_data = tear:GetData()
    if not t_data.somethingWicked_customTearFlags then return end
    for key, value in pairs(SomethingWicked.TearFlagData) do
        local result
        if value.OverrideTearCollision and t_data.somethingWicked_customTearFlags & key > 0 then
            result = value:OverrideTearCollision(tear, collider)
        end
        if result ~= nil then
            return result
        end
    end
end
SomethingWicked:AddPriorityCallback(ModCallbacks.MC_PRE_TEAR_COLLISION, CallbackPriority.EARLY, this.OnTearHit)
--SomethingWicked:AddCallback(ModCallbacks.MC_ENTITY_TAKE_DMG, this.OnTearHit)

--[[function this:OnTearUpdate(tear)
    --[[if tear.FrameCount == 0 then
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
SomethingWicked:AddPriorityCallback(ModCallbacks.MC_POST_TEAR_UPDATE, CallbackPriority.LATE, this.OnTearUpdate)]]

mod:AddCallback(ModCallbacks.MC_POST_UPDATE, function ()
    for idx, tear in pairs(tearRefs) do
        if tear and tear:Exists()  then
            local flags = tearsWithFlags[idx]
            for _, flag in pairs(flags) do
                local f_data = SomethingWicked.TearFlagData[flag]
                if f_data.OverrideTearUpdate then
                    f_data:OverrideTearUpdate(tear)
                end
            end
        end
    end
end)

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
