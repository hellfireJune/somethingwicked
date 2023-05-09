local mod = SomethingWicked
local ff = FiendFolio

local synergies = {
    [CollectibleType.SOMETHINGWICKED_D_STOCK] = function (player, mult, rng, iconfig)
        local hf = function (enemy, p, m, r)
            if r:RandomInt(2) == 0 then
                Isaac.Spawn(EntityType.ENTITY_PICKUP, PickupVariant.PICKUP_COIN, 0, enemy.Position, mod.SlotHelpers:GetPayoutVector(r), p)
            end
        end
        ff:electrumShock(player, mult, rng, iconfig, nil, hf)
    end,
    [CollectibleType.SOMETHINGWICKED_BALROGS_HEAD] = function ()
        --add me elsewhere :3
    end,
    [CollectibleType.SOMETHINGWICKED_WOODEN_DICE] = function ()
        
    end,
    [CollectibleType.SOMETHINGWICKED_BOOK_OF_LUCIFER] = function ()
        
    end,
    [CollectibleType.SOMETHINGWICKED_TOYBOX] = function ()
        
    end,
    [CollectibleType.SOMETHINGWICKED_TIAMATS_DICE] = function ()
        
    end,
    [CollectibleType.SOMETHINGWICKED_XXXS_FAVOURITE_TOYS] = function ()
        
    end,
    [CollectibleType.SOMETHINGWICKED_CURSED_CANDLE] = function ()
        
    end,
    [CollectibleType.SOMETHINGWICKED_VOID_EGG] = function ()
        
    end,
    [CollectibleType.SOMETHINGWICKED_DADS_WALLET] = function ()
        
    end,
    [CollectibleType.SOMETHINGWICKED_BOOK_OF_INSANITY] = function ()
        
    end,
    [CollectibleType.SOMETHINGWICKED_CHAOS_HEART] = function ()
        
    end,
    [CollectibleType.SOMETHINGWICKED_CURSED_MUSHROOM] = function ()
        
    end,
    [CollectibleType.SOMETHINGWICKED_OLD_DICE] = function ()
        
    end,
    [CollectibleType.SOMETHINGWICKED_ENCYCLOPEDIA] = function ()
        
    end,
    [CollectibleType.SOMETHINGWICKED_TRINKET_SMASHER] = function ()
        
    end,
    [CollectibleType.SOMETHINGWICKED_CHASM] = function ()
        
    end,
    [CollectibleType.SOMETHINGWICKED_FETUS_IN_FETU] = function ()
        
    end,
    [CollectibleType.SOMETHINGWICKED_EDENS_HEAD] = function ()
        
    end,
    [CollectibleType.SOMETHINGWICKED_ABANDONED_BOX] = function ()
        
    end,
    [CollectibleType.SOMETHINGWICKED_GOLDEN_CARD] = function ()
        
    end,
    [CollectibleType.SOMETHINGWICKED_BOLINE] = function ()
        
    end,
}