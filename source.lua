--[[
    Raknot UI Library
    v1.0
    by raknot (onys)
    https://github.com/raknot/Raknot-UI
]]

local TweenService = game:GetService("TweenService")
local UserInputService = game:GetService("UserInputService")
local CoreGui = game:GetService("CoreGui")

local RaknotUI = {}
RaknotUI.__index = RaknotUI
RaknotUI.Version = "1.0.2"
RaknotUI.GitHubURL = "https://github.com/raknot/Raknot-UI"

-- Redesigned color theme with better contrast and visual hierarchy
local Themes = {
    Dark = {
        Background = Color3.fromRGB(15, 15, 20),
        Surface = Color3.fromRGB(25, 25, 32),
        SurfaceHover = Color3.fromRGB(35, 35, 45),
        Border = Color3.fromRGB(45, 45, 55),
        Text = Color3.fromRGB(255, 255, 255),
        TextSecondary = Color3.fromRGB(170, 170, 180),
        TextTertiary = Color3.fromRGB(110, 110, 120),
        Hover = Color3.fromRGB(40, 40, 50),
        Active = Color3.fromRGB(50, 50, 65),
        Accent = Color3.fromRGB(88, 166, 255),
        AccentHover = Color3.fromRGB(108, 186, 255),
        SliderTrack = Color3.fromRGB(35, 35, 45),
        SliderFill = Color3.fromRGB(88, 166, 255)
    },
    Light = {
        Background = Color3.fromRGB(250, 250, 252),
        Surface = Color3.fromRGB(255, 255, 255),
        SurfaceHover = Color3.fromRGB(245, 245, 250),
        Border = Color3.fromRGB(225, 225, 235),
        Text = Color3.fromRGB(15, 15, 20),
        TextSecondary = Color3.fromRGB(80, 80, 95),
        TextTertiary = Color3.fromRGB(130, 130, 145),
        Hover = Color3.fromRGB(240, 240, 248),
        Active = Color3.fromRGB(230, 230, 242),
        Accent = Color3.fromRGB(68, 146, 235),
        AccentHover = Color3.fromRGB(88, 166, 255),
        SliderTrack = Color3.fromRGB(220, 220, 230),
        SliderFill = Color3.fromRGB(68, 146, 235)
    }
}

local CurrentTheme = "Dark"
local Theme = Themes[CurrentTheme]
local NotificationContainer = nil
local ActiveNotifications = {}
local MenuKeybind = Enum.KeyCode.RightControl

local function CreateTween(object, properties, duration, style, direction)
    duration = duration or 0.25
    style = style or Enum.EasingStyle.Sine
    direction = direction or Enum.EasingDirection.Out
    local tween = TweenService:Create(object, TweenInfo.new(duration, style, direction), properties)
    tween:Play()
    return tween
end

local function CreateUICorner(radius)
    local corner = Instance.new("UICorner")
    corner.CornerRadius = UDim.new(0, radius or 6)
    return corner
end

local function CreateStroke(color, thickness, transparency)
    local stroke = Instance.new("UIStroke")
    stroke.Color = color or Theme.Border
    stroke.Thickness = thickness or 1
    stroke.Transparency = transparency or 0
    stroke.ApplyStrokeMode = Enum.ApplyStrokeMode.Border
    return stroke
end

