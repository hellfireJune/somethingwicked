local this = {}
--[[
    hearts: knave of hearts effect
    clubs: minor inner eye
    diamonds: piercing and damage up
    spades: ???
]]

local StyleAdders = {
    ["CLUBS"] = function (tear)
        
    end,
    ["DIAMONDS"] = function (tear)
        
    end,
    ["SPADES"] = function (tear)
        
    end,
    ["HEARTS"] = function (tear)
        
    end,
}
local styleVariant = {
    ["CLUBS"] = TearVariant.SOMETHINGWICKED_JOKER_CLUBS,
    ["DIAMONDS"] = TearVariant.SOMETHINGWICKED_JOKER_DIAMONDS,
    ["SPADES"] = TearVariant.SOMETHINGWICKED_JOKER_SPADES,
    ["HEARTS"] = TearVariant.SOMETHINGWICKED_JOKER_HEARTS,
}

function this:FamiliarInit(familiar)
    familiar:AddToFollowers()
    familiar.Parent = familiar.Parent or familiar.Player
end

local function GetRandomStyle(rng)
    local weighter = rng:RandomFloat()
    if weighter < 0.25 then
        return "CLUBS"
    end
    if weighter < 0.5 then
        return "DIAMONDS"
    end
    if weighter < 0.75 then
        return "SPADES"
    end
    return "HEARTS"
end

function this:FamiliarUpdate(familiar)
    local player = familiar.Player
    local p_data = player:GetData()
    local direction = player:GetFireDirection()

    p_data.SomethingWickedPData.jokerBabyStyle = p_data.SomethingWickedPData.jokerBabyStyle or "NONE"

    familiar.FireCooldown = math.max(familiar.FireCooldown - 1, 0)

    if direction ~= Direction.NO_DIRECTION and familiar.FireCooldown <= 0 then
        local f_rng = familiar:GetDropRNG()
        local fireAngle = SomethingWicked.HoldItemHelpers:GetUseDirection(player)

        local tear = familiar:FireProjectile(fireAngle)
        tear.CollisionDamage = 3.5

        local style = GetRandomStyle(f_rng)
        tear:ChangeVariant(styleVariant[style])

        if style == p_data.SomethingWickedPData.jokerBabyStyle  then
            StyleAdders[style](tear)

            local t_data = tear:GetData()
            t_data.somethingWicked_shouldJokerGlow = true
            tear:Update()
        end

        familiar.FireCooldown = 10
    end
    familiar:FollowParent()
end

local function IsJokerShapedTear(tear)
    return tear.Variant == TearVariant.SOMETHINGWICKED_JOKER_SPADES 
    and tear.Variant == TearVariant.SOMETHINGWICKED_JOKER_CLUBS 
    and tear.Variant == TearVariant.SOMETHINGWICKED_JOKER_DIAMONDS 
    and tear.Variant == TearVariant.SOMETHINGWICKED_JOKER_HEARTS 
end

local function IsRed(tear)
    return tear.Variant ~= TearVariant.SOMETHINGWICKED_JOKER_SPADES 
    and tear.Variant ~= TearVariant.SOMETHINGWICKED_JOKER_CLUBS 
end

SomethingWicked:AddCallback(ModCallbacks.MC_POST_TEAR_UPDATE, function (_, tear)
    local t_data = tear:GetData()
    if t_data.somethingWicked_shouldJokerGlow then
        local isRed = IsRed(tear)
    end

    if IsJokerShapedTear(tear) then
        local sprite = tear:GetSprite()
        sprite.Rotation = SomethingWicked.EnemyHelpers:GetAngleDegreesButGood(tear.Velocity)
    end
end)

this.EIDEntries = {}
return this