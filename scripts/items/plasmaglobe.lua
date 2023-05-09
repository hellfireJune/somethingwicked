local this = {}
CollectibleType.SOMETHINGWICKED_PLASMA_GLOBE = Isaac.GetItemIdByName("Plasma Globe")
local mod = SomethingWicked

this.baseProcChance = 0.125
this.Color = Color(1, 1, 1, 1, 0.5, 0.82, 1)
local function ProcChance(player)
    return (player.Luck >= 0 and (this.baseProcChance + (this.baseProcChance* ((player.Luck) / 2))) or (this.baseProcChance / math.abs(player.Luck)))
end
SomethingWicked.TFCore:AddNewFlagData(SomethingWicked.CustomTearFlags.FLAG_ELECTROSTUN, {
    ApplyLogic = function (_, p, tear)
        if p:HasCollectible(CollectibleType.SOMETHINGWICKED_PLASMA_GLOBE) then
            local rng = p:GetCollectibleRNG(CollectibleType.SOMETHINGWICKED_PLASMA_GLOBE) 
            print(ProcChance(p))
            if rng:RandomFloat() > ProcChance(p) then
                return
            end
            return true
        end
    end,
    EnemyHitEffect = function (_, tear, pos, enemy)
        local p = mod:UtilGetPlayerFromTear(tear)
        mod:UtilAddElectrostun(enemy, p, 60)
    end,
    TearColor = this.Color
})

this.EIDEntries = {
    [CollectibleType.SOMETHINGWICKED_PLASMA_GLOBE] = {
        desc = "↑ Tears have a chance to confuse enemies, and cause them to shoot lightning out in random directions#Scales with luck",
        encycloDesc = SomethingWicked:UtilGenerateWikiDesc("Tears have a chance to confuse enemies, and cause them to shoot lightning out in random directions. Scales with luck")
    }
}
return this