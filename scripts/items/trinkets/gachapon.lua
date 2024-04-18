local mod = SomethingWicked
local game = Game()
local sfx = SFXManager()

local thingsToCheck = {}

local function OnUpdate()
    local frameCount = game:GetRoom():GetFrameCount()
    local pickingUp = false
    local allPlayers = mod:UtilGetAllPlayers()
    for index, player in ipairs(allPlayers) do
        local item = player.QueuedItem.Item
        if item ~= nil
        and item:IsTrinket()
        and item.ID == mod.TRINKETS.GACHAPON then
            pickingUp = true
            break
        end
    end

    if not pickingUp then
        --print("a")
        for index, trinket in ipairs(thingsToCheck) do
            local pickup = trinket.pickup
            if trinket.frame <= frameCount
            and ((pickup:Exists() == false)
            or (pickup.Type ~= EntityType.ENTITY_PICKUP or pickup.Variant ~= PickupVariant.PICKUP_TRINKET 
            or (pickup.SubType ~= mod.TRINKETS.GACHAPON and pickup.SubType ~= mod.TRINKETS.GACHAPON + TrinketType.TRINKET_GOLDEN_FLAG))) then
                local player
                if trinket.SpawnerEntity then
                    player = trinket.SpawnerEntity:ToPlayer()
                end

                mod:GachaponDestroy(pickup, player)
            end
        end
    end
    thingsToCheck = {}

    local allTrinkets = Isaac.FindByType(EntityType.ENTITY_PICKUP, PickupVariant.PICKUP_TRINKET, mod.TRINKETS.GACHAPON)
    local allGoldenTrinkets = Isaac.FindByType(EntityType.ENTITY_PICKUP, PickupVariant.PICKUP_TRINKET, mod.TRINKETS.GACHAPON + TrinketType.TRINKET_GOLDEN_FLAG)
    for index, value in ipairs(allGoldenTrinkets) do
        table.insert(allTrinkets, value)
    end
    for index, value in ipairs(allTrinkets) do
        table.insert(thingsToCheck, { frame = frameCount + 1, pickup = value})
    end
end

function mod:GachaponDestroy(trinket, player, forceGold)
    if player == nil then
        player = Isaac.GetPlayer(0)
    end
    local p_data = player:GetData()

    local mult = 1
    if trinket and (trinket.SubType > TrinketType.TRINKET_GOLDEN_FLAG)
    or forceGold then
        mult = mult + 1
    end
    p_data.WickedPData.gachaponBonus = (p_data.WickedPData.gachaponBonus or 0) + mult

    local pos = trinket and trinket.Position or player.Position
    Isaac.Spawn(EntityType.ENTITY_EFFECT, EffectVariant.POOF02, 1, pos, Vector.Zero, trinket or player)
    Isaac.Spawn(EntityType.ENTITY_EFFECT, EffectVariant.POOF02, 2, pos, Vector.Zero, trinket or player)

    sfx:Play(SoundEffect.SOUND_THUMBSUP)
    player:AddCacheFlags(CacheFlag.CACHE_ALL)
    player:EvaluateItems()
end

mod:AddCallback(ModCallbacks.MC_POST_UPDATE, OnUpdate)

--stats are in main.lua, where all the stats are
function mod:GachaponStatsEvaluate(player, flag)
    local p_data = player:GetData()
    local mult = p_data.WickedPData.gachaponBonus
    if mult == nil then
        return 0
    end

    if player:HasCollectible(CollectibleType.COLLECTIBLE_MOMS_BOX) then
        mult = mult + 1
    end
    return mult
end