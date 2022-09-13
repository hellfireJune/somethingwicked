local this = {}
TrinketType.SOMETHINGWICKED_MR_SKITS = Isaac.GetItemIdByName("Mr. Skits")

function this:OnKillBoss(_, br)
    if br then
        return
    end
    for _, player in pairs(SomethingWicked.ItemHelpers:AllPlayersWithTrinket(TrinketType.SOMETHINGWICKED_MR_SKITS)) do
        for i = 1, 4, 1 do
            local scrunkly = Isaac.Spawn(EntityType.ENTITY_FAMILIAR, FamiliarVariant.SOMETHINGWICKED_NIGHTMARE, 0, player.Position, Vector.Zero, player)      
            scrunkly:ClearEntityFlags(EntityFlag.FLAG_APPEAR)
        end
    end
end

SomethingWicked:AddBossRoomClearCallback(this.OnKillBoss)

this.EIDEntries = {}
return this