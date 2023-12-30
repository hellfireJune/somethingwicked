local mod = SomethingWicked

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
end

local function UpdateFamiliar(_, orbital)
    local parent = orbital.Parent
    local position = orbital.Position + orbital.Velocity
    local parentIsPlayer = parent.Type == EntityType.ENTITY_PLAYER
    local isBig = orbital.SubType > 1

    local radius = parentIsPlayer and 240 or 120
    local distance = parent.Position:Distance(position)

    if distance > radius then
        if orbital.State == 0 then
            orbital.State = 1

            local vector = mod:CollisionKnockback(position-orbital.Velocity, position, orbital.Velocity)
            orbital.Velocity = vector
        end
    elseif orbital.State == 1 then
        orbital.State = 0
    end
end

SomethingWicked:AddCallback(ModCallbacks.MC_FAMILIAR_INIT, FamiliarInit, FamiliarVariant.SOMETHINGWICKED_TERATOMA_ORBITAL)
SomethingWicked:AddCallback(ModCallbacks.MC_FAMILIAR_UPDATE, UpdateFamiliar, FamiliarVariant.SOMETHINGWICKED_TERATOMA_ORBITAL)

function this:TeratomaChunkPickup(player, room)
    local rng = player:GetCollectibleRNG(CollectibleType.SOMETHINGWICKED_TERATOMA_CHUNK)
    for i = 1, 8 + rng:RandomInt(6), 1 do
        Isaac.Spawn(EntityType.ENTITY_FAMILIAR, FamiliarVariant.SOMETHINGWICKED_TERATOMA_ORBITAL, 0, player.Position, Vector.Zero, player)
    end
end