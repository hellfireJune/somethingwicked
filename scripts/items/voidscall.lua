local mod = SomethingWicked
local sfx = SFXManager()

local frameWait = 2
local angleVariance = 5
local baseChance = 0.3
local function procChance(player)
    local luck = player.Luck + (player:HasTrinket(TrinketType.TRINKET_TEARDROP_CHARM) and 3 or 0)
    local hearts = math.ceil(player:GetHearts() / 2)
    local chanceMod = math.max(-0, hearts - (luck/6) - 0.5)

    return (baseChance - ((1 - 1 / (1 + chanceMod)) * 0.27))
end
local function callOfTheVoidOnFire(_, shooter, vector, scalar, player)
    if not player:HasCollectible(mod.ITEMS.CALL_OF_THE_VOID) then
        return
    end

    local c_rng = player:GetCollectibleRNG(mod.ITEMS.CALL_OF_THE_VOID)
    local chance = procChance(player)
    if c_rng:RandomFloat() < 1 + chance then
        local a = mod.EnemyHelpers:Lerp(-angleVariance, angleVariance, c_rng:RandomFloat())
        local v = vector:Rotated(a)
        v = mod:UtilGetFireVector(v, player)*2

        local sawTear = player:FireTear(shooter.Position-v, v, false, true, false, nil, 1.1*scalar)
        sawTear:ChangeVariant(TearVariant.SOMETHINGWICKED_VOIDSBLADE)
        sawTear.Scale = sawTear.Scale * 1.3

        local s_data = sawTear:GetData()
        s_data.sw_sawData = {
            TotalBonusCollides = 3
        }
        sawTear:GetSprite():Play("Spin", true)
        sawTear.FallingAcceleration = sawTear.FallingAcceleration / 2
        sawTear:Update()
    end
end
mod:AddCustomCBack(mod.CustomCallbacks.SWCB_ON_FIRE_PURE, callOfTheVoidOnFire)

mod:AddCallback(ModCallbacks.MC_POST_TEAR_UPDATE, function (_, tear)
    local t_data = tear:GetData()
    if t_data and t_data.sw_sawData then
        if t_data.sw_sawData.frameWait then
            if t_data.sw_sawData.waitNext then
                tear.Velocity = Vector.Zero
                t_data.sw_sawData.waitNext = false
            end
            t_data.sw_sawData.frameWait = t_data.sw_sawData.frameWait - 1
            if t_data.sw_sawData.frameWait < 0 then
                t_data.sw_sawData.frameWait = nil
            end
        else
            if t_data.sw_sawData.lastVeloc then
                tear.Velocity = t_data.sw_sawData.lastVeloc
                t_data.sw_sawData.lastVeloc = nil
            end
            if t_data.sw_sawData.restartSprite then
                t_data.sw_sawData.restartSprite = false
                local sprite = tear:GetSprite()
                sprite.PlaybackSpeed = 1
                sprite:Update()
            end
        end
    end
end)
local function DoGibs(multiplier, person)
    local rng = RNG()
    rng:SetSeed(Random() + 1, 1)
    if not person:HasEntityFlags(EntityFlag.FLAG_NO_BLOOD_SPLASH) then
        for i = 1, multiplier, 1 do
            local dedbaby = Isaac.Spawn(1000, 2, 1, person.Position + Vector(0, 1), Vector.Zero, person)
            dedbaby.Color = person.SplatColor
            dedbaby.SpriteOffset = person.SpriteOffset + Vector(0,-5) + RandomVector() * rng:RandomInt(15)
            dedbaby:Update()
        end
    end
    local s = multiplier == 1 and SoundEffect.SOUND_MEATY_DEATHS or SoundEffect.SOUND_DEATH_BURST_LARGE
    sfx:Play(s, 1)
end
--a slight bit of this was taken from tainted treasures (mainly the collision and gibs shit), ty guwah/jd/whoever made lil slugger
mod:AddCallback(ModCallbacks.MC_PRE_TEAR_COLLISION, function (_, tear, collider)
    local s_data = tear:GetData()
    if not s_data then
       return 
    end
    if s_data.sw_sawData then
        s_data.sw_sawData.collides = s_data.sw_sawData.collides or {}
        local collides = s_data.sw_sawData.collides[collider.Index] or 0
        if not s_data.sw_sawData.frameWait
        and collides < s_data.sw_sawData.TotalBonusCollides then
            if collider:TakeDamage(tear.CollisionDamage, 0, EntityRef(tear), 0) then
                s_data.sw_sawData.collides[collider.Index] = collides + 1
                local gibsMult = 1
                if s_data.sw_sawData.TotalBonusCollides > collides + 1
                and not collider:HasMortalDamage() then
                    if not s_data.sw_sawData.lastVeloc then
                        s_data.sw_sawData.lastVeloc = tear.Velocity
                    end
                    s_data.sw_sawData.frameWait = frameWait
                    tear.Velocity = s_data.sw_sawData.lastVeloc / 10
                    s_data.sw_sawData.waitNext = true

                    local sprite = tear:GetSprite()
                    sprite.PlaybackSpeed = 1
                    sprite:Update()
                    sprite.PlaybackSpeed = 0
                    s_data.sw_sawData.restartSprite = true
                else
                    if s_data.sw_sawData.lastVeloc then
                        tear.Velocity = s_data.sw_sawData.lastVeloc
                        s_data.sw_sawData.lastVeloc = nil
                    end
                    gibsMult = 4
                    collider:BloodExplode()
                end
    
                DoGibs(gibsMult, collider)
            end
        end
        return true
    end 
end)


this.EIDEntries = {
    [mod.ITEMS.CALL_OF_THE_VOID] = {
        desc = "Made of steel and black",
        Hide = true,
    }
}
return this