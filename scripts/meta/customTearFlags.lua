local mod = SomethingWicked
SomethingWicked.TearFlagData = {}

--[[
    possible values for the initData:
    
    ApplyLogic: function
    EnemyHitEffect: function
    EndHitEffect: function
    PostApply: function

    OverrideGenericExplosion: function

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
    DontAddKnifeColor
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
mod.tearRefs = {}

local function PostApply(player, tear, flag)
    if tear.Type == EntityType.ENTITY_TEAR then        
        tearsWithFlags[tear.Index] = (tearsWithFlags[tear.Index] or {})
        table.insert(tearsWithFlags[tear.Index], flag)

        mod.tearRefs[tear.Index] = tear
    end
end

local function GetTearFlagsToApply(player, tear)
    local flagsToReturn = 0
    local colorBlacklist = 0
    for enum, value in pairs(SomethingWicked.TearFlagData) do
        local apply, skipColor = value:ApplyLogic(player, tear)
        if apply then
            flagsToReturn = flagsToReturn | enum

            local t_data = tear:GetData()
            if not t_data.somethingWicked_customTearFlags or enum & t_data.somethingWicked_customTearFlags == 0 then
                if value.PostApply then
                    value:PostApply(player, tear)
                end
                PostApply(player, tear, enum)
            end

            if skipColor then
                colorBlacklist = colorBlacklist | enum
            end
        end
    end
    return flagsToReturn, colorBlacklist
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

local function GetTearColorFromFlags(tflags, isLaser, colorBlacklist)
    colorBlacklist = colorBlacklist or 0
    local color = Color(1, 1, 1)
    local idx = isLaser and "LaserColor" or "TearColor"
    if tflags > 0 then
        for key, value in pairs(SomethingWicked.TearFlagData) do
            local c = value[idx]
            if c == nil and isLaser then
                c = value.TearColor
            end
            if c and tflags & key > 0 and not (tflags & colorBlacklist > 0) then
                color = color * c
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
        local flags, colorBlacklist = GetTearFlagsToApply(player, tear)
        t_data.somethingWicked_customTearFlags = flags
        if oldFlags then flags = flags | oldFlags end

        local t_variant = GetTearVariantFromFlags(flags)
        if not mod:UtilTableHasValue(variantBlacklist, tear.Variant) and t_variant then
            mod:ChangeTearVariant(t_variant)
        end
        local t_color = GetTearColorFromFlags(flags, nil, colorBlacklist)
        if t_color then
            tear.Color = tear.Color * t_color
        end
    end
end

function mod:addWickedTearFlag(tear, flag)
    local t_data = tear:GetData()
    if mod.TearFlagData[flag].PostApply then
        local p = mod:UtilGetPlayerFromTear(tear)
        mod.TearFlagData[flag]:PostApply(p, tear)
        PostApply(p, tear, flag)
    end
    t_data.somethingWicked_customTearFlags = (t_data.somethingWicked_customTearFlags or 0) | flag
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
    tear = tear:ToTear()
    if t_data.somethingWicked_customTearFlags > 0 then
        local p = mod:UtilGetPlayerFromTear(tear)
        for key, value in pairs(SomethingWicked.TearFlagData) do
            if value.EndHitEffect and t_data.somethingWicked_customTearFlags & key > 0 then
                value:EndHitEffect(tear, tear.Position, p)
            end
        end
    end
    if tear:HasTearFlags(TearFlags.TEAR_BURSTSPLIT) then
        for index, value in ipairs(Isaac.FindByType(2)) do
            local v_data = value:GetData()
            local player = mod:UtilGetPlayerFromTear(value)
            if value.FrameCount == 0 and value.Parent == nil and v_data.somethingWicked_customTearFlags == nil and player then
                value = value:ToTear()
                v_data.sw_isHaemoSplitShot = true
                v_data.somethingWicked_customTearFlags = t_data.somethingWicked_customTearFlags

                for key, flag in pairs(SomethingWicked.TearFlagData) do
                
                    if t_data.somethingWicked_customTearFlags & key > 0 and flag.PostApply then
                        flag:PostApply(player, value)
                        PostApply(player, value, key)
                    end
                end
            end
        end
    end

    if tearsWithFlags[tear.Index] or mod.tearRefs[tear.Index] then
        tearsWithFlags[tear.Index] = nil
        mod.tearRefs[tear.Index] = nil
    end
end

SomethingWicked:AddCallback(ModCallbacks.MC_POST_ENTITY_REMOVE, TearRemove, EntityType.ENTITY_TEAR)

function mod:__callStatusEffects(collider, tear, flags, pos, p)
    if not tear then
        return
    end
    if not flags then
        local t_data = tear:GetData()
        if t_data.somethingWicked_customTearFlags == nil then
            return
        end
        flags = t_data.somethingWicked_customTearFlags
    end
    if not pos then
        pos = tear.Position
    end
    if not p then
        p = mod:UtilGetPlayerFromTear(tear)
    end
    if flags > 0 then
        for key, value in pairs(SomethingWicked.TearFlagData) do
            if value.EnemyHitEffect and flags & key > 0 then
                value:EnemyHitEffect(tear, pos, collider, p)
            end
        end
    end
end

local function OnTearHit(_, tear, collider)
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
SomethingWicked:AddPriorityCallback(ModCallbacks.MC_PRE_TEAR_COLLISION, CallbackPriority.EARLY, OnTearHit)
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
    for idx, tear in pairs(mod.tearRefs) do
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

--lazars :)
local function LaserHitEnemy(_, laser, enemy)
    if enemy:IsVulnerableEnemy() then
        mod:__callStatusEffects(enemy, laser)
    end
end
mod:AddCallback(ModCallbacks.MC_POST_LASER_COLLISION, LaserHitEnemy)

local function PostFireMisc(_, laser)
    local player = mod:UtilGetPlayerFromTear(laser)
    if player then
        local l_data = laser:GetData()
        local flags, blacklist = GetTearFlagsToApply(player, laser)
        l_data.somethingWicked_customTearFlags = (l_data.somethingWicked_customTearFlags or 0) | flags

        local t_color = GetTearColorFromFlags(flags, laser.Type == EntityType.ENTITY_LASER, blacklist)
        if t_color then
            laser.Color = laser.Color * t_color
        end
    end
end
mod:AddCallback(ModCallbacks.MC_POST_FIRE_BRIMSTONE, PostFireMisc)
mod:AddCallback(ModCallbacks.MC_POST_FIRE_TECH_LASER, PostFireMisc)
mod:AddCallback(ModCallbacks.MC_POST_FIRE_TECH_X_LASER, PostFireMisc)
mod:AddCallback(ModCallbacks.MC_POST_FIRE_BOMB, PostFireMisc)

function mod:CheckEnemiesInExplosion(bomb, p)
    if bomb.IsFetus then
        local pos = bomb.Position
        local flags = bomb:GetData().somethingWicked_customTearFlags
        
        mod:UtilScheduleForUpdate(function ()        
            local explosions = Isaac.FindByType(EntityType.ENTITY_EFFECT, EffectVariant.BOMB_EXPLOSION)

            local explosion
            for index, value in ipairs(explosions) do
                if value.FrameCount <= 1 and (pos - value.Position):Length() <= 1 then
                explosion = value
                    break
                end
            end

            --i ctrl f'd explosion radius in the isaac discord because i knew if i tried to find it myself it would be slow, painful, and i would end up with an innacurate result
            --https://discord.com/channels/123641386921754625/123961790529929218/946888588073775125 thank you kittenchilly
            if explosion then
                local bombScale = explosion.SpriteScale
                local capsule = Capsule(pos, bombScale, 0, 75)

                for index, value in ipairs(Isaac.FindInCapsule(capsule, EntityPartition.ENEMY)) do
                    if value:IsVulnerableEnemy() then
                        mod:__callStatusEffects(value, bomb, flags, pos, p)
                    end
                end
                --print(explosion.SpriteScale, "is the size btw")
            end
        end, 1, ModCallbacks.MC_POST_UPDATE)
    end
end

--[[local function LaserUpdate(_, laser) i wrote this all before i found out there is literally a laser collision callback LOL
    print(laser.FrameCount)
    local player = SomethingWicked:UtilGetPlayerFromTear(laser)
    if not player then
        return
    end
    if laser.FrameCount ~= 1 then
        return
    end
    
    local samples = laser:GetSamples()
    for i=0, #samples-2 do
    local capsule = Capsule(samples:Get(i), samples:Get(i+1), laser.Size)--laser:GetCollisionCapsule(Vector(200, 0))
    if not capsule then
        print("btw, it's null capsule")
        capsule = laser:GetNullCapsule()
    end

    local enemies = Isaac.FindInCapsule(capsule, EntityPartition.ENEMY)
    for index, value in ipairs(enemies) do
        --local poof = Isaac.Spawn(EntityType.ENTITY_EFFECT, EffectVariant.POOF01, 0, value.Position, Vector.Zero, player)
        print("Def hit enemy")
        value:TakeDamage(0.1, 0, EntityRef(laser), 0)--value:SetColor(Color(0, 0, 1), 2, 99999, false, false)
    end
    end
    --[[local poof = Isaac.Spawn(EntityType.ENTITY_EFFECT, EffectVariant.POOF01, 0, capsule:GetVec3(), Vector.Zero, player)
    local poof2 = Isaac.Spawn(EntityType.ENTITY_EFFECT, EffectVariant.POOF01, 0, capsule:GetVec2(), Vector.Zero, player)
end
SomethingWicked:AddPriorityCallback(ModCallbacks.MC_POST_LASER_UPDATE, CallbackPriority.LATE, LaserUpdate)]]
