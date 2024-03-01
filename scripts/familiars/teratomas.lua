local mod = SomethingWicked
local game = Game()

local spriteArray = {
    "teratoma_sheet_001",
    "teratoma_sheet_002",
    "teratoma_sheet_003",
}

local function FamiliarInit(_, familiar)
    if familiar.SubType == 2 then
        return
    end

    local sprite = familiar:GetSprite()

    local rng = familiar:GetDropRNG()
    sprite:ReplaceSpritesheet(0, "gfx/familiars/"..mod:GetRandomElement(spriteArray, rng)..".png")
    sprite:LoadGraphics()

    familiar.Velocity = RandomVector()*2
end

local moveSpeed = 2
local superMoveSpeed = 7.5;
local function UpdateFamiliar(_, orbital)
    local f_data = orbital:GetData()
    local parent = orbital.Parent
    local position = orbital.Position + orbital.Velocity
    local parentIsPlayer = parent.Type == EntityType.ENTITY_PLAYER
    local isBig = orbital.SubType > 1

    local radius = parentIsPlayer and 80 or 40
    local away = parent.Position - position
    local distance = away:Length()
    if f_data.sw_lastVelAdded then
        orbital.Velocity = orbital.Velocity - f_data.sw_lastVelAdded
    end

    if distance > radius then
        if orbital.State == 0 then
            orbital.State = 1
            local vector = mod:CollisionKnockback(position, position+(away), orbital.Velocity)
            orbital.Velocity = vector*superMoveSpeed

            f_data.sw_tomaDesperationFrames = 0
        end
    elseif orbital.State == 1 then
        orbital.State = 0
    end
    f_data.sw_tomaDesperationFrames = (f_data.sw_tomaDesperationFrames or 0) + 1
    
    local lerp = math.max(0.1, 1-(f_data.sw_tomaDesperationFrames/10))
    local speed = mod:Lerp(moveSpeed, superMoveSpeed, lerp)  orbital.Velocity = orbital.Velocity:Normalized()*speed
    
    local room = game:GetRoom()
    if room:GetFrameCount() > 0 then
        f_data.sw_lastVelAdded = (parent.Position - (f_data.sw_lastParentPos or Vector.Zero))
        orbital.Velocity = orbital.Velocity + f_data.sw_lastVelAdded
    else
        orbital.Velocity = RandomVector() * moveSpeed
    end
    f_data.sw_lastParentPos = parent.Position
end

SomethingWicked:AddCallback(ModCallbacks.MC_FAMILIAR_INIT, FamiliarInit, FamiliarVariant.SOMETHINGWICKED_TERATOMA_ORBITAL)
SomethingWicked:AddCallback(ModCallbacks.MC_FAMILIAR_UPDATE, UpdateFamiliar, FamiliarVariant.SOMETHINGWICKED_TERATOMA_ORBITAL)

mod:AddPriorityCallback(ModCallbacks.MC_PRE_FAMILIAR_COLLISION, CallbackPriority.LATE, function (_, familiar, other)
    
end)