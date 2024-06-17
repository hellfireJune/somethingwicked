local mod = SomethingWicked
local game = Game()
local angVariance = 20
local maxSpeed = 20
local wantedDistance = 120

local function checkFamiliars(p_data)
    local tab = p_data.WickedPData.YoYos
    local newTab = {}
    if tab then
        for key, value in pairs(tab) do
            if value and value:Exists() then
                newTab[#newTab+1] = value
            end
        end
    end
    
    return newTab, #newTab
end

local function getEstimatedyoyos(player)
    return mod:BasicFamiliarNum(player, mod.ITEMS.THE_YOYO)
end

local function YoYoCheck(_, player)
    if not player:HasCollectible(mod.ITEMS.THE_YOYO) then return end

    local p_data = player:GetData()
    if player:GetFireDirection() ~= Direction.NO_DIRECTION then
        local aim = player:GetAimDirection()
        p_data.sw_yoyoDirection = aim

        local est = getEstimatedyoyos(player)
        local tab, cur = checkFamiliars(p_data)
        p_data.WickedPData.YoYos = tab

        local c_rng = player:GetCollectibleRNG(mod.ITEMS.THE_YOYO)
        while cur < est do
            cur = cur + 1

            local vel = (aim):Rotated(angVariance*math.tan(c_rng:RandomFloat()*5))
            local yo = Isaac.Spawn(EntityType.ENTITY_FAMILIAR, FamiliarVariant.SOMETHINGWICKED_YOYO, 0, player.Position, vel, player)
            yo:ClearEntityFlags(EntityFlag.FLAG_APPEAR)
            table.insert(p_data.WickedPData.YoYos, yo)
        end
    else
        p_data.sw_yoyoDirection = nil
    end
end
mod:AddCallback(ModCallbacks.MC_POST_PEFFECT_UPDATE, YoYoCheck)

local function YoYoCollide(_, familiar, other)
    other = other:ToNPC()
    if not other or not other:IsVulnerableEnemy() then
        return
    end

    --PUT COOL KNOCKBACK FUNCTION HERE
    local ang = mod:CollisionKnockback(familiar.Position, other.Position, familiar.Velocity)

    familiar:GetData()["sw_yoknockback"] = (ang*maxSpeed*1.5)
    
    if not other:HasEntityFlags(EntityFlag.FLAG_NO_PHYSICS_KNOCKBACK) then
        other:AddVelocity(ang*-0.8)
    end
end
mod:AddCallback(ModCallbacks.MC_PRE_FAMILIAR_COLLISION, YoYoCollide, FamiliarVariant.SOMETHINGWICKED_YOYO)

local deathTick = 5
local function YoYoUpdate(_, familiar)
    local room = game:GetRoom()
    if room:GetFrameCount() == 0 then
        familiar:Remove()
        return
    end

    local player = familiar.Player
    local p_data = player:GetData()
    local f_data = familiar:GetData()

    local dir = p_data.sw_yoyoDirection
    if dir then
        f_data.sw_yoyoDeathTick = 0
    else
        f_data.sw_yoyoDeathTick = f_data.sw_yoyoDeathTick + 1
        if f_data.sw_yoyoDeathTick >= deathTick then
            familiar:Remove()
            return
        end
        dir = f_data.sw_cachedYoYoDir
    end
    f_data.sw_cachedYoYoDir = dir
        
    f_data.sw_yoAcceleration = (f_data.sw_yoAcceleration or 1) +1.5
    local trgt = ((player.Position+player.Velocity)+(dir*wantedDistance))
    local currSpeed = math.min(f_data.sw_yoAcceleration, maxSpeed)
    currSpeed = math.min(currSpeed, trgt:Distance(familiar.Position))
    local vel = (trgt-familiar.Position):Normalized()*currSpeed
    if f_data.sw_yoknockback then
        familiar.Velocity = f_data.sw_yoknockback
        f_data.sw_yoknockback = nil
    end
    familiar.Velocity = mod:Lerp(familiar.Velocity, (vel), 0.2)
    if familiar.Velocity:Length() > maxSpeed then
        familiar.Velocity:Resize(maxSpeed)
    end

    local color = Color.Lerp(Color(1, 1, 1, 1), Color(1, 1, 1, 0), f_data.sw_yoyoDeathTick/deathTick)
    familiar.Color = color
end
mod:AddCallback(ModCallbacks.MC_FAMILIAR_UPDATE, YoYoUpdate, FamiliarVariant.SOMETHINGWICKED_YOYO)