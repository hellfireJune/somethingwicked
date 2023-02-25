local this = {}
local mod = SomethingWicked
local game = Game()
CollectibleType.SOMETHINGWICKED_CLOAK_OF_EDITH = Isaac.GetItemIdByName("Cloak of Edith")
EffectVariant.SOMETHINGWICKED_EDITH_SALT_CIRCLE = Isaac.GetEntityVariantByName("Edith Salt Circle")

function this:NewRoomLogic()
    local level = game:GetLevel()
    local room = game:GetRoom()
    mod.save.runData = mod.save.runData or {}
    mod.save.runData.CoE_rooms = mod.save.runData.CoE_rooms or {}

    local idx = level:GetCurrentRoomIndex()
    if not mod.save.runData.CoE_rooms[idx] then
        local newData = {}
        
        local stacks = mod.ItemHelpers:GlobalGetCollectibleNum(CollectibleType.SOMETHINGWICKED_CLOAK_OF_EDITH)
        local rng = mod.ItemHelpers:GlobalGetCollectibleRNG(CollectibleType.SOMETHINGWICKED_CLOAK_OF_EDITH)

        local rocks = {}
        for i = 0, room:GetGridSize(), 1 do
            local g = room:GetGridEntity(i)
            if g and g:GetType() == GridEntityType.GRID_ROCK then
                local emptyAdjacent = false
                for ii = 0, 3, 1 do
                    local o_idx = i + mod.RedKeyRoomHelpers.adjindexes[RoomShape.ROOMSHAPE_1x1][ii]
                    local o_g = room:GetGridEntity(o_idx)
                    if not o_g
                    or o_g:GetType() == GridEntityType.GRID_PIT then
                        emptyAdjacent = true
                    end
                end
                if emptyAdjacent then
                    table.insert(rocks, i)
                end
            end
        end
        rocks = SomethingWicked:UtilShuffleTable(rocks, rng)
        for i = 1, stacks, 1 do
            if rocks[stacks] then
                table.insert(newData, rocks[stacks])
            end
        end

        mod.save.runData.CoE_rooms[idx] = newData
    end
    local rCoEdata = mod.save.runData.CoE_rooms[idx]
    for _, rockIdx in ipairs(rCoEdata) do
        local rock = room:GetGridEntity(rockIdx)
        rock.CollisionClass = GridCollisionClass.COLLISION_WALL
        --this would be where i made the rock change sprite and also make it tall

        local circle = Isaac.Spawn(EntityType.ENTITY_EFFECT, EffectVariant.SOMETHINGWICKED_EDITH_SALT_CIRCLE, 0, rock.Position, Vector.Zero, nil)
        local c_data = circle:GetData()
        c_data.somethingWicked_edithparentRock = rock
    end
end

local radius = 100
local dmg = 5
local cooldown = 30
function this:EffectUpdate(effect)
    local e_data = effect:GetData()
    local rock = e_data.somethingWicked_edithparentRock
    if rock and rock.State == 1 then
        e_data.sw_CoEattackCooldown = e_data.sw_CoEattackCooldown or 0
        if e_data.sw_CoEattackCooldown <= 0 then
            local enemies = Isaac.FindInRadius(effect.Position, radius, EntityPartition.ENEMY)
            for _, ent in ipairs(enemies) do
                if not ent:HasEntityFlags(EntityFlag.FLAG_NO_PHYSICS_KNOCKBACK) then
                    local veloc = ent.Position - effect.Position
                    veloc = veloc:Normalized():Resized(20)

                    ent:AddEntityFlags(EntityFlag.FLAG_KNOCKED_BACK)
                    ent:AddVelocity(veloc)
                end

                ent:TakeDamage(dmg, 0, EntityRef(effect), 1)
                ent:SetColor(Color(1, 1, 1, 1, 0.5, 0.5, 0.5), math.floor(cooldown*0.6666), 1, true, false)
                e_data.sw_CoEattackCooldown = cooldown
            end
        else
            e_data.sw_CoEattackCooldown = e_data.sw_CoEattackCooldown - 1
        end

        local players = Isaac.FindInRadius(effect.Position, radius, EntityPartition.PLAYER)
        for _, player in ipairs(players) do
            local p_data = player:GetData()
            p_data.sw_inEdithAura = true
        end
    else
        effect:Remove()
    end
end

function this:PEffectUpdate(player)
    local p_data = player:GetData()
    local shouldBoost = p_data.sw_inEdithAura
    if shouldBoost == nil then
        return
    end

    p_data.sw_shouldEdithBoost = p_data.sw_shouldEdithBoost or false
    if p_data.sw_shouldEdithBoost ~= shouldBoost then
        p_data.sw_shouldEdithBoost = shouldBoost

        player:AddCacheFlags(CacheFlag.CACHE_ALL)
        player:EvaluateItems()
    end
    if not p_data.sw_inEdithAura then
        p_data.sw_inEdithAura = nil
        return
    end
    p_data.sw_inEdithAura = false
end

mod:AddCallback(ModCallbacks.MC_POST_NEW_ROOM, this.NewRoomLogic)
mod:AddCallback(ModCallbacks.MC_POST_EFFECT_UPDATE, this.EffectUpdate, EffectVariant.SOMETHINGWICKED_EDITH_SALT_CIRCLE)
mod:AddCallback(ModCallbacks.MC_POST_PEFFECT_UPDATE, this.PEffectUpdate)
mod:AddCallback(ModCallbacks.MC_EVALUATE_CACHE, function (_, player, flags)
    local shouldBoost = player:GetData().sw_shouldEdithBoost
    if flags == CacheFlag.CACHE_FIREDELAY then
        player.MaxFireDelay = mod.StatUps:TearsUp(player, 0, 0, shouldBoost and 2 or 1)
    end
    if flags == CacheFlag.CACHE_TEARFLAG and shouldBoost then
        player.TearFlags = player.TearFlags | TearFlags.TEAR_HOMING
    end
    if flags == CacheFlag.CACHE_TEARCOLOR and shouldBoost then
        player.TearColor = player.TearColor * Color(0.8, 0.8, 0.8, 1, 0.2, 0.2, 0.2)
    end
end)

this.EIDEntries = {
    [CollectibleType.SOMETHINGWICKED_CLOAK_OF_EDITH] = {
        desc = "Turns a rock into  the girl"
    }
}
return this