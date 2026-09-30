local Library = {}
local TweenService = game:GetService("TweenService")
local UserInputService = game:GetService("UserInputService")
local MarketplaceService = game:GetService("MarketplaceService")
local CoreGui = game:GetService("CoreGui")

-- ==================== DEFAULT THEME ====================
local DefaultTheme = {
    Background     = Color3.fromRGB(15, 15, 20),
    Secondary      = Color3.fromRGB(22, 22, 30),
    Card           = Color3.fromRGB(28, 28, 38),
    Accent         = Color3.fromRGB(0, 180, 255),
    AccentDark     = Color3.fromRGB(0, 120, 180),
    Text           = Color3.fromRGB(245, 245, 250),
    TextDark       = Color3.fromRGB(140, 140, 155),
    TextMuted      = Color3.fromRGB(100, 100, 115),
    Success        = Color3.fromRGB(50, 205, 100),
    Warning        = Color3.fromRGB(255, 180, 50),
    Locked         = Color3.fromRGB(255, 80, 80),
    ToggleOn       = Color3.fromRGB(0, 180, 255),
    ToggleOff      = Color3.fromRGB(45, 45, 58),
    Button         = Color3.fromRGB(35, 35, 48),
    ButtonHover    = Color3.fromRGB(50, 50, 68),
    Stroke         = Color3.fromRGB(40, 40, 55),
}

-- Font ที่รองรับ (ใครก็เปลี่ยนได้)
local Fonts = {
    Gotham       = Enum.Font.Gotham,
    GothamBold   = Enum.Font.GothamBold,
    GothamMedium = Enum.Font.GothamMedium,
    GothamBlack  = Enum.Font.GothamBlack,
    SourceSans   = Enum.Font.SourceSans,
    SourceSansBold = Enum.Font.SourceSansBold,
    Ubuntu       = Enum.Font.Ubuntu,
    Arial        = Enum.Font.Arial,
    ArialBold    = Enum.Font.ArialBold,
    Code         = Enum.Font.Code,
    Fantasy      = Enum.Font.Fantasy,
    Highway      = Enum.Font.Highway,
}

local function Create(class, props)
    local obj = Instance.new(class)
    for i, v in pairs(props or {}) do
        obj[i] = v
    end
    return obj
end

local function Tween(obj, props, time, style)
    TweenService:Create(obj, TweenInfo.new(time or 0.2, style or Enum.EasingStyle.Quad, Enum.EasingDirection.Out), props):Play()
end

local function AddStroke(parent, color, thickness)
    return Create("UIStroke", {
        Parent = parent,
        Color = color or DefaultTheme.Stroke,
        Thickness = thickness or 1,
        ApplyStrokeMode = Enum.ApplyStrokeMode.Border
    })
end

-- ==================== KEY SYSTEM ====================
local ValidKey = nil
local IsUnlocked = false

function Library:SetKey(key)
    ValidKey = tostring(key)
end

function Library:Unlock(key)
    if ValidKey and tostring(key) == ValidKey then
        IsUnlocked = true
        return true
    end
    return false
end

function Library:IsUnlocked()
    return IsUnlocked
end