function RaknotUI:CreateWindow(config)
    local window = {}
    window.Tabs = {}
    window.CurrentTab = nil
    window.Authenticated = config.Password == nil or config.Password == ""
    window.Password = config.Password
    window.WatermarkEnabled = false
    
    local ScreenGui = Instance.new("ScreenGui")
    ScreenGui.Name = "RaknotUI"
    ScreenGui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
    ScreenGui.DisplayOrder = 200 -- Increased DisplayOrder to 200 to appear above notifications (which use ZIndex 150)
    ScreenGui.ResetOnSpawn = false
    ScreenGui.Parent = CoreGui
    
    -- Store ScreenGui reference in window object for keybind access
    window.ScreenGui = ScreenGui

    -- Starting with transparency 1 for fade-in animation
    local MainFrame = Instance.new("Frame")
    MainFrame.Name = "MainFrame"
    MainFrame.Size = UDim2.new(0, 600, 0, 400)
    MainFrame.Position = UDim2.new(0.5, -300, 0.5, -200)
    MainFrame.BackgroundColor3 = Theme.Background
    MainFrame.BackgroundTransparency = 1
    MainFrame.BorderSizePixel = 0
    MainFrame.ZIndex = 250 -- Increased MainFrame ZIndex to 250 to ensure it appears above notifications (ZIndex 150)
    MainFrame.Parent = ScreenGui
    CreateUICorner(8).Parent = MainFrame
    CreateStroke(Theme.Border, 1, 0.6).Parent = MainFrame
    
    -- Fade-in animation on window open
    CreateTween(MainFrame, {BackgroundTransparency = 0.05}, 0.3, Enum.EasingStyle.Sine, Enum.EasingDirection.Out)
    
    -- Watermark (optional, top left)
    local Watermark = Instance.new("TextLabel")
    Watermark.Size = UDim2.new(0, 200, 0, 24)
    Watermark.Position = UDim2.new(0, 10, 0, 10)
    Watermark.BackgroundColor3 = Theme.Surface
    Watermark.BackgroundTransparency = 0.2
    Watermark.Text = ""
    Watermark.TextColor3 = Theme.Text
    Watermark.TextSize = 11
    Watermark.Font = Enum.Font.GothamBold
    Watermark.TextXAlignment = Enum.TextXAlignment.Center
    Watermark.Visible = false
    Watermark.Parent = ScreenGui
    CreateUICorner(6).Parent = Watermark
    CreateStroke(Theme.Border, 1, 0.4).Parent = Watermark
    
    local TopBar = Instance.new("Frame")
    TopBar.Name = "TopBar"
    TopBar.Size = UDim2.new(1, 0, 0, 28)
    TopBar.BackgroundColor3 = Theme.Surface
    TopBar.BackgroundTransparency = 0.05
    TopBar.BorderSizePixel = 0
    TopBar.Parent = MainFrame
    CreateUICorner(6).Parent = TopBar
    CreateStroke(Theme.Border, 1, 0.4).Parent = TopBar
    
    local TopBarFix = Instance.new("Frame")
    TopBarFix.Size = UDim2.new(1, 0, 0, 6)
    TopBarFix.Position = UDim2.new(0, 0, 1, -6)
    TopBarFix.BackgroundColor3 = Theme.Surface
    TopBarFix.BackgroundTransparency = 0.05
    TopBarFix.BorderSizePixel = 0
    TopBarFix.Parent = TopBar
    
    local TitleLabel = Instance.new("TextLabel")
    TitleLabel.Size = UDim2.new(1, -60, 1, 0)
    TitleLabel.Position = UDim2.new(0, 10, 0, 0)
    TitleLabel.BackgroundTransparency = 1
    TitleLabel.Text = config.Title or "Raknot UI"
    TitleLabel.TextColor3 = Theme.Text
    TitleLabel.TextSize = 12
    TitleLabel.Font = Enum.Font.GothamBold
    TitleLabel.TextXAlignment = Enum.TextXAlignment.Left
    TitleLabel.Parent = TopBar
    
    -- Fixed close button to use simple X instead of unicode symbol
    local CloseBtn = Instance.new("TextButton")
    CloseBtn.Size = UDim2.new(0, 28, 0, 28)
    CloseBtn.Position = UDim2.new(1, -28, 0, 0)
    CloseBtn.BackgroundTransparency = 1
    CloseBtn.Text = "X"
    CloseBtn.TextColor3 = Theme.TextSecondary
    CloseBtn.TextSize = 16
    CloseBtn.Font = Enum.Font.GothamBold
    CloseBtn.Parent = TopBar
    
    -- Added hover effect for close button
    CloseBtn.MouseEnter:Connect(function()
        CreateTween(CloseBtn, {TextColor3 = Color3.fromRGB(255, 80, 80)}, 0.2)
    end)
    CloseBtn.MouseLeave:Connect(function()
        CreateTween(CloseBtn, {TextColor3 = Theme.TextSecondary}, 0.2)
    end)
    
    -- Force close when clicked
    CloseBtn.MouseButton1Click:Connect(function()
        ScreenGui.Enabled = false
    end)
    
    local TabBar = Instance.new("Frame")
    TabBar.Name = "TabBar"
    TabBar.Size = UDim2.new(1, 0, 0, 40)
    TabBar.Position = UDim2.new(0, 0, 0, 28)
    TabBar.BackgroundColor3 = Theme.Surface
    TabBar.BackgroundTransparency = 0.05
    TabBar.BorderSizePixel = 0
    TabBar.Parent = MainFrame
    CreateStroke(Theme.Border, 1, 0.4).Parent = TabBar
    
    local TabBarLayout = Instance.new("UIListLayout")
    TabBarLayout.FillDirection = Enum.FillDirection.Horizontal
    TabBarLayout.HorizontalAlignment = Enum.HorizontalAlignment.Left
    TabBarLayout.SortOrder = Enum.SortOrder.LayoutOrder
    TabBarLayout.Padding = UDim.new(0, 4)
    TabBarLayout.Parent = TabBar
    
    local ContentFrame = Instance.new("Frame")
    ContentFrame.Name = "ContentFrame"
    ContentFrame.Size = UDim2.new(1, -16, 1, -84)
    ContentFrame.Position = UDim2.new(0, 8, 0, 76)
    ContentFrame.BackgroundTransparency = 1
    ContentFrame.BorderSizePixel = 0
    ContentFrame.Parent = MainFrame
    
    -- Dragging
    local dragging, dragInput, dragStart, startPos
    TopBar.InputBegan:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 then
            dragging = true
            dragStart = input.Position
            startPos = MainFrame.Position
            input.Changed:Connect(function()
                if input.UserInputState == Enum.UserInputState.End then
                    dragging = false
                end
            end)
        end
    end)
    TopBar.InputChanged:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseMovement then
            dragInput = input
        end
    end)
    UserInputService.InputChanged:Connect(function(input)
        if input == dragInput and dragging then
            local delta = input.Position - dragStart
            MainFrame.Position = UDim2.new(startPos.X.Scale, startPos.X.Offset + delta.X, startPos.Y.Scale, startPos.Y.Offset + delta.Y)
        end
    end)
    
    -- Fixed menu keybind toggle to use window:ToggleUI function
    UserInputService.InputBegan:Connect(function(input, gameProcessed)
        if input.KeyCode == MenuKeybind and not gameProcessed then
            -- Toggle ScreenGui.Enabled directly using stored reference
            window.ScreenGui.Enabled = not window.ScreenGui.Enabled
        end
    end)
    
    -- Password authentication screen
    if not window.Authenticated then
        local PasswordFrame = Instance.new("Frame")
        PasswordFrame.Size = UDim2.new(0, 300, 0, 150)
        PasswordFrame.Position = UDim2.new(0.5, -150, 0.5, -75)
        PasswordFrame.BackgroundColor3 = Theme.Surface
        PasswordFrame.BorderSizePixel = 0
        PasswordFrame.ZIndex = 200
        PasswordFrame.Parent = ScreenGui
        CreateUICorner(8).Parent = PasswordFrame
        CreateStroke(Theme.Border, 1, 0.4).Parent = PasswordFrame
        
        local PasswordLabel = Instance.new("TextLabel")
        PasswordLabel.Size = UDim2.new(1, 0, 0, 30)
        PasswordLabel.Position = UDim2.new(0, 0, 0, 15)
        PasswordLabel.BackgroundTransparency = 1
        PasswordLabel.Text = "Enter Password"
        PasswordLabel.TextColor3 = Theme.Text
        PasswordLabel.TextSize = 14
        PasswordLabel.Font = Enum.Font.GothamBold
        PasswordLabel.Parent = PasswordFrame
        
        local PasswordBox = Instance.new("TextBox")
        PasswordBox.Size = UDim2.new(1, -40, 0, 36)
        PasswordBox.Position = UDim2.new(0, 20, 0, 55)
        PasswordBox.BackgroundColor3 = Theme.Background
        PasswordBox.BorderSizePixel = 0
        PasswordBox.Text = ""
        PasswordBox.PlaceholderText = "Password"
        PasswordBox.TextColor3 = Theme.Text
        PasswordBox.PlaceholderColor3 = Theme.TextTertiary
        PasswordBox.TextSize = 12
        PasswordBox.Font = Enum.Font.Gotham
        PasswordBox.ClearTextOnFocus = false
        PasswordBox.Parent = PasswordFrame
        CreateUICorner(6).Parent = PasswordBox
        CreateStroke(Theme.Border, 1, 0.4).Parent = PasswordBox
        
        local SubmitBtn = Instance.new("TextButton")
        SubmitBtn.Size = UDim2.new(1, -40, 0, 36)
        SubmitBtn.Position = UDim2.new(0, 20, 0, 100)
        SubmitBtn.BackgroundColor3 = Theme.Accent
        SubmitBtn.BorderSizePixel = 0
        SubmitBtn.Text = "Submit"
        SubmitBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
        SubmitBtn.TextSize = 12
        SubmitBtn.Font = Enum.Font.GothamBold
        SubmitBtn.Parent = PasswordFrame
        CreateUICorner(6).Parent = SubmitBtn
        
        SubmitBtn.MouseButton1Click:Connect(function()
            if PasswordBox.Text == window.Password then
                window.Authenticated = true
                PasswordFrame:Destroy()
                MainFrame.Visible = true
                
                -- Load first user tab after authentication
                for _, tab in ipairs(window.Tabs) do
                    if tab.Name ~= "Settings" then
                        window:SwitchTab(tab.Name)
                        break
                    end
                end
            else
                -- Wrong password shake animation
                for i = 1, 3 do
                    CreateTween(PasswordFrame, {Position = UDim2.new(0.5, -160, 0.5, -75)}, 0.05)
                    task.wait(0.05)
                    CreateTween(PasswordFrame, {Position = UDim2.new(0.5, -140, 0.5, -75)}, 0.05)
                    task.wait(0.05)
                end
                CreateTween(PasswordFrame, {Position = UDim2.new(0.5, -150, 0.5, -75)}, 0.05)
            end
        end)
        
        MainFrame.Visible = false
    end
    
    function window:CreateTab(name, hidden)
        local tab = {}
        tab.Name = name
        tab.Hidden = hidden or false
        
        if not hidden then
            local TabButton = Instance.new("TextButton")
            TabButton.Size = UDim2.new(0, 120, 1, 0)
            TabButton.BackgroundColor3 = Theme.Surface
            TabButton.BackgroundTransparency = 1
            TabButton.BorderSizePixel = 0
            TabButton.Text = name
            TabButton.TextColor3 = Theme.TextSecondary
            TabButton.TextSize = 12
            TabButton.Font = Enum.Font.GothamBold
            -- Settings tab gets highest LayoutOrder to appear on the right
            TabButton.LayoutOrder = (name == "Settings") and 9999 or #window.Tabs
            TabButton.Parent = TabBar
            
            -- Clear hover feedback for tabs
            TabButton.MouseEnter:Connect(function()
                if window.CurrentTab ~= name then
                    CreateTween(TabButton, {BackgroundTransparency = 0, BackgroundColor3 = Theme.Hover}, 0.2)
                end
            end)
            TabButton.MouseLeave:Connect(function()
                if window.CurrentTab ~= name then
                    CreateTween(TabButton, {BackgroundTransparency = 1}, 0.2)
                end
            end)
            
            TabButton.MouseButton1Click:Connect(function()
                window:SwitchTab(name)
            end)
            
            CreateUICorner(6).Parent = TabButton
            tab.Button = TabButton
        end
        
        local TabContent = Instance.new("ScrollingFrame")
        TabContent.Name = name .. "Content"
        TabContent.Size = UDim2.new(1, 0, 1, 0)
        TabContent.Position = UDim2.new(0, 0, 0, 0)
        TabContent.BackgroundTransparency = 1
        TabContent.BorderSizePixel = 0
        TabContent.ScrollBarThickness = 4
        TabContent.ScrollBarImageColor3 = Theme.Border
        TabContent.CanvasSize = UDim2.new(0, 0, 0, 0)
        TabContent.Visible = false
        TabContent.Parent = ContentFrame
        
        local ContentLayout = Instance.new("UIListLayout")
        ContentLayout.FillDirection = Enum.FillDirection.Vertical
        ContentLayout.HorizontalAlignment = Enum.HorizontalAlignment.Left
        ContentLayout.SortOrder = Enum.SortOrder.LayoutOrder
        ContentLayout.Padding = UDim.new(0, 6)
        ContentLayout.Parent = TabContent
        
        ContentLayout:GetPropertyChangedSignal("AbsoluteContentSize"):Connect(function()
            TabContent.CanvasSize = UDim2.new(0, 0, 0, ContentLayout.AbsoluteContentSize.Y + 8)
        end)
        
        tab.Content = TabContent
        
        function tab:AddLabel(text)
            local Label = Instance.new("TextLabel")
            Label.Size = UDim2.new(1, -8, 0, 28)
            Label.BackgroundTransparency = 1
            Label.Text = text
            Label.TextColor3 = Theme.TextTertiary
            Label.TextSize = 12
            Label.Font = Enum.Font.Gotham
            Label.TextXAlignment = Enum.TextXAlignment.Left
            Label.TextWrapped = true
            Label.Parent = TabContent
            return Label
        end
        
        function tab:AddButton(text, callback)
            local Button = Instance.new("TextButton")
            Button.Size = UDim2.new(1, -8, 0, 38)
            Button.BackgroundColor3 = Theme.Surface
            Button.BorderSizePixel = 0
            Button.Text = text
            Button.TextColor3 = Theme.Text
            Button.TextSize = 12
            Button.Font = Enum.Font.GothamBold
            Button.Parent = TabContent
            CreateUICorner(6).Parent = Button
            CreateStroke(Theme.Border, 1, 0.4).Parent = Button
            
            -- Clear hover state for buttons with accent color
            Button.MouseEnter:Connect(function()
                CreateTween(Button, {BackgroundColor3 = Theme.Accent}, 0.2)
                CreateTween(Button, {TextColor3 = Color3.fromRGB(255, 255, 255)}, 0.2)
            end)
            Button.MouseLeave:Connect(function()
                CreateTween(Button, {BackgroundColor3 = Theme.Surface}, 0.2)
                CreateTween(Button, {TextColor3 = Theme.Text}, 0.2)
            end)
            Button.MouseButton1Click:Connect(function()
                CreateTween(Button, {BackgroundColor3 = Theme.AccentHover}, 0.1)
                task.wait(0.1)
                CreateTween(Button, {BackgroundColor3 = Theme.Accent}, 0.1)
                if callback then callback() end
            end)
            
            return Button
        end
        
        function tab:AddToggle(text, default, callback)
            local toggleState = default or false
            
            local ToggleFrame = Instance.new("Frame")
            ToggleFrame.Size = UDim2.new(1, -8, 0, 38)
            ToggleFrame.BackgroundColor3 = Theme.Surface
            ToggleFrame.BorderSizePixel = 0
            ToggleFrame.Parent = TabContent
            CreateUICorner(6).Parent = ToggleFrame
            CreateStroke(Theme.Border, 1, 0.4).Parent = ToggleFrame
            
            -- Hover feedback on toggle frame
            ToggleFrame.MouseEnter:Connect(function()
                CreateTween(ToggleFrame, {BackgroundColor3 = Theme.SurfaceHover}, 0.2)
            end)
            ToggleFrame.MouseLeave:Connect(function()
                CreateTween(ToggleFrame, {BackgroundColor3 = Theme.Surface}, 0.2)
            end)
            
            local ToggleLabel = Instance.new("TextLabel")
            ToggleLabel.Size = UDim2.new(1, -60, 1, 0)
            ToggleLabel.Position = UDim2.new(0, 12, 0, 0)
            ToggleLabel.BackgroundTransparency = 1
            ToggleLabel.Text = text
            ToggleLabel.TextColor3 = Theme.Text
            ToggleLabel.TextSize = 12
            ToggleLabel.Font = Enum.Font.Gotham
            ToggleLabel.TextXAlignment = Enum.TextXAlignment.Left
            ToggleLabel.Parent = ToggleFrame
            
            local ToggleButton = Instance.new("TextButton")
            ToggleButton.Size = UDim2.new(0, 44, 0, 22)
            ToggleButton.Position = UDim2.new(1, -52, 0.5, -11)
            ToggleButton.BackgroundColor3 = toggleState and Theme.Accent or Theme.Active
            ToggleButton.BorderSizePixel = 0
            ToggleButton.Text = ""
            ToggleButton.Parent = ToggleFrame
            CreateUICorner(11).Parent = ToggleButton
            
            local ToggleCircle = Instance.new("Frame")
            ToggleCircle.Size = UDim2.new(0, 18, 0, 18)
            ToggleCircle.Position = toggleState and UDim2.new(1, -20, 0.5, -9) or UDim2.new(0, 2, 0.5, -9)
            ToggleCircle.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
            ToggleCircle.BorderSizePixel = 0
            ToggleCircle.Parent = ToggleButton
            CreateUICorner(9).Parent = ToggleCircle
            
            ToggleButton.MouseButton1Click:Connect(function()
                toggleState = not toggleState
                CreateTween(ToggleCircle, {Position = toggleState and UDim2.new(1, -20, 0.5, -9) or UDim2.new(0, 2, 0.5, -9)}, 0.2, Enum.EasingStyle.Back)
                CreateTween(ToggleButton, {BackgroundColor3 = toggleState and Theme.Accent or Theme.Active}, 0.2)
                if callback then callback(toggleState) end
            end)
            
            return ToggleFrame
        end
        
        function tab:AddSlider(text, min, max, default, callback)
            local sliderValue = default or min
            local draggingSlider = false
            
            local SliderFrame = Instance.new("Frame")
            SliderFrame.Size = UDim2.new(1, -8, 0, 52)
            SliderFrame.BackgroundColor3 = Theme.Surface
            SliderFrame.BorderSizePixel = 0
            SliderFrame.Parent = TabContent
            CreateUICorner(6).Parent = SliderFrame
            CreateStroke(Theme.Border, 1, 0.4).Parent = SliderFrame
            
            -- Hover feedback on slider frame
            SliderFrame.MouseEnter:Connect(function()
                CreateTween(SliderFrame, {BackgroundColor3 = Theme.SurfaceHover}, 0.2)
            end)
            SliderFrame.MouseLeave:Connect(function()
                if not draggingSlider then
                    CreateTween(SliderFrame, {BackgroundColor3 = Theme.Surface}, 0.2)
                end
            end)
            
            local SliderLabel = Instance.new("TextLabel")
            SliderLabel.Size = UDim2.new(0, 120, 0, 20)
            SliderLabel.Position = UDim2.new(0, 12, 0, 8)
            SliderLabel.BackgroundTransparency = 1
            SliderLabel.Text = text
            SliderLabel.TextColor3 = Theme.Text
            SliderLabel.TextSize = 12
            SliderLabel.Font = Enum.Font.Gotham
            SliderLabel.TextXAlignment = Enum.TextXAlignment.Left
            SliderLabel.Parent = SliderFrame
            
            local ValueLabel = Instance.new("TextLabel")
            ValueLabel.Size = UDim2.new(0, 40, 0, 20)
            ValueLabel.Position = UDim2.new(1, -50, 0, 8)
            ValueLabel.BackgroundTransparency = 1
            ValueLabel.Text = tostring(sliderValue)
            ValueLabel.TextColor3 = Theme.Accent
            ValueLabel.TextSize = 11
            ValueLabel.Font = Enum.Font.GothamBold
            ValueLabel.TextXAlignment = Enum.TextXAlignment.Right
            ValueLabel.Parent = SliderFrame
            
            local SliderTrack = Instance.new("Frame")
            SliderTrack.Size = UDim2.new(1, -24, 0, 6)
            SliderTrack.Position = UDim2.new(0, 12, 1, -18)
            SliderTrack.BackgroundColor3 = Theme.SliderTrack
            SliderTrack.BorderSizePixel = 0
            SliderTrack.Parent = SliderFrame
            CreateUICorner(3).Parent = SliderTrack
            
            local SliderFill = Instance.new("Frame")
            SliderFill.Size = UDim2.new((sliderValue - min) / (max - min), 0, 1, 0)
            SliderFill.BackgroundColor3 = Theme.SliderFill
            SliderFill.BorderSizePixel = 0
            SliderFill.Parent = SliderTrack
            CreateUICorner(3).Parent = SliderFill
            
            -- Animated slider thumb that appears when dragging
            local SliderThumb = Instance.new("Frame")
            SliderThumb.Size = UDim2.new(0, 14, 0, 14)
            SliderThumb.Position = UDim2.new((sliderValue - min) / (max - min), -7, 0.5, -7)
            SliderThumb.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
            SliderThumb.BorderSizePixel = 0
            SliderThumb.BackgroundTransparency = 1
            SliderThumb.Parent = SliderTrack
            CreateUICorner(7).Parent = SliderThumb
            CreateStroke(Theme.Accent, 2, 0).Parent = SliderThumb
            
            local function updateSlider(input)
                local pos = (input.Position.X - SliderTrack.AbsolutePosition.X) / SliderTrack.AbsoluteSize.X
                pos = math.clamp(pos, 0, 1)
                sliderValue = math.floor(min + (max - min) * pos)
                ValueLabel.Text = tostring(sliderValue)
                CreateTween(SliderFill, {Size = UDim2.new(pos, 0, 1, 0)}, 0.1)
                CreateTween(SliderThumb, {Position = UDim2.new(pos, -7, 0.5, -7)}, 0.1)
                if callback then callback(sliderValue) end
            end
            
            SliderTrack.InputBegan:Connect(function(input)
                if input.UserInputType == Enum.UserInputType.MouseButton1 then
                    draggingSlider = true
                    -- Show thumb when dragging
                    CreateTween(SliderThumb, {BackgroundTransparency = 0}, 0.15)
                    CreateTween(SliderFrame, {BackgroundColor3 = Theme.SurfaceHover}, 0.2)
                    updateSlider(input)
                end
            end)
            
            SliderTrack.InputEnded:Connect(function(input)
                if input.UserInputType == Enum.UserInputType.MouseButton1 then
                    draggingSlider = false
                    -- Hide thumb when done
                    CreateTween(SliderThumb, {BackgroundTransparency = 1}, 0.15)
                    CreateTween(SliderFrame, {BackgroundColor3 = Theme.Surface}, 0.2)
                end
            end)
            
            UserInputService.InputChanged:Connect(function(input)
                if draggingSlider and input.UserInputType == Enum.UserInputType.MouseMovement then
                    updateSlider(input)
                end
            end)
            
            return SliderFrame
        end
        
        function tab:AddDropdown(text, options, callback)
            local dropdownOpen = false
            local selectedOption = options[1] or "None"
            
            local DropdownFrame = Instance.new("Frame")
            DropdownFrame.Size = UDim2.new(1, -8, 0, 38)
            DropdownFrame.BackgroundColor3 = Theme.Surface
            DropdownFrame.BorderSizePixel = 0
            DropdownFrame.Parent = TabContent
            CreateUICorner(6).Parent = DropdownFrame
            CreateStroke(Theme.Border, 1, 0.4).Parent = DropdownFrame
            
            -- Hover feedback on dropdown
            DropdownFrame.MouseEnter:Connect(function()
                if not dropdownOpen then
                    CreateTween(DropdownFrame, {BackgroundColor3 = Theme.SurfaceHover}, 0.2)
                end
            end)
            DropdownFrame.MouseLeave:Connect(function()
                if not dropdownOpen then
                    CreateTween(DropdownFrame, {BackgroundColor3 = Theme.Surface}, 0.2)
                end
            end)
            
            local DropdownLabel = Instance.new("TextLabel")
            DropdownLabel.Size = UDim2.new(1, -80, 1, 0)
            DropdownLabel.Position = UDim2.new(0, 12, 0, 0)
            DropdownLabel.BackgroundTransparency = 1
            DropdownLabel.Text = text
            DropdownLabel.TextColor3 = Theme.Text
            DropdownLabel.TextSize = 12
            DropdownLabel.Font = Enum.Font.Gotham
            DropdownLabel.TextXAlignment = Enum.TextXAlignment.Left
            DropdownLabel.Parent = DropdownFrame
            
            -- Fixed dropdown to use simple arrow instead of unicode
            local DropdownButton = Instance.new("TextButton")
            DropdownButton.Size = UDim2.new(0, 60, 0, 28)
            DropdownButton.Position = UDim2.new(1, -68, 0.5, -14)
            DropdownButton.BackgroundColor3 = Theme.Active
            DropdownButton.BorderSizePixel = 0
            DropdownButton.Text = selectedOption
            DropdownButton.TextColor3 = Theme.Text
            DropdownButton.TextSize = 10
            DropdownButton.Font = Enum.Font.Gotham
            DropdownButton.Parent = DropdownFrame
            CreateUICorner(5).Parent = DropdownButton
            
            -- Changed dropdown list parent to ScreenGui for proper layering above all content
            local DropdownList = Instance.new("Frame")
            DropdownList.Size = UDim2.new(0, 120, 0, math.min(#options * 32, 128))
            DropdownList.Position = UDim2.new(0, 0, 0, 0)
            DropdownList.BackgroundColor3 = Theme.Surface
            DropdownList.BorderSizePixel = 0
            DropdownList.Visible = false
            DropdownList.ZIndex = 300
            DropdownList.Parent = window.ScreenGui
            CreateUICorner(6).Parent = DropdownList
            CreateStroke(Theme.Border, 1, 0.4).Parent = DropdownList
            
            local DropdownScroll = Instance.new("ScrollingFrame")
            DropdownScroll.Size = UDim2.new(1, -8, 1, -8)
            DropdownScroll.Position = UDim2.new(0, 4, 0, 4)
            DropdownScroll.BackgroundTransparency = 1
            DropdownScroll.BorderSizePixel = 0
            DropdownScroll.ScrollBarThickness = 4
            DropdownScroll.ScrollBarImageColor3 = Theme.Border
            DropdownScroll.CanvasSize = UDim2.new(0, 0, 0, #options * 32)
            DropdownScroll.Parent = DropdownList
            
            local DropdownLayout = Instance.new("UIListLayout")
            DropdownLayout.FillDirection = Enum.FillDirection.Vertical
            DropdownLayout.SortOrder = Enum.SortOrder.LayoutOrder
            DropdownLayout.Padding = UDim.new(0, 2)
            DropdownLayout.Parent = DropdownScroll
            
            for i, option in ipairs(options) do
                local OptionButton = Instance.new("TextButton")
                OptionButton.Size = UDim2.new(1, 0, 0, 30)
                OptionButton.BackgroundColor3 = Theme.Surface
                OptionButton.BorderSizePixel = 0
                OptionButton.Text = option
                OptionButton.TextColor3 = Theme.Text
                OptionButton.TextSize = 10
                OptionButton.Font = Enum.Font.Gotham
                OptionButton.Parent = DropdownScroll
                
                OptionButton.MouseEnter:Connect(function()
                    CreateTween(OptionButton, {BackgroundColor3 = Theme.Hover}, 0.2)
                end)
                OptionButton.MouseLeave:Connect(function()
                    CreateTween(OptionButton, {BackgroundColor3 = Theme.Surface}, 0.2)
                end)
                
                OptionButton.MouseButton1Click:Connect(function()
                    selectedOption = option
                    -- Removed arrow from button text
                    DropdownButton.Text = selectedOption
                    DropdownList.Visible = false
                    dropdownOpen = false
                    callback(option)
                end)
            end
            
            DropdownButton.MouseButton1Click:Connect(function()
                dropdownOpen = not dropdownOpen
                DropdownList.Visible = dropdownOpen
                
                -- Calculate absolute screen position when dropdown opens
                if dropdownOpen then
                    local absPos = DropdownButton.AbsolutePosition
                    local absSize = DropdownButton.AbsoluteSize
                    DropdownList.Position = UDim2.new(0, absPos.X + absSize.X - 120, 0, absPos.Y + absSize.Y + 4)
                end
                
                DropdownButton.Text = selectedOption
            end)
            
            return DropdownFrame
        end
        
        -- Added textbox component for user text input
        function tab:AddTextbox(text, placeholder, callback)
            local TextboxFrame = Instance.new("Frame")
            TextboxFrame.Size = UDim2.new(1, -8, 0, 38)
            TextboxFrame.BackgroundColor3 = Theme.Surface
            TextboxFrame.BorderSizePixel = 0
            TextboxFrame.Parent = TabContent
            CreateUICorner(6).Parent = TextboxFrame
            CreateStroke(Theme.Border, 1, 0.4).Parent = TextboxFrame
            
            -- Hover feedback on textbox frame
            TextboxFrame.MouseEnter:Connect(function()
                CreateTween(TextboxFrame, {BackgroundColor3 = Theme.SurfaceHover}, 0.2)
            end)
            TextboxFrame.MouseLeave:Connect(function()
                CreateTween(TextboxFrame, {BackgroundColor3 = Theme.Surface}, 0.2)
            end)
            
            local TextboxLabel = Instance.new("TextLabel")
            TextboxLabel.Size = UDim2.new(0, 100, 1, 0)
            TextboxLabel.Position = UDim2.new(0, 12, 0, 0)
            TextboxLabel.BackgroundTransparency = 1
            TextboxLabel.Text = text
            TextboxLabel.TextColor3 = Theme.Text
            TextboxLabel.TextSize = 12
            TextboxLabel.Font = Enum.Font.Gotham
            TextboxLabel.TextXAlignment = Enum.TextXAlignment.Left
            TextboxLabel.Parent = TextboxFrame
            
            local Textbox = Instance.new("TextBox")
            Textbox.Size = UDim2.new(0, 180, 0, 28)
            Textbox.Position = UDim2.new(1, -188, 0.5, -14)
            Textbox.BackgroundColor3 = Theme.Active
            Textbox.BorderSizePixel = 0
            Textbox.Text = ""
            Textbox.PlaceholderText = placeholder or "Enter text..."
            Textbox.PlaceholderColor3 = Color3.fromRGB(100, 100, 100)
            Textbox.TextColor3 = Theme.Text
            Textbox.TextSize = 11
            Textbox.Font = Enum.Font.Gotham
            Textbox.ClearTextOnFocus = false
            Textbox.Parent = TextboxFrame
            CreateUICorner(5).Parent = Textbox
            
            -- Focused state for textbox
            Textbox.Focused:Connect(function()
                CreateTween(Textbox, {BackgroundColor3 = Theme.Hover}, 0.2)
                CreateTween(TextboxFrame, {BackgroundColor3 = Theme.SurfaceHover}, 0.2)
            end)
            
            Textbox.FocusLost:Connect(function(enterPressed)
                CreateTween(Textbox, {BackgroundColor3 = Theme.Active}, 0.2)
                CreateTween(TextboxFrame, {BackgroundColor3 = Theme.Surface}, 0.2)
                if enterPressed and callback then
                    callback(Textbox.Text)
                end
            end)
            
            return TextboxFrame
        end
        
        table.insert(window.Tabs, tab)
        return tab
    end
    
    function window:SwitchTab(name)
        for _, tab in ipairs(window.Tabs) do
            if tab.Button then
                CreateTween(tab.Button, {
                    BackgroundTransparency = tab.Name == name and 0 or 1,
                    BackgroundColor3 = tab.Name == name and Theme.Active or Theme.Surface,
                    TextColor3 = tab.Name == name and Theme.Text or Theme.TextSecondary
                }, 0.2)
            end
            tab.Content.Visible = (tab.Name == name)
        end
        window.CurrentTab = name
    end
    
    -- Repositioned notification container to bottom right
    function window:Notify(title, message, duration)
        if not NotificationContainer then
            NotificationContainer = Instance.new("Frame")
            NotificationContainer.Name = "NotificationContainer"
            NotificationContainer.Size = UDim2.new(0, 300, 1, 0)
            NotificationContainer.AnchorPoint = Vector2.new(1, 1) -- Anchor from bottom right
            NotificationContainer.Position = UDim2.new(1, -10, 1, -10) -- 10 pixels from bottom right corner
            NotificationContainer.BackgroundTransparency = 1
            NotificationContainer.ZIndex = 150
            NotificationContainer.Parent = window.ScreenGui -- Use stored ScreenGui reference
            
            local NotifLayout = Instance.new("UIListLayout")
            NotifLayout.FillDirection = Enum.FillDirection.Vertical
            NotifLayout.VerticalAlignment = Enum.VerticalAlignment.Bottom
            NotifLayout.SortOrder = Enum.SortOrder.LayoutOrder
            NotifLayout.Padding = UDim.new(0, 8)
            NotifLayout.Parent = NotificationContainer
        end
        
        local Notification = Instance.new("Frame")
        Notification.Size = UDim2.new(1, 0, 0, 70)
        Notification.BackgroundColor3 = Theme.Surface
        Notification.BorderSizePixel = 0
        Notification.Parent = NotificationContainer
        CreateUICorner(6).Parent = Notification
        CreateStroke(Theme.Border, 1, 0.4).Parent = Notification
        
        local NotifTitle = Instance.new("TextLabel")
        NotifTitle.Size = UDim2.new(1, -16, 0, 20)
        NotifTitle.Position = UDim2.new(0, 8, 0, 8)
        NotifTitle.BackgroundTransparency = 1
        NotifTitle.Text = title
        NotifTitle.TextColor3 = Theme.Text
        NotifTitle.TextSize = 12
        NotifTitle.Font = Enum.Font.GothamBold
        NotifTitle.TextXAlignment = Enum.TextXAlignment.Left
        NotifTitle.Parent = Notification
        
        local NotifMessage = Instance.new("TextLabel")
        NotifMessage.Size = UDim2.new(1, -16, 0, 34)
        NotifMessage.Position = UDim2.new(0, 8, 0, 28)
        NotifMessage.BackgroundTransparency = 1
        NotifMessage.Text = message
        NotifMessage.TextColor3 = Theme.TextSecondary
        NotifMessage.TextSize = 11
        NotifMessage.Font = Enum.Font.Gotham
        NotifMessage.TextXAlignment = Enum.TextXAlignment.Left
        NotifMessage.TextWrapped = true
        NotifMessage.Parent = Notification
        
        task.delay(duration or 3, function()
            CreateTween(Notification, {BackgroundTransparency = 1}, 0.3)
            for _, child in ipairs(Notification:GetDescendants()) do
                if child:IsA("GuiObject") then
                    CreateTween(child, {BackgroundTransparency = 1, TextTransparency = 1}, 0.3)
                end
            end
            task.wait(0.3)
            Notification:Destroy()
        end)
    end
    
    -- Settings tab always created last and positioned on the right
    local SettingsTab = window:CreateTab("Settings", false)
    
    SettingsTab:AddLabel("Raknot UI v" .. RaknotUI.Version)
    
    -- Moved menu key section before watermark toggle
    local MenuKeyContainer = Instance.new("Frame")
    MenuKeyContainer.Size = UDim2.new(1, -16, 0, 40)
    MenuKeyContainer.BackgroundTransparency = 1
    MenuKeyContainer.Parent = SettingsTab.Content
    
    local MenuKeyLabel = Instance.new("TextLabel")
    MenuKeyLabel.Size = UDim2.new(0, 120, 1, 0)
    MenuKeyLabel.Position = UDim2.new(0, 0, 0, 0)
    MenuKeyLabel.BackgroundTransparency = 1
    MenuKeyLabel.Text = "Menu Key"
    MenuKeyLabel.TextColor3 = Theme.Text
    MenuKeyLabel.TextSize = 12
    MenuKeyLabel.Font = Enum.Font.GothamBold
    MenuKeyLabel.TextXAlignment = Enum.TextXAlignment.Left
    MenuKeyLabel.Parent = MenuKeyContainer
    
    local MenuKeyButton = Instance.new("TextButton")
    MenuKeyButton.Size = UDim2.new(0, 150, 0, 32)
    MenuKeyButton.Position = UDim2.new(1, -150, 0.5, -16)
    MenuKeyButton.BackgroundColor3 = Theme.Surface
    MenuKeyButton.BorderSizePixel = 0
    MenuKeyButton.Text = MenuKeybind.Name
    MenuKeyButton.TextColor3 = Theme.Text
    MenuKeyButton.TextSize = 11
    MenuKeyButton.Font = Enum.Font.GothamBold
    MenuKeyButton.Parent = MenuKeyContainer
    CreateUICorner(6).Parent = MenuKeyButton
    CreateStroke(Theme.Accent, 1, 0.4).Parent = MenuKeyButton
    
    MenuKeyButton.MouseEnter:Connect(function()
        CreateTween(MenuKeyButton, {BackgroundColor3 = Theme.Hover}, 0.2)
    end)
    MenuKeyButton.MouseLeave:Connect(function()
        CreateTween(MenuKeyButton, {BackgroundColor3 = Theme.Surface}, 0.2)
    end)
    
    local listening = false
    MenuKeyButton.MouseButton1Click:Connect(function()
        if listening then return end
        listening = true
        MenuKeyButton.Text = "Press a key..."
        
        local connection
        connection = UserInputService.InputBegan:Connect(function(input, gameProcessed)
            if input.UserInputType == Enum.UserInputType.Keyboard then
                MenuKeybind = input.KeyCode
                MenuKeyButton.Text = input.KeyCode.Name
                listening = false
                connection:Disconnect()
            end
        end)
    end)
    
    -- Watermark toggle now appears after menu key
    SettingsTab:AddToggle("Watermark", false, function(enabled)
        window.WatermarkEnabled = enabled
        Watermark.Visible = enabled
        if enabled then
            spawn(function()
                while window.WatermarkEnabled do
                    local time = os.date("%H:%M:%S")
                    Watermark.Text = "Raknot UI - " .. time
                    task.wait(1)
                end
            end)
        end
    end)
    
    -- Copy GitHub link button
    SettingsTab:AddButton("Copy GitHub Link", function()
        setclipboard("github.com/raknot/Raknot-UI")
        window:Notify("Copied", "GitHub link copied to clipboard", 2)
    end)
    
    -- Load first user tab on open (skip Settings)
    if window.Authenticated then
        for _, tab in ipairs(window.Tabs) do
            if tab.Name ~= "Settings" then
                window:SwitchTab(tab.Name)
                break
            end
        end
    end
    
    return window
end

-- Updated ToggleUI to use stored ScreenGui reference
function RaknotUI:ToggleUI()
    if self.ScreenGui then
        self.ScreenGui.Enabled = not self.ScreenGui.Enabled
    end
end

return RaknotUI
