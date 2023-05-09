local this = {}
CollectibleType.SOMETHINGWICKED_BRAVERY = Isaac.GetItemIdByName("Bravery")
this.DamageMult = 1.5

local flag = false
function this:OnDamag(ent, amount, flags, source, dmgCooldown)
    ent = ent:ToNPC()
    if not ent then
        return
    end
    if flag or 
    source == nil or source.Entity == nil 
    or SomethingWicked:UtilGetPlayerFromTear(source.Entity) == nil then
        return 
    end
    local player = SomethingWicked:UtilGetPlayerFromTear(source.Entity)
    local hasItem = player:HasCollectible(CollectibleType.SOMETHINGWICKED_BRAVERY)
    if not hasItem then
        return
    end
    local boss = ent:IsBoss() or ent:IsChampion()
    if boss  then
        flag = true
        ent:TakeDamage(amount * this.DamageMult, flags, source, dmgCooldown)
        flag = false
        return false
    end
end

SomethingWicked:AddCallback(ModCallbacks.MC_ENTITY_TAKE_DMG, this.OnDamag)

this.EIDEntries = {
    [CollectibleType.SOMETHINGWICKED_BRAVERY] = {
        desc = "↑ "..this.DamageMult.."x damage against bosses and champion enemies",

        pools = {
            SomethingWicked.encyclopediaLootPools.POOL_TREASURE,
            SomethingWicked.encyclopediaLootPools.POOL_GOLDEN_CHEST,
            SomethingWicked.encyclopediaLootPools.POOL_CRANE_GAME,
            SomethingWicked.encyclopediaLootPools.POOL_GREED_TREASURE,
        },
        encycloDesc = SomethingWicked:UtilGenerateWikiDesc(
            { "All damage caused by this player (including bomb damage and other non-tear related damage sources) deals "..((this.DamageMult*100) - 100).."% more damage to bosses" }
        )
    }
}
return this