--!strict
-- Único acesso aos dados do jogador. Nunca usar DataStoreService diretamente.
-- Requer ProfileStore em src/server/Lib/ProfileStore.luau (github.com/MadStudioRoblox/ProfileStore)

local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")

local Config = require(ReplicatedStorage.Shared.Config)
local ProfileStore = require(script.Parent.Parent.Lib.ProfileStore)

local TEMPLATE = {
	Coins = Config.Economy.StartingCoins,
	Inventory = {} :: { [string]: number },
	ProcessedPurchases = {} :: { [string]: boolean },
}

export type Data = typeof(TEMPLATE)

local store = ProfileStore.New("PlayerData_v1", TEMPLATE)
local profiles: { [Player]: any } = {}

local PlayerData = {}

local function onPlayerAdded(player: Player)
	local profile = store:StartSessionAsync("Player_" .. player.UserId, {
		Cancel = function()
			return player.Parent ~= Players
		end,
	})
	if profile == nil then
		player:Kick("Não foi possível carregar os teus dados. Tenta novamente.")
		return
	end
	profile:AddUserId(player.UserId)
	profile:Reconcile()
	profile.OnSessionEnd:Connect(function()
		profiles[player] = nil
		player:Kick("Sessão de dados terminada. Volta a entrar.")
	end)
	if player.Parent == Players then
		profiles[player] = profile
	else
		profile:EndSession()
	end
end

local function onPlayerRemoving(player: Player)
	local profile = profiles[player]
	if profile then
		profile:EndSession()
	end
end

function PlayerData.Init()
	Players.PlayerAdded:Connect(onPlayerAdded)
	Players.PlayerRemoving:Connect(onPlayerRemoving)
	for _, player in Players:GetPlayers() do
		task.spawn(onPlayerAdded, player)
	end
end

function PlayerData.Get(player: Player): Data?
	local profile = profiles[player]
	return profile and profile.Data
end

-- Grava imediatamente. Devolve true se correu bem.
function PlayerData.Save(player: Player): boolean
	local profile = profiles[player]
	if not profile then
		return false
	end
	local ok = pcall(function()
		profile:Save()
	end)
	return ok
end

return PlayerData
