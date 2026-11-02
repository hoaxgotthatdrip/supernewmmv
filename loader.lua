-- MMV weapon recolor (client-side). Click a color; click it again to get a "back to normal?" prompt.
-- RightControl = on/off, RightShift = hide/show menu.
local C = {Material = Enum.Material.SmoothPlastic, -- Neon = glowy, SmoothPlastic = no glow, Metal = shiny, Glass = see-through
    Speed = 0.4, KeepGlass = true,
    Ignore = {"bomb","radio","boom","emote","trap","pet","fake","grenade","mine"}, Only = {}}

local P = {{"Red",255,0,0},{"Dark Red",140,0,0},{"Orange",255,130,0},{"Yellow",255,240,0},{"Gold",212,175,55},
    {"Lime",150,255,0},{"Green",0,255,0},{"Dark Green",0,110,30},{"Teal",0,200,170},{"Cyan",0,255,255},
    {"Sky Blue",80,170,255},{"Blue",0,60,255},{"Navy",0,0,120},{"Purple",150,0,255},{"Magenta",255,0,200},
    {"Pink",255,120,200},{"Brown",110,65,30},{"White",255,255,255},{"Gray",128,128,128},
    {"Dark Gray",50,50,50},{"Black",0,0,0},{"Rainbow"},{"Normal"}}

local UIS, RS, lp, cam = game:GetService("UserInputService"), game:GetService("RunService"),
    game.Players.LocalPlayer, workspace.CurrentCamera
local sel, on, orig, removed = "Purple", true, {}, {}

local function has(list, s) for _, w in ipairs(list) do if s:find(w, 1, true) then return true end end end
local function ok(n)
    n = n:lower()
    if #C.Only > 0 then return has(C.Only, n) end
    return not has(C.Ignore, n)
end
local function col()
    if sel == "Rainbow" then return Color3.fromHSV(os.clock() * C.Speed % 1, 1, 1) end
    for _, p in ipairs(P) do if p[1] == sel then return Color3.fromRGB(p[2], p[3], p[4]) end end
end

local function set(o, k, v) if not orig[o] then orig[o] = {} end if orig[o][k] == nil then orig[o][k] = o[k] end o[k] = v end

local function paint(root)
    local c = col()
    for _, d in ipairs(root:GetDescendants()) do
        if d:IsA("BasePart") then
            local n = d.Name:lower()
            if not (C.KeepGlass and (n:find("glass") or n:find("lens"))) then
                set(d, "Color", c); set(d, "Material", C.Material)
                if d:IsA("MeshPart") then set(d, "TextureID", "") end
            end
        elseif d:IsA("SurfaceAppearance") or d:IsA("Texture") or d:IsA("Decal") then
            removed[d] = d.Parent; d.Parent = nil
        elseif d:IsA("SpecialMesh") then set(d, "TextureId", "")
        elseif d:IsA("ParticleEmitter") or d:IsA("Trail") or d:IsA("Beam") then set(d, "Color", ColorSequence.new(c))
        elseif d:IsA("PointLight") or d:IsA("SpotLight") then set(d, "Color", c) end
    end
end

local function restore()
    for o, props in pairs(orig) do
        if o.Parent then for k, v in pairs(props) do pcall(function() o[k] = v end) end end
        orig[o] = nil
    end
    for o, par in pairs(removed) do pcall(function() o.Parent = par end) removed[o] = nil end
end

RS.RenderStepped:Connect(function()
    if not on then return end
    local ch = lp.Character
    for _, v in ipairs(ch and ch:GetChildren() or {}) do if v:IsA("Tool") and ok(v.Name) then paint(v) end end
    for _, v in ipairs(cam:GetChildren()) do if (v:IsA("Model") or v:IsA("Folder")) and ok(v.Name) then paint(v) end end
end)

-- GUI
local function new(cls, props, par) local i = Instance.new(cls) for k, v in pairs(props) do i[k] = v end i.Parent = par return i end
local gui = new("ScreenGui", {Name = "MMVRecolorGui", ResetOnSpawn = false}, (gethui and gethui()) or game:GetService("CoreGui"))
local fr = new("Frame", {Size = UDim2.new(0,230,0,330), Position = UDim2.new(0,20,0.5,-165), BackgroundColor3 = Color3.fromRGB(20,20,24), BorderSizePixel = 0}, gui)
new("UICorner", {}, fr)
local title = new("TextLabel", {Size = UDim2.new(1,0,0,30), BackgroundColor3 = Color3.fromRGB(35,35,42), BorderSizePixel = 0,
    Text = "MMV Recolor (drag)", TextColor3 = Color3.new(1,1,1), Font = Enum.Font.GothamBold, TextSize = 14}, fr)
