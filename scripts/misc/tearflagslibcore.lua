local this = {}
SomethingWicked.TearFlagCore = {}
SomethingWicked.TearFlagData = {}

--[[
    possible values for the initData:
    ApplyLogic: function, if return true add the tear effect
        called for anything that should add the effect
    EnemyHitEffect: function.
    AnyHitEffect: function, for where a tear would hit a wall, for example.
        
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

local function FireTear(tear)
    local player = SomethingWicked:UtilGetPlayerFromTear(tear)
    if player then
        local t_data = tear:GetData()
        t_data.somethingWicked_customTearFlags = GetTearFlagsToApply(player, tear)
    end
end

SomethingWicked:AddCallback(ModCallbacks.MC_POST_FIRE_TEAR, FireTear)

local function TearRemove(tear)
    local t_data = tear:GetData()
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
    local t_data = tear:GetData()
    if t_data.somethingWicked_customTearFlags > 0 then
        for key, value in pairs(SomethingWicked.TearFlagData) do
            if value.OverrideTearUpdate and t_data.somethingWicked_customTearFlags & key > 0 then
                value:OverrideTearUpdate(tear)
            end
        end
    end
end
SomethingWicked:AddCallback(ModCallbacks.MC_POST_TEAR_UPDATE, this.OnTearUpdate)