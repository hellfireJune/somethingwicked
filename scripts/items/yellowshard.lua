local this = {}
CollectibleType.SOMETHINGWICKED_YELLOW_SIGIL = Isaac.GetItemIdByName("Yellow Sigil")
this.ProcChance = 0.5

function this:OnDamage(entity, amount, flag)
    local player = entity:ToPlayer()
    if player:HasCollectible(CollectibleType.SOMETHINGWICKED_YELLOW_SIGIL) then
        if player:GetDropRNG():RandomFloat() <= this.ProcChance then
            local ent = Isaac.Spawn(EntityType.ENTITY_FAMILIAR, FamiliarVariant.SOMETHINGWICKED_NIGHTMARE, 0, player.Position, Vector.Zero, player)
            ent:ClearEntityFlags(EntityFlag.FLAG_APPEAR)
        end
    end
end

SomethingWicked:AddPriorityCallback(ModCallbacks.MC_ENTITY_TAKE_DMG, CallbackPriority.LATE, this.OnDamage, EntityType.ENTITY_PLAYER)

this.EIDEntries = {
    [CollectibleType.SOMETHINGWICKED_YELLOW_SIGIL] = {
        desc = "↑ "..this.ProcChance * 100 .."% chance to spawn a nightmare familiar on damage",
        pools = {
            SomethingWicked.encyclopediaLootPools.POOL_TREASURE,
            SomethingWicked.encyclopediaLootPools.POOL_GREED_TREASURE,
            SomethingWicked.encyclopediaLootPools.POOL_RED_CHEST
        },
        encycloDesc = SomethingWicked:UtilGenerateWikiDesc({this.ProcChance * 100 .."% chance to spawn a nightmare familiar on damage", "These nightmare familiars will block bullets and erattically orbit the player, firing homing tears at anything in a nearby radius","Nightmares will die after two hits"}, "...a curious symbol or letter in gold. It was neither Arabic nor Chinese, nor as I found afterwards did it belong to any human script")
    }
}
return this