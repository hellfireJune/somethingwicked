local mod = SomethingWicked
local json = require("json")
local game = Game()

if mod:HasData() then
    mod.save = json.decode(mod:LoadData())
else mod.save = {} end

mod.save.runData = mod.save.runData or {}
mod.save.runData.playersData = mod.save.runData.playersData or {}



local function PlayerInit(_, player)
    local p_data = player:GetData()

    if game:GetFrameCount() > 0 then
        for i, v in ipairs(SomethingWicked:UtilGetAllPlayers()) do
            if v.Index == player.Index then
                p_data.SomethingWickedPData = SomethingWicked.save.runData.playersData[i] or {}
            end
        end
    else p_data.SomethingWickedPData = {} end
end

local function PreGameExit()
    mod:SaveModData()
end

function mod:SaveModData()

    for i, v in ipairs(SomethingWicked:UtilGetAllPlayers()) do
        SomethingWicked.save.runData.playersData[i] = v:GetData().SomethingWickedPData
    end

    local string = json.encode(SomethingWicked.save)
    SomethingWicked:SaveData(string)
end

local function ClearRunData(_, continue)
    if continue ~= true then
        SomethingWicked.save.runData = nil
        SomethingWicked.save.runData = {}
        SomethingWicked.save.runData.playersData = {}
    end
end

function mod:SaveWoRunData()
    local runData = mod.save.runData

    local oldData = json.decode(mod:LoadData())
    local tab = mod.save
    tab.runData = oldData.runData
    tab = json.encode(tab)
    SomethingWicked:SaveData(tab)
    mod.save.runData = runData
end

SomethingWicked:AddPriorityCallback(ModCallbacks.MC_POST_PLAYER_INIT, CallbackPriority.EARLY, PlayerInit)
SomethingWicked:AddCallback(ModCallbacks.MC_PRE_GAME_EXIT, PreGameExit)
SomethingWicked:AddCallback(ModCallbacks.MC_POST_GAME_STARTED, ClearRunData)
mod:AddCallback(ModCallbacks.MC_POST_NEW_LEVEL, function ()
    mod:SaveModData()
end)