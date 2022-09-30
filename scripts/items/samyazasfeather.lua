local this = {}
CollectibleType.SOMETHINGWICKED_SAMYAZAS_FEATHER = Isaac.GetItemIdByName("Samyaza's Feather")

this.TearColor = Color(0.35, 0.2, 0.35)
function this:FireTear(tear)
    local p = SomethingWicked:UtilGetPlayerFromTear(tear)
    if p and p:HasCollectible(CollectibleType.SOMETHINGWICKED_SAMYAZAS_FEATHER) then
        local c_rng = p:GetCollectibleRNG(CollectibleType.SOMETHINGWICKED_SAMYAZAS_FEATHER)
        if c_rng:RandomFloat() < 0.15 then
            tear:AddTearFlags(TearFlags.TEAR_HOMING)
            tear.Color = this.TearColor
        end
    end
end

function this:EvalCache(player)
   player.Damage = SomethingWicked.StatUps:DamageUp(player, 0.7 * player:GetCollectibleNum(CollectibleType.SOMETHINGWICKED_SAMYAZAS_FEATHER)) 
end

SomethingWicked:AddCallback(ModCallbacks.MC_EVALUATE_CACHE, this.EvalCache, CacheFlag.CACHE_DAMAGE)
SomethingWicked:AddCallback(ModCallbacks.MC_POST_FIRE_TEAR, this.FireTear)

this.EIDEntries = {
    [CollectibleType.SOMETHINGWICKED_SAMYAZAS_FEATHER] = {
        desc = "↑ +0.7 Damage up#↑ Small chance for a tear to have homing"
    }
}
return this