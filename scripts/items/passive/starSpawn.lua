local mod = SomethingWicked

--max mult = 2.6, min mult = 0.5
function mod:StarSpawnPlayerDamage(player)
    if player:HasCollectible(CollectibleType.SOMETHINGWICKED_STAR_SPAWN) then
        local p_data = player:GetData()

        local rng = player:GetCollectibleRNG(CollectibleType.SOMETHINGWICKED_STAR_SPAWN)
        local rand = rng:RandomFloat()
        local favoured = false
        if rand > 0.5 then
            favoured = true
        end
        rand=(rand*1.3)+0.3

        for i = 1, 2, 1 do
            local isDmg = i == 1
            local mult = rand
            --[[local lerp = (mult-0.5)/0.5
            lerp = mod:Clamp(mod:Lerp(0.3, 0, lerp)+1, 1.3, 1)
            mult = mult*lerp]]
            if favoured then
                mult = 1.6/mult
            end

            if isDmg then
                p_data.SomethingWickedPData.SSDamageBuff = mult
            else
                p_data.SomethingWickedPData.SSTearsBuff = mult
            end

            favoured = not favoured
        end
        
        player:AddCacheFlags(CacheFlag.CACHE_ALL)
        player:EvaluateItems()
    end
end

function mod:StarSpawnEval(player, flags)
    if player:HasCollectible(CollectibleType.SOMETHINGWICKED_STAR_SPAWN) then
        local p_data = player:GetData()
        p_data.SomethingWickedPData.SSDamageBuff = p_data.SomethingWickedPData.SSDamageBuff or 1.15
        p_data.SomethingWickedPData.SSTearsBuff = p_data.SomethingWickedPData.SSTearsBuff or 1.15

        if flags == CacheFlag.CACHE_DAMAGE then
            player.Damage = player.Damage * p_data.SomethingWickedPData.SSDamageBuff
        end
        if flags == CacheFlag.CACHE_FIREDELAY then
            player.MaxFireDelay = mod:TearsUp(player, 0, 0, p_data.SomethingWickedPData.SSTearsBuff)
        end
        if flags == CacheFlag.CACHE_TEARCOLOR then
            player.TearColor = player.TearColor * Color(1, 0.74, 0.74, 1, 0.5)
        end
    end
end