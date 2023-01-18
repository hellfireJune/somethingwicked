local this = {}
local json = include("json")
SomethingWicked.save.unlockData = SomethingWicked.save.unlockData or {}
SomethingWicked.save.unlockData.FLAG_UNLOCK_ALL = SomethingWicked.save.unlockData.FLAG_UNLOCK_ALL or false
SomethingWicked.save.unlockData.unlocks = SomethingWicked.save.unlockData.unlocks or {}

SomethingWicked.unlocks = {
    ["APOLLYONS_CROWN"] = {
        unlockData = {
            Collectibles = {CollectibleType.SOMETHINGWICKED_APOLLYONS_CROWN}
        },
        lockStatus = false
    }
}

this.contentToLock = {
    Collectibles = {},
    Trinkets = {},
    Consumables = {},
}
for key, value in pairs(SomethingWicked.unlocks) do
    local unlock = SomethingWicked.save.unlockData.unlocks[key]
    if unlock then
        value.lockStatus = unlock.lockStatus
    end
    if value.unlockData then
        for _, coll in pairs(value.unlockData.Collectibles) do
            table.insert(this.contentToLock.Collectibles, {coll, value.lockStatus})
        end
    end
    SomethingWicked.save.unlockData.unlocks[key] = value
end

function SomethingWicked:IsAchievementUnlocked(id)
    local unlocker = SomethingWicked.save.unlockData.unlocks[id]
    return unlocker ~= nil and unlocker.lockStatus
end

