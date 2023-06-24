local this = {}

function this:UsePill(effect, player)
    if player:HasTrinket(TrinketType.SOMETHINGWICKED_SUGAR_COATED_PILL) then
        SomethingWicked.save.runData.sugarCoatedPillEffect = effect
        player:TryRemoveTrinket(TrinketType.SOMETHINGWICKED_SUGAR_COATED_PILL)

        SomethingWicked.sfx:Play(SoundEffect.SOUND_VAMP_GULP)
    end
end

function this:GetPill(effect)
    if SomethingWicked.save.runData.sugarCoatedPillEffect and SomethingWicked.save.runData.sugarCoatedPillEffect == effect then
        return PillEffect.PILLEFFECT_FULL_HEALTH
    end
end

SomethingWicked:AddCallback(ModCallbacks.MC_GET_PILL_EFFECT, this.GetPill)
SomethingWicked:AddCallback(ModCallbacks.MC_USE_PILL, this.UsePill)

this.EIDEntries = {
    [TrinketType.SOMETHINGWICKED_SUGAR_COATED_PILL] = {
        isTrinket = true,
        desc = "Upon using a pill, all pills of that type will be turned into Full Health for the rest of the run#This trinket is consumed on pill use",
        encycloDesc = SomethingWicked:UtilGenerateWikiDesc({"Upon using a pill, all pills of that type will be turned into a Full Health pill for the rest of the run","This trinket is consumed on pill use"})
    }
}
return this