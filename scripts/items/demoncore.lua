local this = {}
TrinketType.SOMETHINGWICKED_DEMON_CORE = Isaac.GetTrinketIdByName("Demon Core")

function this:OnDamage(player)
    player = player:ToPlayer()

    if not player:HasTrinket(TrinketType.SOMETHINGWICKED_DEMON_CORE) then
        return
    end
    local p_data = player:GetData()
    if p_data.SomethingWickedPData.demonCoreFlag == nil then
        p_data.SomethingWickedPData.demonCoreFlag = false
    end

    if not p_data.SomethingWickedPData.demonCoreFlag then
        local room = SomethingWicked.game:GetRoom()
        room:MamaMegaExplosion(player.Position)

        p_data.SomethingWickedPData.demonCoreFlag = true
    end
end

function this:ResetFlag()
    for _, player in ipairs(SomethingWicked:UtilGetAllPlayers()) do
        if player and player:GetData().SomethingWickedPData.demonCoreFlag ~= nil then 
            player:GetData().SomethingWickedPData.demonCoreFlag = false
        end
    end
end

SomethingWicked:AddCallback(ModCallbacks.MC_POST_NEW_LEVEL, this.ResetFlag)
SomethingWicked:AddCallback(ModCallbacks.MC_ENTITY_TAKE_DMG, this.OnDamage, EntityType.ENTITY_PLAYER)

this.EIDEntries = {
    [TrinketType.SOMETHINGWICKED_DEMON_CORE] = {
        isTrinket = true,
        desc = "↑ Taking damage will spawn a Mama Mega explosion for the current room#Works only once per floor",
        encycloDesc = SomethingWicked:UtilGenerateWikiDesc({"Taking damage will spawn a Mama Mega explosion for the current room","Works only once per floor"})
    }
}
return this