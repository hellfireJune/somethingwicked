local this = {}

local function procChance(player, c_rng)
    return 1
end
function this:FirePure(shooter, vector, scalar, player)
    if player:HasCollectible(CollectibleType.SOMETHINGWICKED_SPECIAL_HERBS_BOX) then
        local c_rng = player:GetCollectibleRNG(CollectibleType.SOMETHINGWICKED_SPECIAL_HERBS_BOX)
        if c_rng:RandomFloat() < procChance(player, c_rng) then
            local room = SomethingWicked.game:GetRoom()

            local angle = c_rng:RandomInt(61) - 30
            vector = vector:Rotated(angle):Resized(360)
            local flag, point2 = room:CheckLine(shooter.Position, shooter.Position + vector, 3)

            vector = vector:Resized(30)
            local spawnVector = shooter.Position + vector
            while spawnVector:Distance(shooter.Position) < (shooter.Position):Distance(point2) do
                Isaac.Spawn(EntityType.ENTITY_EFFECT, EffectVariant.SOMETHINGWICKED_SPIDER_EGG, 0, spawnVector, Vector.Zero, player)
                spawnVector = spawnVector + vector
            end
        end
    end
end

SomethingWicked:AddCustomCBack(SomethingWicked.CustomCallbacks.SWCB_ON_FIRE_PURE, this.FirePure)

this.EIDEntries = {}
return this