--[[this.specialMarkIDs = {
    DOGMA_MOTHER_ROOMDESC = -10,
    MEGA_SATAN_ROOMDESC = -7,
    DELIRIUM_BOSSID = 70,
    ULTRAGREED_BOSSID = 62
}

this.itemUnlocks = {
    ApollyonsCrown = { CollectibleType.SOMETHINGWICKED_APOLLYONS_CROWN, function ()
        return SomethingWicked.save.unlockData.APOLLYON_CROWN_FLAG
    end,
    "gfx/ui/sw achievements/achievement_apollyonscrown.png" },
    MammonsTooth = { CollectibleType.SOMETHINGWICKED_MAMMONS_TOOTH, function ()
        return SomethingWicked.save.unlockData.ABIAH_MOMSHEART_FLAG
    end,
    "gfx/ui/sw achievements/achievement_apollyonscrown.png" },
    DStock = { CollectibleType.SOMETHINGWICKED_D_STOCK, function() 
        return SomethingWicked.save.unlockData.ABIAH_MEGA_SATAN_FLAG
    end,
    "gfx/ui/sw achievements/achievement_apollyonscrown.png" },
    VoidEgg = { CollectibleType.SOMETHINGWICKED_VOID_EGG, function() 
        return SomethingWicked.save.unlockData.ABIAH_HUSH_FLAG
    end,
    "gfx/ui/sw achievements/achievement_apollyonscrown.png" },
    DadsWallet = { CollectibleType.SOMETHINGWICKED_DADS_WALLET, function() 
        return SomethingWicked.save.unlockData.ABIAH_GREEDIER_FLAG
    end,
    "gfx/ui/sw achievements/achievement_apollyonscrown.png" },
    ElectricDice = {CollectibleType.SOMETHINGWICKED_ELECTRIC_DICE, function() 
        return SomethingWicked.save.unlockData.ABIAH_DELIRIUM_FLAG
    end,
    "gfx/ui/sw achievements/achievement_apollyonscrown.png" }
}

this.trinketUnlocks = {
    TwoOfCoins = { TrinketType.SOMETHINGWICKED_TWO_OF_COINS, function ()
        return SomethingWicked.save.unlockData.ABIAH_SATAN_FLAG
    end,
    "gfx/ui/sw achievements/achievement_apollyonscrown.png" },
}


function this:OnGameStart(continue)
    local g = SomethingWicked.game
    SomethingWicked.save.runData.ItemBlacklist = SomethingWicked.save.runData.ItemBlacklist or {}

    if SomethingWicked.save.unlockData.FLAG_UNLOCK_ALL then
        return
    end

    for _, item in pairs(this.itemUnlocks) do
        local unlockFunction = item[2]
        if unlockFunction == nil or unlockFunction() ~= true then
            --g:GetItemPool():RemoveCollectible(item[1])
            table.insert( SomethingWicked.save.runData.ItemBlacklist, item[1])
        end
    end
    for _, trinket in pairs(this.trinketUnlocks) do
        local unlockFunction = trinket[2]
        if unlockFunction == nil or unlockFunction() ~= true then
            g:GetItemPool():RemoveTrinket(trinket[1])
        end
    end
end

SomethingWicked:AddCallback(ModCallbacks.MC_POST_GAME_STARTED, this.OnGameStart)


function this:UnlockAnimationAndSave(achievement)
    if SomethingWicked.save.unlockData.FLAG_UNLOCK_ALL then
        return
    end

    if achievement[2]() == true then
        return
    end

    CCO.AchievementDisplayAPI.PlayAchievement(achievement[3])


    for i, v in ipairs(SomethingWicked:UtilGetAllPlayers()) do
        SomethingWicked.save.runData.playersData[i] = v:GetData().SomethingWickedPData
    end

    local string = json.encode(SomethingWicked.save)
    SomethingWicked:SaveData(string)
end


--------------------------------
---  The Actual Unlocks Bit  ---
--------------------------------
local MarkType = 
{
    IT_LIVES_HARD = 1,
    ISAAC = 2,
    SATAN = 3,
    XXX = 4,
    THE_LAMB = 5,
    BOSS_RUSH = 6,
    HUSH = 7,
    MEGA_SATAN = 8,
    DELIRIUM = 9,
    GREED = 10,
    GREEDIER = 11,
    DOGMA = 12,
    MOTHER = 13,
}

this.saveCharacters = {
    ABIAH = 1,
}

this.CompletionMarks = {}
this.CompletionMarks[this.saveCharacters] = {
    [MarkType.IT_LIVES_HARD] = {
        this.itemUnlocks.MammonsTooth, 
        function ()
            SomethingWicked.save.unlockData.ABIAH_MOMSHEART_FLAG = true
        end
    },
    [MarkType.SATAN] = {
        this.trinketUnlocks.TwoOfCoins,
        function ()
            SomethingWicked.save.unlockData.ABIAH_SATAN_FLAG = true
        end
    },
    [MarkType.MEGA_SATAN] = {
        this.itemUnlocks.DStock, 
        function ()
            SomethingWicked.save.unlockData.ABIAH_MEGA_SATAN_FLAG = true
        end
    },
    [MarkType.DELIRIUM] = {
        this.itemUnlocks.ElectricDice,
        function ()
            SomethingWicked.save.unlockData.ABIAH_DELIRIUM_FLAG = true
        end
    },
    [MarkType.HUSH] = {
        this.itemUnlocks.VoidEgg,
        function ()
            SomethingWicked.save.unlockData.ABIAH_HUSH_FLAG = true
        end
    },
    [MarkType.GREEDIER] = {
        this.itemUnlocks.DadsWallet,
        function ()
            SomethingWicked.save.unlockData.ABIAH_GREEDIER_FLAG = true
        end
    },
}



function this:ApollyonsCrownBirettaUnlock()
    if this.itemUnlocks.ApollyonsCrown[2]() ~= true then
        local locusts = #Isaac.FindByType(EntityType.ENTITY_FAMILIAR, FamiliarVariant.ABYSS_LOCUST)

        if locusts >= 10 then
            this:UnlockAnimationAndSave(this.itemUnlocks.ApollyonsCrown)
            SomethingWicked.save.unlockData.APOLLYON_CROWN_FLAG = true
        end
    end
end

function this:MarkSetter()
    local room = SomethingWicked.game:GetRoom()
    local level = SomethingWicked.game:GetLevel()
    if (room:GetType() ~= RoomType.ROOM_BOSS and room:GetType() ~= RoomType.ROOM_BOSSRUSH and (room:GetType() ~= RoomType.ROOM_DUNGEON or level:GetStage() == LevelStage.STAGE_8)) or level:GetStage() <= LevelStage.STAGE3_1 then
        return
    end

    for _, player in ipairs(SomethingWicked:UtilGetAllPlayers()) do
        if this.CompletionMarks[player:GetPlayerType()] then
            local mark = this:GetCompletionMark(room, level)
            if mark ~= nil then
                local unlock = this.CompletionMarks[player:GetPlayerType()][mark]
                if unlock and unlock[1] and unlock[1][2] ~= true then
                    this:UnlockAnimationAndSave(unlock[1])
                    unlock[2]()
                end

                if mark == MarkType.GREEDIER then
                    
                    unlock = this.CompletionMarks[player:GetPlayerType()][MarkType.GREED]
                    if unlock and unlock[1] and unlock[1][2] ~= true then
                        this:UnlockAnimationAndSave(unlock[1])
                        unlock[2]()
                    end
                end
            end
        end
    end
end

--Most of the special shit to detect certain bosses (mainly the grid index shit) i found through the job mod. ty
function this:GetCompletionMark(room, level)
    local game = SomethingWicked.game
    local roomDesc = level:GetCurrentRoomDesc()

    if game:IsGreedMode() ~= true then
        if room:GetType() == RoomType.ROOM_BOSSRUSH then
            return MarkType.BOSS_RUSH
        end

        if level:GetStage() == LevelStage.STAGE4_2 then
            local mark = level:GetStageType() < StageType.STAGETYPE_GREEDMODE and MarkType.IT_LIVES_HARD or MarkType.MOTHER

            if mark == MarkType.IT_LIVES_HARD then
                return (room:IsCurrentRoomLastBoss() and game.Difficulty == Difficulty.DIFFICULTY_HARD) and mark or nil
            else
                return roomDesc.SafeGridIndex == this.specialMarkIDs.DOGMA_MOTHER_ROOMDESC and mark or nil
            end
        elseif level:GetStage() == LevelStage.STAGE4_3 then
            return MarkType.HUSH
        elseif level:GetStage() == LevelStage.STAGE5 then
            return StageType == StageType.STAGETYPE_ORIGINAL and MarkType.SATAN or MarkType.ISAAC
        elseif level:GetStage() == LevelStage.STAGE6 then
            if roomDesc.SafeGridIndex == this.specialMarkIDs.MEGA_SATAN_ROOMDESC then
                return MarkType.MEGA_SATAN
            else
                return StageType == StageType.STAGETYPE_ORIGINAL and MarkType.THE_LAMB or MarkType.XXX
            end
        elseif level:GetStage() == LevelStage.STAGE7 and room:GetBossID() == this.specialMarkIDs.DELIRIUM_BOSSID then
            return MarkType.DELIRIUM
        elseif level:GetStage() == LevelStage.STAGE8 and roomDesc.SafeGridIndex == this.specialMarkIDs.DOGMA_MOTHER_ROOMDESC then
            return MarkType.DOGMA
        end
    elseif level:GetStage() == LevelStage.STAGE7_GREED and room:GetBossID() == this.specialMarkIDs.ULTRAGREED_BOSSID then
        return game.Difficulty == Difficulty.DIFFICULTY_GREEDIER and MarkType.GREEDIER or MarkType.GREED
    end
end]]

function this:Awesome(cmd)
    if cmd == "27616" then
        --[[SomethingWicked.save.unlockData.FLAG_UNLOCK_ALL = not SomethingWicked.save.unlockData.FLAG_UNLOCK_ALL
        print(SomethingWicked.save.unlockData.FLAG_UNLOCK_ALL and "awesome" or "not so awesome")]]
        print("sorry im temporarily just making everything unlocked from the start ):. itll come back when abiah is done and the unlocks are ready.")
    end
end

--SomethingWicked:AddCallback(ModCallbacks.MC_PRE_SPAWN_CLEAN_AWARD, this.MarkSetter)
--SomethingWicked:AddCallback(ModCallbacks.MC_POST_NEW_ROOM, this.ApollyonsCrownBirettaUnlock)
SomethingWicked:AddCallback(ModCallbacks.MC_EXECUTE_CMD, this.Awesome)