local mod = SomethingWicked

function mod:SoPBombExplode(bomb, p)
    local b_data = bomb:GetData()
    
    p.Velocity = b_data.sw_savedplayervel
    if b_data.sw_superProviBomb then
        mod:DoMegaBlank(bomb.Position, p)
    else
        mod:DoMicroBlank(bomb.Position, p)
    end
end

function mod:SoPBombUpdate(bomb, p)
    local b_data = bomb:GetData()
    local b_rng = bomb:GetDropRNG()
    if bomb.IsFetus and not b_data.sw_proviBombWipe then
        b_data.sw_proviBombWipe = true
        if (b_rng:RandomFloat() > 0.1) then
            b_data.sw_isBlankBomb = false
            return
        end
    end
    
    bomb:SetExplosionCountdown(0) 
    b_data.sw_savedplayervel = p.Velocity
end

mod:AddCallback(ModCallbacks.MC_POST_PLAYER_USE_BOMB, function (_, player, bomb)
    if player:HasCollectible(mod.ITEMS.STAR_OF_PROVIDENCE) then
        local p_data = player:GetData()

        local ready = p_data.sw_superProviBombTimer == nil
        if ready then
            p_data.sw_superProviBombReady = 15*30
            local b_data = bomb:GetData()
            b_data.sw_superProviBomb = true
        end
    end
end)

function mod:SOPPlayerUpdate(player)
    if player:HasCollectible(mod.ITEMS.STAR_OF_PROVIDENCE) then
        local p_data = player:GetData()
        if p_data.WickedPData.sw_superProviBombTimer then
            p_data.WickedPData.sw_superProviBombTimer = p_data.WickedPData.sw_superProviBombTimer -1
            if p_data.WickedPData.sw_superProviBombTimer <= 0 then
                p_data.WickedPData.sw_superProviBombTimer = nil
            end
        end
    end
end