local Loading = Instance.new("ScreenGui")
Loading.Parent = game.Players.LocalPlayer:WaitForChild("PlayerGui")
Loading.Name = "奔跑"

local Frame = Instance.new("Frame")
Frame.Size = UDim2.new(0.3, 0, 0.08, 0)
Frame.Position = UDim2.new(0.5, 0, 0.7, 0)
Frame.AnchorPoint = Vector2.new(0.5, 0.5)
Frame.Parent = Loading

local uiStroke = Instance.new("UIStroke")
uiStroke.Parent = Frame
uiStroke.Color = Color3.fromRGB(0, 0, 0)
uiStroke.Thickness = 4

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
textBox.Text = "100%"
textBox.TextColor3 = Color3.fromRGB(255, 255, 255)
textBox.TextTransparency = 0
textBox.Parent = Bar
textBox.BackgroundTransparency = 1
textBox.TextScaled = true

local uiStroke = Instance.new("UIStroke")
uiStroke.Parent = textBox
uiStroke.Color = Color3.fromRGB(0, 0, 0)
uiStroke.Thickness = 4

local NormalWalkSpeed = 10
local SprintSpeed = 20
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
    textBox.Text = math.floor(Stamina) .. "%"
    Bar.Size = UDim2.new(Stamina / 100, 0, 1, 0)
    
    if Stamina <= 0 and not StaminaDepleted then
        StaminaDepleted = true
        require(game.Players.LocalPlayer.PlayerGui.MainUI.Initiator.Main_Game).caption("You are Exhausted...",true)
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

local function handleContext(name, state, input)
    if state == Enum.UserInputState.Begin then
        sprinting = true
        startSprint()
    else
        sprinting = false
        stopSprint()
    end
end

cas:BindAction("Sprint", handleContext, true, Leftc, RightC)
cas:SetPosition("Sprint", UDim2.new(.2, 0, .5, 0))
cas:SetTitle("Sprint", "Sprint")
cas:GetButton("Sprint").Size = UDim2.new(.3, 0, .3, 0)
