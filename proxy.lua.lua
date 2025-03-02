local gameId = 417267366
local teleportDelay = 1.5
local messageDelay = 1.5
local waitBeforeRejoin = 3

local messages = {
    "/syrup | 1",
    "/syrup | 2",
    "/syrup | 3",
    "/syrup | 4",
    "/syrup | 5",
    "/syrup | 6",
    "/syrup | 7",
    "/syrup | 8",
    "/syrup | 9",
    "/syrup | 10",
    "/syrup | 11",
    "/syrup | 12",
    "/syrup | 13"
}

local TeleportService = game:GetService("TeleportService")
local HttpService = game:GetService("HttpService")

repeat wait() until game.Players.LocalPlayer
local player = game.Players.LocalPlayer

function waitForCharacter()
    while not player.Character or not player.Character:FindFirstChild("HumanoidRootPart") do
        player.CharacterAdded:Wait()
        wait(1)
    end
end

function spamChat()
    task.spawn(function()
        while true do
            for _, msg in ipairs(messages) do
                game:GetService("ReplicatedStorage").DefaultChatSystemChatEvents.SayMessageRequest:FireServer(msg, "All")
                wait(messageDelay)
            end
        end
    end)
end

function followPlayers()
    local players = game:GetService("Players"):GetPlayers()

    for _, targetPlayer in pairs(players) do
        if targetPlayer ~= player and targetPlayer.Character and targetPlayer.Character:FindFirstChild("HumanoidRootPart") then
            local target = targetPlayer.Character.HumanoidRootPart

            for i = 1, 15 do
                if target and player.Character and player.Character:FindFirstChild("HumanoidRootPart") then
                    player.Character.HumanoidRootPart.CFrame = target.CFrame
                end
                wait(0.1)
            end
        end
    end
end

function joinDifferentServer()
    local success, response = pcall(function()
        return HttpService:JSONDecode(game:HttpGet("https://games.roblox.com/v1/games/" .. gameId .. "/servers/Public?sortOrder=Asc&limit=100"))
    end)

    if not success or not response or not response.data then
        warn("Failed to fetch server list. Retrying in 5 seconds...")
        wait(5)
        return joinDifferentServer()
    end

    for _, server in pairs(response.data) do
        if server.id ~= game.JobId and server.playing < server.maxPlayers then
            TeleportService:TeleportToPlaceInstance(gameId, server.id)
            return
        end
    end

    warn("No valid servers found. Retrying in 5 seconds...")
    wait(5)
    return joinDifferentServer()
end

while true do
    waitForCharacter()

    task.spawn(spamChat)
    followPlayers()

    wait(waitBeforeRejoin)
    joinDifferentServer()

    wait(5)
end
