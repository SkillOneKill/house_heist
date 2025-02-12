Config = {}

-- 🏠 Liste der Häuser, die ausgeraubt werden können
Config.Houses = {
    [1] = { coords = vector3(-1974.7767, 630.9743, 122.6889), robbed = false },
    [2] = { coords = vector3(-1996.3278, 591.2554, 118.1019), robbed = false },
    [3] = { coords = vector3(-1896.2327, 642.4896, 130.2090), robbed = false },
    [4] = { coords = vector3(-1928.8364, 595.6570, 122.2875), robbed = false },
    [5] = { coords = vector3(-1937.4067, 551.3699, 115.0229), robbed = false },
    -- Füge weitere Häuser hinzu
}

Config.BreakInTime = 60000 -- Millisekunden (5 Sekunden)
Config.RequiredWeapon = "weapon_crowbar" -- Waffe, die gehalten werden muss
Config.SuccessChance = 45 -- 75% Erfolgschance
Config.AlarmChance = 80 -- 50% Chance auf stillen Alarm
Config.PoliceJob = "police" -- Name des Polizeijobs
Config.Cooldown = 900 -- Cooldown in Sekunden (15 Minuten)

-- **Zentrale Belohnungsstruktur**
Config.Rewards = {
    items = { 
        {name = "money", amount = {500, 1000}}, 
        {name = "scrapmetal", amount = {1, 13}}, 
        {name = "gazbottle", amount = {1, 4}},    
        {name = "armour", amount = {1, 1}},
        {name = "garbage", amount = {1, 2}}, 
        {name = "diamond", amount = {1, 1}}
    },
    weapons = {
        {name = "weapon_pistol", amount = {1, 1}},
        {name = "weapon_smg", amount = {1, 1}}
    }
}