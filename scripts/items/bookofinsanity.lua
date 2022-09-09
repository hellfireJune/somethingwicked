local this = {}
CollectibleType.SOMETHINGWICKED_BOOK_OF_INSANITY = Isaac.GetItemIdByName("Book of Insanity")
FamiliarVariant.SOMETHINGWICKED_NIGHTMARE = Isaac.GetEntityVariantByName("Nightmare")

TrinketType.SOMETHINGWICKED_NIGHTMARE_FUEL = Isaac.GetTrinketIdByName("Nightmare Fuel")

this.SubTypes = {
    NIGHTMARE_STANDARD = 0,
    NIGHTMARE_PERMANENT = 1,
    NIGHTMARE_HOLY = 2
}

this.Distance = 250
this.AnimationEnum = {
    [90] = "ShootDown",
    [180] = "ShootLeft",
    [-90] = "ShootUpward",
    [0] = "ShootRight",
}
this.IdleEnum = {
    ["Upward"] = "IdleUpward",
    ["Left"] = "IdleLeft",
    ["Down"] = "IdleDown",
    ["Right"] = "IdleRight",
}
this.MovementSpeedCap = 30

this.HeadSprites = {
    [this.SubTypes.NIGHTMARE_STANDARD] = {
        "nightmare_sheet_01",
        "nightmare_sheet_02",
        "nightmare_sheet_03",
    },
    [this.SubTypes.NIGHTMARE_PERMANENT] = {
        "nightmare_sheet_01",
    }
}

function this:FamiliarInit(familiar)
    local sprite = familiar:GetSprite()

    familiar:AddToOrbit(75)
    familiar.OrbitDistance = Vector(75, 75)
	familiar.OrbitSpeed = 0.01
    
    local poof = Isaac.Spawn(EntityType.ENTITY_EFFECT, EffectVariant.POOF01, 0, familiar.Position, Vector.Zero, familiar)
    poof.Color = Color(0.1, 0.1, 0.1)
    SomethingWicked.sfx:Play(SoundEffect.SOUND_BLACK_POOF, 1, 0)
    familiar:GetSprite():Play("Float", true)

    local spriteArray = this.HeadSprites[familiar.SubType]
    local rng = familiar:GetDropRNG()
    sprite:ReplaceSpritesheet(0, "gfx/familiars/"..SomethingWicked:GetRandomElement(spriteArray, rng)..".png")
    sprite:LoadGraphics()

    --[[familiar.MaxHitPoints = 2
    familiar.HitPoints = familiar.MaxHitPoints]]
end

function this:PlayAnimation(sprite, anim)
    local frame = sprite:GetFrame()
    sprite:Play(anim, false)
    sprite:SetFrame(frame)
end

function this:FamiliarUpdate(familiar)
    local player = familiar.Player
    local sprite = familiar:GetSprite()
    familiar.OrbitDistance = Vector(75, 75) 
	familiar.OrbitSpeed = 0.01 

    local position = (familiar:GetOrbitPosition(player.Position + player.Velocity))
    position = player.Position + player.Velocity + ((player.Position + player.Velocity) - position) * math.sin(0.1 * familiar.FrameCount)
    if SomethingWicked.game:GetRoom():GetFrameCount() == 0 then
        familiar.Velocity = Vector.Zero
        familiar.Position = position
        --we stan a weird ass fuckin visual glitch
    else
        local velocity = (position) - familiar.Position
        if velocity:Length() > this.MovementSpeedCap then
            velocity:Resize(this.MovementSpeedCap)
        end
        familiar.Velocity = velocity
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

            local tear = familiar:FireProjectile(direction)
            tear = tear:ToTear()

            tear.CollisionDamage = player:HasCollectible(CollectibleType.COLLECTIBLE_BFFS) and 2 or 1
            tear:ChangeVariant(TearVariant.BLOOD)
            tear:AddTearFlags(TearFlags.TEAR_HOMING | TearFlags.TEAR_SPECTRAL)

	    	if player:HasTrinket(TrinketType.TRINKET_FORGOTTEN_LULLABY) then
    			familiar.FireCooldown = 8
		    else
	    		familiar.FireCooldown = 11
    		end

            tear:Update()
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

function this.FamiliarDeath(familiar)
    if familiar.Variant ~= FamiliarVariant.SOMETHINGWICKED_NIGHTMARE then
        return
    end
    local poof = Isaac.Spawn(EntityType.ENTITY_EFFECT, EffectVariant.POOF01, 0, familiar.Position, Vector.Zero, familiar)
    poof.Color = Color(0.1, 0.1, 0.1)
    SomethingWicked.sfx:Play(SoundEffect.SOUND_BLACK_POOF, 1, 0)
end

