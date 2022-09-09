local this = {}
this.lastHadCurse = false
TrinketType.SOMETHINGWICKED_DAMNED_SOUL = Isaac.GetTrinketIdByName("Damned Soul")
TrinketType.SOMETHINGWICKED_VIRTUOUS_SOUL = Isaac.GetTrinketIdByName("Virtuous Soul")

this.dmgUp = 0.3
this.tearsUp = 0.3
this.luckup = 1
this.speedUp = 0.15
this.sspeedUp = 0.1
this.rangeUp = 0.75

function this:OnCache(player, flags)
    local id = ((SomethingWicked.game:GetLevel():GetCurses() == LevelCurse.CURSE_NONE) and TrinketType.SOMETHINGWICKED_VIRTUOUS_SOUL or TrinketType.SOMETHINGWICKED_DAMNED_SOUL)
    local mult = player:GetTrinketMultiplier(id)

    if flags == CacheFlag.CACHE_DAMAGE then
        player.Damage = SomethingWicked.StatUps:DamageUp(player, this.dmgUp * mult) end
    if flags == CacheFlag.CACHE_FIREDELAY then
        player.MaxFireDelay = SomethingWicked.StatUps:GetFireDelay(SomethingWicked.StatUps:GetTears(player.MaxFireDelay) + (this.tearsUp * mult)) end
    if flags == CacheFlag.CACHE_LUCK then
        player.Luck = player.Luck + (this.luckup * mult) end
    if flags == CacheFlag.CACHE_SPEED then
        player.MoveSpeed = player.MoveSpeed + (this.speedUp * mult) end
    if flags == CacheFlag.CACHE_SHOTSPEED then
        player.ShotSpeed = player.ShotSpeed + (this.sspeedUp * mult) end
    if flags == CacheFlag.CACHE_RANGE then
        player.TearRange = player.TearRange + (this.rangeUp * mult * 40) end

end

function this:onUpdate(player)
    if player:HasTrinket(TrinketType.SOMETHINGWICKED_DAMNED_SOUL) or player:HasTrinket(TrinketType.SOMETHINGWICKED_VIRTUOUS_SOUL) then
        local hadCurse = (SomethingWicked.game:GetLevel():GetCurses() == LevelCurse.CURSE_NONE)
        if hadCurse ~= this.lastHadCurse then
            this.lastHadCurse = hadCurse
            player:AddCacheFlags(CacheFlag.CACHE_ALL)
            player:EvaluateItems()
        end
    end
end

SomethingWicked:AddCallback(ModCallbacks.MC_POST_PEFFECT_UPDATE, this.onUpdate)
SomethingWicked:AddCallback(ModCallbacks.MC_EVALUATE_CACHE, this.OnCache)

this.statsString = "#↑ +"..this.dmgUp.." Damage#↑ +"..this.tearsUp.." Tears#↑ +"..this.luckup.." Luck#↑ +"..this.speedUp.." Speed#↑ +"..this.sspeedUp.." Shot Speed#↑ +"..this.rangeUp.." Range"
this.statsStringsEncyclo = {"+"..this.dmgUp.." Damage","+"..this.tearsUp.." Tears","+"..this.luckup.." Luck"," +"..this.speedUp.." Speed","+"..this.sspeedUp.." Shot Speed","+"..this.rangeUp.." Range"}
this.metadataFunction = function (item)
    EID:addGoldenTrinketMetadata(item, nil, { this.dmgUp, this.tearsUp, this.luckup, this.speedUp, this.sspeedUp, this.rangeUp } )
end

this.EIDEntries = {
    [TrinketType.SOMETHINGWICKED_DAMNED_SOUL] = {
        isTrinket = true,
        desc = "!!! When there is a curse on the current floor:"..this.statsString,
        metadataFunction = this.metadataFunction,
        encycloDesc = SomethingWicked:UtilGenerateWikiDesc({"When there is a curse on the current floor:", this.statsStringsEncyclo[1], this.statsStringsEncyclo[2], this.statsStringsEncyclo[3], this.statsStringsEncyclo[4], this.statsStringsEncyclo[5], this.statsStringsEncyclo[6],})
    },
    [TrinketType.SOMETHINGWICKED_VIRTUOUS_SOUL] = {
        isTrinket = true,
        desc = "!!! When there is no curse on the current floor:"..this.statsString,
        metadataFunction = this.metadataFunction,
        encycloDesc = SomethingWicked:UtilGenerateWikiDesc({"When there is no curse on the current floor:", this.statsStringsEncyclo[1], this.statsStringsEncyclo[2], this.statsStringsEncyclo[3], this.statsStringsEncyclo[4], this.statsStringsEncyclo[5], this.statsStringsEncyclo[6],})
    }
}
return this