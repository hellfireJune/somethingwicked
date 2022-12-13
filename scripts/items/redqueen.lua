local this = {}
CollectibleType.SOMETHINGWICKED_RED_QUEEN = Isaac.GetItemIdByName("Red Queen")

local function proc(player) 
    return 1
end
function this:EnemyDMG(tear, collider, player, procChance)
    if not player or not player:HasCollectible(CollectibleType.SOMETHINGWICKED_RED_QUEEN) then
        return
    end

    local c_rng = player:GetCollectibleRNG(CollectibleType.SOMETHINGWICKED_RED_QUEEN)
    if c_rng:RandomFloat() > proc(player) then
        return
    end
    
    local room = SomethingWicked.game:GetRoom()

    local p_data = player:GetData()
    p_data.somethingWicked_RedQueenVolleyData = p_data.somethingWicked_RedQueenVolleyData or {}
    local startPos = room:GetClampedGridIndex(collider.Position)
    startPos = room:GetGridPosition(startPos)

    table.insert(p_data.somethingWicked_RedQueenVolleyData, {Tile = startPos, direction = nil})
end
SomethingWicked:AddCustomCBack(SomethingWicked.CustomCallbacks.SWCB_ON_ENEMY_HIT, this.EnemyDMG)

function this:PlayerUpdate(player)
    local p_data = player:GetData()
    if not p_data.somethingWicked_RedQueenVolleyData then
        return
    end

    for idx, value in pairs(p_data.somethingWicked_RedQueenVolleyData) do
        if value.Effect == nil
        or not value.Effect:Exists() then
            if value.ShouldDestroyIfNil then
                if value.direction == nil then
                    for i = 1, 720, 90 do
                        local mult = (i > 360 and 1 or 0)
                        i = i % 360 + (45 * mult)
                        local direction = Vector.FromAngle(i):Resized(40*(mult*0.5+1))

                        local currentTilePos = value.Tile + direction
                        table.insert(p_data.somethingWicked_RedQueenVolleyData, {Tile = currentTilePos, direction = direction})
                    end
                else
                    local currentTilePos = value.Tile + value.direction
                    table.insert(p_data.somethingWicked_RedQueenVolleyData, {Tile = currentTilePos, direction = value.direction})
                end
                p_data.somethingWicked_RedQueenVolleyData[idx] = nil
            else
                if value.Tile then
                    
                    local effect = Isaac.Spawn(EntityType.ENTITY_EFFECT, EffectVariant.SOMETHINGWICKED_GLITCHED_TILE, 0, value.Tile, Vector.Zero, player):ToEffect()
                    effect:SetTimeout(12)
                    value.Effect = effect

                    value.ShouldDestroyIfNil = true
                else
                    p_data.somethingWicked_RedQueenVolleyData[idx] = nil
                end
            end
        end
    end
end
SomethingWicked:AddCallback(ModCallbacks.MC_POST_PEFFECT_UPDATE, this.PlayerUpdate)

SomethingWicked:AddCallback(ModCallbacks.MC_POST_EFFECT_UPDATE, function (_, effect)
    if effect.Timeout < 1 then
        effect:Remove()
    end
end, EffectVariant.SOMETHINGWICKED_GLITCHED_TILE)
SomethingWicked:AddCallback(ModCallbacks.MC_POST_NEW_ROOM, function ()
    for _, value in ipairs(SomethingWicked:UtilGetAllPlayers()) do
        local p_data = value:GetData()
        p_data.somethingWicked_RedQueenVolleyData = nil
    end
end)

this.EIDEntries = {}
return this