local mod = SomethingWicked

mod.CrownSpecialLocusts = {
    {CollectibleType.COLLECTIBLE_IPECAC, 1},
    {CollectibleType.COLLECTIBLE_JACOBS_LADDER, 1},
    {CollectibleType.COLLECTIBLE_BLOOD_MARTYR, 1},
    {CollectibleType.COLLECTIBLE_COMMON_COLD, 1},
    {CollectibleType.COLLECTIBLE_CRICKETS_HEAD, 1},
    {CollectibleType.COLLECTIBLE_FIRE_MIND, 1},
    {CollectibleType.COLLECTIBLE_HALO_OF_FLIES, 2},
    {CollectibleType.COLLECTIBLE_HOLY_LIGHT, 1},
    {CollectibleType.COLLECTIBLE_INNER_EYE, 3},
    {CollectibleType.COLLECTIBLE_MUTANT_SPIDER, 4},
    {CollectibleType.COLLECTIBLE_NUMBER_ONE, 1},
    {CollectibleType.COLLECTIBLE_SPOON_BENDER, 1},
    {CollectibleType.SOMETHINGWICKED_CURSED_MUSHROOM, 1}
}
local preventPoof = false
function mod:DestroyCrownLocustsWithInitSeeds(seeds, flies, player)
    if seeds == nil and player then
        local p_data = player:GetData()
        seeds = {}
        for index, value in ipairs(p_data.SomethingWickedPData.crownLocusts) do
            seeds = mod:utilMerge(seeds, value)
        end
    end

    for index, value in ipairs(flies) do
        if mod:UtilTableHasValue(seeds, value.InitSeed) then
            value:Remove()
        end
    end

    if player then
        local p_data = player:GetData()
        p_data.SomethingWickedPData.crownLocusts = {}
        p_data.SomethingWickedPData.crownMult = nil
        player:AddCacheFlags(CacheFlag.CACHE_FAMILIARS)
        preventPoof = true
        player:EvaluateItems()
        preventPoof = false
    end
end

local chanceForSpecialLocust = 0.12044
local function FamiliarCache(_, player)
    local stacks, rng, sourceItem = mod:BasicFamiliarNum(player, CollectibleType.SOMETHINGWICKED_APOLLYONS_CROWN)
    --player:CheckFamiliar(FamiliarVariant.ABYSS_LOCUST, stacks*2, rng, sourceItem, this.dummyItem)

    local p_data = player:GetData()
    p_data.SomethingWickedPData.crownLocusts = p_data.SomethingWickedPData.crownLocusts or {}
    if not p_data.SomethingWickedPData.crownMult then
        p_data.SomethingWickedPData.crownMult = math.max(rng:RandomInt(4)+1,2)
    end
    stacks = stacks*p_data.SomethingWickedPData.crownMult
    local numToCheck = math.max(stacks, #p_data.SomethingWickedPData.crownLocusts)
    
    for i = 1, numToCheck, 1 do
        local fly = p_data.SomethingWickedPData.crownLocusts[i]
        
        if fly then
            local seeds = {}
            for index, value in pairs(fly) do
                table.insert(seeds, value)
            end
            local flies = Isaac.FindByType(EntityType.ENTITY_FAMILIAR, FamiliarVariant.ABYSS_LOCUST)
            mod:DestroyCrownLocustsWithInitSeeds(seeds, flies)
        end


        fly = {}

        if i <= stacks then
            local shouldBeSpecial = rng:RandomFloat() < chanceForSpecialLocust

            local count, type = 1, CollectibleType.SOMETHINGWICKED_APOLLYONS_CROWN
            if not shouldBeSpecial then
                
            else
                local randLocust = mod:GetRandomElement(mod.CrownSpecialLocusts, rng)
                type = randLocust[1] count = randLocust[2]
            end

            for j = 1, count, 1 do
                local locust = Isaac.Spawn(EntityType.ENTITY_FAMILIAR, FamiliarVariant.ABYSS_LOCUST, type, player.Position, Vector.Zero, player)
                locust.Parent = player
                if preventPoof and count == 1 then
                    locust:ClearEntityFlags(EntityFlag.FLAG_APPEAR)
                end

                fly[j] = locust.InitSeed
            end
        end

        p_data.SomethingWickedPData.crownLocusts[i] = fly
    end
end

SomethingWicked:AddCallback(ModCallbacks.MC_EVALUATE_CACHE, FamiliarCache, CacheFlag.CACHE_FAMILIARS)

--[[this.EIDEntries = {
}
return this]]