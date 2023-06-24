local this = {}

this.TearColor = Color(0.35, 0.2, 0.35)
function this:FireTear(tear)
    local p = SomethingWicked:UtilGetPlayerFromTear(tear)
    if p and p:HasCollectible(CollectibleType.SOMETHINGWICKED_SAMYAZAS_PLUME) then
        local c_rng = p:GetCollectibleRNG(CollectibleType.SOMETHINGWICKED_SAMYAZAS_PLUME)
        if c_rng:RandomFloat() < 0.15 then
            tear:AddTearFlags(TearFlags.TEAR_HOMING)
            tear.Color = tear.Color * this.TearColor
        end
    end
end

function this:EvalCache(player)
   player.MaxFireDelay = SomethingWicked.StatUps:TearsUp(player, 0.5 * player:GetCollectibleNum(CollectibleType.SOMETHINGWICKED_SAMYAZAS_PLUME)) 
end

SomethingWicked:AddCallback(ModCallbacks.MC_EVALUATE_CACHE, this.EvalCache, CacheFlag.CACHE_FIREDELAY)
SomethingWicked:AddCallback(ModCallbacks.MC_POST_FIRE_TEAR, this.FireTear)

this.EIDEntries = {
    [CollectibleType.SOMETHINGWICKED_SAMYAZAS_PLUME] = {
        desc = "↑ +0.5 tears up#↑ Small chance for a tear to have homing",
        Hide = true,
    }
}
return this