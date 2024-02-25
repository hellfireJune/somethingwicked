local function OnDamage(_, player)
    player = player:ToPlayer()

    if not player:HasTrinket(mod.TRINKETS.DEMON_CORE) then
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

SomethingWicked:AddCallback(ModCallbacks.MC_ENTITY_TAKE_DMG, OnDamage, EntityType.ENTITY_PLAYER)