-- ==================== CREATE WINDOW ====================
function Library:CreateWindow(config)
    config = config or {}

    -- ===== ตั้งค่าที่เปลี่ยนได้ทั้งหมด =====
    local title          = config.Title or "UI Library"
    local placeId        = config.PlaceId or 2753915549

    -- Theme (ใครก็ใส่ของตัวเองได้)
    local Theme = {}
    for k, v in pairs(DefaultTheme) do
        Theme[k] = (config.Theme and config.Theme[k]) or v
    end

    -- Font (ใครก็เปลี่ยนได้)
    local MainFont       = config.Font or Fonts.Gotham
    local BoldFont       = config.BoldFont or Fonts.GothamBold
    local MediumFont     = config.MediumFont or Fonts.GothamMedium

    -- Background (Color / Image / GIF)
    -- config.BackgroundType = "Color" | "Image" | "Gif"
    -- config.BackgroundColor = Color3
    -- config.BackgroundImage = "rbxassetid://123456789"  (รองรับทั้งรูปปกติและ GIF)
    -- config.BackgroundTransparency = 0 ~ 1
    local bgType         = config.BackgroundType or "Color"
    local bgColor        = config.BackgroundColor or Theme.Background
    local bgImage        = config.BackgroundImage or ""
    local bgTransparency = config.BackgroundTransparency or 0

    -- ดึงชื่อเกม
    local gameName = "Unknown Game"
    pcall(function()
        local info = MarketplaceService:GetProductInfo(placeId)
        gameName = info.Name or "Unknown Game"
    end)

    local ScreenGui = Create("ScreenGui", {
        Name = "PremiumUI_" .. math.random(10000, 99999),
        Parent = CoreGui,
        ZIndexBehavior = Enum.ZIndexBehavior.Sibling,
        ResetOnSpawn = false
    })

    -- Main Frame
    local Main = Create("Frame", {
        Name = "Main",
        Parent = ScreenGui,
        BackgroundColor3 = bgColor,
        BackgroundTransparency = (bgType == "Color") and 0 or 1,
        BorderSizePixel = 0,
        Position = UDim2.new(0.5, -300, 0.5, -220),
        Size = UDim2.new(0, 600, 0, 440),
        ClipsDescendants = true
    })
    Create("UICorner", {CornerRadius = UDim.new(0, 12), Parent = Main})
    AddStroke(Main, Theme.Accent, 1.5)

    -- ===== Background Image / GIF =====
    local BgImageLabel = nil
    if bgType == "Image" or bgType == "Gif" then
        BgImageLabel = Create("ImageLabel", {
            Name = "CustomBackground",
            Parent = Main,
            BackgroundTransparency = 1,
            BorderSizePixel = 0,
            Size = UDim2.new(1, 0, 1, 0),
            Image = bgImage,
            ImageTransparency = bgTransparency,
            ScaleType = Enum.ScaleType.Crop,   -- หรือ Fit / Stretch ตามชอบ
            ZIndex = 0
        })
        Create("UICorner", {CornerRadius = UDim.new(0, 12), Parent = BgImageLabel})

        -- ถ้าเป็น GIF (บาง asset รองรับการเล่นอัตโนมัติ)
        if bgType == "Gif" then
            -- Roblox ไม่ได้ play GIF อัตโนมัติทุกตัว
            -- แต่ถ้า asset เป็น animated image จะแสดงได้
            -- ถ้าอยากทำ frame animation เอง บอกได้ จะเพิ่มระบบให้
        end
    end

    -- Shadow
    local Shadow = Create("ImageLabel", {
        Parent = Main,
        BackgroundTransparency = 1,
        Position = UDim2.new(0, -15, 0, -15),
        Size = UDim2.new(1, 30, 1, 30),
        Image = "rbxassetid://6014261993",
        ImageColor3 = Color3.fromRGB(0, 0, 0),
        ImageTransparency = 0.55,
        ScaleType = Enum.ScaleType.Slice,
        SliceCenter = Rect.new(49, 49, 450, 450),
        ZIndex = -1
    })

    -- ===== Title Bar =====
    local TitleBar = Create("Frame", {
        Parent = Main,
        BackgroundColor3 = Theme.Secondary,
        BackgroundTransparency = 0.15,
        BorderSizePixel = 0,
        Size = UDim2.new(1, 0, 0, 42),
        ZIndex = 2
    })
    Create("UICorner", {CornerRadius = UDim.new(0, 12), Parent = TitleBar})
    Create("Frame", {
        Parent = TitleBar,
        BackgroundColor3 = Theme.Secondary,
        BackgroundTransparency = 0.15,
        BorderSizePixel = 0,
        Position = UDim2.new(0, 0, 1, -12),
        Size = UDim2.new(1, 0, 0, 12),
        ZIndex = 2
    })

    local TitleLabel = Create("TextLabel", {
        Parent = TitleBar,
        BackgroundTransparency = 1,
        Position = UDim2.new(0, 16, 0, 0),
        Size = UDim2.new(0.55, 0, 1, 0),
        Font = BoldFont,
        Text = title,
        TextColor3 = Theme.Text,
        TextSize = 16,
        TextXAlignment = Enum.TextXAlignment.Left,
        ZIndex = 3
    })

    local GameLabel = Create("TextLabel", {
        Parent = TitleBar,
        BackgroundTransparency = 1,
        Position = UDim2.new(0.52, 0, 0, 0),
        Size = UDim2.new(0.38, 0, 1, 0),
        Font = MainFont,
        Text = gameName,
        TextColor3 = Theme.TextDark,
        TextSize = 12,
        TextXAlignment = Enum.TextXAlignment.Right,
        TextTruncate = Enum.TextTruncate.AtEnd,
        ZIndex = 3
    })

    local CloseBtn = Create("TextButton", {
        Parent = TitleBar,
        BackgroundTransparency = 1,
        Position = UDim2.new(1, -40, 0, 0),
        Size = UDim2.new(0, 40, 1, 0),
        Font = BoldFont,
        Text = "✕",
        TextColor3 = Theme.TextDark,
        TextSize = 16,
        ZIndex = 3
    })
    CloseBtn.MouseEnter:Connect(function()
        Tween(CloseBtn, {TextColor3 = Theme.Locked})
    end)
    CloseBtn.MouseLeave:Connect(function()
        Tween(CloseBtn, {TextColor3 = Theme.TextDark})
    end)
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

    -- ===== Sidebar =====
    local Sidebar = Create("Frame", {
        Parent = Main,
        BackgroundColor3 = Theme.Secondary,
        BackgroundTransparency = 0.2,
        BorderSizePixel = 0,
        Position = UDim2.new(0, 0, 0, 42),
        Size = UDim2.new(0, 140, 1, -42),
        ZIndex = 2
    })

    local TabList = Create("ScrollingFrame", {
        Parent = Sidebar,
        BackgroundTransparency = 1,
        Size = UDim2.new(1, 0, 1, 0),
        CanvasSize = UDim2.new(0, 0, 0, 0),
        ScrollBarThickness = 2,
        ScrollBarImageColor3 = Theme.Accent,
        BorderSizePixel = 0,
        ZIndex = 2
    })
    Create("UIListLayout", {
        Parent = TabList,
        SortOrder = Enum.SortOrder.LayoutOrder,
        Padding = UDim.new(0, 6)
    })
    Create("UIPadding", {
        Parent = TabList,
        PaddingTop = UDim.new(0, 12),
        PaddingLeft = UDim.new(0, 10),
        PaddingRight = UDim.new(0, 10),
        PaddingBottom = UDim.new(0, 12)
    })

    -- ===== Content =====
    local Content = Create("Frame", {
        Parent = Main,
        BackgroundTransparency = 1,
        Position = UDim2.new(0, 140, 0, 42),
        Size = UDim2.new(1, -140, 1, -42),
        ZIndex = 2
    })

    local Tabs = {}
    local CurrentTab = nil
    local Window = {}

    -- ==================== CREATE TAB ====================
    function Window:CreateTab(name, icon)
        local TabBtn = Create("TextButton", {
            Parent = TabList,
            BackgroundColor3 = Theme.Card,
            BorderSizePixel = 0,
            Size = UDim2.new(1, 0, 0, 36),
            Font = MediumFont,
            Text = (icon and (icon .. "  ") or "") .. name,
            TextColor3 = Theme.TextDark,
            TextSize = 13,
            AutoButtonColor = false,
            ZIndex = 3
        })
        Create("UICorner", {CornerRadius = UDim.new(0, 8), Parent = TabBtn})
        AddStroke(TabBtn, Theme.Stroke, 1)

        local Indicator = Create("Frame", {
            Parent = TabBtn,
            BackgroundColor3 = Theme.Accent,
            BorderSizePixel = 0,
            Position = UDim2.new(0, 0, 0.2, 0),
            Size = UDim2.new(0, 3, 0.6, 0),
            Visible = false,
            ZIndex = 4
        })
        Create("UICorner", {CornerRadius = UDim.new(1, 0), Parent = Indicator})

        local TabPage = Create("Frame", {
            Parent = Content,
            BackgroundTransparency = 1,
            Size = UDim2.new(1, 0, 1, 0),
            Visible = false,
            ZIndex = 2
        })

        -- Co1
        local Co1 = Create("ScrollingFrame", {
            Parent = TabPage,
            BackgroundTransparency = 1,
            Position = UDim2.new(0, 0, 0, 0),
            Size = UDim2.new(0.5, -6, 1, 0),
            CanvasSize = UDim2.new(0, 0, 0, 0),
            ScrollBarThickness = 3,
            ScrollBarImageColor3 = Theme.Accent,
            BorderSizePixel = 0,
            ZIndex = 2
        })
        local Co1Layout = Create("UIListLayout", {
            Parent = Co1,
            SortOrder = Enum.SortOrder.LayoutOrder,
            Padding = UDim.new(0, 10)
        })
        Create("UIPadding", {
            Parent = Co1,
            PaddingTop = UDim.new(0, 12),
            PaddingLeft = UDim.new(0, 12),
            PaddingRight = UDim.new(0, 6),
            PaddingBottom = UDim.new(0, 12)
        })

        -- Co2
        local Co2 = Create("ScrollingFrame", {
            Parent = TabPage,
            BackgroundTransparency = 1,
            Position = UDim2.new(0.5, 6, 0, 0),
            Size = UDim2.new(0.5, -12, 1, 0),
            CanvasSize = UDim2.new(0, 0, 0, 0),
            ScrollBarThickness = 3,
            ScrollBarImageColor3 = Theme.Accent,
            BorderSizePixel = 0,
            ZIndex = 2
        })
        local Co2Layout = Create("UIListLayout", {
            Parent = Co2,
            SortOrder = Enum.SortOrder.LayoutOrder,
            Padding = UDim.new(0, 10)
        })
        Create("UIPadding", {
            Parent = Co2,
            PaddingTop = UDim.new(0, 12),
            PaddingLeft = UDim.new(0, 6),
            PaddingRight = UDim.new(0, 12),
            PaddingBottom = UDim.new(0, 12)
        })

        local function UpdateCanvas(sf, layout)
            sf.CanvasSize = UDim2.new(0, 0, 0, layout.AbsoluteContentSize.Y + 24)
        end
        Co1Layout:GetPropertyChangedSignal("AbsoluteContentSize"):Connect(function()
            UpdateCanvas(Co1, Co1Layout)
        end)
        Co2Layout:GetPropertyChangedSignal("AbsoluteContentSize"):Connect(function()
            UpdateCanvas(Co2, Co2Layout)
        end)

        local Tab = { Co1 = Co1, Co2 = Co2, Page = TabPage }

        local function SelectTab()
            if CurrentTab then
                CurrentTab.Page.Visible = false
                for _, t in pairs(Tabs) do
                    Tween(t.Button, {BackgroundColor3 = Theme.Card, TextColor3 = Theme.TextDark})
                    t.Indicator.Visible = false
                end
            end
            TabPage.Visible = true
            Tween(TabBtn, {BackgroundColor3 = Theme.AccentDark, TextColor3 = Theme.Text})
            Indicator.Visible = true
            CurrentTab = Tab
        end

        TabBtn.MouseButton1Click:Connect(SelectTab)
        TabBtn.MouseEnter:Connect(function()
            if CurrentTab ~= Tab then
                Tween(TabBtn, {BackgroundColor3 = Color3.fromRGB(38, 38, 52)})
            end
        end)
        TabBtn.MouseLeave:Connect(function()
            if CurrentTab ~= Tab then
                Tween(TabBtn, {BackgroundColor3 = Theme.Card})
            end
        end)

        table.insert(Tabs, {Button = TabBtn, Indicator = Indicator, Page = TabPage})
        if #Tabs == 1 then SelectTab() end
        TabList.CanvasSize = UDim2.new(0, 0, 0, TabList:FindFirstChildOfClass("UIListLayout").AbsoluteContentSize.Y + 24)

        -- ==================== CREATE SECTION ====================
        function Tab:CreateSection(name, column, description)
            column = column or "Co1"
            local parent = (column == "Co2") and Co2 or Co1

            local Section = Create("Frame", {
                Parent = parent,
                BackgroundColor3 = Theme.Card,
                BackgroundTransparency = 0.1,
                BorderSizePixel = 0,
                Size = UDim2.new(1, 0, 0, 50),
                ZIndex = 3
            })
            Create("UICorner", {CornerRadius = UDim.new(0, 10), Parent = Section})
            AddStroke(Section, Theme.Stroke, 1)

            local SectionTitle = Create("TextLabel", {
                Parent = Section,
                BackgroundTransparency = 1,
                Position = UDim2.new(0, 12, 0, 8),
                Size = UDim2.new(1, -24, 0, 18),
                Font = BoldFont,
                Text = name,
                TextColor3 = Theme.Accent,
                TextSize = 13,
                TextXAlignment = Enum.TextXAlignment.Left,
                ZIndex = 4
            })

            local descHeight = 0
            if description and description ~= "" then
                Create("TextLabel", {
                    Parent = Section,
                    BackgroundTransparency = 1,
                    Position = UDim2.new(0, 12, 0, 26),
                    Size = UDim2.new(1, -24, 0, 16),
                    Font = MainFont,
                    Text = description,
                    TextColor3 = Theme.TextMuted,
                    TextSize = 11,
                    TextXAlignment = Enum.TextXAlignment.Left,
                    TextWrapped = true,
                    ZIndex = 4
                })
                descHeight = 18
            end

            local SectionContent = Create("Frame", {
                Parent = Section,
                BackgroundTransparency = 1,
                Position = UDim2.new(0, 0, 0, 30 + descHeight),
                Size = UDim2.new(1, 0, 0, 0),
                ZIndex = 3
            })
            local ContentLayout = Create("UIListLayout", {
                Parent = SectionContent,
                SortOrder = Enum.SortOrder.LayoutOrder,
                Padding = UDim.new(0, 8)
            })
            Create("UIPadding", {
                Parent = SectionContent,
                PaddingLeft = UDim.new(0, 12),
                PaddingRight = UDim.new(0, 12),
                PaddingBottom = UDim.new(0, 12)
            })

            local function ResizeSection()
                local h = ContentLayout.AbsoluteContentSize.Y + 42 + descHeight
                Section.Size = UDim2.new(1, 0, 0, h)
                SectionContent.Size = UDim2.new(1, 0, 0, ContentLayout.AbsoluteContentSize.Y + 12)
            end
            ContentLayout:GetPropertyChangedSignal("AbsoluteContentSize"):Connect(ResizeSection)

            local Sec = {}

            local function MakeLocked(parentFrame)
                local LockOverlay = Create("Frame", {
                    Parent = parentFrame,
                    BackgroundColor3 = Color3.fromRGB(10, 10, 15),
                    BackgroundTransparency = 0.3,
                    BorderSizePixel = 0,
                    Size = UDim2.new(1, 0, 1, 0),
                    ZIndex = 10
                })
                Create("UICorner", {CornerRadius = UDim.new(0, 6), Parent = LockOverlay})

                local LockText = Create("TextLabel", {
                    Parent = LockOverlay,
                    BackgroundTransparency = 1,
                    Size = UDim2.new(1, 0, 1, 0),
                    Font = BoldFont,
                    Text = "🔒 LOCKED  |  Enter Key",
                    TextColor3 = Theme.Locked,
                    TextSize = 12,
                    ZIndex = 11
                })
                return LockOverlay, LockText
            end

            -- ========== BUTTON ==========
            function Sec:CreateButton(text, callback, locked)
                locked = locked or false
                local Btn = Create("TextButton", {
                    Parent = SectionContent,
                    BackgroundColor3 = Theme.Button,
                    BorderSizePixel = 0,
                    Size = UDim2.new(1, 0, 0, 32),
                    Font = MediumFont,
                    Text = text,
                    TextColor3 = Theme.Text,
                    TextSize = 13,
                    AutoButtonColor = false,
                    ZIndex = 4
                })
                Create("UICorner", {CornerRadius = UDim.new(0, 7), Parent = Btn})
                AddStroke(Btn, Theme.Stroke, 1)

                local LockOverlay, LockText
                if locked then
                    LockOverlay, LockText = MakeLocked(Btn)
                end

                Btn.MouseEnter:Connect(function()
                    if not locked or IsUnlocked then
                        Tween(Btn, {BackgroundColor3 = Theme.ButtonHover})
                    end
                end)
                Btn.MouseLeave:Connect(function()
                    Tween(Btn, {BackgroundColor3 = Theme.Button})
                end)

                Btn.MouseButton1Click:Connect(function()
                    if locked and not IsUnlocked then
                        LockText.Text = "🔒 LOCKED  |  Need Key!"
                        Tween(LockText, {TextColor3 = Theme.Warning}, 0.1)
                        task.delay(1.2, function()
                            if LockText then
                                LockText.Text = "🔒 LOCKED  |  Enter Key"
                                Tween(LockText, {TextColor3 = Theme.Locked}, 0.15)
                            end
                        end)
                        return
                    end
                    if callback then callback() end
                end)

                if locked then
                    task.spawn(function()
                        while locked and LockOverlay and LockOverlay.Parent do
                            if IsUnlocked then
                                LockOverlay:Destroy()
                                locked = false
                                break
                            end
                            task.wait(0.4)
                        end
                    end)
                end
                return Btn
            end

            -- ========== TOGGLE ==========
            function Sec:CreateToggle(text, default, callback, locked)
                default = default or false
                locked = locked or false
                local state = default

                local ToggleFrame = Create("Frame", {
                    Parent = SectionContent,
                    BackgroundTransparency = 1,
                    Size = UDim2.new(1, 0, 0, 30),
                    ZIndex = 4
                })

                Create("TextLabel", {
                    Parent = ToggleFrame,
                    BackgroundTransparency = 1,
                    Position = UDim2.new(0, 0, 0, 0),
                    Size = UDim2.new(1, -55, 1, 0),
                    Font = MainFont,
                    Text = text,
                    TextColor3 = Theme.Text,
                    TextSize = 13,
                    TextXAlignment = Enum.TextXAlignment.Left,
                    ZIndex = 5
                })

                local ToggleBg = Create("Frame", {
                    Parent = ToggleFrame,
                    BackgroundColor3 = state and Theme.ToggleOn or Theme.ToggleOff,
                    Position = UDim2.new(1, -46, 0.5, -11),
                    Size = UDim2.new(0, 42, 0, 22),
                    ZIndex = 5
                })
                Create("UICorner", {CornerRadius = UDim.new(1, 0), Parent = ToggleBg})

                local Circle = Create("Frame", {
                    Parent = ToggleBg,
                    BackgroundColor3 = Color3.fromRGB(255, 255, 255),
                    Position = state and UDim2.new(1, -20, 0.5, -9) or UDim2.new(0, 2, 0.5, -9),
                    Size = UDim2.new(0, 18, 0, 18),
                    ZIndex = 6
                })
                Create("UICorner", {CornerRadius = UDim.new(1, 0), Parent = Circle})

                local Click = Create("TextButton", {
                    Parent = ToggleFrame,
                    BackgroundTransparency = 1,
                    Size = UDim2.new(1, 0, 1, 0),
                    Text = "",
                    ZIndex = 7
                })

                local LockOverlay, LockText
                if locked then
                    LockOverlay, LockText = MakeLocked(ToggleFrame)
                end

                Click.MouseButton1Click:Connect(function()
                    if locked and not IsUnlocked then
                        if LockText then
                            LockText.Text = "🔒 LOCKED  |  Need Key!"
                            Tween(LockText, {TextColor3 = Theme.Warning}, 0.1)
                            task.delay(1.2, function()
                                if LockText then
                                    LockText.Text = "🔒 LOCKED  |  Enter Key"
                                    Tween(LockText, {TextColor3 = Theme.Locked}, 0.15)
                                end
                            end)
                        end
                        return
                    end
                    state = not state
                    Tween(ToggleBg, {BackgroundColor3 = state and Theme.ToggleOn or Theme.ToggleOff})
                    Tween(Circle, {Position = state and UDim2.new(1, -20, 0.5, -9) or UDim2.new(0, 2, 0.5, -9)})
                    if callback then callback(state) end
                end)

                if locked then
                    task.spawn(function()
                        while locked and LockOverlay and LockOverlay.Parent do
                            if IsUnlocked then
                                LockOverlay:Destroy()
                                locked = false
                                break
                            end
                            task.wait(0.4)
                        end
                    end)
                end

                return {
                    Set = function(val)
                        state = val
                        Tween(ToggleBg, {BackgroundColor3 = state and Theme.ToggleOn or Theme.ToggleOff})
                        Tween(Circle, {Position = state and UDim2.new(1, -20, 0.5, -9) or UDim2.new(0, 2, 0.5, -9)})
                    end,
                    Get = function() return state end
                }
            end

            -- ========== DROPDOWN ==========
            function Sec:CreateDropdown(text, options, callback, locked)
                options = options or {"Option 1", "Option 2"}
                locked = locked or false
                local selected = options[1]
                local open = false

                local DropFrame = Create("Frame", {
                    Parent = SectionContent,
                    BackgroundTransparency = 1,
                    Size = UDim2.new(1, 0, 0, 32),
                    ClipsDescendants = false,
                    ZIndex = 4
                })

                local DropBtn = Create("TextButton", {
                    Parent = DropFrame,
                    BackgroundColor3 = Theme.Button,
                    BorderSizePixel = 0,
                    Size = UDim2.new(1, 0, 0, 32),
                    Font = MainFont,
                    Text = "  " .. text .. ": " .. selected,
                    TextColor3 = Theme.Text,
                    TextSize = 13,
                    TextXAlignment = Enum.TextXAlignment.Left,
                    AutoButtonColor = false,
                    ZIndex = 5
                })
                Create("UICorner", {CornerRadius = UDim.new(0, 7), Parent = DropBtn})
                AddStroke(DropBtn, Theme.Stroke, 1)

                local Arrow = Create("TextLabel", {
                    Parent = DropBtn,
                    BackgroundTransparency = 1,
                    Position = UDim2.new(1, -28, 0, 0),
                    Size = UDim2.new(0, 24, 1, 0),
                    Font = BoldFont,
                    Text = "▾",
                    TextColor3 = Theme.TextDark,
                    TextSize = 14,
                    ZIndex = 6
                })

                local DropList = Create("Frame", {
                    Parent = DropFrame,
                    BackgroundColor3 = Theme.Secondary,
                    BorderSizePixel = 0,
                    Position = UDim2.new(0, 0, 0, 36),
                    Size = UDim2.new(1, 0, 0, 0),
                    Visible = false,
                    ZIndex = 30,
                    ClipsDescendants = true
                })
                Create("UICorner", {CornerRadius = UDim.new(0, 8), Parent = DropList})
                AddStroke(DropList, Theme.Accent, 1)
                Create("UIListLayout", {
                    Parent = DropList,
                    SortOrder = Enum.SortOrder.LayoutOrder,
                    Padding = UDim.new(0, 3)
                })
                Create("UIPadding", {
                    Parent = DropList,
                    PaddingTop = UDim.new(0, 4),
                    PaddingBottom = UDim.new(0, 4),
                    PaddingLeft = UDim.new(0, 4),
                    PaddingRight = UDim.new(0, 4)
                })

                for _, opt in ipairs(options) do
                    local OptBtn = Create("TextButton", {
                        Parent = DropList,
                        BackgroundColor3 = Theme.Button,
                        BorderSizePixel = 0,
                        Size = UDim2.new(1, 0, 0, 28),
                        Font = MainFont,
                        Text = "  " .. opt,
                        TextColor3 = Theme.Text,
                        TextSize = 12,
                        TextXAlignment = Enum.TextXAlignment.Left,
                        AutoButtonColor = false,
                        ZIndex = 31
                    })
                    Create("UICorner", {CornerRadius = UDim.new(0, 5), Parent = OptBtn})

                    OptBtn.MouseEnter:Connect(function()
                        Tween(OptBtn, {BackgroundColor3 = Theme.ButtonHover})
                    end)
                    OptBtn.MouseLeave:Connect(function()
                        Tween(OptBtn, {BackgroundColor3 = Theme.Button})
                    end)
                    OptBtn.MouseButton1Click:Connect(function()
                        if locked and not IsUnlocked then return end
                        selected = opt
                        DropBtn.Text = "  " .. text .. ": " .. selected
                        open = false
                        Tween(DropList, {Size = UDim2.new(1, 0, 0, 0)}, 0.15)
                        task.delay(0.15, function() DropList.Visible = false end)
                        Arrow.Text = "▾"
                        if callback then callback(selected) end
                    end)
                end

                local LockOverlay, LockText
                if locked then
                    LockOverlay, LockText = MakeLocked(DropFrame)
                end

                DropBtn.MouseButton1Click:Connect(function()
                    if locked and not IsUnlocked then
                        if LockText then
                            LockText.Text = "🔒 LOCKED  |  Need Key!"
                            Tween(LockText, {TextColor3 = Theme.Warning}, 0.1)
                            task.delay(1.2, function()
                                if LockText then
                                    LockText.Text = "🔒 LOCKED  |  Enter Key"
                                    Tween(LockText, {TextColor3 = Theme.Locked}, 0.15)
                                end
                            end)
                        end
                        return
                    end
                    open = not open
                    if open then
                        DropList.Visible = true
                        local h = #options * 31 + 8
                        Tween(DropList, {Size = UDim2.new(1, 0, 0, h)}, 0.18)
                        Arrow.Text = "▴"
                    else
                        Tween(DropList, {Size = UDim2.new(1, 0, 0, 0)}, 0.15)
                        task.delay(0.15, function() DropList.Visible = false end)
                        Arrow.Text = "▾"
                    end
                end)

                if locked then
                    task.spawn(function()
                        while locked and LockOverlay and LockOverlay.Parent do
                            if IsUnlocked then
                                LockOverlay:Destroy()
                                locked = false
                                break
                            end
                            task.wait(0.4)
                        end
                    end)
                end

                return {
                    Set = function(val)
                        selected = val
                        DropBtn.Text = "  " .. text .. ": " .. selected
                    end,
                    Get = function() return selected end
                }
            end

            return Sec
        end

        return Tab
    end

    -- ===== Key Box =====
    function Window:CreateKeyBox()
        local KeyFrame = Create("Frame", {
            Parent = Main,
            BackgroundColor3 = Theme.Secondary,
            BackgroundTransparency = 0.15,
            BorderSizePixel = 0,
            Position = UDim2.new(0, 150, 1, -50),
            Size = UDim2.new(1, -160, 0, 38),
            ZIndex = 5
        })
        Create("UICorner", {CornerRadius = UDim.new(0, 8), Parent = KeyFrame})
        AddStroke(KeyFrame, Theme.Stroke, 1)

        local KeyBox = Create("TextBox", {
            Parent = KeyFrame,
            BackgroundTransparency = 1,
            Position = UDim2.new(0, 12, 0, 0),
            Size = UDim2.new(0.7, 0, 1, 0),
            Font = MainFont,
            PlaceholderText = "Enter Key here...",
            PlaceholderColor3 = Theme.TextMuted,
            Text = "",
            TextColor3 = Theme.Text,
            TextSize = 13,
            TextXAlignment = Enum.TextXAlignment.Left,
            ClearTextOnFocus = false,
            ZIndex = 6
        })

        local UnlockBtn = Create("TextButton", {
            Parent = KeyFrame,
            BackgroundColor3 = Theme.Accent,
            BorderSizePixel = 0,
            Position = UDim2.new(0.72, 0, 0.15, 0),
            Size = UDim2.new(0.26, 0, 0.7, 0),
            Font = BoldFont,
            Text = "Unlock",
            TextColor3 = Theme.Text,
            TextSize = 12,
            AutoButtonColor = false,
            ZIndex = 6
        })
        Create("UICorner", {CornerRadius = UDim.new(0, 6), Parent = UnlockBtn})

        UnlockBtn.MouseButton1Click:Connect(function()
            if Library:Unlock(KeyBox.Text) then
                UnlockBtn.Text = "✓ Unlocked"
                Tween(UnlockBtn, {BackgroundColor3 = Theme.Success})
                KeyBox.Text = ""
                KeyBox.PlaceholderText = "Access Granted!"
            else
                UnlockBtn.Text = "Wrong!"
                Tween(UnlockBtn, {BackgroundColor3 = Theme.Locked})
                task.delay(1.5, function()
                    UnlockBtn.Text = "Unlock"
                    Tween(UnlockBtn, {BackgroundColor3 = Theme.Accent})
                end)
            end
        end)
    end

    -- ===== ฟังก์ชันเปลี่ยนพื้นหลังแบบ Runtime =====
    function Window:SetBackground(bgConfig)
        bgConfig = bgConfig or {}
        local newType = bgConfig.Type or "Color"
        local newColor = bgConfig.Color or Theme.Background
        local newImage = bgConfig.Image or ""
        local newTrans = bgConfig.Transparency or 0

        if BgImageLabel then
            BgImageLabel:Destroy()
            BgImageLabel = nil
        end

        if newType == "Color" then
            Main.BackgroundColor3 = newColor
            Main.BackgroundTransparency = 0
        elseif newType == "Image" or newType == "Gif" then
            Main.BackgroundTransparency = 1
            BgImageLabel = Create("ImageLabel", {
                Name = "CustomBackground",
                Parent = Main,
                BackgroundTransparency = 1,
                Size = UDim2.new(1, 0, 1, 0),
                Image = newImage,
                ImageTransparency = newTrans,
                ScaleType = Enum.ScaleType.Crop,
                ZIndex = 0
            })
            Create("UICorner", {CornerRadius = UDim.new(0, 12), Parent = BgImageLabel})
        end
    end

    return Window
end

return Library
