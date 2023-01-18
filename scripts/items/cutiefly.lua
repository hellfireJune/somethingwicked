local this = {}
CollectibleType.SOMETHINGWICKED_CUTIE_FLY_ITEM = Isaac.GetItemIdByName("Cutie Fly")
FamiliarVariant.SOMETHINGWICKED_CUTIE_FLY = Isaac.GetEntityVariantByName("Cutie Fly")

SomethingWicked:AddCallback(ModCallbacks.MC_FAMILIAR_INIT, function(_, familiar) 
    familiar:AddToOrbit(-27)
    familiar.OrbitSpeed = 3
    familiar.RoomClearCount = 20

end, FamiliarVariant.SOMETHINGWICKED_CUTIE_FLY)

local function NewRoomBehaviour(familiar)
    if not familiar.Parent and familiar.RoomClearCount > 3 then
        local c_rng = familiar.Player:GetCollectibleRNG(CollectibleType.SOMETHINGWICKED_CUTIE_FLY_ITEM)

        local enemies = Isaac.FindInRadius(Vector.Zero, 80000, 8)
        enemies = SomethingWicked:UtilShuffleTable(enemies, c_rng)

        for _, enemy in pairs(enemies) do
            enemy = enemy:ToNPC()
            if enemy and enemy:IsEnemy() and not enemy:IsBoss() and not enemy:HasEntityFlags(EntityFlag.FLAG_NO_STATUS_EFFECTS) then
                --print("a")
                enemy:AddCharmed(EntityRef(familiar.Player), -1)
                familiar.Parent = enemy
                break
            end
        end
    end
end
function this:FamilarUpdate(familiar)
    familiar.OrbitSpeed = 3
    familiar.OrbitDistance = SomethingWicked.EnemyHelpers:Lerp(Vector(120, 120), Vector(70, 70), (math.sin(familiar.FrameCount / 10) * 0.5) + 0.5)

    if familiar.Parent then
        if familiar.Parent:Exists()  then
            familiar.RoomClearCount = 0
        else
            familiar.Parent = nil
        end
    end
    local target = familiar.Parent or familiar.Player
    local pos = SomethingWicked.FamiliarHelpers:DynamicOrbit(familiar, target, familiar.OrbitSpeed, familiar.OrbitDistance)
    if SomethingWicked.game:GetRoom():GetFrameCount() == 0 then
        familiar.Velocity = Vector.Zero
        familiar.Position = pos
    else
        if SomethingWicked.game:GetRoom():GetFrameCount() == 1 then
            NewRoomBehaviour(familiar)
        end
        familiar.Velocity = SomethingWicked.EnemyHelpers:Lerp(familiar.Velocity, pos - familiar.Position, 0.2)
    end
end
SomethingWicked:AddCallback(ModCallbacks.MC_FAMILIAR_UPDATE, this.FamilarUpdate, FamiliarVariant.SOMETHINGWICKED_CUTIE_FLY)


function this:OnNewThing()
    for _, value in ipairs(Isaac.FindByType(EntityType.ENTITY_FAMILIAR, FamiliarVariant.SOMETHINGWICKED_CUTIE_FLY)) do
        value = value:ToFamiliar()
        NewRoomBehaviour(value)
    end
end

SomethingWicked:AddCustomCBack(SomethingWicked.CustomCallbacks.SWCB_NEW_WAVE_SPAWNED, this.OnNewThing)

function this:HealParent()
    
    for _, familiar in ipairs(Isaac.FindByType(EntityType.ENTITY_FAMILIAR, FamiliarVariant.SOMETHINGWICKED_CUTIE_FLY)) do
        familiar = familiar:ToFamiliar()
        if familiar.Parent then
            local parent = familiar.Parent
            parent:AddHealth(10)
        end
    end
end
SomethingWicked:AddCustomCBack(SomethingWicked.CustomCallbacks.SWCB_ON_ITEM_SHOULD_CHARGE, this.HealParent)

SomethingWicked:AddCallback(ModCallbacks.MC_EVALUATE_CACHE, function (_, player, flags)
        local stacks, rng, sourceItem = SomethingWicked.FamiliarHelpers:BasicFamiliarNum(player, CollectibleType.SOMETHINGWICKED_CUTIE_FLY_ITEM)
        player:CheckFamiliar(FamiliarVariant.SOMETHINGWICKED_CUTIE_FLY, stacks, rng, sourceItem)
end, CacheFlag.CACHE_FAMILIARS)

this.EIDEntries = {}
return this