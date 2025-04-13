local mod = SomethingWicked
local game = Game()

local directory = "gfx/grid/grid_lourdeswaterangelstatue.anm2"
local directions = {
    [0] = Vector(-1, 0),
    [1] = Vector(0, -1),
    [2] = Vector(1, 0),
    [3] = Vector(0, 1)
}

local otherRockSprites = {
    [-1] = { -- left
        [0] = -1,
        [5] = 3,
        [6] = 3,
    },
    [1] = {
        [1] = -1,
        [5] = 3,
        [7] = 3,
    }, -- right
    [-13] = {
        [2] = -1,
        [4] = 0,
        [5] = 0,
    }, --up
    [13] = {
        [3] = -1,
        [6] = 0,
        [7] = 0,
    }, --down
}

local function NewRoomLogic()
    local level = game:GetLevel()
    local room = game:GetRoom()
    mod.save.runData = mod.save.runData or {}
    mod.save.runData.CoE_rooms = mod.save.runData.CoE_rooms or {}

    local idx = level:GetCurrentRoomDesc().SafeGridIndex
    local currRoom = level:GetCurrentRoomDesc ()
    if level:GetStartingRoomIndex() == idx
    and currRoom.VisitedCount == 1 then
        mod.save.runData.CoE_rooms = {}
    end
    if not mod.save.runData.CoE_rooms[idx] then
        local newData = {}
        
        local stacks = PlayerManager.GetNumCollectibles(mod.ITEMS.LOURDES_WATER)
        local rng = mod:GlobalGetCollectibleRNG(mod.ITEMS.LOURDES_WATER)

        local rocks = {}
        for i = 0, room:GetGridSize(), 1 do
            local g = room:GetGridEntity(i)
            if g and g:GetType() == GridEntityType.GRID_ROCK then
                local emptyAdjacent = false
                for ii = 0, 3, 1 do
                    local o_idx = i + mod.adjindexes[RoomShape.ROOMSHAPE_1x1][ii]
                    if math.abs(mod.adjindexes[RoomShape.ROOMSHAPE_1x1][ii]) == 13 then
                        o_idx = i + room:GetGridWidth()
                    end
                    local o_g = room:GetGridEntity(o_idx)
                    if room:IsPositionInRoom(room:GetGridPosition(i) + (Vector(40, 40)*directions[ii]), 32) and (not o_g
                    or o_g:GetType() == GridEntityType.GRID_PIT) then
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
        if not rock or rock.State ~= 1 then
            return
        end

        local sprite = rock:GetSprite()
        rock:GetSprite():Load(directory, true)
        sprite:Play("idle", true)
        sprite:Update()

        for i = 0, 3, 1 do
            local key = mod.adjindexes[RoomShape.ROOMSHAPE_1x1][i]
            local o_idx = rockIdx + key
            if math.abs(key) == 13 then
                o_idx = rockIdx + room:GetGridWidth()
            end

            local adjRock = room:GetGridEntity(o_idx)
            if adjRock then
                local o_sprite = adjRock:GetSprite()
                if o_sprite:GetAnimation()  =="big" then
                    local newFrame = otherRockSprites[key][o_sprite:GetFrame()]
                    if newFrame then
                        if newFrame == -1 then
                            o_sprite:Play("normal", true)
                        else
                            o_sprite:SetFrame(newFrame)
                        end

                        o_sprite:Update()
                        adjRock:Update()
                    end
                end
            end
        end

        local circle = Isaac.Spawn(EntityType.ENTITY_EFFECT, mod.EFFECTS.HOLY_STATUE_CIRCLE, 0, rock.Position, Vector.Zero, nil)
        local c_data = circle:GetData()
        c_data.somethingWicked_edithparentRock = rock

        local c_sprite = circle:GetSprite()
        c_sprite:Play("Appear")
    end
end

local radius = 100
local dmg = 5
local cooldown = 30
local function EffectUpdate(_, effect)
    local e_sprite = effect:GetSprite()
    local e_data = effect:GetData()
    local rock = e_data.somethingWicked_edithparentRock
    if rock and rock.State == 1 then
        e_data.sw_CoEattackCooldown = e_data.sw_CoEattackCooldown or 0
        if e_data.sw_CoEattackCooldown <= 0 then
            local level = game:GetLevel()
            local stage = level:GetAbsoluteStage()

            local enemies = Isaac.FindInRadius(effect.Position, radius, EntityPartition.ENEMY)
            for _, ent in ipairs(enemies) do
                if ent.Type ~= EntityType.ENTITY_BOMB then
                    if not ent:HasEntityFlags(EntityFlag.FLAG_NO_PHYSICS_KNOCKBACK) then
                        local veloc = ent.Position - effect.Position
                        veloc = veloc:Normalized():Resized(20)

                        ent:AddEntityFlags(EntityFlag.FLAG_KNOCKED_BACK)
                        ent:AddVelocity(veloc)
                    end

                    ent:TakeDamage(10 + 2 * (stage - 1), 0, EntityRef(effect), 1)
                    ent:SetColor(Color(1, 1, 1, 1, 0.5, 0.5, 0.5), math.floor(cooldown*0.6666), 1, true, false)
                    e_data.sw_CoEattackCooldown = cooldown
                end
            end
        else
            e_data.sw_CoEattackCooldown = e_data.sw_CoEattackCooldown - 1
        end

        local players = Isaac.FindInRadius(effect.Position, radius, EntityPartition.PLAYER)
        for _, player in ipairs(players) do
            local p_data = player:GetData()
            p_data.sw_inEdithAura = true
        end

        local rHelper = e_data.sw_renderHelper
        if e_data.sw_renderHelper == nil then
            e_data.sw_renderHelper = Isaac.Spawn(EntityType.ENTITY_EFFECT, mod.EFFECTS.MOTV_HELPER, 4, effect.Position, Vector.Zero, effect)
            rHelper = e_data.sw_renderHelper
            rHelper.Parent = effect
            local sprite = rHelper:GetSprite()
            sprite:Load(directory, true)
            sprite:ReplaceSpritesheet(0, "butidreamofawoman.png")
            sprite:LoadGraphics()
            sprite:Play("idle", true)
        end

        if e_sprite:IsFinished("Appear") then
            e_sprite:Play("Idle")
        end
    else
        e_sprite:Play("Disappear")
        if e_sprite:IsFinished("Disappear") then
            effect:Remove()
        end
        
        if e_data.sw_renderHelper then
            e_data.sw_renderHelper:Remove()
        end
    end
end

function mod:lourdesWaterTick(player)
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

mod:AddCallback(ModCallbacks.MC_POST_NEW_ROOM, NewRoomLogic)
mod:AddCallback(ModCallbacks.MC_POST_EFFECT_UPDATE, EffectUpdate, mod.EFFECTS.HOLY_STATUE_CIRCLE)
mod:AddCallback(ModCallbacks.MC_POST_PEFFECT_UPDATE, mod.lourdesWaterTick)