new("UICorner", {}, title)
local sc = new("ScrollingFrame", {Size = UDim2.new(1,-10,1,-40), Position = UDim2.new(0,5,0,35), BackgroundTransparency = 1,
    BorderSizePixel = 0, ScrollBarThickness = 4, AutomaticCanvasSize = Enum.AutomaticSize.Y, CanvasSize = UDim2.new()}, fr)
new("UIGridLayout", {CellSize = UDim2.new(0.5,-4,0,32), CellPadding = UDim2.new(0,4,0,4)}, sc)

-- confirm popup
local box = new("Frame", {Size = UDim2.new(0,200,0,100), Position = UDim2.new(0.5,-100,0.5,-50), BackgroundColor3 = Color3.fromRGB(35,35,42),
    BorderSizePixel = 0, Visible = false, ZIndex = 20}, fr)
new("UICorner", {}, box); new("UIStroke", {Color = Color3.new(1,1,1)}, box)
new("TextLabel", {Size = UDim2.new(1,-16,0,50), Position = UDim2.new(0,8,0,6), BackgroundTransparency = 1, TextWrapped = true,
    Font = Enum.Font.GothamBold, TextSize = 13, TextColor3 = Color3.new(1,1,1), ZIndex = 21,
    Text = "Would you like to change it back to normal?"}, box)

local btns = {}
local function refresh() for n, b in pairs(btns) do b.UIStroke.Enabled = (n == sel) end end
local function normal() sel, on = "Normal", false restore() refresh() end

for i, t in ipairs({{"Yes", Color3.fromRGB(0,160,70), 8}, {"No", Color3.fromRGB(170,40,40), 106}}) do
    local b = new("TextButton", {Size = UDim2.new(0,86,0,28), Position = UDim2.new(0,t[3],1,-36), BackgroundColor3 = t[2], BorderSizePixel = 0,
        Text = t[1], Font = Enum.Font.GothamBold, TextSize = 13, TextColor3 = Color3.new(1,1,1), ZIndex = 21}, box)
    new("UICorner", {}, b)
    b.MouseButton1Click:Connect(function() if i == 1 then normal() end box.Visible = false end)
end

for _, p in ipairs(P) do
    local name = p[1]
    local b = new("TextButton", {Text = name, Font = Enum.Font.GothamBold, TextSize = 12, BorderSizePixel = 0, TextColor3 = Color3.new(1,1,1),
        BackgroundColor3 = p[2] and Color3.fromRGB(p[2], p[3], p[4]) or Color3.fromRGB(60,60,70)}, sc)
    new("UICorner", {}, b); new("UIStroke", {Color = Color3.new(1,1,1), Thickness = 2, Enabled = false}, b)
    if p[2] and (p[2]*.299 + p[3]*.587 + p[4]*.114) > 140 then b.TextColor3 = Color3.new(0,0,0); b.UIStroke.Color = Color3.new(0,0,0) end
    if name == "Rainbow" then
        b.BackgroundColor3 = Color3.new(1,1,1)
        new("UIGradient", {Color = ColorSequence.new({ColorSequenceKeypoint.new(0, Color3.fromRGB(255,0,0)), ColorSequenceKeypoint.new(.2, Color3.fromRGB(255,255,0)),
            ColorSequenceKeypoint.new(.4, Color3.fromRGB(0,255,0)), ColorSequenceKeypoint.new(.6, Color3.fromRGB(0,255,255)),
            ColorSequenceKeypoint.new(.8, Color3.fromRGB(0,0,255)), ColorSequenceKeypoint.new(1, Color3.fromRGB(255,0,255))})}, b)
    end
    b.MouseButton1Click:Connect(function()
        if name == "Normal" then normal()
        elseif sel == name and on then box.Visible = true
        else sel, on = name, true refresh() end
    end)
    btns[name] = b
end
refresh()

-- drag + keys
local drag, ds, sp
title.InputBegan:Connect(function(i) if i.UserInputType == Enum.UserInputType.MouseButton1 or i.UserInputType == Enum.UserInputType.Touch then drag, ds, sp = true, i.Position, fr.Position end end)
UIS.InputChanged:Connect(function(i) if drag and (i.UserInputType == Enum.UserInputType.MouseMovement or i.UserInputType == Enum.UserInputType.Touch) then local d = i.Position - ds fr.Position = UDim2.new(sp.X.Scale, sp.X.Offset + d.X, sp.Y.Scale, sp.Y.Offset + d.Y) end end)
UIS.InputEnded:Connect(function(i) if i.UserInputType == Enum.UserInputType.MouseButton1 or i.UserInputType == Enum.UserInputType.Touch then drag = false end end)
UIS.InputBegan:Connect(function(i, g)
    if g then return end
    if i.KeyCode == Enum.KeyCode.RightControl then on = not on if not on then restore() end
    elseif i.KeyCode == Enum.KeyCode.RightShift then fr.Visible = not fr.Visible end
end)
