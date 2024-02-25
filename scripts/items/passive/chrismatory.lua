local mod = SomethingWicked

local wisps = 8
local angleOffset = 15
local angleVariance = 45
local function procChance(player)
    local luck = player.Luck + (player:HasTrinket(TrinketType.TRINKET_TEARDROP_CHARM) and 3 or 0)
    return 0.2 + ((1 - 1 / (1 + 0.10 * luck)) * 0.37)
end
mod:AddCustomCBack(mod.CustomCallbacks.SWCB_ON_FIRE_PURE, function (_,  shooter, vector, scalar, player)
    if player:HasCollectible(mod.ITEMS.CHRISMATORY) then
        local isPlayer = shooter.Type == EntityType.ENTITY_PLAYER
        local p_data = player:GetData()
        local c_rng = player:GetCollectibleRNG(mod.ITEMS.CHRISMATORY)

        --print(p_data.sw_chrismatoryTick)
        if p_data.sw_chrismatoryTick and p_data.sw_chrismatoryTick ~= 150 then
            for i = 1, wisps, 1 do
                local angle = (angleOffset + c_rng:RandomInt(angleVariance)+1)*(i%2==1 and -1 or 1)
                angle = vector:Rotated(angle)

                local v = mod:UtilGetFireVector(angle, player)
                local wisp = player:FireTear(shooter.Position - v, v, false, true, false, nil, scalar)
                wisp.Parent = nil
                wisp:ChangeVariant(TearVariant.SOMETHINGWICKED_WISP)
                wisp:AddTearFlags(TearFlags.TEAR_SPECTRAL)
                wisp.Height = wisp.Height * 3
                wisp.Scale = wisp.Scale * 1.15
                
                local colour = Color(1, 1, 1, 1)
                colour:SetColorize(2, 2, 2, 0.5)
                wisp.Color = colour
                local t_data = wisp:GetData()
                t_data.sw_homingSpeed = 15*(c_rng:RandomFloat()/2+0.75)
                t_data.sw_isChrisWisp = true
    
                SomethingWicked:UtilAddTrueHoming(wisp, mod.FamiliarHelpers:FindNearestVulnerableEnemy(wisp.Position), 35, false)
            end
            local fire = Isaac.Spawn(EntityType.ENTITY_EFFECT, EffectVariant.SOMETHINGWICKED_CHRISMATORYFIRE, 0, shooter.Position + Vector(0, -(shooter.Size/2)), Vector.Zero, nil):ToEffect()
            fire.SpriteRotation = vector:GetAngleDegrees()
            fire.SpriteScale = Vector(1,1)*scalar

            if isPlayer then
                p_data.sw_chrismatoryTick = -1

                player.FireDelay = player.FireDelay + math.abs(player.FireDelay)
                player.Velocity = player.Velocity - (vector*(math.max(player.MaxFireDelay*0.5, 0)^0.8))
                local color = Color(1, 1, 1, 1, 0.8, 0.8, 0.8)
                player:SetColor(color, 10, 5, true, false)
                mod.sfx:Play(SoundEffect.SOUND_JELLY_BOUNCE, 1, 0)
            end
        elseif isPlayer and c_rng:RandomFloat() < procChance(player) then
            p_data.sw_chrismatoryTick = 150
        end
    end
end)

mod:AddCallback(ModCallbacks.MC_POST_PEFFECT_UPDATE, function (_, player)
    local p_data = player:GetData()
    if p_data.sw_chrismatoryTick then
        p_data.sw_chrismatoryTick = p_data.sw_chrismatoryTick - 1
        if p_data.sw_chrismatoryTick < 0 then
            p_data.sw_chrismatoryTick = nil
        end
        local color = Color(1, 1, 1, 1, 0.25, 0.25, 0.25)
        player:SetColor(color, 2, 3, false, false)
    end
end)
