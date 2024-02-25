local mod = SomethingWicked
local ff = FiendFolio

local synergies = {
    [mod.ITEMS.D_STOCK] = function (player, mult, rng, iconfig)
        local hf = function (enemy, p, m, r)
            if r:RandomInt(2) == 0 then
                Isaac.Spawn(EntityType.ENTITY_PICKUP, PickupVariant.PICKUP_COIN, 0, enemy.Position, mod.SlotHelpers:GetPayoutVector(r), p)
            end
        end
        ff:electrumShock(player, mult, rng, iconfig, nil, hf)
    end,
    [mod.ITEMS.BALROGS_HEAD] = function ()
        --add me elsewhere :3
    end,
    [mod.ITEMS.WOODEN_DICE] = function ()
        
    end,
    [mod.ITEMS.BOOK_OF_LUCIFER] = function ()
        
    end,
    [mod.ITEMS.TOYBOX] = function ()
        
    end,
    [mod.ITEMS.TIAMATS_DICE] = function ()
        
    end,
    [mod.ITEMS.BOOK_OF_EXODUS] = function ()
        
    end,
    [mod.ITEMS.CURSED_CANDLE] = function ()
        
    end,
    [mod.ITEMS.VOID_EGG] = function ()
        
    end,
    [mod.ITEMS.DADS_WALLET] = function ()
        
    end,
    [mod.ITEMS.BOOK_OF_INSANITY] = function ()
        
    end,
    [mod.ITEMS.CHAOS_HEART] = function ()
        
    end,
    [mod.ITEMS.CURSED_MUSHROOM] = function ()
        
    end,
    [mod.ITEMS.OLD_DICE] = function ()
        
    end,
    [mod.ITEMS.ENCYCLOPEDIA] = function ()
        
    end,
    [mod.ITEMS.TRINKET_SMASHER] = function ()
        
    end,
    [mod.ITEMS.CHASM] = function ()
        
    end,
    [mod.ITEMS.FETUS_IN_FETU] = function ()
        
    end,
    [mod.ITEMS.EDENS_HEAD] = function ()
        
    end,
    [mod.ITEMS.ABANDONED_BOX] = function ()
        
    end,
    [mod.ITEMS.GOLDEN_CARD] = function ()
        
    end,
    [mod.ITEMS.BOLINE] = function ()
        
    end,
}
return synergies