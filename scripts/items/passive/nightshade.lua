local mod = SomethingWicked
local wispsCap = 6

local function OnEnemyKill(_, entity)
    if entity == nil or not entity:IsEnemy() then
        return
    end
    
    local wisps = Isaac.FindByType(EntityType.ENTITY_FAMILIAR, FamiliarVariant.WISP, mod.ITEMS.NIGHTSHADE)
    for _, player in ipairs(mod:AllPlayersWithCollectible(mod.ITEMS.NIGHTSHADE)) do--[[and entity:GetDropRNG():RandomFloat() <= 0.33]] 
            
        local numToDo = 0
        for index, value in ipairs(wisps) do
            value = value:ToFamiliar()
            local np = value.Player
            if GetPtrHash(np) == GetPtrHash(player) then
                numToDo = numToDo + 1
                    
                if numToDo >= wispsCap then
                    goto tryagain
                end
            end
        end

        local wisp = Isaac.Spawn(EntityType.ENTITY_FAMILIAR, FamiliarVariant.WISP, mod.ITEMS.NIGHTSHADE, player.Position, Vector.Zero, player)
        wisp.Parent = player

        ::tryagain::
    end
end

local function RemoveWisps()
    local wisps = Isaac.FindByType(EntityType.ENTITY_FAMILIAR, FamiliarVariant.WISP, mod.ITEMS.NIGHTSHADE)
    if wisps ~= nil and #wisps > 0 then
        for _, wisp in ipairs(wisps) do
            wisp:Remove()
        end
    end
end

local timeToDie = 180
local function WispUpdate(_, wisp)
    if wisp.SubType ~= mod.ITEMS.NIGHTSHADE then
        return
    end
    
    local a = wisp.FrameCount / timeToDie
    if a == 1 then
        wisp:Die()
        return
    end
    
    local colour = Color(1, 1, 1, 1-a)
    wisp.Color = colour
end

mod:AddCallback(ModCallbacks.MC_POST_ENTITY_KILL, OnEnemyKill)
mod:AddCallback(ModCallbacks.MC_POST_NEW_ROOM, RemoveWisps)
mod:AddCallback(ModCallbacks.MC_FAMILIAR_UPDATE, WispUpdate, FamiliarVariant.WISP)