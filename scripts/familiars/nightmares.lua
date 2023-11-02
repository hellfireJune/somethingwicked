local mod = SomethingWicked
local sfx = SFXManager()

this.MovementSpeedCap = 30

function this:FamiliarInit(familiar)
    --print(familiar.SubType)
    local sprite = familiar:GetSprite()

    familiar:AddToOrbit(3)
    familiar.OrbitDistance = Vector(110, 90)
	familiar.OrbitSpeed = 0.01
    
    local poof = Isaac.Spawn(EntityType.ENTITY_EFFECT, EffectVariant.POOF01, 0, familiar.Position, Vector.Zero, familiar)
    poof.Color = Color(0.1, 0.1, 0.1)
    sfx:Play(SoundEffect.SOUND_BLACK_POOF, 1, 0)
    familiar:GetSprite():Play("Float", true)

    local spriteArray = this.HeadSprites[familiar.SubType]
    local rng = familiar:GetDropRNG()
    sprite:ReplaceSpritesheet(0, "gfx/familiars/"..SomethingWicked:GetRandomElement(spriteArray, rng)..".png")
    sprite:LoadGraphics()

    --[[familiar.MaxHitPoints = 2
    familiar.HitPoints = familiar.MaxHitPoints]]
end

local virtueSpread = 20
function this:FamiliarUpdate(familiar)
    local player = familiar.Player
    local sprite = familiar:GetSprite()
    familiar.OrbitDistance = Vector(75, 75) 
	familiar.OrbitSpeed = 0.01 

    SomethingWicked.EnemyHelpers:FluctuatingOrbitFunc(familiar, player)
    if familiar.Velocity:Length() > this.MovementSpeedCap then
        familiar.Velocity:Resize(this.MovementSpeedCap)
    end

    familiar:PickEnemyTarget(this.Distance, 13, 1)
    if familiar.FireCooldown <= 0 then
        
        if familiar.Target and familiar.Target.Position:Distance(familiar.Position) < this.Distance then
            --shoot
            local direction = (familiar.Target.Position - familiar.Position):Normalized()
            local anim = "ShootDown" local diff = 999
            for key, value in pairs(this.AnimationEnum) do
                local currentDiff = math.abs(direction:GetAngleDegrees() - key)
                if currentDiff < diff then
                    diff = currentDiff
                    anim = value
                end
            end
            this:PlayAnimation(sprite, anim)

            for i = -virtueSpread, doVirtueFire and virtueSpread or -virtueSpread, virtueSpread do
                if not doVirtueFire then
                    i = 0
                end
                
                local tear = familiar:FireProjectile(direction:Rotated(i))
                tear = tear:ToTear()

                tear.CollisionDamage = player:HasCollectible(CollectibleType.COLLECTIBLE_BFFS) and 2 or 1
                tear:ChangeVariant(TearVariant.BLOOD)
                tear:AddTearFlags(TearFlags.TEAR_SPECTRAL)

                local coolDown = doVirtueFire and 30 or 12
	        	familiar.FireCooldown = math.ceil(coolDown * (player:HasTrinket(TrinketType.TRINKET_FORGOTTEN_LULLABY) and 0.7 or 1))

                tear:Update()
            end
        else
            this:PlayAnimation(sprite, "Float")
        end
    else
        if familiar.FireCooldown < 3 then
            for key, value in pairs(this.IdleEnum) do
                if string.find(sprite:GetAnimation(), key) then
                    this:PlayAnimation(sprite, value)
                    break
                end
            end
        end

        familiar.FireCooldown = familiar.FireCooldown - 1
    end

    SomethingWicked.FamiliarHelpers:KillableFamiliarFunction(familiar, true, false, true)
end

SomethingWicked:AddCallback(ModCallbacks.MC_FAMILIAR_UPDATE, this.FamiliarUpdate, FamiliarVariant.SOMETHINGWICKED_NIGHTMARE)
SomethingWicked:AddCallback(ModCallbacks.MC_FAMILIAR_INIT, this.FamiliarInit, FamiliarVariant.SOMETHINGWICKED_NIGHTMARE)

mod:AddCallback(ModCallbacks.MC_POST_ENTITY_KILL, function (familiar)
    if familiar.Variant ~= FamiliarVariant.SOMETHINGWICKED_NIGHTMARE then
        return
    end

    local poof = Isaac.Spawn(EntityType.ENTITY_EFFECT, EffectVariant.POOF01, 0, familiar.Position, Vector.Zero, familiar)
    poof.Color = Color(0.1, 0.1, 0.1)
    sfx:Play(SoundEffect.SOUND_BLACK_POOF, 1, 0)
end, EntityType.ENTITY_FAMILIAR)