SomethingWicked:AddCallback(ModCallbacks.MC_FAMILIAR_UPDATE, this.FamiliarUpdate, FamiliarVariant.SOMETHINGWICKED_NIGHTMARE)
SomethingWicked:AddCallback(ModCallbacks.MC_FAMILIAR_INIT, this.FamiliarInit, FamiliarVariant.SOMETHINGWICKED_NIGHTMARE)
SomethingWicked:AddCallback(ModCallbacks.MC_POST_ENTITY_KILL, this.FamiliarDeath, EntityType.ENTITY_FAMILIAR)
--SomethingWicked:AddCallback(ModCallbacks.MC_EVALUATE_CACHE, this.CacheFlag, CacheFlag.CACHE_FAMILIARS)


function this:UseItem(_, _, player, flags)
    --local p_data = player:GetData()
    local scrunkly = Isaac.Spawn(EntityType.ENTITY_FAMILIAR, FamiliarVariant.SOMETHINGWICKED_NIGHTMARE, 0, player.Position, Vector.Zero, player)      
    scrunkly:ClearEntityFlags(EntityFlag.FLAG_APPEAR)

    return true
end


function this:CacheFlag(player)    
    local rng = player:GetCollectibleRNG(CollectibleType.SOMETHINGWICKED_BOOK_OF_INSANITY)
    local sourceItem = Isaac.GetItemConfig():GetTrinket(TrinketType.SOMETHINGWICKED_NIGHTMARE_FUEL)
    player:CheckFamiliar(FamiliarVariant.SOMETHINGWICKED_NIGHTMARE, player:GetTrinketMultiplier(TrinketType.SOMETHINGWICKED_NIGHTMARE_FUEL), rng, sourceItem, this.SubTypes.NIGHTMARE_PERMANENT)
end

function  this:WispUpdate(familiar)
    if familiar.SubType == CollectibleType.SOMETHINGWICKED_BOOK_OF_INSANITY then    
        local player = familiar.Player
        
        local position = (familiar:GetOrbitPosition(player.Position + player.Velocity))
        position = player.Position + player.Velocity + ((player.Position + player.Velocity) - position) * math.sin(0.125 * familiar.FrameCount)
        if SomethingWicked.game:GetRoom():GetFrameCount() == 0 then
            familiar.Velocity = Vector.Zero
            familiar.Position = position
            --we stan a weird ass fuckin visual glitch
        else
            local velocity = (position) - familiar.Position
            familiar.Velocity = velocity
        end
    end
end

SomethingWicked:AddCallback(ModCallbacks.MC_FAMILIAR_UPDATE, this.WispUpdate, FamiliarVariant.WISP)

SomethingWicked:AddCallback(ModCallbacks.MC_EVALUATE_CACHE, this.CacheFlag, CacheFlag.CACHE_FAMILIARS)
SomethingWicked:AddCallback(ModCallbacks.MC_USE_ITEM, this.UseItem, CollectibleType.SOMETHINGWICKED_BOOK_OF_INSANITY)


function this:NewRoom()
    for _, value in ipairs(SomethingWicked:UtilGetAllPlayers()) do
        if value:HasTrinket(TrinketType.SOMETHINGWICKED_NIGHTMARE_FUEL) then
           value:AddCacheFlags(CacheFlag.CACHE_FAMILIARS)
           value:EvaluateItems()
        end
    end
end

SomethingWicked:AddCallback(ModCallbacks.MC_POST_NEW_ROOM, this.NewRoom)

this.EIDEntries = {
    [CollectibleType.SOMETHINGWICKED_BOOK_OF_INSANITY] = {
        desc = "Spawns a Nightmare familiar upon use#These nightmare familiars will block bullets and erattically orbit the player, firing homing tears at anything in a nearby radius#Nightmares will die after two hits",
        
        pools = {
            SomethingWicked.encyclopediaLootPools.POOL_TREASURE,
            SomethingWicked.encyclopediaLootPools.POOL_LIBRARY,
            SomethingWicked.encyclopediaLootPools.POOL_GREED_TREASURE
        },
        encycloDesc = SomethingWicked:UtilGenerateWikiDesc({"Spawns a Nightmare familiar upon book use","These nightmare familiars will block bullets and erattically orbit the player, firing homing tears at anything in a nearby radius","Nightmares will die after two hits"})
    },
    [TrinketType.SOMETHINGWICKED_NIGHTMARE_FUEL] = {
        desc = "Spawns 1 Nightmare familiar which erattically orbits the player and attacks nearby enemies with homing tears#Familiar respawns each room if it dies",
        isTrinket = true,
        encycloDesc = SomethingWicked:UtilGenerateWikiDesc({"Spawns 1 Nightmare familiar which erattically orbits the player and attacks nearby enemies with homing tears","Familiar respawns each room if it dies"})
    }
}
return this