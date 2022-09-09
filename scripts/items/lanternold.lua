local this = {}
this.game = SomethingWicked.game
CollectibleType.SOMETHINGWICKED_LANTERN = Isaac.GetItemIdByName("Lantern")

function this:damageUp(player)
    player.Damage = SomethingWicked.StatUps:DamageUp(player, 0.7 * player:GetCollectibleNum(CollectibleType.SOMETHINGWICKED_LANTERN))
end

function this:Enlighten()
    --this.game:GetLevel():AddCurse(LevelCurse.CURSE_OF_DARKNESS)

    for _, player in ipairs(SomethingWicked:UtilGetAllPlayers()) do
        if player:HasCollectible(CollectibleType.SOMETHINGWICKED_LANTERN) then
            
            local darknessmod = this.game:GetDarknessModifier()
            if (darknessmod > 0) then
                this.game:Darken(0, 1)
            end

            return
        end
    end
end

function this:RemoveCurseOfDarkness()
    local level = this.game:GetLevel()
    if level then
        level:RemoveCurses(LevelCurse.CURSE_OF_DARKNESS)
    end
end

SomethingWicked:AddCallback(ModCallbacks.MC_EVALUATE_CACHE, this.damageUp, CacheFlag.CACHE_DAMAGE)
SomethingWicked:AddCallback(ModCallbacks.MC_POST_UPDATE, this.Enlighten)
SomethingWicked:AddCallback(ModCallbacks.MC_POST_NEW_LEVEL, this.RemoveCurseOfDarkness)

this.EIDEntries = {
    [1] = {
        id = CollectibleType.SOMETHINGWICKED_LANTERN,
        desc = "bozo"
    }
}
return this