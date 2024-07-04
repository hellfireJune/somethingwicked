local mod = SomethingWicked
local game = Game()

local function Update(_, player)
    if not player:HasCollectible(mod.ITEMS.SUPERIORITY) then
        return
    end
    local p_data = player:GetData()
    p_data.sw_supCount = p_data.sw_supCount or 0
    local room = game:GetRoom()
    local enemies = math.max(0, room:GetAliveEnemiesCount()-1)
    if enemies ~= p_data.sw_supCount then
        p_data.sw_supCount = enemies
        player:AddCacheFlags(CacheFlag.CACHE_DAMAGE)
        player:EvaluateItems()
    end
end
mod:AddCallback(ModCallbacks.MC_POST_PEFFECT_UPDATE, Update)