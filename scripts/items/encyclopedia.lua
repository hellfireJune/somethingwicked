local this = {}
this.bonusLibraryChance = 0.2

function this:NewLevel()
    local libraryExists 
    local newLibraryExists
    local level = SomethingWicked.game:GetLevel()

    local itemflag, player = SomethingWicked.ItemHelpers:GlobalPlayerHasCollectible(CollectibleType.SOMETHINGWICKED_ENCYCLOPEDIA)
    if itemflag and player then
        local rng = player:GetCollectibleRNG(CollectibleType.SOMETHINGWICKED_ENCYCLOPEDIA)
        libraryExists = SomethingWicked.RedKeyRoomHelpers:RoomTypeCurrentlyExists(RoomType.ROOM_LIBRARY, level, rng)

        if not libraryExists then
            local randomFloat = rng:RandomFloat()
            if randomFloat < this.bonusLibraryChance then
                newLibraryExists = SomethingWicked.RedKeyRoomHelpers:GenerateSpecialRoom("library", 1, 6, true, rng)
            end
        end
    end
end 

function this:UseItem(_, rngObj, player)
    local game = SomethingWicked.game
    local shopIDx = game:GetLevel():QueryRoomTypeIndex(RoomType.ROOM_LIBRARY, true, rngObj)
    game:StartRoomTransition(shopIDx, Direction.NO_DIRECTION, RoomTransitionAnim.TELEPORT)

    return { Discharge = false }
end

this.lastEncycloCheck = nil
function this:PlayerUpdate(player)
    if not player:HasCollectible(CollectibleType.SOMETHINGWICKED_ENCYCLOPEDIA) then
        return
    end
    local rng = player:GetCollectibleRNG(CollectibleType.SOMETHINGWICKED_ENCYCLOPEDIA)
    local encycloCheck = SomethingWicked.RedKeyRoomHelpers:RoomTypeCurrentlyExists(RoomType.ROOM_LIBRARY, SomethingWicked.game:GetLevel(), rng)
    if encycloCheck ~= this.lastEncycloCheck then
        this.lastEncycloCheck = encycloCheck

        local _, slot = SomethingWicked.ItemHelpers:CheckPlayerForActiveData(player, CollectibleType.SOMETHINGWICKED_ENCYCLOPEDIA)
        local newCharge = (encycloCheck) and 1 or 0
        player:SetActiveCharge(newCharge, slot)
    end
end

SomethingWicked:AddCallback(ModCallbacks.MC_USE_ITEM, this.UseItem, CollectibleType.SOMETHINGWICKED_ENCYCLOPEDIA)
SomethingWicked:AddCallback(ModCallbacks.MC_POST_NEW_LEVEL, this.NewLevel)
SomethingWicked:AddCallback(ModCallbacks.MC_POST_PEFFECT_UPDATE, this.PlayerUpdate)

this.EIDEntries = {
    [CollectibleType.SOMETHINGWICKED_ENCYCLOPEDIA] = {
        desc = "↑ Bonus 20% chance to spawn a library on new floor entry#Teleports the player to the library on use# !!! Only charged if there is a library on the floor",
        encycloDesc = SomethingWicked:UtilGenerateWikiDesc({"If there is a library on the current floor, this item is always charged and using the item will teleport you there","Bonus 20% chance to spawn a library upon entering a new floor while held"}),
        pools = {
            SomethingWicked.encyclopediaLootPools.POOL_LIBRARY,
            SomethingWicked.encyclopediaLootPools.POOL_TREASURE,
            SomethingWicked.encyclopediaLootPools.POOL_GREED_TREASURE
        }
    }
}
return this