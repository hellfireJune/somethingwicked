--
local this = {}
SomethingWicked.StatUps = {}

function SomethingWicked.StatUps:DamageUp(player, damage, flat, mult)
    damage = damage or 0
    flat = flat or 0
    mult = mult or 1

    local baseMult = SomethingWicked.StatUps:GetCurrentDamageMultiplier(player)
    damage = damage * baseMult
    flat = flat * baseMult

    --TY to ipecac community mod for this easy damage up formula
    return (math.sqrt(player.Damage^2 + (damage * (14.694 * baseMult)))+flat)*mult
end

function SomethingWicked.StatUps:GetCurrentDamageMultiplier(player)
    player = player:ToPlayer()
    local mult = 1
    local playerType = player:GetPlayerType()
    local charMult = this.CharacterDamageMultipliers[playerType]
    if type(charMult) == "function" then charMult = charMult(player) end
    if charMult ~= nil then mult = charMult end
    
    --Also, stolen from the damage multiplier stat mod. Thanks to "FainT" so so so much
    for collectible, multiplier in pairs(this.DamageMultiplers) do
        if player:HasCollectible(collectible) then
            if type(multiplier) == "function" then multiplier = multiplier(player) end
            mult = mult * multiplier
        end
    end
    return mult
end

function SomethingWicked.StatUps:GetCurrentTearsMultiplier(player)
  local mult = 1
  for collectible, multiplier in pairs(this.TearMultipliers) do
    if player:HasCollectible(collectible) then
        if type(multiplier) == "function" then multiplier = multiplier(player) end
        mult = mult * multiplier
    end
end
return mult
end

function SomethingWicked.StatUps:TearsUp(player, tears, flat, mult)
  tears = tears or 0
  flat = flat or 0
  mult = mult or 1

  local baseMult = SomethingWicked.StatUps:GetCurrentTearsMultiplier(player)
  
  tears = tears * baseMult
  flat = flat * baseMult

  local currentTears = SomethingWicked.StatUps:GetTears(player.MaxFireDelay)
  local currmax = 5 + (player:GetTrinketMultiplier(TrinketType.TRINKET_CANCER))
  tears = math.min(tears*1.1 + currentTears, math.max(currmax * baseMult * mult, currentTears)) - currentTears
  return SomethingWicked.StatUps:GetFireDelay(math.max((currentTears + (tears) + flat) * mult, 0.2))
end

--shamelessly nabbed from an old message from mr.seemsgood i found.
-- Helper functions to turn fire delay into equivalent tears up (since via api only fire delay is accessible, not tears)
 function SomethingWicked.StatUps:GetTears(fireDelay)
    return 30 / (fireDelay + 1)
end
function SomethingWicked.StatUps:GetFireDelay(tears)
    return math.max(30 / tears - 1, -0.9999)
end

this.CharacterDamageMultipliers = {
    [PlayerType.PLAYER_EVE] = function(player)
    if player:GetHearts() > 2 then
        return 0.75
    end end,
    [PlayerType.PLAYER_MAGDALENA_B] = 0.75,
    [PlayerType.PLAYER_XXX] = 1.05,
    [PlayerType.PLAYER_CAIN] = 1.2,
    [PlayerType.PLAYER_KEEPER] = 1.2,
    [PlayerType.PLAYER_EVE_B] = 1.2,
    [PlayerType.PLAYER_JUDAS] = 1.35,
    [PlayerType.PLAYER_THELOST_B] = 1.3,
    [PlayerType.PLAYER_LAZARUS2] = 1.4,
    [PlayerType.PLAYER_AZAZEL] = 1.5,
    [PlayerType.PLAYER_AZAZEL_B] = 1.5,
    [PlayerType.PLAYER_THEFORGOTTEN] = 1.5,
    [PlayerType.PLAYER_THEFORGOTTEN_B] = 1.5,
    [PlayerType.PLAYER_BLACKJUDAS] = 2,
}

--This one was stolen from the damage multiplier stat mod. I thank them so so much
this.DamageMultiplers = {
    [CollectibleType.COLLECTIBLE_MAXS_HEAD] = 1.5,
    [CollectibleType.COLLECTIBLE_MAGIC_MUSHROOM] = function (player)
      -- Cricket's Head/Blood of the Martyr/Magic Mushroom don't stack with each other
      if player:HasCollectible(CollectibleType.COLLECTIBLE_MAXS_HEAD) then return 1 end
      return 1.5
    end,
    [CollectibleType.COLLECTIBLE_BLOOD_MARTYR] = function (player)
      if not player:GetEffects():HasCollectibleEffect(CollectibleType.COLLECTIBLE_BOOK_OF_BELIAL) then return 1 end
  
      -- Cricket's Head/Blood of the Martyr/Magic Mushroom don't stack with each other
      if
        player:HasCollectible(CollectibleType.COLLECTIBLE_MAXS_HEAD) or
        player:GetEffects():HasCollectibleEffect(CollectibleType.COLLECTIBLE_MAGIC_MUSHROOM)
      then return 1 end
      return 1.5
    end,
    [CollectibleType.COLLECTIBLE_POLYPHEMUS] = 2,
    [CollectibleType.COLLECTIBLE_SACRED_HEART] = 2.3,
    [CollectibleType.COLLECTIBLE_EVES_MASCARA] = 2,
    [CollectibleType.COLLECTIBLE_ODD_MUSHROOM_RATE] = 0.9,
    [CollectibleType.COLLECTIBLE_20_20] = 0.75,
    [CollectibleType.COLLECTIBLE_EVES_MASCARA] = 2,
  
    [CollectibleType.COLLECTIBLE_SOY_MILK] = function (player)
      -- Almond Milk overrides Soy Milk
      if player:HasCollectible(CollectibleType.COLLECTIBLE_ALMOND_MILK) then return 1 end
      return 0.2
    end,
    [CollectibleType.COLLECTIBLE_CROWN_OF_LIGHT] = function (player)
      if player:GetEffects():HasCollectibleEffect(CollectibleType.COLLECTIBLE_CROWN_OF_LIGHT) then return 2 end
      return 1
    end,
    [CollectibleType.COLLECTIBLE_ALMOND_MILK] = 0.33,
    [CollectibleType.COLLECTIBLE_IMMACULATE_HEART] = 1.2,
}

this.TearMultipliers = {
    [CollectibleType.COLLECTIBLE_BRIMSTONE] = 0.33,
    [CollectibleType.COLLECTIBLE_IPECAC] = 0.33,
    [CollectibleType.COLLECTIBLE_MONSTROS_LUNG] = 0.2,
    [CollectibleType.COLLECTIBLE_EVES_MASCARA] = 0.66,
    [CollectibleType.COLLECTIBLE_MUTANT_SPIDER] = 0.42,
    [CollectibleType.COLLECTIBLE_POLYPHEMUS] = 0.42,
    [CollectibleType.COLLECTIBLE_SOY_MILK] = 5.5,
    [CollectibleType.COLLECTIBLE_ALMOND_MILK] = 4,
    [CollectibleType.COLLECTIBLE_HAEMOLACRIA] = 0.66,
    [CollectibleType.COLLECTIBLE_INNER_EYE] = 0.66,
    [CollectibleType.COLLECTIBLE_DR_FETUS] = 0.4
}