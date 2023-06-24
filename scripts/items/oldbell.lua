local this = {}
local mod = SomethingWicked

local freezeDuration = 120
local EnemiesToUnfreeze = {}
local EnemiesToIgnore = {}
function this:UseItem()
    mod.FreezeTimer = (mod.FreezeTimer or 0) + freezeDuration
    return true
end
mod:AddCallback(ModCallbacks.MC_USE_ITEM, this.UseItem, CollectibleType.SOMETHINGWICKED_OLD_BELL)

local WhiteList = {
    { Type = EntityType.ENTITY_EFFECT, Variant = EffectVariant.TEAR_POOF_A},
    { Type = EntityType.ENTITY_EFFECT, Variant = EffectVariant.TEAR_POOF_B},
}
local function IsPlayerEnt(ent)
    local types = { EntityType.ENTITY_PLAYER, EntityType.ENTITY_TEAR, EntityType.ENTITY_FAMILIAR}

    return mod:UtilTableHasValue(types, ent.Type)
end
local function IsEntityPlayerOwnedAtAll(ent, lastEnt)
    if lastEnt == nil then
        if IsPlayerEnt(ent) then
            return true
        end
        for _, value in ipairs(WhiteList) do
            if ent.Type == value.Type
            and ent.Variant == value.Variant then
                return true
            end
        end
    end
    for i = 1, 2, 1 do
        local testEnt = i == 1 and ent.Parent or ent.SpawnerEntity
        if testEnt then
            if IsPlayerEnt(ent) then
                return true
            end                            

            if lastEnt == nil or GetPtrHash(testEnt) ~= GetPtrHash(lastEnt) then
                if IsEntityPlayerOwnedAtAll(testEnt, ent) then
                    return true
                end
            end
        end
    end
    return false
end

function this:FreezeUpdate()
    if mod.FreezeTimer then
        if mod.FreezeTimer <= 0 then
            for index, value in ipairs(EnemiesToUnfreeze) do
                if value then
                    value:ClearEntityFlags(EntityFlag.FLAG_FREEZE)
                end
            end

            EnemiesToIgnore = {}
            EnemiesToUnfreeze = {}
            return
        end
        local roomEntities = Isaac.GetRoomEntities()
        for index, value in ipairs(roomEntities) do
            if not value:HasEntityFlags(EntityFlag.FLAG_FREEZE)
            and not mod:UtilTableHasValue(EnemiesToIgnore) then
                local shouldFreeze = not IsEntityPlayerOwnedAtAll(value)
                if shouldFreeze then
                    value:AddEntityFlags(EntityFlag.FLAG_FREEZE)
                    table.insert(EnemiesToUnfreeze, value)
                else
                    table.insert(EnemiesToIgnore, value)
                end
            end
        end
        mod.FreezeTimer = mod.FreezeTimer - 1
    end
end
mod:AddCallback(ModCallbacks.MC_POST_UPDATE, this.FreezeUpdate)

mod:AddCallback(ModCallbacks.MC_POST_ENTITY_REMOVE, function (_, entity)
    if mod:UtilTableHasValue(EnemiesToUnfreeze, entity) then
        entity:ClearEntityFlags(EntityFlag.FLAG_FREEZE)
    end
end)

this.EIDEntries = {
    [CollectibleType.SOMETHINGWICKED_OLD_BELL] = {
        desc = "Freezes time for"..math.floor((freezeDuration/30)).." seconds",
        Hide = true,
    }
}
return this