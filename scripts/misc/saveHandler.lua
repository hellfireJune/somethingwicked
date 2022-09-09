local this = {}
local json = require("json")

if SomethingWicked:HasData() then
    SomethingWicked.save = json.decode(SomethingWicked:LoadData())
else SomethingWicked.save = {} end

SomethingWicked.save.runData = SomethingWicked.save.runData or {}
SomethingWicked.save.runData.playersData = SomethingWicked.save.runData.playersData or {}



function this:PlayerInit(player)
    local game = SomethingWicked.game
    local p_data = player:GetData()

    if game:GetFrameCount() > 0 then
        for i, v in ipairs(SomethingWicked:UtilGetAllPlayers()) do
            if v.Index == player.Index then
                p_data.SomethingWickedPData = SomethingWicked.save.runData.playersData[i] or {}
            end
        end
    else p_data.SomethingWickedPData = {} end
end

function this:PreGameExit()
    for i, v in ipairs(SomethingWicked:UtilGetAllPlayers()) do
        SomethingWicked.save.runData.playersData[i] = v:GetData().SomethingWickedPData
    end

    local string = json.encode(SomethingWicked.save)
    SomethingWicked:SaveData(string)
end

function this:ClearRunData(continue)
    if continue ~= true then
        SomethingWicked.save.runData = nil
        SomethingWicked.save.runData = {}
        SomethingWicked.save.runData.playersData = {}
    end
end

SomethingWicked:AddCallback(ModCallbacks.MC_POST_PLAYER_INIT, this.PlayerInit)
SomethingWicked:AddCallback(ModCallbacks.MC_PRE_GAME_EXIT, this.PreGameExit)
SomethingWicked:AddCallback(ModCallbacks.MC_POST_GAME_STARTED, this.ClearRunData)