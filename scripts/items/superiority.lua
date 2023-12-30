local mod = SomethingWicked

function this:Update(player)
    if not player:HasCollectible(CollectibleType.SOMETHINGWICKED_SUPERIORITY) then
        return
    end
    local p_data = player:GetData()
    p_data.sw_supCount = p_data.sw_supCount or 0
    local room = mod.game:GetRoom()
    local enemies = math.max(0, room:GetAliveEnemiesCount()-1)
    if enemies ~= p_data.sw_supCount then
        p_data.sw_supCount = enemies
        player:AddCacheFlags(CacheFlag.CACHE_DAMAGE)
        player:EvaluateItems()
    end
end
mod:AddCallback(ModCallbacks.MC_POST_PEFFECT_UPDATE, this.Update)

function this:Cache(player)
    local p_data = player:GetData()
    if p_data.sw_supCount ~= nil then
        player.Damage = mod.StatUps:DamageUp(player, 0, 0.7*math.min(p_data.sw_supCount, 7))
    end
end
mod:AddCallback(ModCallbacks.MC_EVALUATE_CACHE, this.Cache, CacheFlag.CACHE_DAMAGE)

this.EIDEntries = {
    [CollectibleType.SOMETHINGWICKED_SUPERIORITY] = {
        desc = "↑ +0.7 damage for every enemy alive in the room, minus one#Caps at 7 enemies.",

        pools = {
            SomethingWicked.encyclopediaLootPools.POOL_TREASURE,
            SomethingWicked.encyclopediaLootPools.POOL_GREED_TREASURE,
            SomethingWicked.encyclopediaLootPools.POOL_CRANE_GAME,
        },
    }
}
return this