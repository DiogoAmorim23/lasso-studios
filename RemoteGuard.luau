--!strict
-- Validação central para RemoteEvents: tipos, limites, distância e frequência.

local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Config = require(ReplicatedStorage.Shared.Config)

local RemoteGuard = {}

local lastCalls: { [Player]: { [string]: { count: number, window: number } } } = {}

function RemoteGuard.isFiniteNumber(v: any, min: number, max: number): boolean
	return type(v) == "number" and v == v and v >= min and v <= max
end

function RemoteGuard.isString(v: any, maxLen: number): boolean
	return type(v) == "string" and #v > 0 and #v <= maxLen
end

-- Rate limit por jogador e por remote.
function RemoteGuard.rateLimit(player: Player, remoteName: string): boolean
	local now = os.clock()
	local perPlayer = lastCalls[player]
	if not perPlayer then
		perPlayer = {}
		lastCalls[player] = perPlayer
	end
	local entry = perPlayer[remoteName]
	if not entry or now - entry.window >= 1 then
		perPlayer[remoteName] = { count = 1, window = now }
		return true
	end
	entry.count += 1
	return entry.count <= Config.Remotes.MaxActionsPerSecond
end

-- Distância do jogador a uma posição (no servidor).
function RemoteGuard.isNear(player: Player, position: Vector3, maxDistance: number?): boolean
	local root = player.Character and player.Character:FindFirstChild("HumanoidRootPart")
	if not root or not root:IsA("BasePart") then
		return false
	end
	return (root.Position - position).Magnitude <= (maxDistance or Config.Remotes.MaxInteractDistance)
end

function RemoteGuard.cleanup(player: Player)
	lastCalls[player] = nil
end

return RemoteGuard
