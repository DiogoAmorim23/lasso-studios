--!strict
-- ÚNICO sítio para preços, raridades e economia.

local Config = {}

Config.Rarities = {
	Common = { Weight = 70, Value = 10 },
	Rare = { Weight = 25, Value = 50 },
	Legendary = { Weight = 5, Value = 500 },
}

Config.Economy = {
	StartingCoins = 100,
	MaxCoins = 1e9,
}

-- Ids de Developer Products (substituir pelos teus)
Config.Products = {
	[0] = { Name = "Exemplo: 500 moedas", Coins = 500 },
}

Config.Remotes = {
	MaxActionsPerSecond = 5,
	MaxInteractDistance = 15, -- studs
}

return Config
