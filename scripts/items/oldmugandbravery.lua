local this = {}
CollectibleType.SOMETHINGWICKED_BRAVERY = Isaac.GetItemIdByName("Bravery")
CollectibleType.SOMETHINGWICKED_SUPERIORITY = Isaac.GetItemIdByName("Superiority")
this.DamageMult = 1.3

function this:OnDamag(ent, amount, flags, source, dmgCooldown)
    if flags & DamageFlag.DAMAGE_CLONES ~= 0 or 
    source == nil or source.Entity == nil 
    or SomethingWicked:UtilGetPlayerFromTear(source.Entity) == nil then
        return 
    end
    local player = SomethingWicked:UtilGetPlayerFromTear(source.Entity)
    local flag = ent:IsBoss()
    local item = flag and CollectibleType.SOMETHINGWICKED_BRAVERY or CollectibleType.SOMETHINGWICKED_SUPERIORITY
    local hasItem = player:HasCollectible(item) 
    if hasItem then
        ent:TakeDamage(amount * (this.DamageMult - 1), flags | DamageFlag.DAMAGE_CLONES, EntityRef(ent), dmgCooldown)
    end
end

SomethingWicked:AddCallback(ModCallbacks.MC_ENTITY_TAKE_DMG, this.OnDamag)

this.EIDEntries = {
    [CollectibleType.SOMETHINGWICKED_BRAVERY] = {
        desc = "↑ "..this.DamageMult.."x damage against bosses",

        pools = {
            SomethingWicked.encyclopediaLootPools.POOL_TREASURE,
            SomethingWicked.encyclopediaLootPools.POOL_GOLDEN_CHEST,
            SomethingWicked.encyclopediaLootPools.POOL_CRANE_GAME,
            SomethingWicked.encyclopediaLootPools.POOL_GREED_TREASURE,
        },
        encycloDesc = SomethingWicked:UtilGenerateWikiDesc(
            { "All damage caused by this player (including bomb damage and other non-tear related damage sources) deals "..((this.DamageMult*100) - 100).."% more damage to bosses" }
        )
    },
    [CollectibleType.SOMETHINGWICKED_SUPERIORITY] = {
        desc = "↑ "..this.DamageMult.."x damage against non-boss enemies",

        pools = {
            SomethingWicked.encyclopediaLootPools.POOL_TREASURE,
            SomethingWicked.encyclopediaLootPools.POOL_GREED_TREASURE,
            SomethingWicked.encyclopediaLootPools.POOL_CRANE_GAME,
        },
        encycloDesc = SomethingWicked:UtilGenerateWikiDesc(
            { "All damage caused by this player (including bomb damage and other non-tear related damage sources) deals "..((this.DamageMult*100) - 100).."% more damage to non-boss enemies" }
        )
    }
}
return this