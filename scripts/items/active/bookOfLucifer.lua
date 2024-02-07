local mod = SomethingWicked
local sfx = SFXManager()
local game = Game()
local roomTables = {
    {2000, 2003}, --wrath
    {2010, 2013}, --gluttony
    {2020, 2023}, --lust
    {2030, 2033}, --sloth
    {2040, 2043}, --greed
    {2050, 2053}, --envy
    {2060, 2063}, --pride
}

local function UseItem(_, _, player)
    --[[local p_data = player:GetData()
    p_data.SomethingWickedPData.boLuciferBuff = (p_data.SomethingWickedPData.boLuciferBuff or 0) + 1]]
    sfx:Play(SoundEffect.SOUND_DEVIL_CARD, 1, 0)
    local poof = Isaac.Spawn(EntityType.ENTITY_EFFECT, EffectVariant.POOF02, 1, player.Position, Vector.Zero, player)
    local poof2 = Isaac.Spawn(EntityType.ENTITY_EFFECT, EffectVariant.POOF02, 2, player.Position, Vector.Zero, player)
    poof2.Color = Color(0.7, 0, 0)
    poof.Color = Color(0.1, 0.1, 0.1)

    return true
    
    --player:EvaluateItems()
end

mod.generatedLuciferMiniboss = false
function mod:BookOfLuciferNewFloor(player, shouldGen)
        if player and player:GetEffects():GetCollectibleEffect(CollectibleType.SOMETHINGWICKED_BOOK_OF_LUCIFER) then 
            player:GetEffects():RemoveCollectibleEffect(CollectibleType.SOMETHINGWICKED_BOOK_OF_LUCIFER, -1)
            player:AddCacheFlags(CacheFlag.CACHE_DAMAGE)
            player:EvaluateItems()
        end

        if mod.generatedLuciferMiniboss == true or not shouldGen then
            return
        end
        local flag = player:HasCollectible(CollectibleType.SOMETHINGWICKED_BOOK_OF_LUCIFER)
        if flag or player:HasTrinket(TrinketType.SOMETHINGWICKED_SCORCHED_PAGE) then
            mod.generatedLuciferMiniboss = true
            local rng = player:GetCollectibleRNG(CollectibleType.SOMETHINGWICKED_BOOK_OF_LUCIFER)
            if not flag and rng:RandomFloat() < 0.5 then
                return
            end
            local minibossToGen = SomethingWicked:GetRandomElement(roomTables, rng)
            mod:GenerateSpecialRoom("miniboss", minibossToGen[1], minibossToGen[2], true, rng)
        end
end

local function BloodyTears(tear)
    local player = SomethingWicked:UtilGetPlayerFromTear(tear)
    if player
    and player:GetEffects():GetCollectibleEffectNum(CollectibleType.SOMETHINGWICKED_BOOK_OF_LUCIFER) >= 1 then
        SomethingWicked:utilForceBloodTear(tear)
    end
end

local function OnMinibossClear()
    for index, value in ipairs(mod:AllPlayersWithTrinket(TrinketType.SOMETHINGWICKED_SCORCHED_PAGE)) do
        value:UseActiveItem(CollectibleType.SOMETHINGWICKED_BOOK_OF_LUCIFER)
    end
end

SomethingWicked:AddCallback(ModCallbacks.MC_USE_ITEM, UseItem, CollectibleType.SOMETHINGWICKED_BOOK_OF_LUCIFER)
SomethingWicked:AddCallback(ModCallbacks.MC_POST_FIRE_TEAR, BloodyTears)
--SomethingWicked:AddCustomCBack(SomethingWicked.CustomCallbacks.SWCB_ON_MINIBOSS_ROOM_CLEARED, OnMinibossClear)