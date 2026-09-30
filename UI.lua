--[[
    🔥 Simple UI Library for Roblox Executor
    Features: Tab | Section | Co1 / Co2 (Left & Right) | Button | Dropdown | Toggle
    Made for Exploit / Executor scripts
]]

local Library = {}
local TweenService = game:GetService("TweenService")
local UserInputService = game:GetService("UserInputService")
local CoreGui = game:GetService("CoreGui")

-- Theme
local Theme = {
    Background = Color3.fromRGB(20, 20, 25),
    Secondary = Color3.fromRGB(30, 30, 38),
    Accent = Color3.fromRGB(0, 170, 255),
    Text = Color3.fromRGB(255, 255, 255),
    TextDark = Color3.fromRGB(160, 160, 170),
    ToggleOn = Color3.fromRGB(0, 170, 255),
    ToggleOff = Color3.fromRGB(50, 50, 60),
    Button = Color3.fromRGB(40, 40, 50),
    ButtonHover = Color3.fromRGB(55, 55, 70),
}

local function Create(class, props)
    local obj = Instance.new(class)
    for i, v in pairs(props) do
        obj[i] = v
    end
    return obj
end

local function Tween(obj, props, time)
    TweenService:Create(obj, TweenInfo.new(time or 0.2, Enum.EasingStyle.Quad), props):Play()
end

