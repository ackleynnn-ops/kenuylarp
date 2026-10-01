-- KenuySwap 0.2 : gabungan EmoteSwap + UnusualSwap dalam 1 menu tab
-- Tab Emote = logic KenuySwap_0.1_Sebelum.lua (hook EmoteService.SetEmote, 12 slot)
-- Tab Unusual = logic UnusualSwapMenu_0.1.lua (hook AddCosmetics, UnusualSlot)
-- Client-side visual only.
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local UserInputService = game:GetService("UserInputService")
local TweenService = game:GetService("TweenService")
local IS_MOBILE = UserInputService.TouchEnabled and not UserInputService.KeyboardEnabled
local BUBBLE_IMAGE = ""

pcall(function()
  local root = (gethui and gethui() or game:GetService("CoreGui"))
  for _, n in ipairs({ "KenuySwapUI", "EmoteSwapUI", "UnusualSwapUI" }) do
    local old = root:FindFirstChild(n)
    if old then old:Destroy() end
  end
end)
if _G.KenuyToggleConn then pcall(function() _G.KenuyToggleConn:Disconnect() end) _G.KenuyToggleConn = nil end

local Themes = {
  { name = "Abyss", bg = {16,21,32}, panel = {26,34,50}, card = {33,43,63}, accent = {45,212,191}, accentD = {20,120,110}, text = {235,240,248}, dim = {150,163,184}, danger = {244,113,116}, hover = {45,58,82}, applyH = {94,234,212}, clearH = {252,165,165} },
  { name = "Crimson", bg = {24,10,14}, panel = {38,16,22}, card = {52,24,32}, accent = {235,60,80}, accentD = {140,30,45}, text = {255,240,242}, dim = {205,170,178}, danger = {255,140,90}, hover = {70,32,40}, applyH = {255,100,115}, clearH = {255,180,140} },
  { name = "Violet", bg = {18,14,32}, panel = {30,24,54}, card = {42,34,74}, accent = {150,110,255}, accentD = {85,60,160}, text = {240,238,255}, dim = {185,178,215}, danger = {255,120,130}, hover = {60,50,105}, applyH = {175,140,255}, clearH = {255,170,180} },
  { name = "Emerald", bg = {8,24,20}, panel = {14,38,32}, card = {22,54,46}, accent = {50,220,150}, accentD = {22,130,90}, text = {235,250,244}, dim = {170,200,188}, danger = {250,130,120}, hover = {32,72,60}, applyH = {100,240,180}, clearH = {255,175,165} },
  { name = "Amber", bg = {26,20,10}, panel = {42,32,16}, card = {58,44,24}, accent = {245,170,40}, accentD = {150,100,25}, text = {255,246,230}, dim = {210,190,160}, danger = {250,120,100}, hover = {78,60,32}, applyH = {255,200,90}, clearH = {255,175,150} },
}
local function C3(t) return Color3.fromRGB(t[1], t[2], t[3]) end
local Pal = {}
for k, v in pairs(Themes[1]) do if type(v) == "table" then Pal[k] = C3(v) end end
local function pretty(s)
  s = tostring(s):gsub("(%l)(%u)", "%1 %2"):gsub("%s+", " ")
  return (s:gsub("^%s+", ""):gsub("%s+$", ""))
end

-- ================= EMOTE CORE (dari 0.1_Sebelum) =================
local emoteByName, emoteNames, nameById = {}, {}, {}
local function underEmotes(inst)
  local p = inst.Parent
  while p and p ~= ReplicatedStorage do
    if p.Name == "Emotes" then return true end
    p = p.Parent
  end
  return false
end
local function scanEmotes()
  emoteByName, emoteNames, nameById = {}, {}, {}
  local seen = {}
  for _, d in ipairs(ReplicatedStorage.Items:GetDescendants()) do
    if d:IsA("ModuleScript") and underEmotes(d) then
      if not seen[d.Name] then
        seen[d.Name] = true
        local id
        pcall(function() id = d:GetAttribute("ID") end)
        emoteByName[d.Name] = { inst = d, id = id }
        table.insert(emoteNames, d.Name)
      end
    end
  end
  table.sort(emoteNames)
  for name, info in pairs(emoteByName) do if info.id ~= nil then nameById[info.id] = name end end
  return #emoteNames
end
scanEmotes()
do local t = 0 while #emoteNames == 0 and t < 30 do task.wait(1) t += 1 scanEmotes() end end

