local mod = SomethingWicked
local game = Game()
local sfx = SFXManager()

local function NewLevel()
    local libraryExists
    local level = game:GetLevel()

    local itemflag, player = mod:GlobalPlayerHasCollectible(mod.ITEMS.ENCYCLOPEDIA)
    if itemflag and player then
        local rng = player:GetCollectibleRNG(mod.ITEMS.ENCYCLOPEDIA)
        libraryExists = mod:RoomTypeCurrentlyExists(RoomType.ROOM_LIBRARY, level, rng)

        if not libraryExists then
            local randomFloat = rng:RandomFloat()
            if randomFloat < 0.33 then
                mod:GenerateSpecialRoom("library", 1, 6, true, rng)
            end
        end
    end
end 

local function UseItem(_, _, rngObj, player)
    local shopIDx = game:GetLevel():QueryRoomTypeIndex(RoomType.ROOM_LIBRARY, true, rngObj)
    game:StartRoomTransition(shopIDx, Direction.NO_DIRECTION, RoomTransitionAnim.TELEPORT)

    local p_data = player:GetData()
    if player:HasCollectible(CollectibleType.COLLECTIBLE_BOOK_OF_VIRTUES) then
        if p_data.WickedPData.EncycloWisps == nil then
            p_data.WickedPData.EncycloWisps = {[1] = "", [2] = "", [3] = "", [4] = ""}
        end

        local w = Isaac.FindByType(EntityType.ENTITY_FAMILIAR, FamiliarVariant.WISP, mod.ITEMS.ENCYCLOPEDIA)
        local wispsToRespawn = { 1, 2, 3, 4 }
        for _, wisp in pairs(w) do
            local initSeed = wisp.InitSeed
            local flag, idx = mod:UtilTableHasValue(p_data.WickedPData.EncycloWisps, initSeed)
            if flag and idx then
                wispsToRespawn[idx] = nil
            end
        end

        for index, value in ipairs(wispsToRespawn) do
            local wisp = player:AddWisp(mod.ITEMS.ENCYCLOPEDIA, player.Position)
            p_data.WickedPData.EncycloWisps[index] = wisp.InitSeed
        end
    end

    if player:HasCollectible(CollectibleType.COLLECTIBLE_BOOK_OF_BELIAL_PASSIVE) then
        if not p_data.WickedPData.EncycloBelialBuff then
            mod:UtilScheduleForUpdate(function ()
                sfx:Play(SoundEffect.SOUND_DEVIL_CARD, 1, 0)
                Isaac.Spawn(EntityType.ENTITY_EFFECT, EffectVariant.POOF02, 3, player.Position, Vector.Zero, player)
                Isaac.Spawn(EntityType.ENTITY_EFFECT, EffectVariant.POOF02, 4, player.Position, Vector.Zero, player)
            end, 3)
        end
        p_data.WickedPData.EncycloBelialBuff = 1

    end

    return { Discharge = false }
end

local lastEncycloCheck = nil
local function PlayerUpdate(_, player)
    if not player:HasCollectible(mod.ITEMS.ENCYCLOPEDIA) then
        return
    end
    local rng = player:GetCollectibleRNG(mod.ITEMS.ENCYCLOPEDIA)
    local encycloCheck = mod:RoomTypeCurrentlyExists(RoomType.ROOM_LIBRARY, nil, rng)
    if encycloCheck ~= lastEncycloCheck then
        lastEncycloCheck = encycloCheck

        local newCharge = (encycloCheck) and 1 or 0
        local datas = mod:GetAllActiveDatasOfType(player, mod.ITEMS.ENCYCLOPEDIA)
        for slot, oldCharge in pairs(datas) do
            player:SetActiveCharge(newCharge, slot)
        end

        local p_data = player:GetData()
        if not encycloCheck and p_data.WickedPData.EncycloBelialBuff then
            p_data.WickedPData.EncycloBelialBuff = nil
            player:AddCacheFlags(CacheFlag.CACHE_DAMAGE)
            player:EvaluateItems()
        end
        p_data.WickedPData.isEncycloActive = encycloCheck
    end
end

mod:AddCallback(ModCallbacks.MC_FAMILIAR_UPDATE, function (_, familiar)
    if familiar.SubType ~= mod.ITEMS.ENCYCLOPEDIA  then
        return
    end

    local p = familiar.Player
    if not p:GetData().WickedPData.isEncycloActive then
        familiar:Remove()
    end
end, FamiliarVariant.WISP)

SomethingWicked:AddCallback(ModCallbacks.MC_USE_ITEM, UseItem, mod.ITEMS.ENCYCLOPEDIA)
SomethingWicked:AddCallback(ModCallbacks.MC_POST_NEW_LEVEL, NewLevel)
SomethingWicked:AddCallback(ModCallbacks.MC_POST_PEFFECT_UPDATE, PlayerUpdate)