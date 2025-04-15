local Players = game:GetService("Players")
local UserInputService = game:GetService("UserInputService")
local RunService = game:GetService("RunService")
local TweenService = game:GetService("TweenService")

local player = Players.LocalPlayer
local playerGui = player:WaitForChild("PlayerGui")
local camera = workspace.CurrentCamera
local mouse = player:GetMouse()

-- GUI chính
local screenGui = Instance.new("ScreenGui", playerGui)
screenGui.Name = "DraggableImageGui"
screenGui.ResetOnSpawn = false

-- Ảnh nhỏ (150x150)
local image = Instance.new("ImageLabel")
image.Size = UDim2.new(0, 150, 0, 150)
image.Position = UDim2.new(0.5, -75, 0.3, -75)
image.BackgroundTransparency = 1
image.Image = "rbxassetid://138903157832300"
image.ScaleType = Enum.ScaleType.Fit
image.Parent = screenGui

-- Nút ON/OFF
local button = Instance.new("TextButton")
button.Size = UDim2.new(0, 120, 0, 50)
button.Position = UDim2.new(0.5, -60, 0.7, 0)
button.Text = "ON"
button.BackgroundColor3 = Color3.fromRGB(50, 200, 50)
button.TextScaled = true
button.TextColor3 = Color3.new(1, 1, 1)
button.Font = Enum.Font.SourceSansBold
button.Parent = screenGui

-- Âm thanh tương tác
local interactSound = Instance.new("Sound")
interactSound.SoundId = "rbxassetid://88064838619406"
interactSound.Volume = 1
interactSound.Name = "InteractSound"
interactSound.Parent = screenGui

-- Tween animation
local function playTween(uiElement)
	local tweenInfo = TweenInfo.new(0.25, Enum.EasingStyle.Sine, Enum.EasingDirection.Out)
	local tweenInfoBack = TweenInfo.new(0.25, Enum.EasingStyle.Sine, Enum.EasingDirection.In)

	local grow = TweenService:Create(uiElement, tweenInfo, {
		Size = uiElement.Size + UDim2.new(0, 10, 0, 10)
	})
	local shrink = TweenService:Create(uiElement, tweenInfoBack, {
		Size = uiElement.Size
	})

	grow:Play()
	grow.Completed:Wait()
	shrink:Play()
end

-- Toggle image + animation + sound
button.MouseButton1Click:Connect(function()
	interactSound:Play()
	playTween(button)
	playTween(image)

	image.Visible = not image.Visible
	button.Text = image.Visible and "ON" or "OFF"
	button.BackgroundColor3 = image.Visible and Color3.fromRGB(50, 200, 50) or Color3.fromRGB(200, 50, 50)
end)

-- Frame chứa drag
local frame = Instance.new("ImageButton")
frame.Size = image.Size
frame.Position = image.Position
frame.BackgroundTransparency = 1
frame.Image = ""
frame.Parent = screenGui

image:GetPropertyChangedSignal("Position"):Connect(function()
	frame.Position = image.Position
end)

-- Kéo GUI
local dragging, dragInput, mousePos, framePos

frame.InputBegan:Connect(function(input)
	if input.UserInputType == Enum.UserInputType.MouseButton1 then
		dragging = true
		mousePos = input.Position
		framePos = frame.Position

		interactSound:Play()
		playTween(image)

		input.Changed:Connect(function()
			if input.UserInputState == Enum.UserInputState.End then
				dragging = false
			end
		end)
	end
end)

frame.InputChanged:Connect(function(input)
	if input.UserInputType == Enum.UserInputType.MouseMovement then
		dragInput = input
	end
end)

UserInputService.InputChanged:Connect(function(input)
	if input == dragInput and dragging then
		local delta = input.Position - mousePos
		local newPos = UDim2.new(
			framePos.X.Scale, framePos.X.Offset + delta.X,
			framePos.Y.Scale, framePos.Y.Offset + delta.Y
		)
		frame.Position = newPos
		image.Position = newPos
		button.Position = UDim2.new(newPos.X.Scale, newPos.X.Offset, 0.7, 0)
	end
end)

-- Aimbot
local AimbotKey = Enum.KeyCode.E
local AimbotEnabled = false
local AimPart = "Head"
local AimRadius = 500
local NPCFolder = workspace:WaitForChild("NPCs")

local function GetNearestNPC()
	local closest, shortest = nil, AimRadius
	for _, npc in ipairs(NPCFolder:GetChildren()) do
		local part = npc:FindFirstChild(AimPart)
		if part then
			local screenPoint, onScreen = camera:WorldToViewportPoint(part.Position)
			if onScreen then
				local dist = (Vector2.new(screenPoint.X, screenPoint.Y) - Vector2.new(mouse.X, mouse.Y)).Magnitude
				if dist < shortest then
					shortest = dist
					closest = part
				end
			end
		end
	end
	return closest
end

RunService.RenderStepped:Connect(function()
	if AimbotEnabled then
		local target = GetNearestNPC()
		if target then
			camera.CFrame = CFrame.new(camera.CFrame.Position, target.Position)
		end
	end
end)

UserInputService.InputBegan:Connect(function(input, processed)
	if not processed and input.KeyCode == AimbotKey then
		AimbotEnabled = not AimbotEnabled
		warn("Aimbot NPC: " .. tostring(AimbotEnabled))
	end
end)

-- Âm thanh khởi động script, phát 2 lần
for _ = 1, 2 do
	local loadSound = Instance.new("Sound")
	loadSound.SoundId = "rbxassetid://128428750687426"
	loadSound.Volume = 1
	loadSound.PlayOnRemove = true
	loadSound.Parent = workspace
	loadSound:Destroy()
end
