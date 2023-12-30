this.roomTables = {
    {2000, 2003}, --wrath
    {2010, 2013}, --gluttony
    {2020, 2023}, --lust
    {2030, 2033}, --sloth
    {2040, 2043}, --greed
    {2050, 2053}, --envy
    {2060, 2063}, --pride
}

function this:damageCache(player)
    if player and player:GetEffects():GetCollectibleEffect(CollectibleType.SOMETHINGWICKED_BOOK_OF_LUCIFER) then  
        player.Damage = SomethingWicked.StatUps:DamageUp(player, 0.6 * player:GetEffects():GetCollectibleEffectNum(CollectibleType.SOMETHINGWICKED_BOOK_OF_LUCIFER))
    end
end

function this:UseItem(_, _, player)
    --[[local p_data = player:GetData()
    p_data.SomethingWickedPData.boLuciferBuff = (p_data.SomethingWickedPData.boLuciferBuff or 0) + 1]]
    SomethingWicked.sfx:Play(SoundEffect.SOUND_DEVIL_CARD, 1, 0)
    local poof = Isaac.Spawn(EntityType.ENTITY_EFFECT, EffectVariant.POOF02, 1, player.Position, Vector.Zero, player)
    local poof2 = Isaac.Spawn(EntityType.ENTITY_EFFECT, EffectVariant.POOF02, 2, player.Position, Vector.Zero, player)
    poof2.Color = Color(0.7, 0, 0)
    poof.Color = Color(0.1, 0.1, 0.1)

    return true
    
    --player:EvaluateItems()
end

function this:NewFloor()
    for _, player in ipairs(SomethingWicked:UtilGetAllPlayers()) do
        if player and player:GetEffects():GetCollectibleEffect(CollectibleType.SOMETHINGWICKED_BOOK_OF_LUCIFER) then 
            player:GetEffects():RemoveCollectibleEffect(CollectibleType.SOMETHINGWICKED_BOOK_OF_LUCIFER, -1)
            player:AddCacheFlags(CacheFlag.CACHE_DAMAGE)
            player:EvaluateItems()
        end
    end

    local game = SomethingWicked.game
    local level = game:GetLevel()
    if SomethingWicked.RedKeyRoomHelpers:GenericShouldGenerateRoom(level, game) then
        local flag, player = SomethingWicked.ItemHelpers:GlobalPlayerHasCollectible(CollectibleType.SOMETHINGWICKED_BOOK_OF_LUCIFER)
        local flag2, player2 = SomethingWicked.ItemHelpers:GlobalPlayerHasTrinket(TrinketType.SOMETHINGWICKED_SCORCHED_PAGE)
        if (flag and player) or (flag2 and player2) then
            local rng = (player and player:GetCollectibleRNG(CollectibleType.SOMETHINGWICKED_BOOK_OF_LUCIFER))
            or (player2 and player2:GetTrinketRNG(TrinketType.SOMETHINGWICKED_SCORCHED_PAGE)) or RNG()
            if player2 and rng:RandomFloat() < 0.5 then
                return
            end
            local minibossToGen = SomethingWicked:GetRandomElement(this.roomTables, rng)
            SomethingWicked.RedKeyRoomHelpers:GenerateSpecialRoom("miniboss", minibossToGen[1], minibossToGen[2], true, rng)
        end
    end
end

function this:BloodyTears(tear)
    local player = SomethingWicked:UtilGetPlayerFromTear(tear)
    if player
    and player:GetEffects():GetCollectibleEffectNum(CollectibleType.SOMETHINGWICKED_BOOK_OF_LUCIFER) >= 1 then
        SomethingWicked:utilForceBloodTear(tear)
    end
end

function this:OnMinibossClear()
    for index, value in ipairs(SomethingWicked.ItemHelpers:AllPlayersWithTrinket(TrinketType.SOMETHINGWICKED_SCORCHED_PAGE)) do
        value:UseActiveItem(CollectibleType.SOMETHINGWICKED_BOOK_OF_LUCIFER)
    end
end

SomethingWicked:AddCallback(ModCallbacks.MC_USE_ITEM, this.UseItem, CollectibleType.SOMETHINGWICKED_BOOK_OF_LUCIFER)
SomethingWicked:AddCallback(ModCallbacks.MC_EVALUATE_CACHE, this.damageCache, CacheFlag.CACHE_DAMAGE)
SomethingWicked:AddCallback(ModCallbacks.MC_POST_NEW_LEVEL, this.NewFloor)
SomethingWicked:AddCallback(ModCallbacks.MC_POST_FIRE_TEAR, this.BloodyTears)
SomethingWicked:AddCustomCBack(SomethingWicked.CustomCallbacks.SWCB_ON_MINIBOSS_ROOM_CLEARED, this.OnMinibossClear)

this.EIDEntries = {
    [CollectibleType.SOMETHINGWICKED_BOOK_OF_LUCIFER] = {
        desc = "↑ +0.6 damage for the current floor#↑ A bonus sin miniboss will appear on every floor outside of greed mode",
        
        pools = {
            SomethingWicked.encyclopediaLootPools.POOL_TREASURE,
            SomethingWicked.encyclopediaLootPools.POOL_LIBRARY,
            SomethingWicked.encyclopediaLootPools.POOL_DEVIL,
            SomethingWicked.encyclopediaLootPools.POOL_GREED_DEVIL,
            SomethingWicked.encyclopediaLootPools.POOL_GREED_TREASURE
        },
        encycloDesc = SomethingWicked:UtilGenerateWikiDesc(
            { "+0.6 damage for the current floor on use", "A bonus sin miniboss will appear on every floor, outside of greed mode" }
        )
    }
}
return this