function Library:CreateWindow(title)
    local ScreenGui = Create("ScreenGui", {
        Name = "UILib_" .. math.random(1000, 9999),
        Parent = CoreGui,
        ZIndexBehavior = Enum.ZIndexBehavior.Sibling,
        ResetOnSpawn = false
    })

    local Main = Create("Frame", {
        Name = "Main",
        Parent = ScreenGui,
        BackgroundColor3 = Theme.Background,
        BorderSizePixel = 0,
        Position = UDim2.new(0.5, -275, 0.5, -200),
        Size = UDim2.new(0, 550, 0, 400),
        ClipsDescendants = true
    })

    Create("UICorner", {CornerRadius = UDim.new(0, 8), Parent = Main})

    -- Title Bar
    local TitleBar = Create("Frame", {
        Name = "TitleBar",
        Parent = Main,
        BackgroundColor3 = Theme.Secondary,
        BorderSizePixel = 0,
        Size = UDim2.new(1, 0, 0, 35)
    })

    Create("UICorner", {CornerRadius = UDim.new(0, 8), Parent = TitleBar})

    local TitleText = Create("TextLabel", {
        Parent = TitleBar,
        BackgroundTransparency = 1,
        Position = UDim2.new(0, 15, 0, 0),
        Size = UDim2.new(1, -50, 1, 0),
        Font = Enum.Font.GothamBold,
        Text = title or "UI Library",
        TextColor3 = Theme.Text,
        TextSize = 15,
        TextXAlignment = Enum.TextXAlignment.Left
    })

    -- Close Button
    local CloseBtn = Create("TextButton", {
        Parent = TitleBar,
        BackgroundTransparency = 1,
        Position = UDim2.new(1, -35, 0, 0),
        Size = UDim2.new(0, 35, 1, 0),
        Font = Enum.Font.GothamBold,
        Text = "X",
        TextColor3 = Theme.TextDark,
        TextSize = 16
    })

    CloseBtn.MouseButton1Click:Connect(function()
        ScreenGui:Destroy()
    end)

    -- Dragging
    local dragging, dragStart, startPos
    TitleBar.InputBegan:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 then
            dragging = true
            dragStart = input.Position
            startPos = Main.Position
        end
    end)
    TitleBar.InputEnded:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 then
            dragging = false
        end
    end)
    UserInputService.InputChanged:Connect(function(input)
        if dragging and input.UserInputType == Enum.UserInputType.MouseMovement then
            local delta = input.Position - dragStart
            Main.Position = UDim2.new(startPos.X.Scale, startPos.X.Offset + delta.X, startPos.Y.Scale, startPos.Y.Offset + delta.Y)
        end
    end)

    -- Tab Container
    local TabContainer = Create("Frame", {
        Parent = Main,
        BackgroundTransparency = 1,
        Position = UDim2.new(0, 0, 0, 35),
        Size = UDim2.new(0, 130, 1, -35)
    })

    local TabList = Create("ScrollingFrame", {
        Parent = TabContainer,
        BackgroundTransparency = 1,
        Size = UDim2.new(1, 0, 1, 0),
        CanvasSize = UDim2.new(0, 0, 0, 0),
        ScrollBarThickness = 3,
        ScrollBarImageColor3 = Theme.Accent,
        BorderSizePixel = 0
    })

    Create("UIListLayout", {
        Parent = TabList,
        SortOrder = Enum.SortOrder.LayoutOrder,
        Padding = UDim.new(0, 4)
    })

    Create("UIPadding", {
        Parent = TabList,
        PaddingTop = UDim.new(0, 8),
        PaddingLeft = UDim.new(0, 8),
        PaddingRight = UDim.new(0, 8)
    })

    -- Content Area
    local Content = Create("Frame", {
        Parent = Main,
        BackgroundTransparency = 1,
        Position = UDim2.new(0, 130, 0, 35),
        Size = UDim2.new(1, -130, 1, -35)
    })

    local Tabs = {}
    local CurrentTab = nil

    local Window = {}

    function Window:CreateTab(name)
        local TabBtn = Create("TextButton", {
            Parent = TabList,
            BackgroundColor3 = Theme.Secondary,
            BorderSizePixel = 0,
            Size = UDim2.new(1, 0, 0, 32),
            Font = Enum.Font.Gotham,
            Text = name,
            TextColor3 = Theme.TextDark,
            TextSize = 13,
            AutoButtonColor = false
        })
        Create("UICorner", {CornerRadius = UDim.new(0, 6), Parent = TabBtn})

        local TabPage = Create("Frame", {
            Parent = Content,
            BackgroundTransparency = 1,
            Size = UDim2.new(1, 0, 1, 0),
            Visible = false
        })

        -- Left Column (Co1)
        local Co1 = Create("ScrollingFrame", {
            Parent = TabPage,
            BackgroundTransparency = 1,
            Position = UDim2.new(0, 0, 0, 0),
            Size = UDim2.new(0.5, -5, 1, 0),
            CanvasSize = UDim2.new(0, 0, 0, 0),
            ScrollBarThickness = 3,
            ScrollBarImageColor3 = Theme.Accent,
            BorderSizePixel = 0
        })
        Create("UIListLayout", {
            Parent = Co1,
            SortOrder = Enum.SortOrder.LayoutOrder,
            Padding = UDim.new(0, 8)
        })
        Create("UIPadding", {
            Parent = Co1,
            PaddingTop = UDim.new(0, 10),
            PaddingLeft = UDim.new(0, 10),
            PaddingRight = UDim.new(0, 5),
            PaddingBottom = UDim.new(0, 10)
        })

        -- Right Column (Co2)
        local Co2 = Create("ScrollingFrame", {
            Parent = TabPage,
            BackgroundTransparency = 1,
            Position = UDim2.new(0.5, 5, 0, 0),
            Size = UDim2.new(0.5, -10, 1, 0),
            CanvasSize = UDim2.new(0, 0, 0, 0),
            ScrollBarThickness = 3,
            ScrollBarImageColor3 = Theme.Accent,
            BorderSizePixel = 0
        })
        Create("UIListLayout", {
            Parent = Co2,
            SortOrder = Enum.SortOrder.LayoutOrder,
            Padding = UDim.new(0, 8)
        })
        Create("UIPadding", {
            Parent = Co2,
            PaddingTop = UDim.new(0, 10),
            PaddingLeft = UDim.new(0, 5),
            PaddingRight = UDim.new(0, 10),
            PaddingBottom = UDim.new(0, 10)
        })

        -- Auto canvas size
        local function UpdateCanvas(sf)
            local layout = sf:FindFirstChildOfClass("UIListLayout")
            if layout then
                sf.CanvasSize = UDim2.new(0, 0, 0, layout.AbsoluteContentSize.Y + 20)
            end
        end
        Co1:FindFirstChildOfClass("UIListLayout"):GetPropertyChangedSignal("AbsoluteContentSize"):Connect(function()
            UpdateCanvas(Co1)
        end)
        Co2:FindFirstChildOfClass("UIListLayout"):GetPropertyChangedSignal("AbsoluteContentSize"):Connect(function()
            UpdateCanvas(Co2)
        end)

        local Tab = {
            Co1 = Co1,
            Co2 = Co2,
            Page = TabPage
        }

        TabBtn.MouseButton1Click:Connect(function()
            if CurrentTab then
                CurrentTab.Page.Visible = false
                for _, btn in pairs(Tabs) do
                    btn.Button.BackgroundColor3 = Theme.Secondary
                    btn.Button.TextColor3 = Theme.TextDark
                end
            end
            TabPage.Visible = true
            TabBtn.BackgroundColor3 = Theme.Accent
            TabBtn.TextColor3 = Theme.Text
            CurrentTab = Tab
        end)

        table.insert(Tabs, {Button = TabBtn, Page = TabPage})

        -- Select first tab
        if #Tabs == 1 then
            TabPage.Visible = true
            TabBtn.BackgroundColor3 = Theme.Accent
            TabBtn.TextColor3 = Theme.Text
            CurrentTab = Tab
        end

        TabList.CanvasSize = UDim2.new(0, 0, 0, TabList:FindFirstChildOfClass("UIListLayout").AbsoluteContentSize.Y + 16)

        -- Section function
        function Tab:CreateSection(name, column)
            column = column or "Co1"
            local parent = (column == "Co2") and Co2 or Co1

            local Section = Create("Frame", {
                Parent = parent,
                BackgroundColor3 = Theme.Secondary,
                BorderSizePixel = 0,
                Size = UDim2.new(1, 0, 0, 40) -- will resize
            })
            Create("UICorner", {CornerRadius = UDim.new(0, 6), Parent = Section})

            local SectionTitle = Create("TextLabel", {
                Parent = Section,
                BackgroundTransparency = 1,
                Position = UDim2.new(0, 10, 0, 5),
                Size = UDim2.new(1, -20, 0, 20),
                Font = Enum.Font.GothamBold,
                Text = name,
                TextColor3 = Theme.Accent,
                TextSize = 13,
                TextXAlignment = Enum.TextXAlignment.Left
            })

            local SectionContent = Create("Frame", {
                Parent = Section,
                BackgroundTransparency = 1,
                Position = UDim2.new(0, 0, 0, 28),
                Size = UDim2.new(1, 0, 0, 0)
            })
            Create("UIListLayout", {
                Parent = SectionContent,
                SortOrder = Enum.SortOrder.LayoutOrder,
                Padding = UDim.new(0, 6)
            })
            Create("UIPadding", {
                Parent = SectionContent,
                PaddingLeft = UDim.new(0, 10),
                PaddingRight = UDim.new(0, 10),
                PaddingBottom = UDim.new(0, 10)
            })

            local function ResizeSection()
                local layout = SectionContent:FindFirstChildOfClass("UIListLayout")
                local height = layout.AbsoluteContentSize.Y + 38
                Section.Size = UDim2.new(1, 0, 0, height)
                SectionContent.Size = UDim2.new(1, 0, 0, layout.AbsoluteContentSize.Y + 10)
            end
            SectionContent:FindFirstChildOfClass("UIListLayout"):GetPropertyChangedSignal("AbsoluteContentSize"):Connect(ResizeSection)

            local Sec = {}

            -- Button
            function Sec:CreateButton(text, callback)
                local Btn = Create("TextButton", {
                    Parent = SectionContent,
                    BackgroundColor3 = Theme.Button,
                    BorderSizePixel = 0,
                    Size = UDim2.new(1, 0, 0, 30),
                    Font = Enum.Font.Gotham,
                    Text = text,
                    TextColor3 = Theme.Text,
                    TextSize = 13,
                    AutoButtonColor = false
                })
                Create("UICorner", {CornerRadius = UDim.new(0, 5), Parent = Btn})

                Btn.MouseEnter:Connect(function()
                    Tween(Btn, {BackgroundColor3 = Theme.ButtonHover})
                end)
                Btn.MouseLeave:Connect(function()
                    Tween(Btn, {BackgroundColor3 = Theme.Button})
                end)
                Btn.MouseButton1Click:Connect(function()
                    if callback then callback() end
                end)
                return Btn
            end

            -- Toggle
            function Sec:CreateToggle(text, default, callback)
                default = default or false
                local state = default

                local ToggleFrame = Create("Frame", {
                    Parent = SectionContent,
                    BackgroundTransparency = 1,
                    Size = UDim2.new(1, 0, 0, 28)
                })

                local Label = Create("TextLabel", {
                    Parent = ToggleFrame,
                    BackgroundTransparency = 1,
                    Position = UDim2.new(0, 0, 0, 0),
                    Size = UDim2.new(1, -50, 1, 0),
                    Font = Enum.Font.Gotham,
                    Text = text,
                    TextColor3 = Theme.Text,
                    TextSize = 13,
                    TextXAlignment = Enum.TextXAlignment.Left
                })

                local ToggleBtn = Create("Frame", {
                    Parent = ToggleFrame,
                    BackgroundColor3 = state and Theme.ToggleOn or Theme.ToggleOff,
                    Position = UDim2.new(1, -42, 0.5, -10),
                    Size = UDim2.new(0, 40, 0, 20)
                })
                Create("UICorner", {CornerRadius = UDim.new(1, 0), Parent = ToggleBtn})

                local Circle = Create("Frame", {
                    Parent = ToggleBtn,
                    BackgroundColor3 = Color3.fromRGB(255, 255, 255),
                    Position = state and UDim2.new(1, -18, 0.5, -8) or UDim2.new(0, 2, 0.5, -8),
                    Size = UDim2.new(0, 16, 0, 16)
                })
                Create("UICorner", {CornerRadius = UDim.new(1, 0), Parent = Circle})

                local Click = Create("TextButton", {
                    Parent = ToggleFrame,
                    BackgroundTransparency = 1,
                    Size = UDim2.new(1, 0, 1, 0),
                    Text = ""
                })

                Click.MouseButton1Click:Connect(function()
                    state = not state
                    Tween(ToggleBtn, {BackgroundColor3 = state and Theme.ToggleOn or Theme.ToggleOff})
                    Tween(Circle, {Position = state and UDim2.new(1, -18, 0.5, -8) or UDim2.new(0, 2, 0.5, -8)})
                    if callback then callback(state) end
                end)

                return {
                    Set = function(val)
                        state = val
                        Tween(ToggleBtn, {BackgroundColor3 = state and Theme.ToggleOn or Theme.ToggleOff})
                        Tween(Circle, {Position = state and UDim2.new(1, -18, 0.5, -8) or UDim2.new(0, 2, 0.5, -8)})
                    end,
                    Get = function() return state end
                }
            end

            -- Dropdown
            function Sec:CreateDropdown(text, options, callback)
                options = options or {"Option 1", "Option 2"}
                local selected = options[1]
                local open = false

                local DropFrame = Create("Frame", {
                    Parent = SectionContent,
                    BackgroundTransparency = 1,
                    Size = UDim2.new(1, 0, 0, 30),
                    ClipsDescendants = false
                })

                local DropBtn = Create("TextButton", {
                    Parent = DropFrame,
                    BackgroundColor3 = Theme.Button,
                    BorderSizePixel = 0,
                    Size = UDim2.new(1, 0, 0, 30),
                    Font = Enum.Font.Gotham,
                    Text = text .. ": " .. selected,
                    TextColor3 = Theme.Text,
                    TextSize = 13,
                    AutoButtonColor = false
                })
                Create("UICorner", {CornerRadius = UDim.new(0, 5), Parent = DropBtn})

                local Arrow = Create("TextLabel", {
                    Parent = DropBtn,
                    BackgroundTransparency = 1,
                    Position = UDim2.new(1, -25, 0, 0),
                    Size = UDim2.new(0, 20, 1, 0),
                    Font = Enum.Font.GothamBold,
                    Text = "▼",
                    TextColor3 = Theme.TextDark,
                    TextSize = 10
                })

                local DropList = Create("Frame", {
                    Parent = DropFrame,
                    BackgroundColor3 = Theme.Secondary,
                    BorderSizePixel = 0,
                    Position = UDim2.new(0, 0, 0, 34),
                    Size = UDim2.new(1, 0, 0, 0),
                    Visible = false,
                    ZIndex = 10,
                    ClipsDescendants = true
                })
                Create("UICorner", {CornerRadius = UDim.new(0, 5), Parent = DropList})
                Create("UIListLayout", {
                    Parent = DropList,
                    SortOrder = Enum.SortOrder.LayoutOrder,
                    Padding = UDim.new(0, 2)
                })

                for _, opt in ipairs(options) do
                    local OptBtn = Create("TextButton", {
                        Parent = DropList,
                        BackgroundColor3 = Theme.Button,
                        BorderSizePixel = 0,
                        Size = UDim2.new(1, 0, 0, 26),
                        Font = Enum.Font.Gotham,
                        Text = opt,
                        TextColor3 = Theme.Text,
                        TextSize = 12,
                        AutoButtonColor = false,
                        ZIndex = 11
                    })
                    Create("UICorner", {CornerRadius = UDim.new(0, 4), Parent = OptBtn})

                    OptBtn.MouseEnter:Connect(function()
                        Tween(OptBtn, {BackgroundColor3 = Theme.ButtonHover})
                    end)
                    OptBtn.MouseLeave:Connect(function()
                        Tween(OptBtn, {BackgroundColor3 = Theme.Button})
                    end)
                    OptBtn.MouseButton1Click:Connect(function()
                        selected = opt
                        DropBtn.Text = text .. ": " .. selected
                        open = false
                        DropList.Visible = false
                        DropList.Size = UDim2.new(1, 0, 0, 0)
                        Arrow.Text = "▼"
                        if callback then callback(selected) end
                    end)
                end

                DropBtn.MouseButton1Click:Connect(function()
                    open = not open
                    if open then
                        DropList.Visible = true
                        local h = #options * 28
                        Tween(DropList, {Size = UDim2.new(1, 0, 0, h)}, 0.15)
                        Arrow.Text = "▲"
                    else
                        Tween(DropList, {Size = UDim2.new(1, 0, 0, 0)}, 0.15)
                        task.delay(0.15, function()
                            DropList.Visible = false
                        end)
                        Arrow.Text = "▼"
                    end
                end)

                return {
                    Set = function(val)
                        selected = val
                        DropBtn.Text = text .. ": " .. selected
                    end,
                    Get = function() return selected end
                }
            end

            return Sec
        end

        return Tab
    end

    return Window
end

return Library
