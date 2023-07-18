local json = include("json")
local mod = SomethingWicked
mod.save.unlockData = mod.save.unlockData or {}
mod.save.unlockAll = mod.save.unlockAll or false
mod.save.unlockData.unlocks = mod.save.unlockData.unlocks or {}

mod.unlocks = {
    ["APOLLYONS_CROWN"] = {
        unlockData = {
            Collectibles = {CollectibleType.SOMETHINGWICKED_APOLLYONS_CROWN}
        },
        lockStatus = false
    }
}

local contentToLock = {
    Collectibles = {},
    Trinkets = {},
    Consumables = {},
}
for key, value in pairs(mod.unlocks) do
    local unlock = mod.save.unlockData.unlocks[key]
    if unlock then
        value.lockStatus = unlock.lockStatus
    end
    if value.unlockData then
        for _, coll in pairs(value.unlockData.Collectibles) do
            table.insert(contentToLock.Collectibles, {coll, value.lockStatus})
        end
    end
    mod.save.unlockData.unlocks[key] = value
end

function mod:IsAchievementUnlocked(id)
    local unlocker = SomethingWicked.save.unlockData.unlocks[id]
    return unlocker ~= nil and unlocker.lockStatus
end

local function Awesome(_, cmd)
    if cmd == "27616" then
        --[[SomethingWicked.save.unlockData.FLAG_UNLOCK_ALL = not SomethingWicked.save.unlockData.FLAG_UNLOCK_ALL
        print(SomethingWicked.save.unlockData.FLAG_UNLOCK_ALL and "awesome" or "not so awesome")]]
        print("how the hell did you even find this command its like old as a fossil")
        print("something wicked will receive unlocks again sometimes soon, but for now this unlock all command does nothing")
    end
end

--SomethingWicked:AddCallback(ModCallbacks.MC_PRE_SPAWN_CLEAN_AWARD, this.MarkSetter)
--SomethingWicked:AddCallback(ModCallbacks.MC_POST_NEW_ROOM, this.ApollyonsCrownBirettaUnlock)
SomethingWicked:AddCallback(ModCallbacks.MC_EXECUTE_CMD, Awesome)