_G.EmoteSwapMap = _G.EmoteSwapMap or {}
_G.EmoteSwapBackup = _G.EmoteSwapBackup or {}
local rng = Random.new()
do
  local function backup(mod)
    local key = mod:GetFullName()
    if not _G.EmoteSwapBackup[key] then
      _G.EmoteSwapBackup[key] = {
        classic = mod:FindFirstChild("AnimationClassic") and mod.AnimationClassic.AnimationId or nil,
        r6 = mod:FindFirstChild("AnimationR6") and mod.AnimationR6.AnimationId or nil,
        anim = mod:FindFirstChild("Animation") and mod.Animation.AnimationId or nil,
      }
      pcall(function() local i = require(mod).AppearanceInfo _G.EmoteSwapBackup[key].dispName = i and i.Name end)
      pcall(function() _G.EmoteSwapBackup[key].sound = require(mod).EmoteInfo.Sound end)
    end
  end
  local function displayNameOf(rep, fallback)
    local dn
    pcall(function() dn = require(rep).AppearanceInfo.Name end)
    if type(dn) == "string" and dn ~= "" then return pretty(dn) end
    return pretty(fallback)
  end
  local function variantAnimId(variant, rig)
    local folder = variant:FindFirstChild("Animations") and variant.Animations:FindFirstChild(rig)
    local anim = folder and folder:FindFirstChild("Animation")
    if anim and anim:IsA("Animation") and anim.AnimationId ~= "" then return anim.AnimationId end
    return nil
  end
  local svc = require(ReplicatedStorage.Services.Items.EmoteService)
  local LP = game:GetService("Players").LocalPlayer
  local PG = LP:WaitForChild("PlayerGui")
  pcall(function() restorefunction(svc.SetEmote) end)
  local old
  old = hookfunction(svc.SetEmote, function(self, p2, p3, ...)
    if typeof(p2) == "Instance" and (p2 == LP.Character or p2:IsDescendantOf(PG))
    and typeof(p3) == "Instance" and p3:IsA("ModuleScript") then
      local target = _G.EmoteSwapMap[p3.Name]
      if target and not emoteByName[target] then scanEmotes() end
      local rep = target and emoteByName[target]
      rep = rep and rep.inst
      if rep then
        pcall(function() backup(p3) end)
        if rep:FindFirstChild("Animation") or rep:FindFirstChild("Animations") then
          pcall(function() require(p3).AppearanceInfo.Name = displayNameOf(rep, target) end)
          p3 = rep
        else
          local okV, errV = pcall(function()
            local sel = rep:FindFirstChild("Selection")
            if sel and #sel:GetChildren() > 0 then
              local vars = sel:GetChildren()
              local v = vars[rng:NextInteger(1, #vars)]
              local r6, r15 = variantAnimId(v, "R6"), variantAnimId(v, "R15")
              if r6 or r15 then
                if r6 and p3:FindFirstChild("AnimationR6") then p3.AnimationR6.AnimationId = r6 end
                if r6 and p3:FindFirstChild("AnimationClassic") then p3.AnimationClassic.AnimationId = r6 end
                if r15 and p3:FindFirstChild("Animation") then p3.Animation.AnimationId = r15 end
                pcall(function()
                  local src, dst = require(p3).EmoteInfo, require(rep).EmoteInfo
                  if src and dst and type(src.Sound) == type(dst.Sound) then src.Sound = dst.Sound end
                end)
                require(p3).AppearanceInfo.Name = displayNameOf(rep, target) .. " " .. tostring(v.Name)
              end
            else
              warn("[KenuySwap] tanpa varian: " .. tostring(target))
            end
          end)
          if not okV then warn("[KenuySwap] varian gagal: " .. tostring(errV):sub(1, 120)) end
        end
      elseif target then
        warn("[KenuySwap] emote tidak dikenal: " .. tostring(target))
      elseif _G.EmoteSwapBackup[p3:GetFullName()] then
        pcall(function()
          local b = _G.EmoteSwapBackup[p3:GetFullName()]
          if b.classic and p3:FindFirstChild("AnimationClassic") then p3.AnimationClassic.AnimationId = b.classic end
          if b.r6 and p3:FindFirstChild("AnimationR6") then p3.AnimationR6.AnimationId = b.r6 end
          if b.anim and p3:FindFirstChild("Animation") then p3.Animation.AnimationId = b.anim end
          if b.dispName ~= nil then require(p3).AppearanceInfo.Name = b.dispName end
          if b.sound ~= nil then require(p3).EmoteInfo.Sound = b.sound end
        end)
      end
    end
    return old(self, p2, p3, ...)
  end)
end

local function getEquippedEmoteNames()
  local out = {}
  pcall(function()
    local ul = require(ReplicatedStorage.Shared.UserData.ClientHooks.useLoadout)
    local eq = ul.GetEquipped()
    for i = 1, 12 do
      local id = eq["EmoteSlot_" .. i]
      out[i] = (id ~= nil and nameById[id]) or (id ~= nil and ("ID " .. tostring(id))) or "-"
    end
  end)
  return out
end

-- ================= UNUSUAL CORE (dari UnusualSwapMenu 0.1) =================
local unusualByName, unusualNames, unusualDisp = {}, {}, {}
local function scanUnusuals()
  unusualByName, unusualNames, unusualDisp = {}, {}, {}
  local seen = {}
  for _, d in ipairs(ReplicatedStorage.Items:GetDescendants()) do
    if d:IsA("ModuleScript") and not seen[d.Name] then
      local ok, m = pcall(require, d)
      if ok and type(m) == "table" and m.EquipInfo and tostring(m.EquipInfo.SlotType) == "Unusual" then
        seen[d.Name] = true
        unusualByName[d.Name] = { inst = d }
        table.insert(unusualNames, d.Name)
        local dn
        pcall(function() dn = m.AppearanceInfo and m.AppearanceInfo.Name end)
        unusualDisp[d.Name] = (type(dn) == "string" and dn ~= "" and dn) or pretty(d.Name)
      end
    end
  end
  table.sort(unusualNames)
  return #unusualNames
end
scanUnusuals()
do local t = 0 while #unusualNames == 0 and t < 30 do task.wait(1) t += 1 scanUnusuals() end end

local cis = require(ReplicatedStorage.Services.Items.ClientItemService)
local unameToId, uidToName = {}, {}
pcall(function()
  local maxId = 3000
  pcall(function() maxId = #cis.IDs + 100 end)
  for i = 1, maxId do
    local ok, nm = pcall(function() return cis.IDs[i] end)
    if ok and nm ~= nil then
      local s = tostring(nm)
      if s ~= "" and s ~= "nil" and not unameToId[s] then
        unameToId[s] = i
        uidToName[i] = s
      end
    end
  end
end)

_G.UnusualSwapMap = _G.UnusualSwapMap or { ["SpawnHalo"] = "ToxicInferno" }
local function buildUnusualIdMap()
  local m = {}
  for ownedName, wantName in pairs(_G.UnusualSwapMap) do
    local oid, wid = unameToId[ownedName], unameToId[wantName]
    if oid and wid then
      m[oid] = wid
      print("[UnusualSwap] map " .. ownedName .. "(" .. oid .. ") -> " .. wantName .. "(" .. wid .. ")")
    else
      warn("[UnusualSwap] id tidak ketemu: " .. tostring(ownedName) .. "=" .. tostring(oid) .. " " .. tostring(wantName) .. "=" .. tostring(wid))
    end
  end
  return m
end
_G.UnusualSwapById = buildUnusualIdMap()

do
  pcall(function()
    if _G.UnusualSwapOldAC then restorefunction(require(ReplicatedStorage.Services.Asset.RigService.AddCosmetics)) _G.UnusualSwapOldAC = nil end
  end)
  pcall(function()
    if _G.UnusualLoggerOldAC then restorefunction(require(ReplicatedStorage.Services.Asset.RigService.AddCosmetics)) _G.UnusualLoggerOldAC = nil end
  end)
  local acFn = require(ReplicatedStorage.Services.Asset.RigService.AddCosmetics)
  local oldAC
  oldAC = hookfunction(acFn, function(rig, idList, ...)
    if type(idList) == "table" then
      _G.UnusualSwapById = _G.UnusualSwapById or {}
      for i, id in ipairs(idList) do
        local rep = _G.UnusualSwapById[id]
        if rep then idList[i] = rep end
      end
    end
    return oldAC(rig, idList, ...)
  end)
  _G.UnusualSwapOldAC = oldAC
end

local function getEquippedUnusual()
  local id, nm = nil, "-"
  pcall(function()
    local ul = require(ReplicatedStorage.Shared.UserData.ClientHooks.useLoadout)
    id = ul.GetEquipped()["UnusualSlot"]
    if id ~= nil then
      local ok, v = pcall(function() return cis.IDs[id] end)
      if ok and v ~= nil then nm = tostring(v) end
      if nm == "nil" or nm == "" then nm = "ID " .. tostring(id) end
    end
  end)
  return nm, id
end

-- ================= UI =================
local FONT, FONTB, FONTBLACK = Enum.Font.Gotham, Enum.Font.GothamBold, Enum.Font.GothamBlack
local function mk(class, props, parent)
  local o = Instance.new(class)
  for k, v in pairs(props) do pcall(function() o[k] = v end) end
  o.Parent = parent
  return o
end
local function paintHover(btn, getNormal, getHover)
  btn.MouseEnter:Connect(function()
    TweenService:Create(btn, TweenInfo.new(0.15), { BackgroundColor3 = getHover() }):Play()
  end)
  btn.MouseLeave:Connect(function()
    TweenService:Create(btn, TweenInfo.new(0.15), { BackgroundColor3 = getNormal() }):Play()
  end)
end
local function guiRoot()
  local ok, h = pcall(function() return gethui and gethui() end)
  if ok and h then return h end
  return game:GetService("CoreGui")
end

local gui = mk("ScreenGui", { Name = "KenuySwapUI", ResetOnSpawn = false, ZIndexBehavior = Enum.ZIndexBehavior.Sibling }, guiRoot())
local main = mk("CanvasGroup", {
  AnchorPoint = Vector2.new(0.5, 0.5), Position = UDim2.fromScale(0.5, 0.5),
  Size = UDim2.fromScale(0.62, 0.68), BackgroundColor3 = Pal.bg,
  BorderSizePixel = 0, GroupTransparency = 1, Visible = false,
}, gui)
mk("UICorner", { CornerRadius = UDim.new(0, 12) }, main)
local mainStroke = mk("UIStroke", { Color = Pal.accent, Thickness = 1, Transparency = 0.6 }, main)
mk("UISizeConstraint", { MinSize = Vector2.new(560, 440) }, main)
mk("UIPadding", {
  PaddingTop = UDim.new(0, 14), PaddingBottom = UDim.new(0, 14),
  PaddingLeft = UDim.new(0, 16), PaddingRight = UDim.new(0, 16),
}, main)

local header = mk("Frame", { Size = UDim2.new(1, 0, 0, 44), BackgroundTransparency = 1 }, main)
local titleLbl = mk("TextLabel", {
  Size = UDim2.new(1, -220, 1, 0), BackgroundTransparency = 1, Text = "  ◈  KenuySwap 0.2",
  Font = FONTB, TextSize = 18, TextColor3 = Pal.accent, TextXAlignment = Enum.TextXAlignment.Left,
}, header)
local minBtn = mk("TextButton", {
  Position = UDim2.new(1, -132, 0, 4), Size = UDim2.new(0, 36, 0, 36), Text = "—",
  Font = FONTB, TextSize = 18, TextColor3 = Pal.accent, BackgroundColor3 = Pal.card,
  BorderSizePixel = 0, AutoButtonColor = false,
}, header)
mk("UICorner", { CornerRadius = UDim.new(0, 8) }, minBtn)
local hintLbl = mk("TextLabel", {
  AnchorPoint = Vector2.new(1, 0), Position = UDim2.fromScale(1, 0), Size = UDim2.new(0, 88, 1, 0),
  BackgroundTransparency = 1, Text = "RightCtrl", Font = FONT, TextSize = 12,
  TextColor3 = Pal.dim, TextXAlignment = Enum.TextXAlignment.Right,
}, header)

-- tab bar
local tabBar = mk("Frame", { Position = UDim2.new(0, 0, 0, 48), Size = UDim2.new(1, 0, 0, 32), BackgroundTransparency = 1 }, main)
local emoteTabBtn = mk("TextButton", {
  Size = UDim2.new(0.5, -4, 1, 0), BackgroundColor3 = Pal.accent, Text = "Emote",
  Font = FONTB, TextSize = 13, TextColor3 = Pal.bg, BorderSizePixel = 0, AutoButtonColor = false,
}, tabBar)
mk("UICorner", { CornerRadius = UDim.new(0, 6) }, emoteTabBtn)
local unusualTabBtn = mk("TextButton", {
  Position = UDim2.new(0.5, 4, 0, 0), Size = UDim2.new(0.5, -4, 1, 0), BackgroundColor3 = Pal.card, Text = "Unusual",
  Font = FONTB, TextSize = 13, TextColor3 = Pal.text, BorderSizePixel = 0, AutoButtonColor = false,
}, tabBar)
mk("UICorner", { CornerRadius = UDim.new(0, 6) }, unusualTabBtn)

local function actionBtn(text, x, w, color, parent)
  local b = mk("TextButton", {
    Position = UDim2.new(x, 0, 1, -60), Size = UDim2.new(w, 0, 0, 32), Text = text,
    Font = FONTB, TextSize = 13, TextColor3 = Pal.bg, BackgroundColor3 = color,
    BorderSizePixel = 0, AutoButtonColor = false,
  }, parent)
  mk("UICorner", { CornerRadius = UDim.new(0, 6) }, b)
  return b
end

-- ===== body Emote (salinan 0.1) =====
local bodyEmote = mk("Frame", {
  Position = UDim2.new(0, 0, 0, 88), Size = UDim2.new(1, 0, 1, -160),
  BackgroundTransparency = 1,
}, main)
local eLeft = mk("Frame", { Size = UDim2.new(0.46, -8, 1, 0), BackgroundColor3 = Pal.panel, BorderSizePixel = 0 }, bodyEmote)
mk("UICorner", { CornerRadius = UDim.new(0, 8) }, eLeft)
mk("UIPadding", { PaddingTop = UDim.new(0, 10), PaddingLeft = UDim.new(0, 10), PaddingRight = UDim.new(0, 10), PaddingBottom = UDim.new(0, 10) }, eLeft)
mk("TextLabel", { Size = UDim2.new(1, 0, 0, 22), BackgroundTransparency = 1, Text = "CURRENT  (klik untuk pilih slot)", Font = FONTB, TextSize = 13, TextColor3 = Pal.text, TextXAlignment = Enum.TextXAlignment.Left }, eLeft)
local eGrid = mk("Frame", { Position = UDim2.new(0, 0, 0, 30), Size = UDim2.new(1, 0, 1, -30), BackgroundTransparency = 1 }, eLeft)
mk("UIGridLayout", { CellSize = UDim2.new(0.48, 0, 0.148, 0), CellPadding = UDim2.new(0.04, 0, 0.02, 0), SortOrder = Enum.SortOrder.LayoutOrder }, eGrid)
local eRight = mk("Frame", { AnchorPoint = Vector2.new(1, 0), Position = UDim2.fromScale(1, 0), Size = UDim2.new(0.54, -8, 1, 0), BackgroundColor3 = Pal.panel, BorderSizePixel = 0 }, bodyEmote)
mk("UICorner", { CornerRadius = UDim.new(0, 8) }, eRight)
mk("UIPadding", { PaddingTop = UDim.new(0, 10), PaddingLeft = UDim.new(0, 10), PaddingRight = UDim.new(0, 10), PaddingBottom = UDim.new(0, 10) }, eRight)
mk("TextLabel", { Size = UDim2.new(1, 0, 0, 22), BackgroundTransparency = 1, Text = "SELECT  (pilih pengganti)", Font = FONTB, TextSize = 13, TextColor3 = Pal.text, TextXAlignment = Enum.TextXAlignment.Left }, eRight)
local eSearch = mk("TextBox", { Position = UDim2.new(0, 0, 0, 30), Size = UDim2.new(1, 0, 0, 30), BackgroundColor3 = Pal.card, TextColor3 = Pal.text, PlaceholderColor3 = Pal.dim, PlaceholderText = "  Cari emote...", Text = "", Font = FONT, TextSize = 13, ClearTextOnFocus = false }, eRight)
mk("UICorner", { CornerRadius = UDim.new(0, 6) }, eSearch)
local eList = mk("ScrollingFrame", { Position = UDim2.new(0, 0, 0, 68), Size = UDim2.new(1, 0, 1, -158), BackgroundTransparency = 1, ScrollBarThickness = 5, ScrollBarImageColor3 = Pal.accent, CanvasSize = UDim2.new(0, 0, 0, 0), AutomaticCanvasSize = Enum.AutomaticSize.Y }, eRight)
mk("UIListLayout", { Padding = UDim.new(0, 5), SortOrder = Enum.SortOrder.LayoutOrder }, eList)
local eCountLbl = mk("TextLabel", { Position = UDim2.new(0, 0, 1, -88), Size = UDim2.new(0.55, 0, 0, 20), BackgroundTransparency = 1, Font = FONT, TextSize = 11, TextColor3 = Pal.dim, TextXAlignment = Enum.TextXAlignment.Left, Text = "" }, eRight)
local eApplyBtn = actionBtn("✔ Pasang", 0, 0.48, Pal.accent, eRight)
local eClearBtn = actionBtn("✕ Lepas", 0.52, 0.48, Pal.danger, eRight)
paintHover(eApplyBtn, function() return Pal.accent end, function() return Pal.applyH end)
paintHover(eClearBtn, function() return Pal.danger end, function() return Pal.clearH end)

-- ===== body Unusual =====
local bodyUnusual = mk("Frame", {
  Position = UDim2.new(0, 0, 0, 88), Size = UDim2.new(1, 0, 1, -160),
  BackgroundTransparency = 1, Visible = false,
}, main)
local uLeft = mk("Frame", { Size = UDim2.new(0.46, -8, 1, 0), BackgroundColor3 = Pal.panel, BorderSizePixel = 0 }, bodyUnusual)
mk("UICorner", { CornerRadius = UDim.new(0, 8) }, uLeft)
mk("UIPadding", { PaddingTop = UDim.new(0, 10), PaddingLeft = UDim.new(0, 10), PaddingRight = UDim.new(0, 10), PaddingBottom = UDim.new(0, 10) }, uLeft)
mk("TextLabel", { Size = UDim2.new(1, 0, 0, 22), BackgroundTransparency = 1, Text = "CURRENT  (unusual terpasang)", Font = FONTB, TextSize = 13, TextColor3 = Pal.text, TextXAlignment = Enum.TextXAlignment.Left }, uLeft)
local uCard = mk("TextButton", { Position = UDim2.new(0, 0, 0, 30), Size = UDim2.new(1, 0, 0, 64), BackgroundColor3 = Pal.card, BorderSizePixel = 0, Text = "", AutoButtonColor = false }, uLeft)
mk("UICorner", { CornerRadius = UDim.new(0, 6) }, uCard)
local uStroke = mk("UIStroke", { Color = Pal.accent, Thickness = 1 }, uCard)
local uLbl = mk("TextLabel", { Position = UDim2.new(0, 10, 0, 6), Size = UDim2.new(1, -20, 0, 22), BackgroundTransparency = 1, Font = FONTB, TextSize = 13, TextColor3 = Pal.text, TextXAlignment = Enum.TextXAlignment.Left, TextTruncate = Enum.TextTruncate.AtEnd, Text = "UnusualSlot: -" }, uCard)
local uSub = mk("TextLabel", { Position = UDim2.new(0, 10, 0, 30), Size = UDim2.new(1, -20, 0, 20), BackgroundTransparency = 1, Font = FONT, TextSize = 12, TextColor3 = Pal.accent, TextXAlignment = Enum.TextXAlignment.Left, TextTruncate = Enum.TextTruncate.AtEnd, Text = "-> -" }, uCard)
mk("TextLabel", { Position = UDim2.new(0, 0, 0, 102), Size = UDim2.new(1, 0, 1, -102), BackgroundTransparency = 1, Font = FONT, TextSize = 11, TextColor3 = Pal.dim, TextWrapped = true, TextYAlignment = Enum.TextYAlignment.Top, Text = "Equip SpawnHalo seperti biasa, visual diganti client-side. Unequip + equip ulang tiap ganti mapping." }, uLeft)
local uRight = mk("Frame", { AnchorPoint = Vector2.new(1, 0), Position = UDim2.fromScale(1, 0), Size = UDim2.new(0.54, -8, 1, 0), BackgroundColor3 = Pal.panel, BorderSizePixel = 0 }, bodyUnusual)
mk("UICorner", { CornerRadius = UDim.new(0, 8) }, uRight)
mk("UIPadding", { PaddingTop = UDim.new(0, 10), PaddingLeft = UDim.new(0, 10), PaddingRight = UDim.new(0, 10), PaddingBottom = UDim.new(0, 10) }, uRight)
mk("TextLabel", { Size = UDim2.new(1, 0, 0, 22), BackgroundTransparency = 1, Text = "SELECT  (pilih pengganti)", Font = FONTB, TextSize = 13, TextColor3 = Pal.text, TextXAlignment = Enum.TextXAlignment.Left }, uRight)
local uSearch = mk("TextBox", { Position = UDim2.new(0, 0, 0, 30), Size = UDim2.new(1, 0, 0, 30), BackgroundColor3 = Pal.card, TextColor3 = Pal.text, PlaceholderColor3 = Pal.dim, PlaceholderText = "  Cari unusual...", Text = "", Font = FONT, TextSize = 13, ClearTextOnFocus = false }, uRight)
mk("UICorner", { CornerRadius = UDim.new(0, 6) }, uSearch)
local uList = mk("ScrollingFrame", { Position = UDim2.new(0, 0, 0, 68), Size = UDim2.new(1, 0, 1, -158), BackgroundTransparency = 1, ScrollBarThickness = 5, ScrollBarImageColor3 = Pal.accent, CanvasSize = UDim2.new(0, 0, 0, 0), AutomaticCanvasSize = Enum.AutomaticSize.Y }, uRight)
mk("UIListLayout", { Padding = UDim.new(0, 5), SortOrder = Enum.SortOrder.LayoutOrder }, uList)
local uCountLbl = mk("TextLabel", { Position = UDim2.new(0, 0, 1, -88), Size = UDim2.new(1, 0, 0, 20), BackgroundTransparency = 1, Font = FONT, TextSize = 11, TextColor3 = Pal.dim, TextXAlignment = Enum.TextXAlignment.Left, Text = "" }, uRight)
local uApplyBtn = actionBtn("✔ Pasang", 0, 0.48, Pal.accent, uRight)
local uClearBtn = actionBtn("✕ Lepas", 0.52, 0.48, Pal.danger, uRight)
paintHover(uApplyBtn, function() return Pal.accent end, function() return Pal.applyH end)
paintHover(uClearBtn, function() return Pal.danger end, function() return Pal.clearH end)

-- tema (5 swatch, di kanan tiap tab agar sama spt 0.1)
local function makeSwatches(parent)
  local lbl = mk("TextLabel", { Position = UDim2.new(0, 0, 1, -118), Size = UDim2.new(1, 0, 0, 16), BackgroundTransparency = 1, Text = "TEMA", Font = FONTB, TextSize = 11, TextColor3 = Pal.dim, TextXAlignment = Enum.TextXAlignment.Left }, parent)
  local sws, strokes = {}, {}
  for i = 1, 5 do
    local sw = mk("TextButton", { Position = UDim2.new((i - 1) * 0.2, 0, 1, -102), Size = UDim2.new(0.184, 0, 0, 26), Text = Themes[i].name, Font = FONTB, TextSize = 10, TextColor3 = Color3.fromRGB(255, 255, 255), BackgroundColor3 = C3(Themes[i].accent), BorderSizePixel = 0, AutoButtonColor = false }, parent)
    mk("UICorner", { CornerRadius = UDim.new(0, 6) }, sw)
    strokes[i] = mk("UIStroke", { Color = Color3.fromRGB(255, 255, 255), Thickness = 2, Transparency = 1 }, sw)
    sws[i] = sw
  end
  strokes[1].Transparency = 0
  return lbl, sws, strokes
end
local eThemeLbl, eSwatches, eStrokes = makeSwatches(eRight)
local uThemeLbl, uSwatches, uStrokes = makeSwatches(uRight)

local status = mk("TextLabel", { Position = UDim2.new(0, 0, 1, -58), Size = UDim2.new(1, 0, 0, 32), BackgroundTransparency = 1, Font = FONT, TextSize = 12, TextColor3 = Pal.dim, TextWrapped = true, TextYAlignment = Enum.TextYAlignment.Top, Text = "" }, main)
local credit = mk("TextLabel", { Position = UDim2.new(0, 0, 1, -22), Size = UDim2.new(1, 0, 0, 18), BackgroundTransparency = 1, Font = FONT, TextSize = 11, TextColor3 = Pal.dim, Text = "made by @ackley" }, main)

local bubbleHidden, minimized, open = false, false, false
local bubble = mk("TextButton", { Position = UDim2.new(1, -72, 0.5, -26), Size = UDim2.new(0, 52, 0, 52), Text = "", BackgroundColor3 = Pal.accent, BorderSizePixel = 0, AutoButtonColor = false, Visible = false }, gui)
mk("UICorner", { CornerRadius = UDim.new(1, 0) }, bubble)
mk("TextLabel", { Size = UDim2.new(1, 0, 1, 0), BackgroundTransparency = 1, Text = "K", Font = FONTBLACK, TextSize = 26, TextColor3 = Color3.fromRGB(255, 255, 255) }, bubble)
local bubbleX = mk("TextButton", { Position = UDim2.new(1, -16, 0, -4), Size = UDim2.new(0, 20, 0, 20), Text = "✕", Font = FONTB, TextSize = 10, TextColor3 = Color3.fromRGB(255, 255, 255), BackgroundColor3 = Pal.danger, BorderSizePixel = 0, AutoButtonColor = false }, bubble)
mk("UICorner", { CornerRadius = UDim.new(1, 0) }, bubbleX)

local function setStatus(msg, isErr)
  status.Text = msg
  status.TextColor3 = isErr and Pal.danger or Pal.dim
end

-- state emote
local equippedEmotes = getEquippedEmoteNames()
local eSelect, eArmed, eBtns = {}, 1, {}
local function validEmote(name) return name and name ~= "" and emoteByName[name] ~= nil end
local function refreshEmote()
  for i = 1, 12 do
    local rep = _G.EmoteSwapMap[equippedEmotes[i]]
    local b = eBtns[i]
    if b then
      b.Lbl.Text = i .. ". " .. tostring(equippedEmotes[i])
      b.Sub.Text = rep and ("-> " .. rep) or "-> -"
      b.Btn.BackgroundColor3 = (i == eArmed) and Pal.accentD or Pal.card
      b.Stroke.Color = (i == eArmed) and Pal.accent or Pal.panel
    end
  end
end
for i = 1, 12 do
  local card = mk("TextButton", { BackgroundColor3 = Pal.card, BorderSizePixel = 0, Text = "", AutoButtonColor = false, LayoutOrder = i }, eGrid)
  mk("UICorner", { CornerRadius = UDim.new(0, 6) }, card)
  local stroke = mk("UIStroke", { Color = Pal.panel, Thickness = 1 }, card)
  local mono = mk("TextLabel", { Position = UDim2.new(0, 6, 0, 6), Size = UDim2.new(0, 26, 0, 26), BackgroundColor3 = Pal.accentD, TextColor3 = Pal.text, Font = FONTB, TextSize = 12, Text = tostring(i), BorderSizePixel = 0 }, card)
  mk("UICorner", { CornerRadius = UDim.new(1, 0) }, mono)
  local lbl = mk("TextLabel", { Position = UDim2.new(0, 38, 0, 4), Size = UDim2.new(1, -44, 0, 18), BackgroundTransparency = 1, Font = FONTB, TextSize = 12, TextColor3 = Pal.text, TextXAlignment = Enum.TextXAlignment.Left, TextTruncate = Enum.TextTruncate.AtEnd, Text = i .. ". -" }, card)
  local sub = mk("TextLabel", { Position = UDim2.new(0, 38, 0, 22), Size = UDim2.new(1, -44, 0, 16), BackgroundTransparency = 1, Font = FONT, TextSize = 11, TextColor3 = Pal.accent, TextXAlignment = Enum.TextXAlignment.Left, TextTruncate = Enum.TextTruncate.AtEnd, Text = "-> -" }, card)
  paintHover(card, function() return (eArmed == i) and Pal.accentD or Pal.card end, function() return Pal.hover end)
  eBtns[i] = { Btn = card, Lbl = lbl, Sub = sub, Stroke = stroke, Mono = mono }
  card.MouseButton1Click:Connect(function()
    eArmed = i
    setStatus("Slot Emote " .. i .. " dipilih (" .. tostring(equippedEmotes[i]) .. "). Pilih pengganti dari daftar.")
    refreshEmote()
  end)
end
local function buildEmoteList(filter)
  filter = string.lower(filter or "")
  for _, c in ipairs(eList:GetChildren()) do if c:IsA("TextButton") then c:Destroy() end end
  local n = 0
  for _, name in ipairs(emoteNames) do
    if filter == "" or string.find(string.lower(name), filter, 1, true) then
      n += 1
      local row = mk("TextButton", { Size = UDim2.new(1, -6, 0, 30), BackgroundColor3 = Pal.card, BorderSizePixel = 0, Text = "", AutoButtonColor = false }, eList)
      mk("UICorner", { CornerRadius = UDim.new(0, 6) }, row)
      local badge = mk("TextLabel", { Position = UDim2.new(0, 8, 0, 3), Size = UDim2.new(0, 24, 0, 24), BackgroundColor3 = Pal.accentD, TextColor3 = Pal.text, Font = FONTB, TextSize = 11, Text = string.upper(string.sub(name, 1, 1)), BorderSizePixel = 0 }, row)
      mk("UICorner", { CornerRadius = UDim.new(1, 0) }, badge)
      mk("TextLabel", { Position = UDim2.new(0, 38, 0, 0), Size = UDim2.new(1, -44, 1, 0), BackgroundTransparency = 1, Font = FONT, TextSize = 12, TextColor3 = Pal.text, TextXAlignment = Enum.TextXAlignment.Left, TextTruncate = Enum.TextTruncate.AtEnd, Text = name }, row)
      paintHover(row, function() return Pal.card end, function() return Pal.hover end)
      row.MouseButton1Click:Connect(function()
        local cur = equippedEmotes[eArmed]
        if not validEmote(name) then setStatus("Gagal: emote tidak ditemukan.", true) return end
        if not cur or cur == "-" then setStatus("Slot " .. eArmed .. " kosong.", true) return end
        _G.EmoteSwapMap[cur] = name
        eSelect[eArmed] = name
        setStatus("OK " .. cur .. " -> " .. name .. " (slot " .. eArmed .. ", langsung aktif).")
        refreshEmote()
      end)
    end
  end
  eCountLbl.Text = n .. " / " .. #emoteNames .. " emote"
end
eSearch:GetPropertyChangedSignal("Text"):Connect(function() buildEmoteList(eSearch.Text) end)
eApplyBtn.MouseButton1Click:Connect(function()
  local cur = equippedEmotes[eArmed]
  if not cur or cur == "-" then setStatus("Slot " .. eArmed .. " kosong.", true) return end
  local pick = eSelect[eArmed] or eSearch.Text
  if not validEmote(pick) then setStatus("Pilih dulu emote dari daftar untuk slot " .. eArmed .. ".", true) return end
  _G.EmoteSwapMap[cur] = pick
  setStatus("OK " .. cur .. " -> " .. pick .. " (slot " .. eArmed .. ").")
  refreshEmote()
end)
eClearBtn.MouseButton1Click:Connect(function()
  local cur = equippedEmotes[eArmed]
  if cur and _G.EmoteSwapMap[cur] then
    _G.EmoteSwapMap[cur] = nil
    eSelect[eArmed] = nil
    setStatus("Mapping slot " .. eArmed .. " (" .. cur .. ") dilepas.")
    refreshEmote()
  else
    setStatus("Slot " .. eArmed .. " tidak punya mapping.", true)
  end
end)

-- state unusual
local uEquippedName, uEquippedId = getEquippedUnusual()
local uPicked = nil
local function validUnusual(name) return name and name ~= "" and unusualByName[name] ~= nil end
local function refreshUnusual()
  uEquippedName, uEquippedId = getEquippedUnusual()
  uLbl.Text = "UnusualSlot: " .. tostring(uEquippedName) .. (uEquippedId and (" (" .. uEquippedId .. ")") or "")
  local rep = _G.UnusualSwapMap[uEquippedName]
  uSub.Text = rep and ("-> " .. rep) or "-> -"
end
local function buildUnusualList(filter)
  filter = string.lower(filter or "")
  for _, c in ipairs(uList:GetChildren()) do if c:IsA("TextButton") then c:Destroy() end end
  local n = 0
  for _, name in ipairs(unusualNames) do
    local d = unusualDisp[name] or name
    if filter == "" or string.find(string.lower(name), filter, 1, true) or string.find(string.lower(d), filter, 1, true) then
      n += 1
      local row = mk("TextButton", { Size = UDim2.new(1, -6, 0, 30), BackgroundColor3 = Pal.card, BorderSizePixel = 0, Text = "", AutoButtonColor = false }, uList)
      mk("UICorner", { CornerRadius = UDim.new(0, 6) }, row)
      local badge = mk("TextLabel", { Position = UDim2.new(0, 8, 0, 3), Size = UDim2.new(0, 24, 0, 24), BackgroundColor3 = Pal.accentD, TextColor3 = Pal.text, Font = FONTB, TextSize = 11, Text = string.upper(string.sub(name, 1, 1)), BorderSizePixel = 0 }, row)
      mk("UICorner", { CornerRadius = UDim.new(1, 0) }, badge)
      mk("TextLabel", { Position = UDim2.new(0, 38, 0, 0), Size = UDim2.new(1, -44, 1, 0), BackgroundTransparency = 1, Font = FONT, TextSize = 12, TextColor3 = Pal.text, TextXAlignment = Enum.TextXAlignment.Left, TextTruncate = Enum.TextTruncate.AtEnd, Text = name }, row)
      paintHover(row, function() return Pal.card end, function() return Pal.hover end)
      row.MouseButton1Click:Connect(function()
        if not validUnusual(name) then setStatus("Gagal: unusual tidak ditemukan.", true) return end
        if not uEquippedName or uEquippedName == "-" then setStatus("UnusualSlot kosong — equip SpawnHalo dulu.", true) return end
        uPicked = name
        _G.UnusualSwapMap[uEquippedName] = name
        _G.UnusualSwapById = buildUnusualIdMap()
        setStatus("OK " .. uEquippedName .. " -> " .. name .. " (equip ulang).")
        refreshUnusual()
      end)
    end
  end
  uCountLbl.Text = n .. " / " .. #unusualNames .. " unusual"
end
uSearch:GetPropertyChangedSignal("Text"):Connect(function() buildUnusualList(uSearch.Text) end)
uApplyBtn.MouseButton1Click:Connect(function()
  if not uEquippedName or uEquippedName == "-" then setStatus("UnusualSlot kosong.", true) return end
  local pick = uPicked or uSearch.Text
  if not validUnusual(pick) then setStatus("Pilih dulu unusual dari daftar.", true) return end
  _G.UnusualSwapMap[uEquippedName] = pick
  _G.UnusualSwapById = buildUnusualIdMap()
  setStatus("OK " .. uEquippedName .. " -> " .. pick .. ". Unequip + equip ulang.")
  refreshUnusual()
end)
uClearBtn.MouseButton1Click:Connect(function()
  if uEquippedName and _G.UnusualSwapMap[uEquippedName] then
    _G.UnusualSwapMap[uEquippedName] = nil
    uPicked = nil
    _G.UnusualSwapById = buildUnusualIdMap()
    setStatus("Mapping " .. uEquippedName .. " dilepas.")
    refreshUnusual()
  else
    setStatus("Tidak punya mapping.", true)
  end
end)

-- tab switch
local function showTab(which)
  local isEmote = which == "emote"
  bodyEmote.Visible = isEmote
  bodyUnusual.Visible = not isEmote
  emoteTabBtn.BackgroundColor3 = isEmote and Pal.accent or Pal.card
  emoteTabBtn.TextColor3 = isEmote and Pal.bg or Pal.text
  unusualTabBtn.BackgroundColor3 = (not isEmote) and Pal.accent or Pal.card
  unusualTabBtn.TextColor3 = (not isEmote) and Pal.bg or Pal.text
  if isEmote then equippedEmotes = getEquippedEmoteNames() refreshEmote() else refreshUnusual() end
end
emoteTabBtn.MouseButton1Click:Connect(function() showTab("emote") end)
unusualTabBtn.MouseButton1Click:Connect(function() showTab("unusual") end)

-- open/min/bubble/drag (sama spt 0.1)
local tweenInfo, basePos, openTween = TweenInfo.new(0.22, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), main.Position, nil
local function updateBubble()
  bubble.Visible = (minimized or (IS_MOBILE and not open)) and not bubbleHidden
end
local function setOpen(v)
  open = v
  if openTween then pcall(function() openTween:Cancel() end) openTween = nil end
  if v then
    if minimized then minimized = false minBtn.Text = "—" end
    equippedEmotes = getEquippedEmoteNames()
    refreshEmote()
    refreshUnusual()
    main.Visible = true
    main.Position = basePos + UDim2.new(0, 0, 0, 24)
    openTween = TweenService:Create(main, tweenInfo, { GroupTransparency = 0, Position = basePos })
    openTween:Play()
  else
    openTween = TweenService:Create(main, tweenInfo, { GroupTransparency = 1, Position = basePos + UDim2.new(0, 0, 0, 24) })
    openTween:Play()
    openTween.Completed:Connect(function()
      if not open then main.Visible = false end
    end)
  end
  updateBubble()
end
local function setMinimized(v)
  minimized = v
  main.Visible = not v
  if not v and not open then open = true end
  updateBubble()
end
minBtn.MouseButton1Click:Connect(function()
  if minimized then setMinimized(false) minBtn.Text = "—" if not open then setOpen(true) end
  else setMinimized(true) minBtn.Text = "+" end
end)
bubble.MouseButton1Click:Connect(function()
  if open and not minimized then setOpen(false)
  else setMinimized(false) minBtn.Text = "—" setOpen(true) end
end)
bubbleX.MouseButton1Click:Connect(function() bubbleHidden = true updateBubble() end)
local function makeDraggable(frame, handle)
  local dragging, start, startPos = false, nil, nil
  handle.InputBegan:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.MouseButton1 then
      dragging, start, startPos = true, input.Position, frame.Position
    end
  end)
  UserInputService.InputChanged:Connect(function(input)
    if dragging and input.UserInputType == Enum.UserInputType.MouseMovement then
      local d = input.Position - start
      frame.Position = startPos + UDim2.new(0, d.X, 0, d.Y)
      if frame == main then basePos = main.Position end
    end
  end)
  UserInputService.InputEnded:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.MouseButton1 then dragging = false end
  end)
end
makeDraggable(main, header)
makeDraggable(bubble, bubble)
_G.KenuyToggleConn = UserInputService.InputBegan:Connect(function(input)
  if input.KeyCode == Enum.KeyCode.RightControl then setOpen(not open) end
end)
local function applyTheme(idx)
  for k, v in pairs(Themes[idx]) do if type(v) == "table" then Pal[k] = C3(v) end end
  main.BackgroundColor3 = Pal.bg
  mainStroke.Color = Pal.accent
  eLeft.BackgroundColor3 = Pal.panel
  eRight.BackgroundColor3 = Pal.panel
  uLeft.BackgroundColor3 = Pal.panel
  uRight.BackgroundColor3 = Pal.panel
  titleLbl.TextColor3 = Pal.accent
  hintLbl.TextColor3 = Pal.dim
  minBtn.BackgroundColor3 = Pal.card
  minBtn.TextColor3 = Pal.accent
  emoteTabBtn.BackgroundColor3 = bodyEmote.Visible and Pal.accent or Pal.card
  unusualTabBtn.BackgroundColor3 = bodyUnusual.Visible and Pal.accent or Pal.card
  eSearch.BackgroundColor3 = Pal.card
  eSearch.TextColor3 = Pal.text
  eSearch.PlaceholderColor3 = Pal.dim
  uSearch.BackgroundColor3 = Pal.card
  uSearch.TextColor3 = Pal.text
  uSearch.PlaceholderColor3 = Pal.dim
  eList.ScrollBarImageColor3 = Pal.accent
  uList.ScrollBarImageColor3 = Pal.accent
  eCountLbl.TextColor3 = Pal.dim
  uCountLbl.TextColor3 = Pal.dim
  eApplyBtn.BackgroundColor3 = Pal.accent
  eApplyBtn.TextColor3 = Pal.bg
  eClearBtn.BackgroundColor3 = Pal.danger
  eClearBtn.TextColor3 = Pal.bg
  uApplyBtn.BackgroundColor3 = Pal.accent
  uApplyBtn.TextColor3 = Pal.bg
  uClearBtn.BackgroundColor3 = Pal.danger
  uClearBtn.TextColor3 = Pal.bg
  bubble.BackgroundColor3 = Pal.accent
  bubbleX.BackgroundColor3 = Pal.danger
  status.TextColor3 = Pal.dim
  credit.TextColor3 = Pal.dim
  for _, b in pairs(eBtns) do
    b.Mono.BackgroundColor3 = Pal.accentD
    b.Mono.TextColor3 = Pal.text
    b.Lbl.TextColor3 = Pal.text
    b.Sub.TextColor3 = Pal.accent
  end
  uCard.BackgroundColor3 = Pal.card
  uLbl.TextColor3 = Pal.text
  uSub.TextColor3 = Pal.accent
  for _, st in ipairs({ eStrokes, uStrokes }) do for j, s in ipairs(st) do s.Transparency = (j == idx) and 0 or 1 end end
  buildEmoteList(eSearch.Text)
  buildUnusualList(uSearch.Text)
  refreshEmote()
  refreshUnusual()
  setStatus("Tema " .. Themes[idx].name .. " aktif.")
end
for _, pack in ipairs({ { eSwatches, 1 }, { uSwatches, 2 } }) do
  local sws = pack[1]
  for i = 1, 5 do
    local idx = i
    sws[idx].MouseButton1Click:Connect(function() applyTheme(idx) end)
  end
end
if IS_MOBILE then hintLbl.Text = "Ketuk K" end
updateBubble()
showTab("emote")
if #emoteNames == 0 and #unusualNames == 0 then
  setStatus("Data emote + unusual kosong.", true)
else
  buildEmoteList("")
  buildUnusualList("")
  refreshEmote()
  refreshUnusual()
  status.Text = #emoteNames .. " emote + " .. #unusualNames .. " unusual terdeteksi. " .. (IS_MOBILE and "Ketuk bubble K." or "Tekan RightCtrl.")
end
print("KenuySwap v0.2 Loaded: " .. #emoteNames .. " emote, " .. #unusualNames .. " unusual")
