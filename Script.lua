local Loading = Instance.new("ScreenGui")
Loading.Parent = game.Players.LocalPlayer:WaitForChild("PlayerGui")
Loading.Name = "奔跑"

local Frame = Instance.new("Frame")
Frame.Size = UDim2.new(0.3, 0, 0.04, 0) -- Reduced height for the stamina bar
Frame.Position = UDim2.new(0.5, 0, 0.95, 0) -- Positioned at the bottom center
Frame.AnchorPoint = Vector2.new(0.5, 0.5)
Frame.Parent = Loading

local frameStroke = Instance.new("UIStroke") -- Renamed to avoid conflict with textBox stroke
frameStroke.Parent = Frame
frameStroke.Color = Color3.fromRGB(0, 0, 0)
frameStroke.Thickness = 4

local Bar = Instance.new("Frame")
Bar.Size = UDim2.new(1, 0, 1, 0) -- Full size relative to Frame
Bar.Position = UDim2.new(0, 0, 0, 0)
Bar.BackgroundColor3 = Color3.fromRGB(0, 166, 255)
Bar.Parent = Frame

local textBox = Instance.new("TextLabel")
textBox.Size = UDim2.new(1, 0, 1, 0)
textBox.Position = UDim2.new(0.5, 0, 0.5, 0)
textBox.Font = Enum.Font.Oswald
textBox.AnchorPoint = Vector2.new(0.5, 0.5)
textBox.TextSize = 40
textBox.Text = ""
textBox.TextColor3 = Color3.fromRGB(255, 255, 255)
textBox.TextTransparency = 0
textBox.Parent = Bar
textBox.BackgroundTransparency = 1
textBox.TextScaled = true

local textStroke = Instance.new("UIStroke") -- Renamed to avoid conflict with Frame stroke
textStroke.Parent = textBox
textStroke.Color = Color3.fromRGB(0, 0, 0)
textStroke.Thickness = 4

local sprintButton = Instance.new("TextButton")
sprintButton.Size = UDim2.new(0, 145, 0, 135) -- Width 200 pixels, Height 50 pixels
sprintButton.Position = UDim2.new(1, -2, 1, -2) -- Positioned in the bottom right corner with padding
sprintButton.AnchorPoint = Vector2.new(1, 1)
sprintButton.BackgroundColor3 = Color3.fromRGB(0, 166, 255)
sprintButton.Text = "" -- Text for identification
sprintButton.Parent = Loading

local NormalWalkSpeed = 16
local SprintSpeed = 22
local CameraEffect = true
local Stamina = 100
local StaminaDrain = 10
local StaminaRegen = 5

local cas = game:GetService("ContextActionService")
local Leftc = Enum.KeyCode.LeftControl
local RightC = Enum.KeyCode.RightControl
local player = game:GetService("Players").LocalPlayer
local char = player.Character or player.CharacterAdded:Wait()
local Humanoid = char:WaitForChild("Humanoid")

local Camera = game.Workspace.CurrentCamera
local TweenService = game:GetService("TweenService")
local UIS = game:GetService("UserInputService")

local StaminaDepleted = false

local function updateStamina()
    Bar.Size = UDim2.new(Stamina / 100, 0, 1, 0)
    if Stamina <= 0 and not StaminaDepleted then
        StaminaDepleted = true
        require(game.Players.LocalPlayer.PlayerGui.MainUI.Initiator.Main_Game).caption("You are Exhausted...", true)
    end
end

local function startSprint()
    if Stamina > 0 then
        if CameraEffect == true then
            TweenService:Create(Camera, TweenInfo.new(0.5), {FieldOfView = 90}):Play()
        end
        Humanoid.WalkSpeed = SprintSpeed
    end
end

local function stopSprint()
    if CameraEffect == true then
        TweenService:Create(Camera, TweenInfo.new(0.5), {FieldOfView = 70}):Play()
    end
    Humanoid.WalkSpeed = NormalWalkSpeed
end

local sprinting = false

UIS.InputBegan:Connect(function(key, gameProcessed)
    if gameProcessed then return end
    if key.KeyCode == Enum.KeyCode.LeftShift then
        sprinting = true
        startSprint()
    end
end)

UIS.InputEnded:Connect(function(key, gameProcessed)
    if gameProcessed then return end
    if key.KeyCode == Enum.KeyCode.LeftShift then
        sprinting = false
        stopSprint()
    end
end)

game:GetService("RunService").RenderStepped:Connect(function(deltaTime)
    if sprinting then
        if Stamina > 0 then
            Stamina = Stamina - StaminaDrain * deltaTime
            if Stamina < 0 then
                Stamina = 0
                stopSprint()
            end
        end
    else
        if Stamina < 100 then
            Stamina = Stamina + StaminaRegen * deltaTime
            if Stamina > 100 then
                Stamina = 100
            end
        end
    end
    updateStamina()
end)

sprintButton.MouseButton1Down:Connect(function()
    sprinting = true
    startSprint()
end)

sprintButton.MouseButton1Up:Connect(function()
    sprinting = false
    stopSprint()
end)
