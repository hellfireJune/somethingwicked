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