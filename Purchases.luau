--!strict
-- Compras: só via ProcessReceipt. Idempotente. Grava ANTES de devolver PurchaseGranted.

local MarketplaceService = game:GetService("MarketplaceService")
local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")

local Config = require(ReplicatedStorage.Shared.Config)
local PlayerData = require(script.Parent.PlayerData)

local Purchases = {}

local function processReceipt(receiptInfo: { [string]: any }): Enum.ProductPurchaseDecision
	local player = Players:GetPlayerByUserId(receiptInfo.PlayerId)
	if not player then
		return Enum.ProductPurchaseDecision.NotProcessedYet
	end

	local data = PlayerData.Get(player)
	if not data then
		return Enum.ProductPurchaseDecision.NotProcessedYet
	end

	local purchaseId = tostring(receiptInfo.PurchaseId)
	if data.ProcessedPurchases[purchaseId] then
		return Enum.ProductPurchaseDecision.PurchaseGranted -- já concedido (idempotente)
	end

	local product = Config.Products[receiptInfo.ProductId]
	if not product then
		warn("Produto desconhecido:", receiptInfo.ProductId)
		return Enum.ProductPurchaseDecision.NotProcessedYet
	end

	-- 1) conceder
	data.Coins = math.min(data.Coins + product.Coins, Config.Economy.MaxCoins)
	data.ProcessedPurchases[purchaseId] = true

	-- 2) gravar
	if not PlayerData.Save(player) then
		-- 3) reverter se falhar
		data.Coins -= product.Coins
		data.ProcessedPurchases[purchaseId] = nil
		return Enum.ProductPurchaseDecision.NotProcessedYet
	end

	-- 4) só agora confirmar
	return Enum.ProductPurchaseDecision.PurchaseGranted
end

function Purchases.Init()
	MarketplaceService.ProcessReceipt = processReceipt
end

return Purchases
