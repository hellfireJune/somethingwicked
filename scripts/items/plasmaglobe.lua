local this = {}
CollectibleType.SOMETHINGWICKED_PLASMA_GLOBE = Isaac.GetItemIdByName("Plasma Globe")

this.baseProcChance = 0.2
local function ProcChance(player)
    return (player.Luck >= 0 and (this.baseProcChance + (this.baseProcChance* ((player.Luck) / 2))) or (this.baseProcChance / math.abs(player.Luck)))
end
function this:FireTear(tear)
    local p = SomethingWicked:UtilGetPlayerFromTear(tear)

    if p and p:HasCollectible(CollectibleType.SOMETHINGWICKED_PLASMA_GLOBE) then
        local rng = p:GetCollectibleRNG(CollectibleType.SOMETHINGWICKED_PLASMA_GLOBE) 
        if rng:RandomFloat() > ProcChance(p) then
            return
        end
        tear.Color = tear.Color * this.Color

        local t_data = tear:GetData()
        t_data.somethingWicked_applyingElectroStun = true
    end
end

function this:ApplyEffect(tear, enemy, player)
    enemy = enemy:ToNPC()
    if not enemy then
        return
    end

    if enemy:HasEntityFlags(EntityFlag.FLAG_NO_STATUS_EFFECTS) then
        return
    end

    local t_data = tear:GetData()

    if t_data.somethingWicked_applyingElectroStun then
        enemy:AddConfusion(EntityRef(player), 60, false)

        local e_data = enemy:GetData()
        e_data.somethingWicked_electroStun = true
        e_data.somethingWicked_electroStunParent = player
    end
end

SomethingWicked:AddCallback(ModCallbacks.MC_POST_FIRE_TEAR, this.FireTear)
SomethingWicked:AddCustomCBack(SomethingWicked.CustomCallbacks.SWCB_ON_ENEMY_HIT, this.ApplyEffect)

this.EIDEntries = {
    [CollectibleType.SOMETHINGWICKED_PLASMA_GLOBE] = {
        desc = "↑ Tears have a chance to confuse enemies, and cause them to shoot lightning out in random directions#Scales with luck",
        encycloDesc = SomethingWicked:UtilGenerateWikiDesc("Tears have a chance to confuse enemies, and cause them to shoot lightning out in random directions. Scales with luck")
    }
}
return this