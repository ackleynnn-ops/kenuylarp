local ReplicatedStorage = game:GetService("ReplicatedStorage")
local UserInputService = game:GetService("UserInputService")
local TweenService = game:GetService("TweenService")
local IS_MOBILE = UserInputService.TouchEnabled and not UserInputService.KeyboardEnabled

local HAS_HOOK = typeof(hookfunction) == "function"
local HAS_RESTORE = typeof(restorefunction) == "function"
local NO_HOOK = not HAS_HOOK
_G.KenuyHasHook = HAS_HOOK
do
  _G.KenuyFieldPatches = _G.KenuyFieldPatches or {}
  _G.KenuyRestorePatches = function()
    for _, p in ipairs(_G.KenuyFieldPatches) do
      pcall(function()
        pcall(function() setreadonly(p.t, false) end)
        p.t[p.k] = p.orig
      end)
    end
    _G.KenuyFieldPatches = {}
    _G.KenuyTryEquipSolara, _G.KenuyTryUnequipSolara = nil, nil
  end
  _G.KenuyPatchField = function(t, k, fn)
    if type(t) ~= "table" or type(k) ~= "string" or type(fn) ~= "function" then return nil end
    pcall(function() setreadonly(t, false) end)
    local cur = t[k]
    if type(cur) ~= "function" then return nil end
    local already = false
    for _, p in ipairs(_G.KenuyFieldPatches) do if p.t == t and p.k == k then already = true break end end
    if not already then table.insert(_G.KenuyFieldPatches, { t = t, k = k, orig = cur }) end
    local f = fn
    pcall(function() if type(newcclosure) == "function" then f = newcclosure(fn) end end)
    t[k] = f
    return cur
  end

  pcall(_G.KenuyRestorePatches)
end

pcall(function()
  local roots = {}
  pcall(function() local h = gethui and gethui() if h then table.insert(roots, h) end end)
  pcall(function() table.insert(roots, game:GetService("CoreGui")) end)
  pcall(function()
    local pg = game:GetService("Players").LocalPlayer:FindFirstChildOfClass("PlayerGui")
    if pg then table.insert(roots, pg) end
  end)
  for _, root in ipairs(roots) do
    for _, n in ipairs({ "KenuySwapUI", "PrototypeMenu", "EmoteSwapUI", "UnusualSwapUI", "KenuyLarp", "VisualLocalGui", "AvatarLoaderUI" }) do
      local old = root:FindFirstChild(n)
      if old then pcall(function() old:Destroy() end) end
    end
  end
end)
if _G.KenuyToggleConn then pcall(function() _G.KenuyToggleConn:Disconnect() end) _G.KenuyToggleConn = nil end

if _G.AccProtoToggleConn then pcall(function() _G.AccProtoToggleConn:Disconnect() end) _G.AccProtoToggleConn = nil end

local Themes = {
  { name = "Abyss", bg = {16,21,32}, panel = {26,34,50}, card = {33,43,63}, accent = {45,212,191}, accentD = {20,120,110}, text = {235,240,248}, dim = {150,163,184}, danger = {244,113,116}, hover = {45,58,82}, applyH = {94,234,212}, clearH = {252,165,165}, grad = {45,212,191}, gradRot = 45 },
  { name = "Crimson", bg = {24,10,14}, panel = {38,16,22}, card = {52,24,32}, accent = {235,60,80}, accentD = {140,30,45}, text = {255,240,242}, dim = {205,170,178}, danger = {255,140,90}, hover = {70,32,40}, applyH = {255,100,115}, clearH = {255,180,140}, grad = {255,120,90}, gradRot = 45 },
  { name = "Violet", bg = {18,14,32}, panel = {30,24,54}, card = {42,34,74}, accent = {150,110,255}, accentD = {85,60,160}, text = {240,238,255}, dim = {185,178,215}, danger = {255,120,130}, hover = {60,50,105}, applyH = {175,140,255}, clearH = {255,170,180}, grad = {255,120,200}, gradRot = 45 },
  { name = "Emerald", bg = {8,24,20}, panel = {14,38,32}, card = {22,54,46}, accent = {50,220,150}, accentD = {22,130,90}, text = {235,250,244}, dim = {170,200,188}, danger = {250,130,120}, hover = {32,72,60}, applyH = {100,240,180}, clearH = {255,175,165}, grad = {120,230,255}, gradRot = 45 },
  { name = "Amber", bg = {26,20,10}, panel = {42,32,16}, card = {58,44,24}, accent = {245,170,40}, accentD = {150,100,25}, text = {255,246,230}, dim = {210,190,160}, danger = {250,120,100}, hover = {78,60,32}, applyH = {255,200,90}, clearH = {255,175,150}, grad = {255,120,120}, gradRot = 45 },
  { name = "Sunset", bg = {28,14,24}, panel = {46,24,38}, card = {62,34,52}, accent = {255,130,90}, accentD = {150,60,140}, text = {255,242,238}, dim = {215,175,190}, danger = {255,150,120}, hover = {80,44,62}, applyH = {255,160,120}, clearH = {255,190,170}, grad = {255,200,110}, gradRot = 30 },
  { name = "Ocean", bg = {10,20,30}, panel = {16,34,50}, card = {24,48,70}, accent = {80,180,255}, accentD = {40,110,180}, text = {235,245,255}, dim = {160,185,210}, danger = {255,130,130}, hover = {36,66,96}, applyH = {120,210,255}, clearH = {255,180,180}, grad = {90,230,220}, gradRot = 60 },
  { name = "Sakura", bg = {28,16,26}, panel = {48,28,46}, card = {66,40,64}, accent = {255,150,200}, accentD = {170,90,160}, text = {255,242,250}, dim = {220,185,210}, danger = {255,140,150}, hover = {88,56,86}, applyH = {255,180,220}, clearH = {255,190,200}, grad = {180,150,255}, gradRot = 45 },
  { name = "Midnight", bg = {10,12,24}, panel = {18,22,44}, card = {28,34,64}, accent = {110,140,255}, accentD = {70,80,170}, text = {238,242,255}, dim = {170,180,210}, danger = {255,130,140}, hover = {44,54,96}, applyH = {140,170,255}, clearH = {255,175,185}, grad = {150,110,255}, gradRot = 90 },
  { name = "Matcha", bg = {14,22,16}, panel = {24,38,28}, card = {34,54,40}, accent = {170,220,120}, accentD = {90,140,70}, text = {242,250,236}, dim = {185,205,175}, danger = {250,140,120}, hover = {48,72,54}, applyH = {200,240,150}, clearH = {255,180,170}, grad = {120,220,200}, gradRot = 30 },
  { name = "Default", bg = {15,15,15}, panel = {15,15,15}, card = {30,30,30}, accent = {255,191,112}, accentD = {150,110,70}, text = {255,255,255}, dim = {170,170,170}, danger = {255,69,69}, hover = {50,50,50}, applyH = {90,180,90}, clearH = {255,120,120}, grad = {255,114,114}, gradRot = 90 },
}
local themeIdx = _G.KenuyThemeIdx or 1
if type(themeIdx) ~= "number" or themeIdx < 1 or themeIdx > #Themes then themeIdx = 1 end

for _di, _th in ipairs(Themes) do
  if _th.name == "Default" then themeIdx = _di _G.KenuyThemeIdx = _di break end
end
local function C3(t) return Color3.fromRGB(t[1], t[2], t[3]) end
local Pal = {}
for k, v in pairs(Themes[themeIdx]) do if type(v) == "table" and k ~= "grad" then Pal[k] = C3(v) end end
_G.KenuyBgOpacity = _G.KenuyBgOpacity or 90
local function pretty(s)
  s = tostring(s):gsub("(%l)(%u)", "%1 %2"):gsub("%s+", " ")
  return (s:gsub("^%s+", ""):gsub("%s+$", ""))
end

local function registryEntries()
  local ok, reg = pcall(require, ReplicatedStorage.Items.Registry)
  if not ok or type(reg) ~= "table" then return nil end
  local okQ, q = pcall(function() return reg:Query({}) end)
  if not okQ or type(q) ~= "table" or type(q._entries) ~= "table" then return nil end
  return q._entries
end

local emoteByName, emoteNames, nameById = {}, {}, {}
local function scanEmotes()
  emoteByName, emoteNames, nameById = {}, {}, {}
  local seen = {}
  local entries = registryEntries()
  if entries then
    for _, e in pairs(entries) do
      if type(e) == "table" and e.Module and typeof(e.Module) == "Instance" then
        local nm = tostring(e.Module)
        if not seen[nm] and type(e.Categories) == "table" then
          for _, c in pairs(e.Categories) do
            if tostring(c) == "Emotes" then
              seen[nm] = true
              emoteByName[nm] = { inst = e.Module, id = e.Id }
              table.insert(emoteNames, nm)
              break
            end
          end
        end
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

_G.EmoteSwapVariant = _G.EmoteSwapVariant or {}

local function selectionCountOf(name)
  local info = emoteByName[name]
  if not info or not info.inst then return 0 end
  local sel = info.inst:FindFirstChild("Selection")
  if not sel then return 0 end
  return #sel:GetChildren()
end
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

      pcall(function()
        local c = mod:FindFirstChild("Character")
        if c and c:IsA("Model") then _G.EmoteSwapBackup[key].charModel = c:Clone() end
      end)
      pcall(function()
        local c = mod:FindFirstChild("CharacterClassic")
        if c and c:IsA("Model") then _G.EmoteSwapBackup[key].charClassicModel = c:Clone() end
      end)
      _G.EmoteSwapBackup[key].charBackedUp = true
    end

    local _b = _G.EmoteSwapBackup[key]
    if _b and not _b.charBackedUp then
      _b.charBackedUp = true
      pcall(function()
        if _b.charModel == nil then
          local c = mod:FindFirstChild("Character")
          if c and c:IsA("Model") then _b.charModel = c:Clone() end
        end
      end)
      pcall(function()
        if _b.charClassicModel == nil then
          local c = mod:FindFirstChild("CharacterClassic")
          if c and c:IsA("Model") then _b.charClassicModel = c:Clone() end
        end
      end)
    end
  end
  local function copyVariantModels(dstMod, variant)
    for _, n in ipairs({ "Character", "CharacterClassic" }) do
      local src = variant:FindFirstChild(n)
      if src and src:IsA("Model") then
        local cur = dstMod:FindFirstChild(n)
        if cur then pcall(function() cur:Destroy() end) end
        pcall(function()
          local cl = src:Clone()
          cl.Parent = dstMod
        end)
      end
    end
  end
  local function restoreVariantModels(mod, b)
    if not b.charBackedUp then return end
    for _, n in ipairs({ "Character", "CharacterClassic" }) do
      local key = (n == "Character") and "charModel" or "charClassicModel"
      local cur = mod:FindFirstChild(n)
      if cur then pcall(function() cur:Destroy() end) end
      if b[key] and typeof(b[key]) == "Instance" then
        pcall(function()
          local cl = b[key]:Clone()
          cl.Parent = mod
        end)
      end
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
  if HAS_RESTORE then pcall(function() restorefunction(svc.SetEmote) end) end

  _G.KenuyEmoteCore = { backup = backup, copyVariantModels = copyVariantModels, restoreVariantModels = restoreVariantModels, displayNameOf = displayNameOf, variantAnimId = variantAnimId }

  local old
  local function kenuyOnSetEmote(self, p2, p3, ...)
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

          pcall(function()
            local sel = rep:FindFirstChild("Selection")
            if sel and #sel:GetChildren() > 0 then
              local vars = sel:GetChildren()
              table.sort(vars, function(a, b) return tostring(a.Name) < tostring(b.Name) end)
              local v = vars[1]
              local vid = _G.EmoteSwapVariant and _G.EmoteSwapVariant[p3.Name]
              if type(vid) == "number" and vars[vid] then
                v = vars[vid]
              else
                v = vars[rng:NextInteger(1, #vars)]
              end
              local r6, r15 = variantAnimId(v, "R6"), variantAnimId(v, "R15")
              if r6 or r15 then
                if r6 and p3:FindFirstChild("AnimationR6") then p3.AnimationR6.AnimationId = r6 end
                if r6 and p3:FindFirstChild("AnimationClassic") then p3.AnimationClassic.AnimationId = r6 end
                if r15 and p3:FindFirstChild("Animation") then p3.Animation.AnimationId = r15 end
                pcall(function()
                  local src, dst = require(p3).EmoteInfo, require(rep).EmoteInfo
                  if src and dst and type(src.Sound) == type(dst.Sound) then src.Sound = dst.Sound end
                end)
                require(p3).AppearanceInfo.Name = displayNameOf(rep, target)
                copyVariantModels(p3, v)
              end
            end
          end)
        end
      elseif _G.EmoteSwapBackup[p3:GetFullName()] then
        pcall(function()
          local b = _G.EmoteSwapBackup[p3:GetFullName()]
          if b.classic and p3:FindFirstChild("AnimationClassic") then p3.AnimationClassic.AnimationId = b.classic end
          if b.r6 and p3:FindFirstChild("AnimationR6") then p3.AnimationR6.AnimationId = b.r6 end
          if b.anim and p3:FindFirstChild("Animation") then p3.Animation.AnimationId = b.anim end
          if b.dispName ~= nil then require(p3).AppearanceInfo.Name = b.dispName end
          if b.sound ~= nil then require(p3).EmoteInfo.Sound = b.sound end
          restoreVariantModels(p3, b)
        end)
      end
    end
    return old(self, p2, p3, ...)
  end
  if HAS_HOOK then
    old = hookfunction(svc.SetEmote, kenuyOnSetEmote)
  else

    old = svc.SetEmote
    _G.KenuyPatchField(svc, "SetEmote", kenuyOnSetEmote)
  end
end

local function kenuyEmoteNestedIds(mod)
  local ids = {}
  pcall(function()
    local af = mod:FindFirstChild("Animations")
    if af then
      for _, rig in ipairs({ "R6", "R15" }) do
        local f = af:FindFirstChild(rig)
        if f then
          for _, an in ipairs({ "Animation", "Intro" }) do
            local a = f:FindFirstChild(an)
            if a and a:IsA("Animation") then ids[rig .. "/" .. an] = a.AnimationId end
          end
        end
      end
    end
  end)
  return ids
end
local function kenuyEmoteWriteNested(slot, ids)
  if type(ids) ~= "table" then return end
  pcall(function()
    local af = slot:FindFirstChild("Animations")
    if not af then return end
    for _, rig in ipairs({ "R6", "R15" }) do
      local f = af:FindFirstChild(rig)
      if f then
        for _, an in ipairs({ "Animation", "Intro" }) do
          local a = f:FindFirstChild(an)
          local v = ids[rig .. "/" .. an]
          if a and a:IsA("Animation") and v ~= nil then a.AnimationId = v end
        end
      end
    end
  end)
end

local function kenuyEmoteEnsureTop(slot, b, ch)
  local s = slot:FindFirstChild(ch)
  if not (s and s:IsA("Animation")) then
    b.createdTop = b.createdTop or {}
    b.createdTop[ch] = true
    local ok, ni = pcall(function()
      local x = Instance.new("Animation")
      x.Name = ch
      x.Parent = slot
      return x
    end)
    if ok and ni then return ni end
    return nil
  end
  return s
end

local function kenuyEmoteMergeNested(slot, rep, b)
  local repAF = rep:FindFirstChild("Animations")
  if not repAF then return end
  local slotAF = slot:FindFirstChild("Animations")
  if not slotAF then
    b.createdAF = true
    pcall(function()
      local cl = repAF:Clone()
      cl.Parent = slot
    end)
    return
  end
  for _, rig in ipairs({ "R6", "R15" }) do
    local rf = repAF:FindFirstChild(rig)
    if rf then
      local sf = slotAF:FindFirstChild(rig)
      if not sf then
        b.createdRig = b.createdRig or {}
        b.createdRig[rig] = true
        pcall(function()
          local cl = rf:Clone()
          cl.Parent = slotAF
        end)
      else
        for _, an in ipairs({ "Animation", "Intro" }) do
          local ra = rf:FindFirstChild(an)
          local sa = sf:FindFirstChild(an)
          if ra and ra:IsA("Animation") and ra.AnimationId ~= "" then
            if not (sa and sa:IsA("Animation")) then
              b.createdAnim = b.createdAnim or {}
              b.createdAnim[rig .. "/" .. an] = true
              pcall(function()
                local ni = Instance.new("Animation")
                ni.Name = an
                ni.AnimationId = ra.AnimationId
                ni.Parent = sf
              end)
            else
              sa.AnimationId = ra.AnimationId
            end
          end
        end
      end
    end
  end
end

local function kenuyNormSoundIds(v)
  local list = {}
  local function push(x)
    local d = tostring(x or ""):match("(%d+)")
    if d then table.insert(list, "rbxassetid://" .. d) end
  end
  if type(v) == "table" then for _, x in ipairs(v) do push(x) end
  elseif v ~= nil then push(v) end
  return list
end

local function kenuyWriteSound(slot, rep, b)
  pcall(function()
    local s, r = require(slot), require(rep)
    if s and r and r.EmoteInfo then
      pcall(function() setreadonly(s, false) end)
      pcall(function() if s.EmoteInfo then setreadonly(s.EmoteInfo, false) end end)
      if s.EmoteInfo == nil then s.EmoteInfo = {} end
      s.EmoteInfo.Sound = r.EmoteInfo.Sound
    end
  end)
  pcall(function()
    b.soundKids = b.soundKids or {}
    for _, c in ipairs(slot:GetChildren()) do
      if c:IsA("Sound") and b.soundKids[c.Name] == nil then
        b.soundKids[c.Name] = c:Clone()
        c:Destroy()
      end
    end
    for _, c in ipairs(rep:GetChildren()) do
      if c:IsA("Sound") then
        local cl = c:Clone()
        cl.Parent = slot
      end
    end
  end)
end
_G.KenuyDirectApplyEmote = function(curName, targetName)
  if not (curName and targetName) then return false end
  if not emoteByName[targetName] then scanEmotes() end
  local tinfo, sinfo = emoteByName[targetName], emoteByName[curName]
  if not (tinfo and sinfo and tinfo.inst and sinfo.inst) then return false end
  local rep, slot = tinfo.inst, sinfo.inst
  local core = _G.KenuyEmoteCore
  if not core then return false end
  pcall(function() core.backup(slot) end)
  local b = _G.EmoteSwapBackup[slot:GetFullName()]
  if not b then return false end
  if b.nested == nil then b.nested = kenuyEmoteNestedIds(slot) end
  local okW = false
  if rep:FindFirstChild("Animation") or rep:FindFirstChild("Animations") then

    okW = true
    pcall(function()
      for _, ch in ipairs({ "AnimationR6", "AnimationClassic", "Animation" }) do
        local r = rep:FindFirstChild(ch)
        if r and r:IsA("Animation") and r.AnimationId ~= "" then
          local s = kenuyEmoteEnsureTop(slot, b, ch)
          if s then s.AnimationId = r.AnimationId end
        end
      end
    end)
    pcall(function() kenuyEmoteMergeNested(slot, rep, b) end)
    pcall(function() kenuyWriteSound(slot, rep, b) end)
    pcall(function() require(slot).AppearanceInfo.Name = core.displayNameOf(rep, targetName) end)
    pcall(function() core.copyVariantModels(slot, rep) end)
  else

    pcall(function()
      local sel = rep:FindFirstChild("Selection")
      if sel and #sel:GetChildren() > 0 then
        local vars = sel:GetChildren()
        table.sort(vars, function(a, c) return tostring(a.Name) < tostring(c.Name) end)
        local v = vars[1]
        local vid = _G.EmoteSwapVariant and _G.EmoteSwapVariant[curName]
        if type(vid) == "number" and vars[vid] then v = vars[vid]
        else v = vars[rng:NextInteger(1, #vars)] end
        local r6, r15 = core.variantAnimId(v, "R6"), core.variantAnimId(v, "R15")
        if r6 or r15 then
          if r6 then
            local a6 = kenuyEmoteEnsureTop(slot, b, "AnimationR6")
            if a6 then a6.AnimationId = r6 end
            local ac = kenuyEmoteEnsureTop(slot, b, "AnimationClassic")
            if ac then ac.AnimationId = r6 end
          end
          if r15 then
            local a15 = kenuyEmoteEnsureTop(slot, b, "Animation")
            if a15 then a15.AnimationId = r15 end
          end
          pcall(function() kenuyWriteSound(slot, rep, b) end)
          require(slot).AppearanceInfo.Name = core.displayNameOf(rep, targetName)
          core.copyVariantModels(slot, v)
          okW = true
        end
      end
    end)
  end

  if okW then
    _G.KenuySoundSwap = _G.KenuySoundSwap or {}
    local olds = kenuyNormSoundIds(b.sound)
    local news = {}
    pcall(function()
      local rm = require(rep)
      if rm and rm.EmoteInfo then news = kenuyNormSoundIds(rm.EmoteInfo.Sound) end
    end)
    if #news > 0 and #olds > 0 then
      _G.KenuySoundSwap[slot:GetFullName()] = { old = olds, new = news }
    else
      _G.KenuySoundSwap[slot:GetFullName()] = nil
    end
  end
  return okW
end
_G.KenuyDirectRestoreEmote = function(curName)
  local sinfo = emoteByName[curName]
  if not (sinfo and sinfo.inst) then return false end
  local slot = sinfo.inst
  local core = _G.KenuyEmoteCore
  local b = _G.EmoteSwapBackup[slot:GetFullName()]
  if not (core and b) then return false end
  pcall(function()
    pcall(function()
      local m0 = require(slot)
      setreadonly(m0, false)
      if m0.EmoteInfo then setreadonly(m0.EmoteInfo, false) end
      if m0.AppearanceInfo then setreadonly(m0.AppearanceInfo, false) end
    end)
    if b.classic and slot:FindFirstChild("AnimationClassic") then slot.AnimationClassic.AnimationId = b.classic end
    if b.r6 and slot:FindFirstChild("AnimationR6") then slot.AnimationR6.AnimationId = b.r6 end
    if b.anim and slot:FindFirstChild("Animation") then slot.Animation.AnimationId = b.anim end
    if type(b.createdTop) == "table" then
      for ch in pairs(b.createdTop) do
        local a = slot:FindFirstChild(ch)
        if a and a:IsA("Animation") then pcall(function() a:Destroy() end) end
      end
    end
    if b.createdAF then
      local af = slot:FindFirstChild("Animations")
      if af then pcall(function() af:Destroy() end) end
    else
      if type(b.createdRig) == "table" then
        local af = slot:FindFirstChild("Animations")
        if af then
          for rig in pairs(b.createdRig) do
            local f = af:FindFirstChild(rig)
            if f then pcall(function() f:Destroy() end) end
          end
        end
      end
      if type(b.createdAnim) == "table" then
        local af = slot:FindFirstChild("Animations")
        if af then
          for key in pairs(b.createdAnim) do
            local rig, an = string.match(key, "^(.-)/(.+)$")
            local sf = rig and af:FindFirstChild(rig)
            local sa = sf and an and sf:FindFirstChild(an)
            if sa and sa:IsA("Animation") then pcall(function() sa:Destroy() end) end
          end
        end
      end
    end
    if type(b.nested) == "table" then kenuyEmoteWriteNested(slot, b.nested) end
    if b.dispName ~= nil then require(slot).AppearanceInfo.Name = b.dispName end
    if b.sound ~= nil then require(slot).EmoteInfo.Sound = b.sound end
    if type(b.soundKids) == "table" then
      for _, c in ipairs(slot:GetChildren()) do
        if c:IsA("Sound") then pcall(function() c:Destroy() end) end
      end
      for _, cl in pairs(b.soundKids) do
        if typeof(cl) == "Instance" then
          pcall(function()
            local nc = cl:Clone()
            nc.Parent = slot
          end)
        end
      end
    end
    core.restoreVariantModels(slot, b)
    if type(_G.KenuySoundSwap) == "table" then _G.KenuySoundSwap[slot:GetFullName()] = nil end
  end)
  return true
end

local function kenuyWheelEmotes()
  local out = {}
  pcall(function()
    local pg = game:GetService("Players").LocalPlayer:FindFirstChildOfClass("PlayerGui")
    if not pg then return end
    local n = pg:FindFirstChild("Game")
    if n then n = n:FindFirstChild("HUD") end
    if n then n = n:FindFirstChild("Interactors") end
    if n then n = n:FindFirstChild("Popups") end
    if n then n = n:FindFirstChild("Emote") end
    if not n then return end
    local function readWheel(wheel, base)
      if not wheel then return end
      for _, child in ipairs(wheel:GetChildren()) do
        local idx = tonumber(string.match(child.Name, "^Emote(%d+)$"))
        if idx then
          local label = nil
          for _, d in ipairs(child:GetDescendants()) do
            if d:IsA("TextLabel") and d.Name == "TextLabel" and tostring(d.Text) ~= "" then label = tostring(d.Text) break end
          end
          if not label then
            for _, d in ipairs(child:GetDescendants()) do
              if (d:IsA("TextLabel") or d:IsA("TextButton")) and tostring(d.Text) ~= "" and not tonumber(tostring(d.Text)) then label = tostring(d.Text) break end
            end
          end
          if label and label ~= "" then out[base + idx] = label end
        end
      end
    end
    readWheel(n:FindFirstChild("Wheel"), 0)
    readWheel(n:FindFirstChild("Wheel2"), 6)
  end)
  return out
end
local function kenuyModuleFromDisplay(disp)
  if not disp or disp == "" then return nil end
  local nospace = tostring(disp):gsub("%s+", "")
  for _, name in ipairs(emoteNames) do
    if name == nospace then return name end
  end
  for _, name in ipairs(emoteNames) do
    if string.lower(name) == string.lower(nospace) then return name end
  end
  for _, name in ipairs(emoteNames) do
    local info = emoteByName[name]
    if info then
      local dn = nil
      pcall(function() dn = require(info.inst).AppearanceInfo.Name end)
      if dn == disp then return name end
      if pretty(name) == disp then return name end
    end
  end
  return nil
end

_G.KenuyWheelOrig = _G.KenuyWheelOrig or {}
_G.KenuyPaintWheel = function()
  local pg = game:GetService("Players").LocalPlayer:FindFirstChildOfClass("PlayerGui")
  if not pg then return 0 end
  local n = pg:FindFirstChild("Game")
  if n then n = n:FindFirstChild("HUD") end
  if n then n = n:FindFirstChild("Interactors") end
  if n then n = n:FindFirstChild("Popups") end
  if n then n = n:FindFirstChild("Emote") end
  if not n then return 0 end
  local count = 0
  for _, wname in ipairs({ "Wheel", "Wheel2" }) do
    local w = n:FindFirstChild(wname)
    if w then
      for _, child in ipairs(w:GetChildren()) do
        if tonumber(string.match(child.Name, "^Emote(%d+)$")) then
          local lbl = nil
          for _, d in ipairs(child:GetDescendants()) do
            if d:IsA("TextLabel") and d.Name == "TextLabel" and tostring(d.Text) ~= "" then lbl = d break end
          end
          if lbl then
            local key = lbl:GetFullName()
            local orig = _G.KenuyWheelOrig[key]
            local mod = (orig and kenuyModuleFromDisplay(orig)) or kenuyModuleFromDisplay(tostring(lbl.Text))
            local want = mod and (_G.EmoteSwapMap or {})[mod]
            if want then
              if _G.KenuyWheelOrig[key] == nil then _G.KenuyWheelOrig[key] = tostring(lbl.Text) end
              local tinfo = emoteByName[want]
              local dn = nil
              if tinfo then pcall(function() dn = require(tinfo.inst).AppearanceInfo.Name end) end
              if type(dn) ~= "string" or dn == "" then dn = pretty(want) end
              if lbl.Text ~= dn then lbl.Text = dn count = count + 1 end
            elseif orig then
              lbl.Text = orig
              _G.KenuyWheelOrig[key] = nil
              count = count + 1
            end
          end
        end
      end
    end
  end
  return count
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

  pcall(function()
    local wheel = kenuyWheelEmotes()
    for idx, disp in pairs(wheel) do
      if idx >= 1 and idx <= 12 and (not out[idx] or out[idx] == "-") then
        local m = kenuyModuleFromDisplay(disp)
        if m then out[idx] = m end
      end
    end
    for i = 1, 12 do if not out[i] then out[i] = "-" end end
  end)
  return out
end

local unusualByName, unusualNames, unusualDisp = {}, {}, {}
local function scanUnusuals()
  unusualByName, unusualNames, unusualDisp = {}, {}, {}
  local seen = {}
  local entries = registryEntries()
  if entries then
    for _, e in pairs(entries) do
      if type(e) == "table" and e.Module and typeof(e.Module) == "Instance" then
        local nm = tostring(e.Module)
        if not seen[nm] then
          local ok, m = pcall(require, e.Module)
          if ok and type(m) == "table" and m.EquipInfo and tostring(m.EquipInfo.SlotType) == "Unusual" then
            seen[nm] = true
            unusualByName[nm] = { inst = e.Module }
            table.insert(unusualNames, nm)
            local dn
            pcall(function() dn = m.AppearanceInfo and m.AppearanceInfo.Name end)
            unusualDisp[nm] = (type(dn) == "string" and dn ~= "" and dn) or pretty(nm)
          end
        end
      end
    end
  end
  table.sort(unusualNames)
  return #unusualNames
end
scanUnusuals()
do local t = 0 while #unusualNames == 0 and t < 30 do task.wait(1) t += 1 scanUnusuals() end end

local cis = require(ReplicatedStorage.Services.Items.ClientItemService)
local unameToId = {}
pcall(function()
  local maxId = 3000
  pcall(function() maxId = #cis.IDs + 100 end)
  for i = 1, maxId do
    local ok, nm = pcall(function() return cis.IDs[i] end)
    if ok and nm ~= nil then
      local s = tostring(nm)
      if s ~= "" and s ~= "nil" and not unameToId[s] then
        unameToId[s] = i
      end
    end
  end
end)

_G.UnusualSwapMap = {}
local function buildUnusualIdMap()
  local m = {}
  for ownedName, wantName in pairs(_G.UnusualSwapMap) do
    local oid, wid = unameToId[ownedName], unameToId[wantName]
    if oid and wid then
      m[oid] = wid
    end
  end
  return m
end
_G.UnusualSwapById = buildUnusualIdMap()

_G.UnusualSwapBackup = _G.UnusualSwapBackup or {}
_G.KenuyDirectApplyUnusual = function(ownedName, wantName)
  if not (ownedName and wantName) then return false end
  if not unusualByName[wantName] then scanUnusuals() end
  local oinfo, winfo = unusualByName[ownedName], unusualByName[wantName]
  if not (oinfo and winfo and oinfo.inst and winfo.inst) then return false end
  local omod, wmod = oinfo.inst, winfo.inst
  local key = omod:GetFullName()
  if not _G.UnusualSwapBackup[key] then
    local bk = {}
    pcall(function()
      for _, n in ipairs({ "Character", "CharacterClassic" }) do
        local m = omod:FindFirstChild(n)
        if m and m:IsA("Model") then bk[n] = m:Clone() end
      end
    end)
    pcall(function()
      local m = require(omod)
      if m.AppearanceInfo then bk.dispName, bk.icon = m.AppearanceInfo.Name, m.AppearanceInfo.Icon end
      if type(m.CosmeticInfo) == "table" then
        bk.cosmetic = {}
        for k, v in pairs(m.CosmeticInfo) do bk.cosmetic[k] = v end
      end
    end)
    _G.UnusualSwapBackup[key] = bk
  end
  pcall(function()
    for _, n in ipairs({ "Character", "CharacterClassic" }) do
      local src = wmod:FindFirstChild(n)
      if src and src:IsA("Model") then
        local cur = omod:FindFirstChild(n)
        if cur then cur:Destroy() end
        local cl = src:Clone()
        cl.Parent = omod
      end
    end
  end)
  pcall(function()
    local mo, mw = require(omod), require(wmod)
    pcall(function() setreadonly(mo, false) end)
    pcall(function() if mo.AppearanceInfo then setreadonly(mo.AppearanceInfo, false) end end)
    pcall(function() if mo.CosmeticInfo then setreadonly(mo.CosmeticInfo, false) end end)
    if mw.AppearanceInfo then
      if mo.AppearanceInfo == nil then mo.AppearanceInfo = {} end
      if mw.AppearanceInfo.Name ~= nil then mo.AppearanceInfo.Name = mw.AppearanceInfo.Name end
      if mw.AppearanceInfo.Icon ~= nil then mo.AppearanceInfo.Icon = mw.AppearanceInfo.Icon end
    end
    if type(mw.CosmeticInfo) == "table" then
      if type(mo.CosmeticInfo) ~= "table" then mo.CosmeticInfo = {} end
      for k, v in pairs(mw.CosmeticInfo) do mo.CosmeticInfo[k] = v end
    end
  end)
  return true
end
_G.KenuyDirectRestoreUnusual = function(ownedName)
  local oinfo = unusualByName[ownedName]
  if not (oinfo and oinfo.inst) then return false end
  local omod = oinfo.inst
  local bk = _G.UnusualSwapBackup[omod:GetFullName()]
  if not bk then return false end
  pcall(function()
    for _, n in ipairs({ "Character", "CharacterClassic" }) do
      if bk[n] and typeof(bk[n]) == "Instance" then
        local cur = omod:FindFirstChild(n)
        if cur then cur:Destroy() end
        local cl = bk[n]:Clone()
        cl.Parent = omod
      end
    end
  end)
  pcall(function()
    local mo = require(omod)
    pcall(function() setreadonly(mo, false) end)
    pcall(function() if mo.AppearanceInfo then setreadonly(mo.AppearanceInfo, false) end end)
    pcall(function() if mo.CosmeticInfo then setreadonly(mo.CosmeticInfo, false) end end)
    if mo.AppearanceInfo then
      if bk.dispName ~= nil then mo.AppearanceInfo.Name = bk.dispName end
      if bk.icon ~= nil then mo.AppearanceInfo.Icon = bk.icon end
    end
    if type(mo.CosmeticInfo) == "table" and type(bk.cosmetic) == "table" then
      for k in pairs(mo.CosmeticInfo) do mo.CosmeticInfo[k] = nil end
      for k, v in pairs(bk.cosmetic) do mo.CosmeticInfo[k] = v end
    end
  end)
  return true
end
if HAS_HOOK then
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

local _uSlotOrig = {}
local function unusualSlotInfo(name)
  local info = unusualByName[name]
  if not info then return nil end
  local disp, icon
  pcall(function()
    local m = require(info.inst)
    if m.AppearanceInfo then
      disp = m.AppearanceInfo.Name
      icon = m.AppearanceInfo.Icon
    end
  end)
  if type(disp) ~= "string" or disp == "" then disp = unusualDisp[name] or pretty(name) end
  if icon ~= nil then
    icon = tostring(icon)
    if not icon:find("rbxasset") then icon = "rbxassetid://" .. icon end
  end
  return disp, icon
end
local function paintUnusualSlot()
  local eqName = getEquippedUnusual()
  local want = (eqName and eqName ~= "-") and _G.UnusualSwapMap[eqName] or nil
  if want and not unusualByName[want] then return 0 end
  local pg = game:GetService("Players").LocalPlayer:FindFirstChildOfClass("PlayerGui")
  if not pg then return 0 end
  local n = 0
  for _, title in ipairs(pg:GetDescendants()) do
    if title:IsA("TextLabel") and title.Name == "Title" and title.Text == "UNUSUAL SLOT" then
      local btn = title.Parent
      if btn then
        local key = btn:GetFullName()
        local itemLbl, iconImg
        pcall(function() itemLbl = btn:FindFirstChild("ItemName") end)
        pcall(function() iconImg = btn:FindFirstChild("IconIMG") end)
        if want then
          if not _uSlotOrig[key] then
            _uSlotOrig[key] = {
              text = (itemLbl and itemLbl:IsA("TextLabel")) and itemLbl.Text or nil,
              img = (iconImg and (iconImg:IsA("ImageLabel") or iconImg:IsA("ImageButton"))) and iconImg.Image or nil,
            }
          end
          local disp, icon = unusualSlotInfo(want)
          if itemLbl and itemLbl:IsA("TextLabel") then itemLbl.Text = disp end
          if iconImg and icon and (iconImg:IsA("ImageLabel") or iconImg:IsA("ImageButton")) then iconImg.Image = icon end
          n += 1
        elseif _uSlotOrig[key] then
          local o = _uSlotOrig[key]
          if itemLbl and itemLbl:IsA("TextLabel") and o.text ~= nil then itemLbl.Text = o.text end
          if iconImg and o.img ~= nil and (iconImg:IsA("ImageLabel") or iconImg:IsA("ImageButton")) then iconImg.Image = o.img end
          _uSlotOrig[key] = nil
          n += 1
        end
      end
    end
  end
  return n
end
local function repaintUnusualSlotSoon()
  for _, d in ipairs({ 0.5, 1.5, 3 }) do task.delay(d, function() pcall(paintUnusualSlot) end) end
end

do

  pcall(function()
    local ul0 = require(ReplicatedStorage.Shared.UserData.ClientHooks.useLoadout)
    if ul0 and ul0.TryEquip and HAS_RESTORE then restorefunction(ul0.TryEquip) end
  end)
  _G.UnusualSlotPaintOld = nil
  _G.UnusualLoggerOldEquip = nil
  local ul = require(ReplicatedStorage.Shared.UserData.ClientHooks.useLoadout)
  if ul and ul.TryEquip and HAS_HOOK then
    local oldT
    oldT = hookfunction(ul.TryEquip, function(...)
      local r = oldT(...)
      repaintUnusualSlotSoon()
      pcall(function() if _G.KenuyRepaintEmoteSlot then _G.KenuyRepaintEmoteSlot() end end)
      return r
    end)
    _G.UnusualSlotPaintOld = oldT
  end
end

if NO_HOOK then
  pcall(function()
    local ul2 = require(ReplicatedStorage.Shared.UserData.ClientHooks.useLoadout)
    if ul2 then
      if ul2.TryEquip and not _G.KenuyTryEquipSolara then
        local origE = ul2.TryEquip
        _G.KenuyPatchField(ul2, "TryEquip", function(...)
          local r = { origE(...) }
          repaintUnusualSlotSoon()
          pcall(function() if _G.KenuyRepaintEmoteSlot then _G.KenuyRepaintEmoteSlot() end end)
          return table.unpack(r)
        end)
        _G.KenuyTryEquipSolara = true
      end
      if ul2.TryUnequip and not _G.KenuyTryUnequipSolara then
        local origU = ul2.TryUnequip
        _G.KenuyPatchField(ul2, "TryUnequip", function(...)
          local r = { origU(...) }
          repaintUnusualSlotSoon()
          pcall(function() if _G.KenuyRepaintEmoteSlot then _G.KenuyRepaintEmoteSlot() end end)
          return table.unpack(r)
        end)
        _G.KenuyTryUnequipSolara = true
      end
    end
  end)
end

local VLP = game:GetService("Players").LocalPlayer
local AVP = game:GetService("Players")
if _G.AvatarLoaderLoop then _G.AvatarLoaderLoop = false end

local avStatusFn = function(msg, isErr) end
local function avNotify(msg, isErr) pcall(avStatusFn, msg, isErr) end
local avDesc, avName, avBackup, avAuto = nil, nil, nil, true
local KORB_MESH, KORB_TEX = 101851696, 101851254
local HEAD_MESH = "rbxassetid://15093053680"

_G.KenuyVisualKorblox = false
_G.KenuyVisualHeadless = false

if type(_G.KenuyVisualBackup) ~= "table" then _G.KenuyVisualBackup = {} end
do
  local bk = _G.KenuyVisualBackup
  bk.hm = bk.hm or {}
  bk.ht = bk.ht or {}
  bk.df = bk.df or {}
  bk.touched = bk.touched or {}
  bk.ktouched = bk.ktouched or {}
end

local function vValidInst(x)
  if not (x and typeof(x) == "Instance") then return false end
  local ok, par = pcall(function() return x.Parent end)
  return ok and par ~= nil
end
local function vTouch(h)
  local bk = _G.KenuyVisualBackup
  bk.touched = bk.touched or {}
  for _, e in ipairs(bk.touched) do if e == h then return end end
  table.insert(bk.touched, h)
end
local function vKTouch(m)
  local bk = _G.KenuyVisualBackup
  bk.ktouched = bk.ktouched or {}
  for _, e in ipairs(bk.ktouched) do if e == m then return end end
  table.insert(bk.ktouched, m)
end

local function vRigs()
  local t = {}
  local function push(m) if m and typeof(m) == "Instance" and m:IsA("Model") then table.insert(t, m) end end
  if VLP.Character and (VLP.Character:FindFirstChild("Right Leg") or VLP.Character:FindFirstChild("RightLeg")) then push(VLP.Character) end
  pcall(function() local r = workspace:FindFirstChild("Rigs") if r and r:FindFirstChild(VLP.Name) then push(r[VLP.Name]) end end)
  pcall(function() local pc = workspace:FindFirstChild("PlayerCache") if pc and pc:FindFirstChild(VLP.Name) then local r6 = pc[VLP.Name]:FindFirstChild("R6") if r6 then push(r6) end end end)
  pcall(function() for _, d in ipairs(VLP.PlayerGui:GetDescendants()) do if d:IsA("Model") and d.Name == "VisualRigClassic" and d:FindFirstChild("Right Leg") then table.insert(t, d) end end end)
  return t
end

local function vAllModels()
  local t, seen = {}, {}
  local function push(m)
    if m and typeof(m) == "Instance" and m:IsA("Model") and not seen[m] then seen[m] = true table.insert(t, m) end
  end
  for _, m in ipairs(vRigs()) do push(m) end
  pcall(function()
    for _, d in ipairs(workspace:GetDescendants()) do
      if d:IsA("Model") and d.Name == VLP.Name then push(d) end
    end
  end)
  return t
end
local function vRestoreHead(h)
  if not (h and typeof(h) == "Instance") then return false end
  local okParent, par = pcall(function() return h.Parent end)
  if not okParent or par == nil then return false end
  if not h:IsA("BasePart") or h:IsA("MeshPart") then return false end
  local bk = _G.KenuyVisualBackup

  if bk.ht[h] ~= nil then pcall(function() h.Transparency = bk.ht[h] end)
  else pcall(function() h.Transparency = 0 end) end

  local sm
  pcall(function() sm = h:FindFirstChildOfClass("SpecialMesh") end)
  if sm then
    if bk.hm[sm] ~= nil then pcall(function() sm.MeshId = bk.hm[sm] end)
    elseif sm.MeshId == HEAD_MESH then pcall(function() sm.MeshId = "" end) end
  end
  pcall(function()
    for _, d in ipairs(h:GetChildren()) do
      if d:IsA("Decal") then
        if bk.df[d] ~= nil then d.Transparency = bk.df[d]
        elseif d.Transparency == 1 then d.Transparency = 0 end
      end
    end
  end)
  return true
end
local function vNatural(m)
  pcall(function()
    local r = m:FindFirstChild("Right Leg") or m:FindFirstChild("RightLeg")
    local l = m:FindFirstChild("Left Leg") or m:FindFirstChild("LeftLeg")
    if r and l and r:IsA("BasePart") and l:IsA("BasePart") then r.Color = l.Color r.Material = l.Material r.Reflectance = 0 end
  end)
end
local function vKApply(m)
  vNatural(m)
  for _, c in ipairs(m:GetChildren()) do if c:IsA("CharacterMesh") and c.BodyPart == Enum.BodyPart.RightLeg and c.MeshId == KORB_MESH then vKTouch(m) return end end
  local cm = Instance.new("CharacterMesh")
  cm.Name = "Korblox Deathspeaker Right Leg"
  cm.BodyPart = Enum.BodyPart.RightLeg
  cm.MeshId = KORB_MESH
  cm.OverlayTextureId = KORB_TEX
  cm.Parent = m
  vKTouch(m)
end
local function vKRemove(m)
  local n = 0
  if not vValidInst(m) then return 0 end
  for _, c in ipairs(m:GetChildren()) do
    if c:IsA("CharacterMesh") and c.BodyPart == Enum.BodyPart.RightLeg and (c.MeshId == KORB_MESH or c.Name:lower():find("korblox")) then
      pcall(function() c:Destroy() end)
      n += 1
    end
  end
  return n
end
local function vHApply(m)
  local h = m:FindFirstChild("Head")
  if not h or not h:IsA("BasePart") or h:IsA("MeshPart") then return end
  local bk = _G.KenuyVisualBackup
  local sm = h:FindFirstChildOfClass("SpecialMesh")
  if sm then if bk.hm[sm] == nil then bk.hm[sm] = sm.MeshId end sm.MeshId = HEAD_MESH end
  if bk.ht[h] == nil then bk.ht[h] = h.Transparency end
  h.Transparency = 1
  for _, d in ipairs(h:GetChildren()) do if d:IsA("Decal") then if bk.df[d] == nil then bk.df[d] = d.Transparency end d.Transparency = 1 end end
  vTouch(h)
end

local function vHRemoveAll()
  local n = 0
  local bk = _G.KenuyVisualBackup
  bk.touched = bk.touched or {}
  local kept = {}
  for _, h in ipairs(bk.touched) do
    if vRestoreHead(h) then table.insert(kept, h) n += 1 end
  end
  bk.touched = kept
  for _, m in ipairs(vAllModels()) do
    local h = m and m:FindFirstChild("Head")
    if h and vRestoreHead(h) then n += 1 end
  end
  return n
end
local function vKRemoveAll()
  local n = 0
  local bk = _G.KenuyVisualBackup
  bk.ktouched = bk.ktouched or {}
  local kept = {}
  for _, m in ipairs(bk.ktouched) do
    if vValidInst(m) then table.insert(kept, m) n += vKRemove(m) end
  end
  bk.ktouched = kept
  for _, m in ipairs(vAllModels()) do n += vKRemove(m) end
  return n
end
local function vApplyAll()
  for _, m in ipairs(vRigs()) do pcall(function()
    if _G.KenuyVisualKorblox then vKApply(m) end
    if _G.KenuyVisualHeadless then vHApply(m) end
  end) end
end

local function vAssertState()
  local kn, hn = 0, 0
  if _G.KenuyVisualKorblox then for _, m in ipairs(vAllModels()) do pcall(vKApply, m) end
  else kn = vKRemoveAll() end
  if _G.KenuyVisualHeadless then for _, m in ipairs(vAllModels()) do pcall(vHApply, m) end
  else hn = vHRemoveAll() end
  return kn, hn
end

pcall(vAssertState)

local function avGetRig()
  local rigs = workspace:FindFirstChild("Rigs")
  if rigs then
    local v = rigs:FindFirstChild(VLP.Name)
    if v then return v end
  end
  if VLP.Character and VLP.Character:FindFirstChildOfClass("Humanoid") then
    return VLP.Character
  end
  local pm = workspace:FindFirstChild("Players")
  if pm then
    local v = pm:FindFirstChild(VLP.Name)
    if v and v:FindFirstChildOfClass("Humanoid") then return v end
  end
  return nil
end
local function avSnap(visual)
  local snap = { clothes = {}, accCount = 0, faceTex = nil }
  for _, c in ipairs(visual:GetChildren()) do
    if c:IsA("Shirt") or c:IsA("Pants") or c:IsA("ShirtGraphic")
    or c:IsA("BodyColors") or c:IsA("CharacterMesh") then
      local ok, cl = pcall(function() return c:Clone() end)
      if ok and cl then table.insert(snap.clothes, cl) end
    elseif c:IsA("Accessory") then
      local ok, cl = pcall(function() return c:Clone() end)
      if ok and cl then
        snap["acc_" .. snap.accCount] = cl
        snap.accCount += 1
      end
    end
  end
  local head = visual:FindFirstChild("Head")
  if head then
    local f = head:FindFirstChild("face") or head:FindFirstChildOfClass("Decal")
    if f and f:IsA("Decal") then snap.faceTex = f.Texture end
  end
  return snap
end
local function avWeld(rig, accClone)
  local handle = accClone:FindFirstChildOfClass("MeshPart") or accClone:FindFirstChildOfClass("Part")
  if not handle then return false end
  local hAtt = nil
  for _, a in ipairs(handle:GetChildren()) do
    if a:IsA("Attachment") then hAtt = a break end
  end
  if not hAtt then
    local head = rig:FindFirstChild("Head")
    if not head then return false end
    pcall(function()
      handle.CanCollide = false handle.Massless = true
      handle.CFrame = head.CFrame
      local w = Instance.new("Weld") w.Name = "KenuyWeld"
      w.Part0, w.Part1, w.C0 = handle, head, CFrame.new(0, 0.5, 0)
      w.Parent = handle
      accClone.Parent = rig
    end)
    return true
  end
  local targetPart, targetAtt = nil, nil
  for _, p in ipairs(rig:GetChildren()) do
    if p:IsA("BasePart") then
      for _, a in ipairs(p:GetChildren()) do
        if a:IsA("Attachment") and a.Name == hAtt.Name then
          targetPart, targetAtt = p, a break
        end
      end
      if targetPart then break end
    end
  end
  if not targetPart then return false end
  for _, w in ipairs(accClone:GetChildren()) do
    if w:IsA("Weld") or w:IsA("WeldConstraint") then pcall(function() w:Destroy() end) end
  end
  for _, w in ipairs(handle:GetChildren()) do
    if w:IsA("Weld") or w:IsA("WeldConstraint") then pcall(function() w:Destroy() end) end
  end
  handle.CanCollide = false handle.Massless = true
  pcall(function() handle.CanQuery = false handle.CanTouch = false end)
  pcall(function()
    handle.CFrame = targetPart.CFrame * targetAtt.CFrame * hAtt.CFrame:Inverse()
  end)
  local w = Instance.new("Weld")
  w.Name = "KenuyWeld" w.Part0 = handle w.Part1 = targetPart
  w.C0 = hAtt.CFrame w.C1 = targetAtt.CFrame w.Parent = handle
  accClone.Parent = rig
  return true
end
local function avCopy(visual, desc)
  local hum = visual:FindFirstChildOfClass("Humanoid")
  if not hum then return false, "Visual rig tidak punya Humanoid." end
  local rigType = Enum.HumanoidRigType.R6
  pcall(function() rigType = hum.RigType end)
  local dummy
  local okD = pcall(function()
    dummy = AVP:CreateHumanoidModelFromDescription(desc, rigType)
  end)
  if not okD or not dummy then return false, "Gagal bikin dummy avatar (rate-limit?). Coba lagi 5 detik." end
  if not avBackup then avBackup = avSnap(visual) end
  pcall(function()
    local pc = workspace:FindFirstChild("PlayerCache")
    local hd = pc and pc:FindFirstChild(VLP.Name)
    if hd and hd:IsA("HumanoidDescription") then
      for _, p in ipairs({ "Face","Head","Torso","RightArm","LeftArm","RightLeg","LeftLeg",
        "Shirt","Pants","GraphicTShirt","HeadColor","TorsoColor","RightArmColor",
        "LeftArmColor","RightLegColor","LeftLegColor","HeightScale","WidthScale",
        "HeadScale","BodyTypeScale","ProportionScale","IdleAnimation","WalkAnimation",
        "RunAnimation","FallAnimation","SwimAnimation","JumpAnimation","ClimbAnimation" }) do
        pcall(function() hd[p] = desc[p] end)
      end
      pcall(function() hd:SetAccessories(desc:GetAccessories(true), true) end)
      pcall(function() hd:SetEmotes(desc:GetEmotes()) end)
    end
  end)
  for _, c in ipairs(visual:GetChildren()) do
    if c:IsA("Accessory") or c:IsA("Shirt") or c:IsA("Pants")
    or c:IsA("ShirtGraphic") or c:IsA("CharacterMesh") or c:IsA("BodyColors") then
      pcall(function() c:Destroy() end)
    end
  end
  local copied = { shirt = 0, pants = 0, acc = 0 }
  for _, c in ipairs(dummy:GetChildren()) do
    if c:IsA("Shirt") or c:IsA("Pants") or c:IsA("ShirtGraphic")
    or c:IsA("BodyColors") or c:IsA("CharacterMesh") then
      local ok = pcall(function()
        local x = c:Clone() x.Parent = visual return x
      end)
      if ok then
        if c:IsA("Shirt") then copied.shirt += 1
        elseif c:IsA("Pants") then copied.pants += 1 end
      end
    end
  end
  pcall(function()
    local dHead = dummy:FindFirstChild("Head")
    local vHead = visual:FindFirstChild("Head")
    if dHead and vHead then
      local dFace = dHead:FindFirstChild("face") or dHead:FindFirstChildOfClass("Decal")
      if dFace and dFace:IsA("Decal") then
        local vFace = vHead:FindFirstChild("face") or vHead:FindFirstChildOfClass("Decal")
        if vFace and vFace:IsA("Decal") then vFace.Texture = dFace.Texture end
      end
      local dMesh = dHead:FindFirstChildOfClass("SpecialMesh")
      local vMesh = vHead:FindFirstChildOfClass("SpecialMesh")
      if dMesh and vMesh then
        vMesh.MeshId, vMesh.TextureId = dMesh.MeshId, dMesh.TextureId
        pcall(function()
          vMesh.MeshType, vMesh.Scale = dMesh.MeshType, dMesh.Scale
          vMesh.Offset, vMesh.VertexColor = dMesh.Offset, dMesh.VertexColor
        end)
      end
    end
  end)
  for _, c in ipairs(dummy:GetChildren()) do
    if c:IsA("Accessory") then
      if avWeld(visual, c:Clone()) then copied.acc += 1 end
    end
  end
  pcall(function() dummy:Destroy() end)
  return true, copied
end
local function avGetIds(username)
  username = tostring(username or ""):gsub("^%s+", ""):gsub("%s+$", ""):gsub("@", "")
  if username == "" then return nil, "Username kosong." end
  local ok, userId = pcall(function() return AVP:GetUserIdFromNameAsync(username) end)
  if not ok or not userId then return nil, "Username '" .. username .. "' tidak ditemukan." end
  local ok2, desc = pcall(function() return AVP:GetHumanoidDescriptionFromUserId(userId) end)
  if not ok2 or not desc then return nil, "Gagal ambil avatar " .. username .. " (rate-limit?)." end
  return userId, desc, username
end
local function avLoad(username)
  avNotify("Loading '" .. tostring(username) .. "'...")
  task.spawn(function()
    local userId, desc, cleanName = avGetIds(username)
    if not userId then avNotify(desc, true) return end
    local visual = avGetRig()
    if not visual then
      avNotify("Character/visual belum spawn. Join match dulu lalu klik Load lagi.", true)
      return
    end
    avDesc, avName = desc, cleanName
    local ok, res = avCopy(visual, desc)
    if ok then
      avNotify("OK @" .. cleanName .. " | shirt:" .. res.shirt .. " pants:" .. res.pants .. " acc:" .. res.acc .. ".")
    else
      avNotify(res, true)
    end
  end)
end
local function avReset()
  if not avBackup then avNotify("Belum ada backup.", true) return end
  local visual = avGetRig()
  if not visual then avNotify("Visual belum spawn.", true) return end
  for _, c in ipairs(visual:GetChildren()) do
    if c:IsA("Accessory") or c:IsA("Shirt") or c:IsA("Pants")
    or c:IsA("ShirtGraphic") or c:IsA("CharacterMesh") or c:IsA("BodyColors") then
      pcall(function() c:Destroy() end)
    end
  end
  for _, cl in ipairs(avBackup.clothes) do
    pcall(function() cl:Clone().Parent = visual end)
  end
  for i = 0, avBackup.accCount - 1 do
    local a = avBackup["acc_" .. i]
    if a then pcall(function() avWeld(visual, a:Clone()) end) end
  end
  pcall(function()
    local vHead = visual:FindFirstChild("Head")
    if vHead and avBackup.faceTex then
      local f = vHead:FindFirstChild("face") or vHead:FindFirstChildOfClass("Decal")
      if f then f.Texture = avBackup.faceTex end
    end
  end)
  avDesc, avName = nil, nil
  avNotify("Avatar dikembalikan ke asli.")
end

local AccVisualAdded = {}
local accNotifyFn = function(msg, isErr) end
local function accNotify(msg, isErr) pcall(accNotifyFn, msg, isErr) end
local ACC_PRESETS = {
  { id = "1744060292", name = "Poisoned Horns" },
  { id = "74891470", name = "Frozen Horns" },
  { id = "215718515", name = "Fiery Horns" },
  { id = "10159600649", name = "8-Bit Royal Crown" },
  { id = "10159610478", name = "8-Bit HP Bar" },
  { id = "10159617728", name = "8-Bit Tabby Cat" },
}
local function accWeld(rig, acc)
  local handle = acc:FindFirstChild("Handle")
  if not handle or not handle:IsA("BasePart") then return false end
  handle.CanCollide = false
  pcall(function() handle.Massless = true handle.CanQuery = false handle.CanTouch = false end)
  local accAtt = handle:FindFirstChild("HatAttachment") or handle:FindFirstChild("HairAttachment")
    or handle:FindFirstChild("FaceFrontAttachment") or handle:FindFirstChild("FaceCenterAttachment")
    or handle:FindFirstChildWhichIsA("Attachment")
  local tp, ta = nil, nil
  if accAtt then
    for _, part in pairs(rig:GetChildren()) do
      if part:IsA("BasePart") then local a = part:FindFirstChild(accAtt.Name) if a then tp, ta = part, a break end end
    end
  end
  if not tp then tp = rig:FindFirstChild("Head") or rig:FindFirstChild("Torso") or rig:FindFirstChild("UpperTorso") end
  if not tp then return false end
  for _, w in pairs(handle:GetChildren()) do if w:IsA("Weld") then w:Destroy() end end
  if accAtt and ta then
    handle.CFrame = tp.CFrame * ta.CFrame:Inverse() * accAtt.CFrame
    local w = Instance.new("Weld")
    w.Name = "AccessoryWeld" w.Part0 = tp w.Part1 = handle w.C0 = ta.CFrame w.C1 = accAtt.CFrame w.Parent = handle
  else
    handle.CFrame = tp.CFrame * CFrame.new(0, tp.Size.Y / 2 + 0.2, 0)
    local w = Instance.new("Weld")
    w.Name = "AccessoryWeld" w.Part0 = tp w.Part1 = handle w.C0 = CFrame.new(0, tp.Size.Y / 2, 0) w.C1 = CFrame.new() w.Parent = handle
  end
  return true
end

local function accTargets()
  local t, seen = {}, {}
  local function push(x) if x and typeof(x) == "Instance" and not seen[x] then seen[x] = true table.insert(t, x) end end
  for _, v in pairs(AccVisualAdded) do push(v) end
  pcall(function()
    local rig = avGetRig()
    if rig then
      for _, c in pairs(rig:GetChildren()) do
        if c:IsA("Accessory") then
          local ok, tag = pcall(function() return c:GetAttribute("KenuyAcc") end)
          if ok and tag ~= nil then push(c) end
        end
      end
    end
  end)
  return t
end
local function accWear(raw, silent)
  local idStr = tostring(raw or ""):match("%d+")
  if not idStr then if not silent then accNotify("ID tidak valid.", true) end return false end
  local rig = avGetRig()
  if not rig then if not silent then accNotify("Rig tidak ketemu (join match dulu).", true) end return false end
  local hum = rig:FindFirstChildOfClass("Humanoid")
  if not hum then if not silent then accNotify("Humanoid tidak ada.", true) end return false end
  if not silent then accNotify("Loading " .. idStr .. "...") end
  local item = nil
  local ok, obj = pcall(function() return game:GetObjects("rbxassetid://" .. idStr)[1] end)
  if ok and obj then item = obj end
  if not item then if not silent then accNotify("Gagal load ID " .. idStr .. ".", true) end return false end
  if item:IsA("Model") then
    local acc = item:FindFirstChildWhichIsA("Accessory", true) or item:FindFirstChildWhichIsA("Shirt", true)
      or item:FindFirstChildWhichIsA("Pants", true) or item:FindFirstChildWhichIsA("ShirtGraphic", true)
    if acc then item = acc end
  end
  local done = false
  pcall(function()
    if item:IsA("Accessory") then
      hum:AddAccessory(item)
      pcall(function() item:SetAttribute("KenuyAcc", idStr) end)
      table.insert(AccVisualAdded, item)
      done = true
      task.delay(0.4, function()
        pcall(function()
          local h = item:FindFirstChild("Handle")
          local head = rig:FindFirstChild("Head")
          if h and head and item.Parent == rig and (h.Position - head.Position).Magnitude > 6 then accWeld(rig, item) end
        end)
      end)
    elseif item:IsA("Shirt") or item:IsA("Pants") or item:IsA("ShirtGraphic") then
      local c = item:Clone() c.Parent = rig pcall(function() c:SetAttribute("KenuyAcc", idStr) end) table.insert(AccVisualAdded, c) item:Destroy() done = true
    else
      if not silent then accNotify("Tipe tak didukung: " .. item.ClassName .. ".", true) end
      item:Destroy()
    end
  end)
  if done and not silent then accNotify("Dipakai: " .. idStr .. " (visual only).") end
  return done
end
_G.KenuyAccWear = accWear
local function accClear()
  local n = 0
  for _, v in pairs(accTargets()) do pcall(function() if v and v.Parent then v:Destroy() n = n + 1 end end) end
  AccVisualAdded = {}
  return n
end
_G.KenuyAccClear = accClear
_G.KenuyAccCount = function() return #AccVisualAdded end

_G.KenuyAccT = _G.KenuyAccT or {}
local _accFpHidden = false
local function accSetVisible(vis)
  for _, v in pairs(accTargets()) do
    pcall(function()
      if v and v.Parent and v:IsA("Accessory") then
        local parts = { v }
        for _, d in pairs(v:GetDescendants()) do table.insert(parts, d) end
        for _, p in pairs(parts) do
          if p:IsA("BasePart") then
            if not vis then
              if _G.KenuyAccT[p] == nil then _G.KenuyAccT[p] = p.Transparency end
              p.Transparency = 1
            elseif _G.KenuyAccT[p] ~= nil then p.Transparency = _G.KenuyAccT[p] end
          elseif p:IsA("ParticleEmitter") or p:IsA("Fire") or p:IsA("Smoke")
            or p:IsA("Sparkles") or p:IsA("Beam") or p:IsA("Trail") then
            if not vis then
              if _G.KenuyAccT[p] == nil then _G.KenuyAccT[p] = p.Enabled end
              p.Enabled = false
            elseif _G.KenuyAccT[p] ~= nil then p.Enabled = _G.KenuyAccT[p] end
          end
        end
      end
    end)
  end
end
_G.KenuyAccSetVisible = accSetVisible
pcall(function()
  for inst, val in pairs(_G.KenuyAccT) do
    if inst and inst.Parent then
      if inst:IsA("BasePart") and inst.Transparency == 1 and type(val) == "number" then inst.Transparency = val end
    end
  end
end)
local function accFpTick()
  local rig = avGetRig()
  local head = rig and rig:FindFirstChild("Head")
  local cam = workspace.CurrentCamera
  if not head or not cam then return end
  local dist = (cam.CFrame.Position - head.Position).Magnitude
  if not _accFpHidden and dist < 2 then accSetVisible(false) _accFpHidden = true
  elseif _accFpHidden and dist > 3 then accSetVisible(true) _accFpHidden = false end
end
_G.KenuyAccLoopGen = (_G.KenuyAccLoopGen or 0) + 1
do
  local myGen = _G.KenuyAccLoopGen
  task.spawn(function()
    while myGen == _G.KenuyAccLoopGen do
      task.wait(0.2)
      pcall(accFpTick)
    end
  end)
end

pcall(vAssertState)

local gui
local function buildKenuyUI()
local FONT, FONTB, FONTBLACK = Enum.Font.GothamBold, Enum.Font.GothamBold, Enum.Font.GothamBlack

local _vs0 = Vector2.new(1280, 720)
pcall(function() _vs0 = workspace.CurrentCamera.ViewportSize end)
local COMPACT = IS_MOBILE or _vs0.X < 900 or _vs0.Y < 550

local T_LEPAS = COMPACT and "X Lepas" or "✕ Lepas"
local T_RESET = COMPACT and "X Reset" or "✕ Reset"
local T_ME = COMPACT and "Saya" or "◎ Saya"
local T_PREV = COMPACT and "<" or "◀"
local T_NEXT = COMPACT and ">" or "▶"
local T_X = COMPACT and "X" or "✕"

local setStatus
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
local function evCorner(inst, r) local c = Instance.new("UICorner") c.CornerRadius = r or UDim.new(0,8) c.Parent = inst return c end
local function evGrad(inst, rot, c0, c1, t0, t1)
  local g = Instance.new("UIGradient") g.Rotation = rot or 90
  g.Color = ColorSequence.new({ColorSequenceKeypoint.new(0,c0),ColorSequenceKeypoint.new(1,c1)})
  g.Transparency = NumberSequence.new({NumberSequenceKeypoint.new(0,t0 or 0),NumberSequenceKeypoint.new(1,t1 or 0)})
  g.Parent = inst return g
end
local function stylePanel(f)
  f.BackgroundColor3 = Color3.fromRGB(15,15,15) f.BackgroundTransparency = 0.15 f.BorderSizePixel = 0
  evCorner(f, UDim.new(0,8))
  local s = Instance.new("UIStroke") s.Color = Color3.fromRGB(60,60,60) s.Thickness = 1 s.Transparency = 0.4 s.ApplyStrokeMode = Enum.ApplyStrokeMode.Border s.Parent = f
end
local function innerFrame(parent, corner)
  local fr = Instance.new("Frame") fr.Name = "Frame" fr.AnchorPoint = Vector2.new(0.5,0.5) fr.Position = UDim2.new(0.5,0,0.5,0)
  fr.Size = UDim2.new(1,-8,1,-8) fr.BackgroundTransparency = 1 fr.Parent = parent
  evCorner(fr, UDim.new(0,corner or 4))
  local st = Instance.new("UIStroke") st.Color = Color3.fromRGB(36,36,36) st.Thickness = 2 st.Transparency = 0.5 st.ApplyStrokeMode = Enum.ApplyStrokeMode.Border st.Parent = fr
  return fr
end
local function titleBlock(parent, text, accent)
  local t = mk("Frame", {Name="Title", Size=UDim2.new(1,-24,0,52), Position=UDim2.new(0,12,0,8), BackgroundTransparency=1}, parent)
  local lbl = mk("TextLabel", {Size=UDim2.new(1,0,0,28), BackgroundTransparency=1, Font=FONTB, TextSize=20, TextXAlignment=Enum.TextXAlignment.Left, TextColor3=Color3.fromRGB(255,255,255), Text=text}, t)
  local box = mk("Frame", {Name="TitleBox", Size=UDim2.new(1,0,0,20), Position=UDim2.new(0,0,0,30), BackgroundTransparency=1}, t)
  local fr = innerFrame(box, 6)
  for _,v in ipairs(box:GetChildren()) do if v:IsA("Frame") and v.Name=="Frame" then for _,s in ipairs(v:GetChildren()) do if s:IsA("UIStroke") then s.Color = Color3.fromRGB(20,20,20) s.Transparency = 0.3 end end end end
  local line = mk("Frame", {Size=UDim2.new(1,-16,0,2), Position=UDim2.new(0,8,0,9), BorderSizePixel=0, BackgroundColor3=accent}, box)
  evGrad(line, 0, accent, Color3.fromRGB(255,255,255), 0, 0.5)
  return t, lbl
end
local function evadeButton(parent, labelText, bg, gradBottom, h)
  local btn = mk("TextButton", {Size=UDim2.new(1,0,0,h or 34), BackgroundColor3=bg, BorderSizePixel=0, AutoButtonColor=true, Text=""}, parent)
  evCorner(btn, UDim.new(0,8))
  evGrad(btn, 90, Color3.fromRGB(255,255,255), gradBottom or Color3.fromRGB(140,140,140), 0.55, 0.15)
  local inner = innerFrame(btn, 4)
  local lbl = mk("TextLabel", {Size=UDim2.new(0.85,0,1,0), Position=UDim2.new(0.07,0,0,0), BackgroundTransparency=1, Font=FONTB, TextSize=14, TextXAlignment=Enum.TextXAlignment.Left, TextColor3=Color3.fromRGB(255,255,255), Text=labelText}, inner)
  mk("UIStroke", {Color=Color3.fromRGB(0,0,0), Thickness=1, Transparency=0.5}, lbl)
  local hover = mk("Frame", {Name="HoverOutline", AnchorPoint=Vector2.new(0.5,0.5), Position=UDim2.new(0.5,0,0.5,0), Size=UDim2.new(1,8,1,8), BackgroundTransparency=1}, btn)
  evCorner(hover, UDim.new(0,10))
  local hs = mk("UIStroke", {Color=Color3.fromRGB(255,255,255), Thickness=2, Transparency=1}, hover)
  btn.MouseEnter:Connect(function() hs.Transparency = 0.25 end)
  btn.MouseLeave:Connect(function() hs.Transparency = 1 end)
  return btn, lbl
end

gui = mk("ScreenGui", { Name = "KenuySwapUI", ResetOnSpawn = false, ZIndexBehavior = Enum.ZIndexBehavior.Sibling, IgnoreGuiInset = true }, guiRoot())
local Dim = mk("Frame", {Name="Dim", Size=UDim2.new(1,0,1,0), BackgroundColor3=Color3.fromRGB(0,0,0), BackgroundTransparency=0.35, BorderSizePixel=0, Visible=false}, gui)
local main = mk("CanvasGroup", { AnchorPoint=Vector2.new(0.5,0.5), Position=UDim2.fromScale(0.5,0.5), Size=UDim2.fromScale(1,1), BackgroundTransparency=1, BorderSizePixel=0, GroupTransparency=1, Visible=false }, gui)
mk("UISizeConstraint", {MinSize=COMPACT and Vector2.new(360,280) or Vector2.new(700,450)}, main)
local uiScale = mk("UIScale", {Scale=1}, main)
local function fitScale()

  if type(_G.KenuyUiScaleMan) == "number" then
    uiScale.Scale = math.clamp(_G.KenuyUiScaleMan, 0.6, 1.4)
    return
  end
  local vs = Vector2.new(960, 600)
  pcall(function() vs = workspace.CurrentCamera.ViewportSize end)
  local s = math.min(vs.X / 980, vs.Y / 640)
  s = math.clamp(s, COMPACT and 0.7 or 0.65, 1)
  uiScale.Scale = s
end
fitScale()
pcall(function()
  workspace.CurrentCamera:GetPropertyChangedSignal("ViewportSize"):Connect(fitScale)
end)
local Left = mk("Frame", {Name="Left", AnchorPoint=Vector2.new(0,0.5), Position=UDim2.new(0.01,0,0.5,0), Size=UDim2.new(COMPACT and 0.19 or 0.2,0,COMPACT and 0.8 or 0.72,0)}, main)
stylePanel(Left)
mk("UISizeConstraint", {MinSize=COMPACT and Vector2.new(140,220) or Vector2.new(200,300), MaxSize=Vector2.new(320,650)}, Left)
titleBlock(Left, "KENUYSWAP", Color3.fromRGB(255,191,112))
local tabList = mk("ScrollingFrame", {Position=UDim2.new(0,12,0,70), Size=UDim2.new(1,-24,1,-190), BackgroundTransparency=1, ScrollBarThickness=3, CanvasSize=UDim2.new(0,0,0,0), AutomaticCanvasSize=Enum.AutomaticSize.Y}, Left)
mk("UIListLayout", {Padding=UDim.new(0,8), SortOrder=Enum.SortOrder.LayoutOrder}, tabList)
local function mkTab(name) local b,_ = evadeButton(tabList, name, Color3.fromRGB(30,30,30), Color3.fromRGB(15,15,15), COMPACT and 44 or 36) b.BackgroundTransparency = 0.4 return b end
local emoteTabBtn = mkTab("EMOTE")
local unusualTabBtn = mkTab("UNUSUAL")
local visualTabBtn = mkTab("VISUAL")
local themeTabBtn = mkTab("TEMA")
local aboutTabBtn = mkTab("ABOUT")
local minBtn = mk("TextButton", {AnchorPoint=Vector2.new(0.5,1), Position=UDim2.new(0.5,0,1,-52), Size=UDim2.new(1,-24,0,32), BackgroundColor3=Color3.fromRGB(30,30,30), Text="—", Font=FONTB, TextSize=16, TextColor3=Color3.fromRGB(255,255,255), BorderSizePixel=0, AutoButtonColor=true}, Left)
evCorner(minBtn, UDim.new(0,8)) evGrad(minBtn, 90, Color3.fromRGB(255,255,255), Color3.fromRGB(100,100,100), 0.6, 0.2) innerFrame(minBtn, 4)
local hintLbl = mk("TextLabel", {AnchorPoint=Vector2.new(0.5,1), Position=UDim2.new(0.5,0,1,-30), Size=UDim2.new(1,-24,0,16), BackgroundTransparency=1, Text="RightCtrl • K=Visual", Font=FONT, TextSize=11, TextColor3=Color3.fromRGB(150,163,184)}, Left)
local Center = mk("Frame", {Name="Center", AnchorPoint=Vector2.new(0.5,0.5), Position=UDim2.new(COMPACT and 0.5 or 0.47,0,0.5,0), Size=UDim2.new(COMPACT and 0.6 or 0.44,0,COMPACT and 0.82 or 0.74,0)}, main)
stylePanel(Center)
mk("UISizeConstraint", {MinSize=COMPACT and Vector2.new(240,220) or Vector2.new(380,300), MaxSize=Vector2.new(880,620)}, Center)
local _, centerTitle = titleBlock(Center, "ABOUT", Color3.fromRGB(255,114,114))
local Right = mk("Frame", {Name="Select", AnchorPoint=Vector2.new(1,0.5), Position=UDim2.new(COMPACT and 0.98 or 0.99,0,0.5,0), Size=UDim2.new(COMPACT and 0.19 or 0.2,0,COMPACT and 0.7 or 0.6,0)}, main)
stylePanel(Right)
local status = mk("TextLabel", {Position=UDim2.new(0,8,COMPACT and 0,117 or 0,137), Size=UDim2.new(1,-16,1,COMPACT and -253 or -273), BackgroundTransparency=1, Font=FONT, TextSize=12, TextColor3=Color3.fromRGB(150,163,184), TextWrapped=true, TextXAlignment=Enum.TextXAlignment.Left, TextYAlignment=Enum.TextYAlignment.Top, Text=""}, Right)

local profBox = mk("Frame", {Position=UDim2.new(0,8,0,8), Size=UDim2.new(1,-16,0,COMPACT and 84 or 104), BackgroundColor3=Color3.fromRGB(25,25,25), BorderSizePixel=0}, Right)
evCorner(profBox, UDim.new(0,8)) evGrad(profBox, 90, Color3.fromRGB(255,255,255), Color3.fromRGB(90,90,90), 0.6, 0.15) innerFrame(profBox, 6)
local profImg = mk("ImageLabel", {Position=UDim2.new(0,8,0,8), Size=UDim2.new(0,COMPACT and 54 or 72,0,COMPACT and 54 or 72), BackgroundColor3=Color3.fromRGB(10,10,10), BorderSizePixel=0, Image=""}, profBox)
evCorner(profImg, UDim.new(0,8))
local profName = mk("TextLabel", {Position=UDim2.new(0,COMPACT and 70 or 88,0,8), Size=UDim2.new(1,COMPACT and -78 or -96,0,20), BackgroundTransparency=1, Font=FONTB, TextSize=13, TextColor3=Color3.fromRGB(255,255,255), TextXAlignment=Enum.TextXAlignment.Left, TextTruncate=Enum.TextTruncate.AtEnd, TextScaled=COMPACT, Text=VLP.DisplayName}, profBox)
local profUser = mk("TextLabel", {Position=UDim2.new(0,COMPACT and 70 or 88,0,28), Size=UDim2.new(1,COMPACT and -78 or -96,0,14), BackgroundTransparency=1, Font=FONT, TextSize=11, TextColor3=Color3.fromRGB(150,163,184), TextXAlignment=Enum.TextXAlignment.Left, TextTruncate=Enum.TextTruncate.AtEnd, Text="@" .. VLP.Name}, profBox)
local profId = mk("TextLabel", {Position=UDim2.new(0,COMPACT and 70 or 88,0,44), Size=UDim2.new(1,COMPACT and -78 or -96,0,14), BackgroundTransparency=1, Font=FONT, TextSize=11, TextColor3=Color3.fromRGB(150,163,184), TextXAlignment=Enum.TextXAlignment.Left, Text="ID " .. tostring(VLP.UserId)}, profBox)
local profTag = mk("TextLabel", {Position=UDim2.new(0,COMPACT and 70 or 88,0,60), Size=UDim2.new(1,COMPACT and -78 or -96,0,14), BackgroundTransparency=1, Font=FONTB, TextSize=11, TextColor3=Color3.fromRGB(90,220,150), TextXAlignment=Enum.TextXAlignment.Left, Text="● Online"}, profBox)
task.spawn(function()
  local ok, img = pcall(function()
    return game:GetService("Players"):GetUserThumbnailAsync(VLP.UserId, Enum.ThumbnailType.HeadShot, Enum.ThumbnailSize.Size100x100)
  end)
  if ok and type(img) == "string" and img ~= "" then profImg.Image = img end
end)

local DISCORD_URL_R = "https://discord.gg/xsCeM84Nmg"
local discLbl = mk("TextLabel", {AnchorPoint=Vector2.new(0,1), Position=UDim2.new(0,8,1,-116), Size=UDim2.new(1,-16,0,16), BackgroundTransparency=1, Font=FONTB, TextSize=11, TextColor3=Color3.fromRGB(235,240,248), TextXAlignment=Enum.TextXAlignment.Left, Text="DISCORD"}, Right)
local discBox = mk("TextBox", {AnchorPoint=Vector2.new(0,1), Position=UDim2.new(0,8,1,-86), Size=UDim2.new(1,-16,0,26), BackgroundColor3=Color3.fromRGB(33,43,63), TextColor3=Color3.fromRGB(45,212,191), Font=FONT, TextSize=11, Text=DISCORD_URL_R, TextEditable=false, ClearTextOnFocus=false}, Right)
evCorner(discBox, UDim.new(0,6))
local discCopyBtn, _dc = evadeButton(Right, "Salin Link", Color3.fromRGB(45,212,191), Color3.fromRGB(140,140,140), 28) discCopyBtn.AnchorPoint = Vector2.new(0,1) discCopyBtn.Position = UDim2.new(0,8,1,-52) discCopyBtn.Size = UDim2.new(1,-16,0,28)
paintHover(discCopyBtn, function() return Pal.accent end, function() return Pal.applyH end)
discCopyBtn.MouseButton1Click:Connect(function()
  local clip = setclipboard
  if type(clip) ~= "function" then pcall(function() clip = getgenv().setclipboard end) end
  if type(clip) == "function" and pcall(clip, DISCORD_URL_R) then setStatus("Link Discord disalin.")
  else setStatus("Clipboard tidak tersedia — salin manual.", true) end
end)
local function emoteAnimId(mod)
  if not (mod and typeof(mod) == "Instance") then return nil end
  local a = mod:FindFirstChild("AnimationR6") or mod:FindFirstChild("AnimationClassic") or mod:FindFirstChild("Animation")
  if a and a:IsA("Animation") and a.AnimationId ~= "" then return a.AnimationId end
  local sel = mod:FindFirstChild("Selection")
  if sel then
    local vars = sel:GetChildren()
    if #vars > 0 then
      local folder = vars[1]:FindFirstChild("Animations")
      local f = folder and (folder:FindFirstChild("R6") or folder:FindFirstChild("R15"))
      local an = f and f:FindFirstChild("Animation")
      if an and an:IsA("Animation") and an.AnimationId ~= "" then return an.AnimationId end
    end
  end

  local af = mod:FindFirstChild("Animations")
  if af then
    local f = af:FindFirstChild("R6") or af:FindFirstChild("R15")
    local an = f and (f:FindFirstChild("Animation") or f:FindFirstChild("Intro"))
    if an and an:IsA("Animation") and an.AnimationId ~= "" then return an.AnimationId end
  end
  return nil
end
local function emoteHasModel(mod)
  if not (mod and typeof(mod) == "Instance") then return false end
  for _, n in ipairs({"Character", "CharacterClassic"}) do
    local m = mod:FindFirstChild(n)
    if m and m:IsA("Model") and m:FindFirstChild("HumanoidRootPart") then return true end
  end
  return false
end

local pvTplCache, pvTplChecked = nil, false
local function pvTemplate()
  if pvTplChecked then return pvTplCache end
  pvTplChecked = true
  pcall(function() pvTplCache = game:GetService("ReplicatedStorage").Assets.Items.VisualRigClassic end)
  return pvTplCache
end
local function pvPreviewModel(mod)

  if mod and typeof(mod) == "Instance" then
    for _, n in ipairs({"Character", "CharacterClassic"}) do
      local m = mod:FindFirstChild(n)
      if m and m:IsA("Model") and m:FindFirstChild("HumanoidRootPart") and m:FindFirstChildOfClass("AnimationController") then
        local ok, cl = pcall(function() return m:Clone() end)
        if ok and cl then return cl end
      end
    end
  end
  local tpl = pvTemplate()
  if tpl then
    local ok, cl = pcall(function() return tpl:Clone() end)
    if ok and cl then return cl end
  end
  return nil
end
local function pvSetupCard(vp, mod, seed)

  local rig = pvPreviewModel(mod)
  if not rig then return false end
  local aid = emoteAnimId(mod)
  local isCharModel = emoteHasModel(mod)
  if not aid and not isCharModel then pcall(function() rig:Destroy() end) return false end
  local wm = vp:FindFirstChild("WorldModel")
  if not wm then pcall(function() rig:Destroy() end) return false end
  rig.Parent = wm
  local hrp = rig:FindFirstChild("HumanoidRootPart")
  if not hrp then pcall(function() rig:Destroy() end) return false end
  pcall(function() rig:PivotTo(CFrame.new(0, 5, 0)) end)
  local cam = vp:FindFirstChildOfClass("Camera") or vp.CurrentCamera
  if cam then
    cam.FieldOfView = 30
    cam.CFrame = CFrame.lookAt(Vector3.new(-7, 8.5, -6.5), Vector3.new(0, 6, 0))
    vp.CurrentCamera = cam
  end
  if aid then
    pcall(function()
      local anim = Instance.new("Animation")
      anim.AnimationId = aid
      local ac = rig:FindFirstChildOfClass("AnimationController")
        if ac then
          local tr = ac:LoadAnimation(anim)
          tr.Looped = true
          tr:Play()

          pcall(function() tr:AdjustSpeed(0) end)

        local freezeAt = 0.6 + ((seed or 0) % 5) * 0.35
        task.spawn(function()
          local t0 = os.clock()
          while os.clock() - t0 < 12 do
            local okL, len = pcall(function() return tr.Length end)
            if okL and len and len > 0.05 then
              task.wait(0.2)
              pcall(function() tr.TimePosition = math.min(freezeAt, len * 0.9) end)
              task.wait(0.1)
              pcall(function() tr:AdjustSpeed(0) end)
              return
            end
            task.wait(0.3)
          end
          pcall(function() tr:AdjustSpeed(0) end)
        end)
      end
    end)
  end
  return true
end
local credit = mk("TextLabel", {AnchorPoint=Vector2.new(0.5,1), Position=UDim2.new(0.5,0,1,-6), Size=UDim2.new(1,-16,0,18), BackgroundTransparency=1, Font=FONT, TextSize=11, TextColor3=Color3.fromRGB(150,163,184), Text="made by @ackley"}, Right)
local function actionBtn(text, x, w, color, parent)
  local b,_ = evadeButton(parent, text, color, Color3.fromRGB(140,140,140), COMPACT and 36 or 32)
  b.Position = UDim2.new(x,0,1,COMPACT and -44 or -40) b.Size = UDim2.new(w,0,0,COMPACT and 36 or 32)
  return b
end

local bubbleHidden, minimized, open = false, false, false
local bubble = mk("TextButton", {Position=UDim2.new(1,-72,0.5,-26), Size=UDim2.new(0,52,0,52), Text="", BackgroundColor3=Color3.fromRGB(45,212,191), BorderSizePixel=0, AutoButtonColor=false, Visible=false}, gui)
evCorner(bubble, UDim.new(1,0)) evGrad(bubble, 90, Color3.fromRGB(255,255,255), Color3.fromRGB(140,140,140), 0.45, 0.1)
mk("TextLabel", {Size=UDim2.new(1,0,1,0), BackgroundTransparency=1, Text="K", Font=FONTBLACK, TextSize=26, TextColor3=Color3.fromRGB(255,255,255)}, bubble)
local bubbleX = mk("TextButton", {Position=UDim2.new(1,-16,0,-4), Size=UDim2.new(0,20,0,20), Text=T_X, Font=FONTB, TextSize=10, TextColor3=Color3.fromRGB(255,255,255), BackgroundColor3=Color3.fromRGB(244,113,116), BorderSizePixel=0, AutoButtonColor=false}, bubble)
evCorner(bubbleX, UDim.new(1,0))
setStatus = function(msg, isErr) status.Text = msg status.TextColor3 = isErr and Pal.danger or Pal.dim end
avStatusFn = setStatus

local bodyEmote = mk("Frame", {Name="bodyEmote", Position=UDim2.new(0,12,0,66), Size=UDim2.new(1,-24,1,-78), BackgroundTransparency=1}, Center)
local eLeft = mk("Frame", {Size=UDim2.new(0.44,-6,1,0), BackgroundColor3=Color3.fromRGB(15,15,15), BackgroundTransparency=0.15, BorderSizePixel=0}, bodyEmote)
evCorner(eLeft, UDim.new(0,8))
mk("UIPadding", {PaddingTop=UDim.new(0,8), PaddingLeft=UDim.new(0,8), PaddingRight=UDim.new(0,8), PaddingBottom=UDim.new(0,8)}, eLeft)
mk("TextLabel", {Size=UDim2.new(1,0,0,20), BackgroundTransparency=1, Text="CURRENT (klik slot)", Font=FONTB, TextSize=12, TextColor3=Color3.fromRGB(235,240,248), TextXAlignment=Enum.TextXAlignment.Left}, eLeft)
mk("TextLabel", {Position=UDim2.new(0,0,0,22), Size=UDim2.new(1,0,0,26), BackgroundTransparency=1, Text="Wajib: join match + equip emote dulu, lalu buka tab ini (slot dibaca dari wheel).", Font=FONT, TextSize=10, TextColor3=Color3.fromRGB(150,163,184), TextXAlignment=Enum.TextXAlignment.Left, TextWrapped=true, TextYAlignment=Enum.TextYAlignment.Top}, eLeft)
local eGrid = mk("Frame", {Position=UDim2.new(0,0,0,50), Size=UDim2.new(1,0,1,-50), BackgroundTransparency=1}, eLeft)
mk("UIGridLayout", {CellSize=UDim2.new(0.48,0,0.148,0), CellPadding=UDim2.new(0.04,0,0.02,0), SortOrder=Enum.SortOrder.LayoutOrder}, eGrid)
local eRight = mk("Frame", {AnchorPoint=Vector2.new(1,0), Position=UDim2.fromScale(1,0), Size=UDim2.new(0.56,-6,1,0), BackgroundColor3=Color3.fromRGB(15,15,15), BackgroundTransparency=0.15, BorderSizePixel=0}, bodyEmote)
evCorner(eRight, UDim.new(0,8))
mk("UIPadding", {PaddingTop=UDim.new(0,8), PaddingLeft=UDim.new(0,8), PaddingRight=UDim.new(0,8), PaddingBottom=UDim.new(0,8)}, eRight)
mk("TextLabel", {Size=UDim2.new(1,0,0,20), BackgroundTransparency=1, Text="SELECT (pengganti)", Font=FONTB, TextSize=12, TextColor3=Color3.fromRGB(235,240,248), TextXAlignment=Enum.TextXAlignment.Left}, eRight)
local eSearch = mk("TextBox", {Position=UDim2.new(0,0,0,26), Size=UDim2.new(1,0,0,28), BackgroundColor3=Color3.fromRGB(33,43,63), TextColor3=Color3.fromRGB(235,240,248), PlaceholderColor3=Color3.fromRGB(150,163,184), PlaceholderText="  Cari emote...", Text="", Font=FONT, TextSize=13, ClearTextOnFocus=false}, eRight)
evCorner(eSearch, UDim.new(0,6))
local eList = mk("ScrollingFrame", {Position=UDim2.new(0,0,0,88), Size=UDim2.new(1,0,1,COMPACT and -196 or -184), BackgroundTransparency=1, ScrollBarThickness=4, CanvasSize=UDim2.new(0,0,0,0), AutomaticCanvasSize=Enum.AutomaticSize.Y}, eRight)
mk("UIGridLayout", {CellSize=COMPACT and UDim2.new(0.48,0,0,132) or UDim2.new(0.31,0,0,132), CellPadding=UDim2.new(0.035,0,0,8), SortOrder=Enum.SortOrder.LayoutOrder}, eList)

local eVarLbl = mk("TextLabel", {Position=UDim2.new(0,0,0,60), Size=UDim2.new(0,58,0,24), BackgroundTransparency=1, Font=FONTB, TextSize=11, TextColor3=Color3.fromRGB(150,163,184), TextXAlignment=Enum.TextXAlignment.Left, Text="VARIAN"}, eRight)
local eVarRow = mk("Frame", {Position=UDim2.new(0,62,0,60), Size=UDim2.new(1,-62,0,24), BackgroundTransparency=1}, eRight)
mk("UIListLayout", {FillDirection=Enum.FillDirection.Horizontal, Padding=UDim.new(0,6), SortOrder=Enum.SortOrder.LayoutOrder, VerticalAlignment=Enum.VerticalAlignment.Center}, eVarRow)
local eCountLbl = mk("TextLabel", {Position=UDim2.new(0,0,1,COMPACT and -100 or -92), Size=UDim2.new(1,0,0,16), BackgroundTransparency=1, Font=FONT, TextSize=11, TextColor3=Color3.fromRGB(150,163,184), TextXAlignment=Enum.TextXAlignment.Left, Text=""}, eRight)
local ePrevBtn, _ep = evadeButton(eRight, T_PREV, Color3.fromRGB(30,30,30), Color3.fromRGB(15,15,15), COMPACT and 34 or 26) ePrevBtn.Position = UDim2.new(0,0,1,COMPACT and -80 or -72) ePrevBtn.Size = UDim2.new(0.3,0,0,COMPACT and 34 or 26)
local ePageLbl = mk("TextLabel", {Position=UDim2.new(0.32,0,1,COMPACT and -80 or -72), Size=UDim2.new(0.36,0,0,COMPACT and 34 or 26), BackgroundTransparency=1, Font=FONTB, TextSize=12, TextColor3=Color3.fromRGB(180,180,180), TextXAlignment=Enum.TextXAlignment.Center, Text="1/1"}, eRight)
local eNextBtn, _en = evadeButton(eRight, T_NEXT, Color3.fromRGB(30,30,30), Color3.fromRGB(15,15,15), COMPACT and 34 or 26) eNextBtn.Position = UDim2.new(0.7,0,1,COMPACT and -80 or -72) eNextBtn.Size = UDim2.new(0.3,0,0,COMPACT and 34 or 26)
local eApplyBtn = actionBtn("✔ Pasang", 0, 0.48, Color3.fromRGB(45,212,191), eRight)
local eClearBtn = actionBtn(T_LEPAS, 0.52, 0.48, Color3.fromRGB(244,113,116), eRight)
paintHover(eApplyBtn, function() return Pal.accent end, function() return Pal.applyH end)
paintHover(eClearBtn, function() return Pal.danger end, function() return Pal.clearH end)

local bodyUnusual = mk("Frame", {Name="bodyUnusual", Position=UDim2.new(0,12,0,66), Size=UDim2.new(1,-24,1,-78), BackgroundTransparency=1, Visible=false}, Center)
local uLeft = mk("Frame", {Size=UDim2.new(0.44,-6,1,0), BackgroundColor3=Color3.fromRGB(15,15,15), BackgroundTransparency=0.15, BorderSizePixel=0}, bodyUnusual)
evCorner(uLeft, UDim.new(0,8))
mk("UIPadding", {PaddingTop=UDim.new(0,8), PaddingLeft=UDim.new(0,8), PaddingRight=UDim.new(0,8), PaddingBottom=UDim.new(0,8)}, uLeft)
mk("TextLabel", {Size=UDim2.new(1,0,0,20), BackgroundTransparency=1, Text="CURRENT (unusual)", Font=FONTB, TextSize=12, TextColor3=Color3.fromRGB(235,240,248), TextXAlignment=Enum.TextXAlignment.Left}, uLeft)
local uCard = mk("TextButton", {Position=UDim2.new(0,0,0,26), Size=UDim2.new(1,0,0,62), BackgroundColor3=Color3.fromRGB(33,43,63), BorderSizePixel=0, Text="", AutoButtonColor=false}, uLeft)
evCorner(uCard, UDim.new(0,6)) evGrad(uCard, 90, Color3.fromRGB(255,255,255), Color3.fromRGB(150,150,150), 0.6, 0.2) innerFrame(uCard, 3)
mk("UIStroke", {Color=Color3.fromRGB(45,212,191), Thickness=1}, uCard)
local uLbl = mk("TextLabel", {Position=UDim2.new(0,10,0,6), Size=UDim2.new(1,-20,0,22), BackgroundTransparency=1, Font=FONTB, TextSize=13, TextColor3=Color3.fromRGB(235,240,248), TextXAlignment=Enum.TextXAlignment.Left, TextTruncate=Enum.TextTruncate.AtEnd, TextScaled=COMPACT, Text="UnusualSlot: -"}, uCard)
local uSub = mk("TextLabel", {Position=UDim2.new(0,10,0,30), Size=UDim2.new(1,-20,0,20), BackgroundTransparency=1, Font=FONT, TextSize=12, TextColor3=Color3.fromRGB(45,212,191), TextXAlignment=Enum.TextXAlignment.Left, TextTruncate=Enum.TextTruncate.AtEnd, TextScaled=COMPACT, Text="-> -"}, uCard)
mk("TextLabel", {Position=UDim2.new(0,0,0,96), Size=UDim2.new(1,0,1,-96), BackgroundTransparency=1, Font=FONT, TextSize=11, TextColor3=Color3.fromRGB(150,163,184), TextWrapped=true, TextYAlignment=Enum.TextYAlignment.Top, Text="Equip SpawnHalo seperti biasa, visual diganti client-side. Unequip + equip ulang tiap ganti mapping."}, uLeft)
local uRight = mk("Frame", {AnchorPoint=Vector2.new(1,0), Position=UDim2.fromScale(1,0), Size=UDim2.new(0.56,-6,1,0), BackgroundColor3=Color3.fromRGB(15,15,15), BackgroundTransparency=0.15, BorderSizePixel=0}, bodyUnusual)
evCorner(uRight, UDim.new(0,8))
mk("UIPadding", {PaddingTop=UDim.new(0,8), PaddingLeft=UDim.new(0,8), PaddingRight=UDim.new(0,8), PaddingBottom=UDim.new(0,8)}, uRight)
mk("TextLabel", {Size=UDim2.new(1,0,0,20), BackgroundTransparency=1, Text="SELECT (pengganti)", Font=FONTB, TextSize=12, TextColor3=Color3.fromRGB(235,240,248), TextXAlignment=Enum.TextXAlignment.Left}, uRight)
local uSearch = mk("TextBox", {Position=UDim2.new(0,0,0,26), Size=UDim2.new(1,0,0,28), BackgroundColor3=Color3.fromRGB(33,43,63), TextColor3=Color3.fromRGB(235,240,248), PlaceholderColor3=Color3.fromRGB(150,163,184), PlaceholderText="  Cari unusual...", Text="", Font=FONT, TextSize=13, ClearTextOnFocus=false}, uRight)
evCorner(uSearch, UDim.new(0,6))
local uList = mk("ScrollingFrame", {Position=UDim2.new(0,0,0,60), Size=UDim2.new(1,0,1,COMPACT and -168 or -156), BackgroundTransparency=1, ScrollBarThickness=4, CanvasSize=UDim2.new(0,0,0,0), AutomaticCanvasSize=Enum.AutomaticSize.Y}, uRight)
mk("UIGridLayout", {CellSize=COMPACT and UDim2.new(0.48,0,0,132) or UDim2.new(0.31,0,0,132), CellPadding=UDim2.new(0.035,0,0,8), SortOrder=Enum.SortOrder.LayoutOrder}, uList)
local uCountLbl = mk("TextLabel", {Position=UDim2.new(0,0,1,COMPACT and -100 or -92), Size=UDim2.new(1,0,0,16), BackgroundTransparency=1, Font=FONT, TextSize=11, TextColor3=Color3.fromRGB(150,163,184), TextXAlignment=Enum.TextXAlignment.Left, Text=""}, uRight)
local uPrevBtn, _up = evadeButton(uRight, T_PREV, Color3.fromRGB(30,30,30), Color3.fromRGB(15,15,15), COMPACT and 34 or 26) uPrevBtn.Position = UDim2.new(0,0,1,COMPACT and -80 or -72) uPrevBtn.Size = UDim2.new(0.3,0,0,COMPACT and 34 or 26)
local uPageLbl = mk("TextLabel", {Position=UDim2.new(0.32,0,1,COMPACT and -80 or -72), Size=UDim2.new(0.36,0,0,COMPACT and 34 or 26), BackgroundTransparency=1, Font=FONTB, TextSize=12, TextColor3=Color3.fromRGB(180,180,180), TextXAlignment=Enum.TextXAlignment.Center, Text="1/1"}, uRight)
local uNextBtn, _un = evadeButton(uRight, T_NEXT, Color3.fromRGB(30,30,30), Color3.fromRGB(15,15,15), COMPACT and 34 or 26) uNextBtn.Position = UDim2.new(0.7,0,1,COMPACT and -80 or -72) uNextBtn.Size = UDim2.new(0.3,0,0,COMPACT and 34 or 26)
local uApplyBtn = actionBtn("✔ Pasang", 0, 0.48, Color3.fromRGB(45,212,191), uRight)
local uClearBtn = actionBtn(T_LEPAS, 0.52, 0.48, Color3.fromRGB(244,113,116), uRight)
paintHover(uApplyBtn, function() return Pal.accent end, function() return Pal.applyH end)
paintHover(uClearBtn, function() return Pal.danger end, function() return Pal.clearH end)

local bodyVisual = mk("Frame", {Name="bodyVisual", Position=UDim2.new(0,12,0,66), Size=UDim2.new(1,-24,1,-78), BackgroundTransparency=1, Visible=false}, Center)
local vLeft = mk("Frame", {Size=UDim2.new(0.46,-6,1,0), BackgroundColor3=Color3.fromRGB(15,15,15), BackgroundTransparency=0.15, BorderSizePixel=0}, bodyVisual)
evCorner(vLeft, UDim.new(0,8))
mk("UIPadding", {PaddingTop=UDim.new(0,8), PaddingLeft=UDim.new(0,8), PaddingRight=UDim.new(0,8), PaddingBottom=UDim.new(0,8)}, vLeft)
mk("TextLabel", {Size=UDim2.new(1,0,0,20), BackgroundTransparency=1, Text="Korless 5mb (Visual Only)", Font=FONTB, TextSize=12, TextColor3=Color3.fromRGB(235,240,248), TextXAlignment=Enum.TextXAlignment.Left}, vLeft)
local vKorbBtn,_ = evadeButton(vLeft, "Korblox : OFF", Color3.fromRGB(33,43,63), Color3.fromRGB(120,120,120), 38) vKorbBtn.Position = UDim2.new(0,0,0,26)
local vHeadBtn,_ = evadeButton(vLeft, "Headless : OFF", Color3.fromRGB(33,43,63), Color3.fromRGB(120,120,120), 38) vHeadBtn.Position = UDim2.new(0,0,0,68)
paintHover(vKorbBtn, function() return Pal.card end, function() return Pal.hover end)
paintHover(vHeadBtn, function() return Pal.card end, function() return Pal.hover end)
mk("TextLabel", {Position=UDim2.new(0,0,0,112), Size=UDim2.new(1,0,0,16), BackgroundTransparency=1, Text="Avatar Loader (username)", Font=FONTB, TextSize=11, TextColor3=Color3.fromRGB(235,240,248), TextXAlignment=Enum.TextXAlignment.Left}, vLeft)
local avBox = mk("TextBox", {Position=UDim2.new(0,0,0,130), Size=UDim2.new(1,0,0,26), BackgroundColor3=Color3.fromRGB(33,43,63), TextColor3=Color3.fromRGB(235,240,248), PlaceholderColor3=Color3.fromRGB(150,163,184), PlaceholderText="  Username...", Text="", Font=FONT, TextSize=12, ClearTextOnFocus=false}, vLeft)
evCorner(avBox, UDim.new(0,6))
local avLoadBtn,_ = evadeButton(vLeft, "✔ Load Avatar", Color3.fromRGB(45,212,191), Color3.fromRGB(140,140,140), 28) avLoadBtn.Position = UDim2.new(0,0,0,160)
paintHover(avLoadBtn, function() return Pal.accent end, function() return Pal.applyH end)
local avResetBtn,_ = evadeButton(vLeft, T_RESET, Color3.fromRGB(244,113,116), Color3.fromRGB(140,140,140), 26) avResetBtn.Position = UDim2.new(0,0,0,192) avResetBtn.Size = UDim2.new(0.48,0,0,26)
paintHover(avResetBtn, function() return Pal.danger end, function() return Pal.clearH end)
local avMeBtn,_ = evadeButton(vLeft, T_ME, Color3.fromRGB(33,43,63), Color3.fromRGB(120,120,120), 26) avMeBtn.Position = UDim2.new(0.52,0,0,192) avMeBtn.Size = UDim2.new(0.48,0,0,26)
paintHover(avMeBtn, function() return Pal.card end, function() return Pal.hover end)
local avAutoBtn,_ = evadeButton(vLeft, "Auto-apply: ON", Color3.fromRGB(33,43,63), Color3.fromRGB(120,120,120), 24) avAutoBtn.Position = UDim2.new(0,0,0,222)
avLoadBtn.MouseButton1Click:Connect(function() avLoad(avBox.Text) end)
avBox.FocusLost:Connect(function(enter) if enter then avLoad(avBox.Text) end end)
avResetBtn.MouseButton1Click:Connect(function() avReset() end)
avMeBtn.MouseButton1Click:Connect(function() avLoad(VLP.Name) end)
avAutoBtn.MouseButton1Click:Connect(function()
  avAuto = not avAuto
  for _,d in ipairs(avAutoBtn:GetDescendants()) do if d:IsA("TextLabel") then d.Text = avAuto and "Auto-apply: ON" or "Auto-apply: OFF" end end
  setStatus("Avatar auto-apply " .. (avAuto and "ON" or "OFF"))
end)

local vRight = mk("Frame", {AnchorPoint=Vector2.new(1,0), Position=UDim2.fromScale(1,0), Size=UDim2.new(0.54,-6,1,0), BackgroundColor3=Color3.fromRGB(15,15,15), BackgroundTransparency=0.15, BorderSizePixel=0}, bodyVisual)
evCorner(vRight, UDim.new(0,8))
mk("UIPadding", {PaddingTop=UDim.new(0,8), PaddingLeft=UDim.new(0,8), PaddingRight=UDim.new(0,8), PaddingBottom=UDim.new(0,8)}, vRight)
mk("TextLabel", {Size=UDim2.new(1,0,0,20), BackgroundTransparency=1, Text="AKSESORIS LOADER", Font=FONTB, TextSize=12, TextColor3=Color3.fromRGB(235,240,248), TextXAlignment=Enum.TextXAlignment.Left}, vRight)
local accBox = mk("TextBox", {Position=UDim2.new(0,0,0,26), Size=UDim2.new(0.62,0,0,30), BackgroundColor3=Color3.fromRGB(33,43,63), TextColor3=Color3.fromRGB(235,240,248), PlaceholderColor3=Color3.fromRGB(150,163,184), PlaceholderText="  ID katalog...", Text="", Font=FONT, TextSize=12, ClearTextOnFocus=false}, vRight)
evCorner(accBox, UDim.new(0,6))
local accWearBtn,_aw = evadeButton(vRight, "Pakai", Pal.accent, Color3.fromRGB(140,140,140), 30) accWearBtn.Position = UDim2.new(0.64,0,0,26) accWearBtn.Size = UDim2.new(0.36,0,0,30)
paintHover(accWearBtn, function() return Pal.accent end, function() return Pal.applyH end)
local accClearBtn,_ac = evadeButton(vRight, "Hapus Visual", Pal.danger, Color3.fromRGB(140,140,140), 28) accClearBtn.Position = UDim2.new(0,0,0,60) accClearBtn.Size = UDim2.new(1,0,0,28)
paintHover(accClearBtn, function() return Pal.danger end, function() return Pal.clearH end)
mk("TextLabel", {Position=UDim2.new(0,0,0,92), Size=UDim2.new(1,0,0,16), BackgroundTransparency=1, Text="PRESET (klik untuk pakai)", Font=FONTB, TextSize=11, TextColor3=Color3.fromRGB(235,240,248), TextXAlignment=Enum.TextXAlignment.Left}, vRight)
local accList = mk("ScrollingFrame", {Position=UDim2.new(0,0,0,112), Size=UDim2.new(1,0,1,-112), BackgroundTransparency=1, ScrollBarThickness=4, CanvasSize=UDim2.new(0,0,0,0), AutomaticCanvasSize=Enum.AutomaticSize.Y}, vRight)
mk("UIListLayout", {Padding=UDim.new(0,6), SortOrder=Enum.SortOrder.LayoutOrder}, accList)
local accRows = {}
local function accRefresh()
  local wornIds = {}
  pcall(function()
    for _, v in pairs(AccVisualAdded) do
      local ok, tag = pcall(function() return v:GetAttribute("KenuyAcc") end)
      if ok and tag ~= nil then wornIds[tostring(tag)] = true end
    end
    local rig = avGetRig()
    if rig then
      for _, c in pairs(rig:GetChildren()) do
        local ok, tag = pcall(function() return c:GetAttribute("KenuyAcc") end)
        if ok and tag ~= nil then wornIds[tostring(tag)] = true end
      end
    end
  end)
  for _, r in ipairs(accRows) do
    if wornIds[r.id] then r.st.Text = "DIPAKAI" r.st.TextColor3 = Color3.fromRGB(90,220,150)
    else r.st.Text = "ID " .. r.id r.st.TextColor3 = Pal.dim end
  end
end
for i, p in ipairs(ACC_PRESETS) do
  local pid, pname = p.id, p.name
  local row = mk("TextButton", {Size=UDim2.new(1,-4,0,36), BackgroundColor3=Color3.fromRGB(25,25,25), BorderSizePixel=0, Text="", AutoButtonColor=true, LayoutOrder=i}, accList)
  evCorner(row, UDim.new(0,6))
  mk("TextLabel", {Position=UDim2.new(0,10,0,2), Size=UDim2.new(1,-84,0,18), BackgroundTransparency=1, Font=FONTB, TextSize=12, TextColor3=Color3.fromRGB(255,255,255), TextXAlignment=Enum.TextXAlignment.Left, TextTruncate=Enum.TextTruncate.AtEnd, Text=i .. ". " .. pname}, row)
  local st = mk("TextLabel", {Position=UDim2.new(0,10,0,20), Size=UDim2.new(1,-20,0,12), BackgroundTransparency=1, Font=FONTB, TextSize=10, TextColor3=Pal.dim, TextXAlignment=Enum.TextXAlignment.Left, Text="ID " .. pid}, row)
  mk("TextLabel", {AnchorPoint=Vector2.new(1,0), Position=UDim2.new(1,-10,0,0), Size=UDim2.new(0,64,1,0), BackgroundTransparency=1, Font=FONTB, TextSize=11, TextColor3=Pal.accent, TextXAlignment=Enum.TextXAlignment.Right, Text="Pakai >"}, row)
  table.insert(accRows, {id=pid, st=st})
  paintHover(row, function() return Color3.fromRGB(25,25,25) end, function() return Pal.hover end)
  row.MouseButton1Click:Connect(function()
    task.spawn(function() accWear(pid) task.wait(1) pcall(accRefresh) end)
  end)
end
accNotifyFn = setStatus
accWearBtn.MouseButton1Click:Connect(function()
  task.spawn(function() accWear(accBox.Text) task.wait(1) pcall(accRefresh) end)
end)
accBox.FocusLost:Connect(function(enter) if enter then task.spawn(function() accWear(accBox.Text) task.wait(1) pcall(accRefresh) end) end end)
accClearBtn.MouseButton1Click:Connect(function()
  local n = accClear()
  setStatus("Visual aksesori dihapus (" .. n .. ").")
  pcall(accRefresh)
end)
accRefresh()
local function vRef()
  local function setBtn(btn, on, label)
    for _,d in ipairs(btn:GetDescendants()) do if d:IsA("TextLabel") then d.Text = label .. (on and " : ON" or " : OFF") end end
    btn.BackgroundColor3 = on and Color3.fromRGB(22,163,74) or Pal.card
  end
  setBtn(vKorbBtn, _G.KenuyVisualKorblox, "Korblox")
  setBtn(vHeadBtn, _G.KenuyVisualHeadless, "Headless")
end
vKorbBtn.MouseButton1Click:Connect(function()
  _G.KenuyVisualKorblox = not _G.KenuyVisualKorblox
  local okA, kn = pcall(vAssertState)
  for _, d in ipairs({0.5,1.5,3}) do task.delay(d, function() pcall(vAssertState) end) end
  vRef()
  if okA then setStatus("Korblox " .. (_G.KenuyVisualKorblox and "ON" or ("OFF" .. (kn and kn > 0 and (" (" .. kn .. " dibersihkan)") or ""))))
  else setStatus("Korblox " .. (_G.KenuyVisualKorblox and "ON" or "OFF") .. " (gagal, coba lagi)", true) end
end)
vHeadBtn.MouseButton1Click:Connect(function()
  _G.KenuyVisualHeadless = not _G.KenuyVisualHeadless
  local okA, _, hn = pcall(vAssertState)
  for _, d in ipairs({0.5,1.5,3}) do task.delay(d, function() pcall(vAssertState) end) end
  vRef()
  if okA then setStatus("Headless " .. (_G.KenuyVisualHeadless and "ON" or ("OFF" .. (hn and hn > 0 and (" (" .. hn .. " direstore)") or ""))))
  else setStatus("Headless " .. (_G.KenuyVisualHeadless and "ON" or "OFF") .. " (gagal, coba lagi)", true) end
end)
vRef()

local equippedEmotes = getEquippedEmoteNames()
local eSelect, eArmed, eBtns = {}, 1, {}
local function validEmote(name) return name and name ~= "" and emoteByName[name] ~= nil end
local function refreshEmote()
  for i = 1, 12 do
    local rep = _G.EmoteSwapMap[equippedEmotes[i]]
    local b = eBtns[i]
    if b then
      b.Lbl.Text = i .. ". " .. tostring(equippedEmotes[i])
      local vsfx = ""
      pcall(function()
        local vv = _G.EmoteSwapVariant[equippedEmotes[i]]
        if rep and type(vv) == "number" and vv >= 1 then vsfx = " V" .. tostring(vv) end
      end)
      b.Sub.Text = rep and ("-> " .. rep .. vsfx) or "-> -"
      b.Btn.BackgroundColor3 = (i == eArmed) and Pal.accentD or Pal.card
      b.Stroke.Color = (i == eArmed) and Pal.accent or Pal.panel
    end
  end
end

local function refreshVariantBar()
  for _, c in ipairs(eVarRow:GetChildren()) do if c:IsA("TextButton") then pcall(function() c:Destroy() end) end end
  local cur = equippedEmotes[eArmed]
  local target = cur and _G.EmoteSwapMap[cur]
  if not target then target = eSelect[eArmed] end
  local n = (target and selectionCountOf(target)) or 0
  if not target or n < 2 then return end
  local active = 0
  pcall(function()
    local vv = cur and _G.EmoteSwapVariant[cur]
    if type(vv) == "number" and vv >= 1 then active = vv end
  end)
  local function addVarBtn(txt, idx, order)
    local b = mk("TextButton", {Text=txt, Font=FONTB, TextSize=COMPACT and 13 or 11, TextColor3=(active == idx) and Pal.bg or Pal.text, BackgroundColor3=(active == idx) and Pal.accent or Pal.card, BorderSizePixel=0, Size=UDim2.new(0, idx == 0 and (COMPACT and 58 or 52) or (COMPACT and 34 or 30), 0, COMPACT and 26 or 22), LayoutOrder=order, AutoButtonColor=true}, eVarRow)
    evCorner(b, UDim.new(0,6))
    b.MouseButton1Click:Connect(function()
      local c2 = equippedEmotes[eArmed]
      if not c2 or c2 == "-" then setStatus("Slot " .. eArmed .. " kosong.", true) return end
      if idx == 0 then _G.EmoteSwapVariant[c2] = nil else _G.EmoteSwapVariant[c2] = idx end
      if NO_HOOK and _G.EmoteSwapMap[c2] then pcall(function() _G.KenuyDirectApplyEmote(c2, _G.EmoteSwapMap[c2]) end) end
      setStatus("Varian " .. tostring(target) .. ": " .. (idx == 0 and "acak." or ("V" .. idx .. " (slot " .. eArmed .. ").")))
      refreshVariantBar() refreshEmote()
    end)
  end
  addVarBtn("Acak", 0, 1)
  for i = 1, n do addVarBtn(tostring(i), i, i + 1) end
end
for i = 1, 12 do
  local card = mk("TextButton", {BackgroundColor3=Color3.fromRGB(33,43,63), BorderSizePixel=0, Text="", AutoButtonColor=false, LayoutOrder=i}, eGrid)
  evCorner(card, UDim.new(0,6)) evGrad(card, 90, Color3.fromRGB(255,255,255), Color3.fromRGB(120,120,120), 0.65, 0.2)
  local stroke = mk("UIStroke", {Color=Color3.fromRGB(26,34,50), Thickness=1}, card)
  local mono = mk("TextLabel", {Position=UDim2.new(0,6,0,6), Size=UDim2.new(0,COMPACT and 20 or 26,0,COMPACT and 20 or 26), BackgroundColor3=Color3.fromRGB(20,120,110), TextColor3=Color3.fromRGB(235,240,248), Font=FONTB, TextSize=12, Text=tostring(i), BorderSizePixel=0}, card)
  evCorner(mono, UDim.new(1,0))
  local lbl = mk("TextLabel", {Position=UDim2.new(0,COMPACT and 30 or 38,0,4), Size=UDim2.new(1,COMPACT and -36 or -44,0,18), BackgroundTransparency=1, Font=FONTB, TextSize=12, TextColor3=Color3.fromRGB(235,240,248), TextXAlignment=Enum.TextXAlignment.Left, TextTruncate=Enum.TextTruncate.AtEnd, TextScaled=COMPACT, Text=i .. ". -"}, card)
  local sub = mk("TextLabel", {Position=UDim2.new(0,COMPACT and 30 or 38,0,22), Size=UDim2.new(1,COMPACT and -36 or -44,0,16), BackgroundTransparency=1, Font=FONT, TextSize=11, TextColor3=Color3.fromRGB(45,212,191), TextXAlignment=Enum.TextXAlignment.Left, TextTruncate=Enum.TextTruncate.AtEnd, TextScaled=COMPACT, Text="-> -"}, card)
  paintHover(card, function() return (eArmed == i) and Pal.accentD or Pal.card end, function() return Pal.hover end)
  eBtns[i] = {Btn=card, Lbl=lbl, Sub=sub, Stroke=stroke, Mono=mono}
  card.MouseButton1Click:Connect(function() eArmed = i setStatus("Slot Emote " .. i .. " dipilih (" .. tostring(equippedEmotes[i]) .. "). Pilih pengganti.") refreshEmote() refreshVariantBar() end)
end
local PAGE = COMPACT and 6 or 9
local ePage, eFilter = 1, ""
local function renderEmotePage()
  for _, c in ipairs(eList:GetChildren()) do if c:IsA("TextButton") then c:Destroy() end end
  local all = {}
  for _, name in ipairs(emoteNames) do
    local dispName = pretty(name)
    if eFilter == "" or string.find(string.lower(name), eFilter, 1, true) or string.find(string.lower(dispName), eFilter, 1, true) then
      table.insert(all, name)
    end
  end
  local pages = math.max(1, math.ceil(#all / PAGE))
  if ePage < 1 then ePage = 1 end
  if ePage > pages then ePage = pages end
  local start = (ePage - 1) * PAGE + 1
  local stop = math.min(start + PAGE - 1, #all)
  for i = start, stop do
    local name = all[i]
    local dispName = pretty(name)
    local eid = emoteByName[name] and emoteByName[name].inst and emoteByName[name].id
    local idStr = eid ~= nil and ("ID " .. tostring(eid)) or ""
    local used = false
    for _, v in pairs(_G.EmoteSwapMap) do if v == name then used = true break end end

    local row = mk("TextButton", {Size=COMPACT and UDim2.new(0.48,0,0,132) or UDim2.new(0.31,0,0,132), BackgroundColor3=Color3.fromRGB(25,25,25), BorderSizePixel=0, Text="", AutoButtonColor=true, LayoutOrder=i}, eList)
    evCorner(row, UDim.new(0,8)) evGrad(row, 90, Color3.fromRGB(255,255,255), Color3.fromRGB(90,90,90), 0.6, 0.15) innerFrame(row, 6)
    local vp = mk("ViewportFrame", {Position=UDim2.new(0,6,0,6), Size=UDim2.new(1,-12,0,84), BackgroundTransparency=1, BorderSizePixel=0, Ambient=Color3.fromRGB(200,200,200), LightColor=Color3.fromRGB(140,140,140)}, row)
    local wm = mk("WorldModel", {}, vp)
    local cam = mk("Camera", {FieldOfView=30}, wm)
    vp.CurrentCamera = cam

    if emoteAnimId(emoteByName[name].inst) or emoteHasModel(emoteByName[name].inst) then
      pvSetupCard(vp, emoteByName[name].inst, i)
    else
      vp:Destroy()
      local badge = mk("TextLabel", {Position=UDim2.new(0,6,0,6), Size=UDim2.new(1,-12,0,84), BackgroundTransparency=1, Font=FONTB, TextSize=28, TextColor3=Color3.fromRGB(90,120,130), Text=string.upper(string.sub(name,1,1))}, row)
    end
    mk("TextLabel", {Position=UDim2.new(0,6,0,92), Size=UDim2.new(1,-12,0,18), BackgroundTransparency=1, Font=FONTB, TextSize=12, TextColor3=Color3.fromRGB(255,255,255), TextXAlignment=Enum.TextXAlignment.Left, TextTruncate=Enum.TextTruncate.AtEnd, TextScaled=COMPACT, Text=dispName}, row)
    mk("TextLabel", {Position=UDim2.new(0,6,0,110), Size=UDim2.new(1,-12,0,14), BackgroundTransparency=1, Font=FONT, TextSize=10, TextColor3=(used and Color3.fromRGB(90,220,150) or Color3.fromRGB(150,163,184)), TextXAlignment=Enum.TextXAlignment.Left, TextTruncate=Enum.TextTruncate.AtEnd, Text=(used and "DIPAKAI  •  " or "") .. idStr}, row)
    paintHover(row, function() return Color3.fromRGB(25,25,25) end, function() return Pal.hover end)
    row.MouseButton1Click:Connect(function()
      local cur = equippedEmotes[eArmed]
      if not validEmote(name) then setStatus("Gagal: emote tidak ditemukan.", true) return end
      if not cur or cur == "-" then setStatus("Slot " .. eArmed .. " kosong.", true) return end
      _G.EmoteSwapMap[cur] = name eSelect[eArmed] = name
      if NO_HOOK then pcall(function() _G.KenuyDirectApplyEmote(cur, name) end) end
      pcall(function() if _G.KenuyPaintWheel then _G.KenuyPaintWheel() end end)
      setStatus("OK " .. cur .. " -> " .. name .. " (slot " .. eArmed .. ").") refreshEmote() renderEmotePage() refreshVariantBar() pcall(function() if _G.KenuyRepaintEmoteSlot then _G.KenuyRepaintEmoteSlot() end end)
    end)
  end
  eCountLbl.Text = #all .. " / " .. #emoteNames .. " emote"
  ePageLbl.Text = ePage .. "/" .. pages
end
local function buildEmoteList(filter)
  eFilter = string.lower(filter or "")
  ePage = 1
  renderEmotePage()
end
eSearch:GetPropertyChangedSignal("Text"):Connect(function() buildEmoteList(eSearch.Text) end)
ePrevBtn.MouseButton1Click:Connect(function() if ePage > 1 then ePage = ePage - 1 renderEmotePage() end end)
eNextBtn.MouseButton1Click:Connect(function() ePage = ePage + 1 renderEmotePage() end)
eApplyBtn.MouseButton1Click:Connect(function()
  local cur = equippedEmotes[eArmed]
  if not cur or cur == "-" then setStatus("Slot " .. eArmed .. " kosong.", true) return end
  local pick = eSelect[eArmed] or eSearch.Text
  if not validEmote(pick) then setStatus("Pilih dulu emote dari daftar untuk slot " .. eArmed .. ".", true) return end
  _G.EmoteSwapMap[cur] = pick setStatus("OK " .. cur .. " -> " .. pick .. " (slot " .. eArmed .. ").") refreshEmote() renderEmotePage() refreshVariantBar() pcall(function() if _G.KenuyRepaintEmoteSlot then _G.KenuyRepaintEmoteSlot() end end)
  if NO_HOOK then pcall(function() _G.KenuyDirectApplyEmote(cur, pick) end) end
  pcall(function() if _G.KenuyPaintWheel then _G.KenuyPaintWheel() end end)
end)
eClearBtn.MouseButton1Click:Connect(function()
  local cur = equippedEmotes[eArmed]
  if cur and _G.EmoteSwapMap[cur] then _G.EmoteSwapMap[cur] = nil eSelect[eArmed] = nil _G.EmoteSwapVariant[cur] = nil setStatus("Mapping slot " .. eArmed .. " (" .. cur .. ") dilepas.") refreshEmote() renderEmotePage() refreshVariantBar() pcall(function() if _G.KenuyRepaintEmoteSlot then _G.KenuyRepaintEmoteSlot() end end)
  if NO_HOOK then pcall(function() _G.KenuyDirectRestoreEmote(cur) end) end
  pcall(function() if _G.KenuyPaintWheel then _G.KenuyPaintWheel() end end)
  else setStatus("Slot " .. eArmed .. " tidak punya mapping.", true) end
end)

local function emoteDisplayOf(name)
  local info = emoteByName[name]
  if not info then return pretty(name) end
  local disp = pretty(name)
  pcall(function()
    local m = require(info.inst)
    if m.AppearanceInfo and type(m.AppearanceInfo.Name) == "string" and m.AppearanceInfo.Name ~= "" then
      disp = m.AppearanceInfo.Name
    end
  end)
  return disp
end
local function paintEmoteSlots()
  local eq = getEquippedEmoteNames()
  local pg2 = game:GetService("Players").LocalPlayer:FindFirstChildOfClass("PlayerGui")
  if not pg2 then return 0 end
  local dispToSlot = {}
  for i = 1, 12 do
    if eq[i] and eq[i] ~= "-" then
      dispToSlot[emoteDisplayOf(eq[i])] = i
      if not dispToSlot[pretty(eq[i])] then dispToSlot[pretty(eq[i])] = i end
    end
  end
  local n = 0
  local function playAid(r, aid)
    if not (r and aid) then return false end
    local started = false
    pcall(function()
      local ac = r:FindFirstChildOfClass("AnimationController")
      if ac then
        for _, tr in ipairs(ac:GetPlayingAnimationTracks()) do pcall(function() tr:Stop() end) end
        local anim = Instance.new("Animation")
        anim.AnimationId = aid
        local tr = ac:LoadAnimation(anim)
        tr.Looped = true
        tr:Play()
        started = true
        pcall(function() tr:AdjustSpeed(0) end)
        task.spawn(function()
          local t0 = os.clock()
          while os.clock() - t0 < 8 do
            local okL, len = pcall(function() return tr.Length end)
            if okL and len and len > 0.05 then
              task.wait(0.15)
              pcall(function() tr.TimePosition = math.min(0.8, len * 0.9) end)
              pcall(function() tr:AdjustSpeed(0) end)
              return
            end
            task.wait(0.3)
          end
          pcall(function() tr:AdjustSpeed(0) end)
        end)
      end
    end)
    return started
  end
  for _, title in ipairs(pg2:GetDescendants()) do
    if title:IsA("TextLabel") and title.Name == "Title" and title.Text == "EMOTE SLOT" then
      local btn = title.Parent
      if btn then
        local itemLbl, idxLbl, vp = nil, nil, nil
        pcall(function() itemLbl = btn:FindFirstChild("ItemName") end)
        pcall(function() idxLbl = btn:FindFirstChild("Index") end)
        pcall(function() vp = btn:FindFirstChild("ViewportFrame") end)
        local slotN = nil
        if idxLbl and idxLbl:IsA("TextLabel") then
          slotN = tonumber(tostring(idxLbl.Text):match("%[(%d+)%]"))
        end
        if not slotN and itemLbl and itemLbl:IsA("TextLabel") then
          slotN = dispToSlot[tostring(itemLbl.Text)]
        end
        local cur = (slotN and eq[slotN]) or nil
        if (not cur or cur == "-" or not _G.EmoteSwapMap[cur]) and itemLbl and itemLbl:IsA("TextLabel") then
          local shown = tostring(itemLbl.Text)
          if shown ~= "" then
            for k, _ in pairs(_G.EmoteSwapMap) do
              if shown == k or shown == pretty(k) or shown == emoteDisplayOf(k) then cur = k break end
            end
          end
        end
        local want = (cur and cur ~= "-") and _G.EmoteSwapMap[cur] or nil
        if want and not emoteByName[want] then want = nil end
        local key = btn:GetFullName()
        local rig = nil
        if vp then pcall(function()
          local wm = vp:FindFirstChild("WorldModel")
          rig = wm and wm:FindFirstChild("VisualRigClassic")
        end) end
        if want then
          local disp = emoteDisplayOf(want)
          if itemLbl and itemLbl:IsA("TextLabel") then itemLbl.Text = disp end
          if rig then
            local aid = emoteAnimId(emoteByName[want].inst)
            if aid then playAid(rig, aid) end
          end
          n += 1
        else

          if itemLbl and itemLbl:IsA("TextLabel") and cur and cur ~= "-" and emoteByName[cur] then
            local shown = tostring(itemLbl.Text)
            local base = emoteDisplayOf(cur)
            local keep = shown == base or shown == pretty(cur) or shown == cur
              or (base ~= "" and string.find(shown, base, 1, true) ~= nil)
            if not keep then
              itemLbl.Text = base
              n += 1
            end
          end

          if rig and cur and cur ~= "-" and emoteByName[cur] then
            local aid = emoteAnimId(emoteByName[cur].inst)
            if aid and playAid(rig, aid) then n += 1 end
          end
        end
      end
    end
  end
  return n
end
local function repaintEmoteSlotSoon()
  for _, d in ipairs({ 0.5, 1.5, 3 }) do task.delay(d, function() pcall(paintEmoteSlots) end) end
end
_G.KenuyRepaintEmoteSlot = function() repaintEmoteSlotSoon() end
_G.KenuyPaintEmoteSlots = function() return paintEmoteSlots() end

local uEquippedName, uEquippedId = getEquippedUnusual()
local uPicked = nil

local uSourceMan = nil
local function uEffSource()
  if uEquippedName and uEquippedName ~= "-" then return uEquippedName end
  return uSourceMan
end
local function validUnusual(name) return name and name ~= "" and unusualByName[name] ~= nil end
local function refreshUnusual()
  uEquippedName, uEquippedId = getEquippedUnusual()
  local src = uEffSource()
  if src and (not uEquippedName or uEquippedName == "-") then
    uLbl.Text = "Manual: " .. tostring(src)
  else
    uLbl.Text = "UnusualSlot: " .. tostring(uEquippedName) .. (uEquippedId and (" (" .. uEquippedId .. ")") or "")
  end
  local rep = src and _G.UnusualSwapMap[src]
  uSub.Text = rep and ("-> " .. rep) or "-> -"
  pcall(paintUnusualSlot)
end
local uPage, uFilter = 1, ""
local function renderUnusualPage()
  for _, c in ipairs(uList:GetChildren()) do if c:IsA("TextButton") then c:Destroy() end end
  local all = {}
  for _, name in ipairs(unusualNames) do
    local d = unusualDisp[name] or name
    if uFilter == "" or string.find(string.lower(name), uFilter, 1, true) or string.find(string.lower(d), uFilter, 1, true) then
      table.insert(all, name)
    end
  end
  local pages = math.max(1, math.ceil(#all / PAGE))
  if uPage < 1 then uPage = 1 end
  if uPage > pages then uPage = pages end
  local start = (uPage - 1) * PAGE + 1
  local stop = math.min(start + PAGE - 1, #all)
  for i = start, stop do
    local name = all[i]
    local d = unusualDisp[name] or name
    local used = false
    for _, v in pairs(_G.UnusualSwapMap) do if v == name then used = true break end end

    local row = mk("TextButton", {Size=COMPACT and UDim2.new(0.48,0,0,132) or UDim2.new(0.31,0,0,132), BackgroundColor3=Color3.fromRGB(25,25,25), BorderSizePixel=0, Text="", AutoButtonColor=true, LayoutOrder=i}, uList)
    evCorner(row, UDim.new(0,8)) evGrad(row, 90, Color3.fromRGB(255,255,255), Color3.fromRGB(90,90,90), 0.6, 0.15) innerFrame(row, 6)
    local okU, dispU, iconU = pcall(unusualSlotInfo, name)
    local disp, icon = d, nil
    if okU then
      if type(dispU) == "string" and dispU ~= "" then disp = dispU end
      if type(iconU) == "string" and iconU ~= "" then icon = iconU end
    end
    if icon then
      local img = mk("ImageLabel", {Position=UDim2.new(0,6,0,6), Size=UDim2.new(1,-12,0,84), BackgroundColor3=Color3.fromRGB(10,10,10), BorderSizePixel=0, Image=icon, ScaleType=Enum.ScaleType.Fit}, row)
      evCorner(img, UDim.new(0,6))
    else
      mk("TextLabel", {Position=UDim2.new(0,6,0,6), Size=UDim2.new(1,-12,0,84), BackgroundTransparency=1, Font=FONTB, TextSize=28, TextColor3=Color3.fromRGB(90,120,130), Text=string.upper(string.sub(name,1,1))}, row)
    end
    mk("TextLabel", {Position=UDim2.new(0,6,0,92), Size=UDim2.new(1,-12,0,18), BackgroundTransparency=1, Font=FONTB, TextSize=12, TextColor3=Color3.fromRGB(255,255,255), TextXAlignment=Enum.TextXAlignment.Left, TextTruncate=Enum.TextTruncate.AtEnd, TextScaled=COMPACT, Text=disp}, row)
    mk("TextLabel", {Position=UDim2.new(0,6,0,110), Size=UDim2.new(1,-12,0,14), BackgroundTransparency=1, Font=FONT, TextSize=10, TextColor3=(used and Color3.fromRGB(90,220,150) or Color3.fromRGB(150,163,184)), TextXAlignment=Enum.TextXAlignment.Left, TextTruncate=Enum.TextTruncate.AtEnd, Text=(used and "DIPAKAI" or name)}, row)
    paintHover(row, function() return Color3.fromRGB(25,25,25) end, function() return Pal.hover end)
    row.MouseButton1Click:Connect(function()
      if not validUnusual(name) then setStatus("Gagal: unusual tidak ditemukan.", true) return end
      local src = uEffSource()
      if not src then
        uSourceMan = name
        setStatus("Sumber manual: " .. name .. ". Klik 1 unusual lain sebagai target.")
        refreshUnusual() repaintUnusualSlotSoon() renderUnusualPage()
        return
      end
      if src == name then setStatus("Sumber & target sama — pilih yang lain.", true) return end
      uPicked = name _G.UnusualSwapMap[src] = name _G.UnusualSwapById = buildUnusualIdMap()
      if NO_HOOK then pcall(function() _G.KenuyDirectApplyUnusual(src, name) end) end
      setStatus("OK " .. src .. " -> " .. name .. " (equip ulang).") refreshUnusual() repaintUnusualSlotSoon() renderUnusualPage()
    end)
  end
  uCountLbl.Text = #all .. " / " .. #unusualNames .. " unusual"
  uPageLbl.Text = uPage .. "/" .. pages
end
local function buildUnusualList(filter)
  uFilter = string.lower(filter or "")
  uPage = 1
  renderUnusualPage()
end
uSearch:GetPropertyChangedSignal("Text"):Connect(function() buildUnusualList(uSearch.Text) end)
uPrevBtn.MouseButton1Click:Connect(function() if uPage > 1 then uPage = uPage - 1 renderUnusualPage() end end)
uNextBtn.MouseButton1Click:Connect(function() uPage = uPage + 1 renderUnusualPage() end)
uApplyBtn.MouseButton1Click:Connect(function()
  local src = uEffSource()
  local pick = uPicked or uSearch.Text
  if not src then
    if validUnusual(pick) then
      uSourceMan = pick
      setStatus("Sumber manual: " .. pick .. ". Pilih target lalu Pasang.")
      refreshUnusual() repaintUnusualSlotSoon() renderUnusualPage()
    else
      setStatus("UnusualSlot kosong — pilih sumber dari daftar dulu.", true)
    end
    return
  end
  if not validUnusual(pick) then setStatus("Pilih dulu unusual dari daftar.", true) return end
  if src == pick then setStatus("Sumber & target sama.", true) return end
  _G.UnusualSwapMap[src] = pick _G.UnusualSwapById = buildUnusualIdMap()
  if NO_HOOK then pcall(function() _G.KenuyDirectApplyUnusual(src, pick) end) end
  setStatus("OK " .. src .. " -> " .. pick .. ". Unequip + equip ulang.") refreshUnusual() repaintUnusualSlotSoon() renderUnusualPage()
end)
uClearBtn.MouseButton1Click:Connect(function()
  local src = uEffSource()
  if src and _G.UnusualSwapMap[src] then _G.UnusualSwapMap[src] = nil uPicked = nil _G.UnusualSwapById = buildUnusualIdMap() setStatus("Mapping " .. src .. " dilepas.") refreshUnusual() repaintUnusualSlotSoon() renderUnusualPage()
  if NO_HOOK then pcall(function() _G.KenuyDirectRestoreUnusual(src) end) end
  elseif uSourceMan then uSourceMan = nil setStatus("Sumber manual dibatalkan.") refreshUnusual() repaintUnusualSlotSoon() renderUnusualPage()
  else setStatus("Tidak punya mapping.", true) end
end)

local bodyTheme
local tSwatches, tStrokes = {}, {}
local tLeft, tRight, tTitle, tOpLbl, opPct, opTrack, opFill, opKnob, tBubbleBtn, tInfo, scLbl, scPct, scTrack, scFill, scKnob
local bodyAbout
local aLeft, aRight, aNotes, aLinkBox, aCopyBtn, aJoinBtn, aMotto

local function showTab(which)
  bodyEmote.Visible = which == "emote"
  bodyUnusual.Visible = which == "unusual"
  bodyVisual.Visible = which == "visual"
  if bodyTheme then bodyTheme.Visible = which == "theme" end
  if bodyAbout then bodyAbout.Visible = which == "about" end
  centerTitle.Text = which == "emote" and "EMOTE SWAP" or which == "unusual" and "UNUSUAL SWAP" or which == "visual" and "VISUAL" or which == "theme" and "TEMA" or "ABOUT"
  local function paintTab(btn, active) btn.BackgroundColor3 = active and Pal.accent or Color3.fromRGB(30,30,30) for _,d in ipairs(btn:GetDescendants()) do if d:IsA("TextLabel") then d.TextColor3 = active and Pal.bg or Pal.text end end end
  paintTab(emoteTabBtn, which=="emote") paintTab(unusualTabBtn, which=="unusual") paintTab(visualTabBtn, which=="visual") paintTab(themeTabBtn, which=="theme") paintTab(aboutTabBtn, which=="about")
  if which == "emote" then equippedEmotes = getEquippedEmoteNames() refreshEmote() refreshVariantBar() repaintEmoteSlotSoon() elseif which == "unusual" then refreshUnusual() elseif which == "visual" then vRef() pcall(accRefresh) end
end
emoteTabBtn.MouseButton1Click:Connect(function() showTab("emote") end)
unusualTabBtn.MouseButton1Click:Connect(function() showTab("unusual") end)
visualTabBtn.MouseButton1Click:Connect(function() showTab("visual") end)
themeTabBtn.MouseButton1Click:Connect(function() showTab("theme") end)
aboutTabBtn.MouseButton1Click:Connect(function() showTab("about") end)

local tweenInfo, basePos, openTween = TweenInfo.new(0.22, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), main.Position, nil
local function updateBubble() bubble.Visible = (minimized or (COMPACT and not open)) and not bubbleHidden end
local function setOpen(v)
  open = v
  if openTween then pcall(function() openTween:Cancel() end) openTween = nil end
  if v then
    if minimized then minimized = false minBtn.Text = "—" end
    equippedEmotes = getEquippedEmoteNames() refreshEmote() refreshVariantBar() refreshUnusual() vRef() repaintEmoteSlotSoon()
    main.Visible = true Dim.Visible = true
    main.Position = basePos + UDim2.new(0,0,0,24)
    openTween = TweenService:Create(main, tweenInfo, {GroupTransparency=0, Position=basePos})
    openTween:Play()
  else
    openTween = TweenService:Create(main, tweenInfo, {GroupTransparency=1, Position=basePos + UDim2.new(0,0,0,24)})
    openTween:Play()
    openTween.Completed:Connect(function() if not open then main.Visible = false Dim.Visible = false end end)
  end
  updateBubble()
end
local function setMinimized(v) minimized = v main.Visible = not v Dim.Visible = not v if not v and not open then open = true end updateBubble() end
minBtn.MouseButton1Click:Connect(function() if minimized then setMinimized(false) minBtn.Text = "—" if not open then setOpen(true) end else setMinimized(true) minBtn.Text = "+" end end)
bubble.MouseButton1Click:Connect(function() if open and not minimized then setOpen(false) else setMinimized(false) minBtn.Text = "—" setOpen(true) end end)
bubbleX.MouseButton1Click:Connect(function() bubbleHidden = true updateBubble() end)
local function makeDraggable(frame, handle)
  local dragging, start, startPos = false, nil, nil
  handle.InputBegan:Connect(function(input) if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then dragging, start, startPos = true, input.Position, frame.Position end end)
  UserInputService.InputChanged:Connect(function(input) if dragging and (input.UserInputType == Enum.UserInputType.MouseMovement or input.UserInputType == Enum.UserInputType.Touch) then local d = input.Position - start frame.Position = startPos + UDim2.new(0,d.X,0,d.Y) if frame == main then basePos = main.Position end end end)
  UserInputService.InputEnded:Connect(function(input) if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then dragging = false end end)
end
makeDraggable(main, Left) makeDraggable(main, Center) makeDraggable(bubble, bubble)
_G.KenuyToggleConn = UserInputService.InputBegan:Connect(function(input) if input.KeyCode == Enum.KeyCode.RightControl then setOpen(not open) end end)
_G.KenuyVisualKeyConn = _G.KenuyVisualKeyConn or nil
pcall(function() if _G.KenuyVisualKeyConn then _G.KenuyVisualKeyConn:Disconnect() end end)
_G.KenuyVisualKeyConn = UserInputService.InputBegan:Connect(function(input, gpe) if gpe then return end if input.KeyCode == Enum.KeyCode.K then if open then setOpen(false) else setMinimized(false) minBtn.Text = "—" showTab("visual") setOpen(true) end end end)
local panelGrads = {}
local function paintGradients()
  local t = Themes[themeIdx]
  local cs = ColorSequence.new({ColorSequenceKeypoint.new(0, C3(t.accent)), ColorSequenceKeypoint.new(1, C3(t.grad or t.accentD))})
  for _, g in ipairs(panelGrads) do g.Color = cs g.Rotation = t.gradRot or 45 end
end
local function applyTheme(idx)
  _G.KenuyThemeIdx = idx themeIdx = idx
  for k, v in pairs(Themes[idx]) do if type(v) == "table" and k ~= "grad" then Pal[k] = C3(v) end end
  paintGradients()
  eSearch.BackgroundColor3 = Pal.card eSearch.TextColor3 = Pal.text eSearch.PlaceholderColor3 = Pal.dim
  uSearch.BackgroundColor3 = Pal.card uSearch.TextColor3 = Pal.text uSearch.PlaceholderColor3 = Pal.dim
  avBox.BackgroundColor3 = Pal.card avBox.TextColor3 = Pal.text avBox.PlaceholderColor3 = Pal.dim
  accBox.BackgroundColor3 = Pal.card accBox.TextColor3 = Pal.text accBox.PlaceholderColor3 = Pal.dim
  if aLeft then aNotes.TextColor3 = Pal.text aLinkBox.BackgroundColor3 = Pal.card aLinkBox.TextColor3 = Pal.accent aMotto.TextColor3 = Pal.dim end
  if tLeft then tTitle.TextColor3 = Pal.text tOpLbl.TextColor3 = Pal.text opPct.TextColor3 = Pal.accent opTrack.BackgroundColor3 = Pal.card opFill.BackgroundColor3 = Pal.accent opKnob.BackgroundColor3 = Pal.accent tInfo.TextColor3 = Pal.dim end
  if scLbl then scLbl.TextColor3 = Pal.text scPct.TextColor3 = Pal.accent scTrack.BackgroundColor3 = Pal.card scFill.BackgroundColor3 = Pal.accent scKnob.BackgroundColor3 = Pal.accent end
  bubble.BackgroundColor3 = Pal.accent bubbleX.BackgroundColor3 = Pal.danger
  status.TextColor3 = Pal.dim credit.TextColor3 = Pal.dim
  profName.TextColor3 = Pal.text profUser.TextColor3 = Pal.dim profId.TextColor3 = Pal.dim
  discLbl.TextColor3 = Pal.text discBox.BackgroundColor3 = Pal.card discBox.TextColor3 = Pal.accent
  discCopyBtn.BackgroundColor3 = Pal.accent
  for _, b in pairs(eBtns) do b.Mono.BackgroundColor3 = Pal.accentD b.Mono.TextColor3 = Pal.text b.Lbl.TextColor3 = Pal.text b.Sub.TextColor3 = Pal.accent end
  uLbl.TextColor3 = Pal.text uSub.TextColor3 = Pal.accent
  vRef()
  for j, s in ipairs(tStrokes) do s.Transparency = (j == idx) and 0 or 1 end
  buildEmoteList(eSearch.Text) buildUnusualList(uSearch.Text) refreshEmote() refreshUnusual() vRef() setStatus("Tema " .. Themes[idx].name .. " aktif.")
end
do
  bodyTheme = mk("Frame", {Name="bodyTheme", Position=UDim2.new(0,12,0,66), Size=UDim2.new(1,-24,1,-78), BackgroundTransparency=1, Visible=false}, Center)
  tLeft = mk("Frame", {Size=UDim2.new(0.46,-6,1,0), BackgroundColor3=Color3.fromRGB(15,15,15), BackgroundTransparency=0.15, BorderSizePixel=0}, bodyTheme)
  evCorner(tLeft, UDim.new(0,8))
  mk("UIPadding", {PaddingTop=UDim.new(0,8), PaddingLeft=UDim.new(0,8), PaddingRight=UDim.new(0,8), PaddingBottom=UDim.new(0,8)}, tLeft)
  tTitle = mk("TextLabel", {Size=UDim2.new(1,0,0,20), BackgroundTransparency=1, Text="TEMA (" .. #Themes .. ")", Font=FONTB, TextSize=12, TextColor3=Color3.fromRGB(235,240,248), TextXAlignment=Enum.TextXAlignment.Left}, tLeft)
  local tGrid = mk("ScrollingFrame", {Position=UDim2.new(0,0,0,26), Size=UDim2.new(1,0,1,-26), BackgroundTransparency=1, ScrollBarThickness=4, CanvasSize=UDim2.new(0,0,0,0), AutomaticCanvasSize=Enum.AutomaticSize.Y}, tLeft)
  mk("UIGridLayout", {CellSize=UDim2.new(0.48,0,0,32), CellPadding=UDim2.new(0.04,0,0,6), SortOrder=Enum.SortOrder.LayoutOrder}, tGrid)
  for i = 1, #Themes do
    local idx = i
    local sw = mk("TextButton", {BackgroundColor3=C3(Themes[idx].accent), Text=Themes[idx].name, Font=FONTB, TextSize=11, TextColor3=Color3.fromRGB(255,255,255), BorderSizePixel=0, AutoButtonColor=false, LayoutOrder=idx}, tGrid)
    evCorner(sw, UDim.new(0,6)) evGrad(sw, 90, Color3.fromRGB(255,255,255), Color3.fromRGB(140,140,140), 0.5, 0.15)
    tStrokes[idx] = mk("UIStroke", {Color=Color3.fromRGB(255,255,255), Thickness=2, Transparency=(idx==themeIdx) and 0 or 1}, sw)
    tSwatches[idx] = sw
    sw.MouseButton1Click:Connect(function() applyTheme(idx) end)
  end
  tRight = mk("Frame", {AnchorPoint=Vector2.new(1,0), Position=UDim2.fromScale(1,0), Size=UDim2.new(0.54,-6,1,0), BackgroundColor3=Color3.fromRGB(15,15,15), BackgroundTransparency=0.15, BorderSizePixel=0}, bodyTheme)
  evCorner(tRight, UDim.new(0,8))
  mk("UIPadding", {PaddingTop=UDim.new(0,8), PaddingLeft=UDim.new(0,8), PaddingRight=UDim.new(0,8), PaddingBottom=UDim.new(0,8)}, tRight)
  tOpLbl = mk("TextLabel", {Size=UDim2.new(1,-60,0,20), BackgroundTransparency=1, Text="OPASITAS", Font=FONTB, TextSize=12, TextColor3=Color3.fromRGB(235,240,248), TextXAlignment=Enum.TextXAlignment.Left}, tRight)
  opPct = mk("TextLabel", {AnchorPoint=Vector2.new(1,0), Position=UDim2.fromScale(1,0), Size=UDim2.new(0,60,0,20), BackgroundTransparency=1, Font=FONTB, TextSize=12, TextColor3=Color3.fromRGB(45,212,191), TextXAlignment=Enum.TextXAlignment.Right, Text="0%"}, tRight)
  opTrack = mk("TextButton", {Position=UDim2.new(0,0,0,28), Size=UDim2.new(1,0,0,12), BackgroundColor3=Color3.fromRGB(33,43,63), Text="", BorderSizePixel=0, AutoButtonColor=false}, tRight)
  evCorner(opTrack, UDim.new(1,0))
  opFill = mk("Frame", {Size=UDim2.new(0,0,1,0), BackgroundColor3=Color3.fromRGB(45,212,191), BorderSizePixel=0}, opTrack)
  evCorner(opFill, UDim.new(1,0))
  opKnob = mk("TextButton", {AnchorPoint=Vector2.new(0.5,0.5), Size=UDim2.new(0,20,0,20), BackgroundColor3=Color3.fromRGB(45,212,191), Text="", Font=FONTB, TextSize=10, TextColor3=Color3.fromRGB(16,21,32), BorderSizePixel=0, AutoButtonColor=false}, opTrack)
  evCorner(opKnob, UDim.new(1,0))
  local bgFrames = {Left, Center, Right, eLeft, eRight, uLeft, uRight, vLeft, vRight, tLeft, tRight}
  local function bgApply()
    local tr = 1 - (_G.KenuyBgOpacity or 90) / 100
    for _, f in ipairs(bgFrames) do pcall(function() f.BackgroundTransparency = tr * 0.85 + 0.05 end) end
    if aLeft then pcall(function() aLeft.BackgroundTransparency = tr * 0.85 + 0.05 end) end
    if aRight then pcall(function() aRight.BackgroundTransparency = tr * 0.85 + 0.05 end) end
  end
  _G.KenuyBgApply = bgApply
  local function opSet(pct)
    pct = math.clamp(pct, 0, 1)
    _G.KenuyBgOpacity = math.floor(pct * 100 + 0.5)
    opFill.Size = UDim2.new(pct,0,1,0) opKnob.Position = UDim2.new(pct,0,0.5,0) opPct.Text = tostring(_G.KenuyBgOpacity) .. "%"
    bgApply()
  end
  local opDrag = false
  local function opFromInput(input) local ax, aw = opTrack.AbsolutePosition.X, opTrack.AbsoluteSize.X if aw <= 0 then return end opSet((input.Position.X - ax) / aw) end
  opKnob.InputBegan:Connect(function(input) if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then opDrag = true opFromInput(input) end end)
  opTrack.InputBegan:Connect(function(input) if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then opDrag = true opFromInput(input) end end)
  UserInputService.InputChanged:Connect(function(input) if opDrag and (input.UserInputType == Enum.UserInputType.MouseMovement or input.UserInputType == Enum.UserInputType.Touch) then opFromInput(input) end end)
  UserInputService.InputEnded:Connect(function(input) if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then opDrag = false end end)
  opSet((_G.KenuyBgOpacity or 90) / 100)
  tBubbleBtn,_ = evadeButton(tRight, "Bubble: ON", Color3.fromRGB(33,43,63), Color3.fromRGB(120,120,120), 30) tBubbleBtn.Position = UDim2.new(0,0,0,52)
  paintHover(tBubbleBtn, function() return Pal.card end, function() return Pal.hover end)
  local function tBubRef() for _,d in ipairs(tBubbleBtn:GetDescendants()) do if d:IsA("TextLabel") then d.Text = bubbleHidden and "Bubble: OFF" or "Bubble: ON" end end end
  tBubRef()
  tBubbleBtn.MouseButton1Click:Connect(function() bubbleHidden = not bubbleHidden tBubRef() updateBubble() setStatus(bubbleHidden and "Bubble disembunyikan." or "Bubble ditampilkan saat minimize.") end)

  scLbl = mk("TextLabel", {Position=UDim2.new(0,0,0,88), Size=UDim2.new(1,-60,0,20), BackgroundTransparency=1, Text="SKALA UI", Font=FONTB, TextSize=12, TextColor3=Color3.fromRGB(235,240,248), TextXAlignment=Enum.TextXAlignment.Left}, tRight)
  scPct = mk("TextButton", {AnchorPoint=Vector2.new(1,0), Position=UDim2.fromScale(1,0), Size=UDim2.new(0,60,0,20), BackgroundTransparency=1, Font=FONTB, TextSize=12, TextColor3=Color3.fromRGB(45,212,191), TextXAlignment=Enum.TextXAlignment.Right, Text="100%", AutoButtonColor=false}, tRight)
  scTrack = mk("TextButton", {Position=UDim2.new(0,0,0,112), Size=UDim2.new(1,0,0,12), BackgroundColor3=Color3.fromRGB(33,43,63), Text="", BorderSizePixel=0, AutoButtonColor=false}, tRight)
  evCorner(scTrack, UDim.new(1,0))
  scFill = mk("Frame", {Size=UDim2.new(0,0,1,0), BackgroundColor3=Color3.fromRGB(45,212,191), BorderSizePixel=0}, scTrack)
  evCorner(scFill, UDim.new(1,0))
  scKnob = mk("TextButton", {AnchorPoint=Vector2.new(0.5,0.5), Size=UDim2.new(0,20,0,20), BackgroundColor3=Color3.fromRGB(45,212,191), Text="", Font=FONTB, TextSize=10, TextColor3=Color3.fromRGB(16,21,32), BorderSizePixel=0, AutoButtonColor=false}, scTrack)
  evCorner(scKnob, UDim.new(1,0))
  local function scApply(s)
    s = math.clamp(s, 0.6, 1.4)
    _G.KenuyUiScaleMan = s
    uiScale.Scale = s
    local p = (s - 0.6) / 0.8
    scFill.Size = UDim2.new(p, 0, 1, 0) scKnob.Position = UDim2.new(p, 0, 0.5, 0) scPct.Text = tostring(math.floor(s * 100 + 0.5)) .. "%"
  end
  local scDrag = false
  local function scFromInput(input) local ax, aw = scTrack.AbsolutePosition.X, scTrack.AbsoluteSize.X if aw <= 0 then return end scApply(0.6 + (input.Position.X - ax) / aw * 0.8) end
  scKnob.InputBegan:Connect(function(input) if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then scDrag = true scFromInput(input) end end)
  scTrack.InputBegan:Connect(function(input) if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then scDrag = true scFromInput(input) end end)
  UserInputService.InputChanged:Connect(function(input) if scDrag and (input.UserInputType == Enum.UserInputType.MouseMovement or input.UserInputType == Enum.UserInputType.Touch) then scFromInput(input) end end)
  UserInputService.InputEnded:Connect(function(input) if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then scDrag = false end end)
  scPct.MouseButton1Click:Connect(function()
    _G.KenuyUiScaleMan = nil
    fitScale()
    local p = (uiScale.Scale - 0.6) / 0.8
    scFill.Size = UDim2.new(p, 0, 1, 0) scKnob.Position = UDim2.new(p, 0, 0.5, 0) scPct.Text = tostring(math.floor(uiScale.Scale * 100 + 0.5)) .. "%"
    setStatus("Skala UI: Auto-fit layar.")
  end)
  do local p = (uiScale.Scale - 0.6) / 0.8 scFill.Size = UDim2.new(p, 0, 1, 0) scKnob.Position = UDim2.new(p, 0, 0.5, 0) scPct.Text = tostring(math.floor(uiScale.Scale * 100 + 0.5)) .. "%" end
  tInfo = mk("TextLabel", {Position=UDim2.new(0,0,0,132), Size=UDim2.new(1,0,1,-132), BackgroundTransparency=1, Font=FONT, TextSize=11, TextColor3=Color3.fromRGB(150,163,184), TextWrapped=true, TextYAlignment=Enum.TextYAlignment.Top, Text="Slider SKALA mengatur besar UI (60-140%), tersimpan. Ketuk angka % untuk Auto-fit. Bubble = tombol K untuk buka cepat."}, tRight)
end
do
  local DISCORD_URL = "https://discord.gg/xsCeM84Nmg"
  local function copyLink()
    local clip = setclipboard
    if type(clip) ~= "function" then pcall(function() clip = getgenv().setclipboard end) end
    if type(clip) == "function" then local ok = pcall(clip, DISCORD_URL) if ok then return true end end
    return false
  end
  local function openLink()
    local ok = pcall(function() game:GetService("GuiService"):OpenBrowserWindow(DISCORD_URL) end)
    if ok then return true end
    local fns = {}
    pcall(function() if getgenv then for _, k in ipairs({"openUrl","open_url"}) do local f = getgenv()[k] if type(f)=="function" then table.insert(fns,f) end end end end)
    for _, fn in ipairs(fns) do if pcall(fn, DISCORD_URL) then return true end end
    return false
  end
  bodyAbout = mk("Frame", {Name="bodyAbout", Position=UDim2.new(0,12,0,66), Size=UDim2.new(1,-24,1,-78), BackgroundTransparency=1, Visible=false}, Center)
  aLeft = mk("Frame", {Size=UDim2.new(0.56,-6,1,0), BackgroundColor3=Color3.fromRGB(15,15,15), BackgroundTransparency=0.15, BorderSizePixel=0}, bodyAbout)
  evCorner(aLeft, UDim.new(0,8))
  mk("UIPadding", {PaddingTop=UDim.new(0,8), PaddingLeft=UDim.new(0,8), PaddingRight=UDim.new(0,8), PaddingBottom=UDim.new(0,8)}, aLeft)
  mk("TextLabel", {Size=UDim2.new(1,0,0,20), BackgroundTransparency=1, Text="(KenuySwap)", Font=FONTB, TextSize=12, TextColor3=Color3.fromRGB(235,240,248), TextXAlignment=Enum.TextXAlignment.Left}, aLeft)
  local aScroll = mk("ScrollingFrame", {Position=UDim2.new(0,0,0,26), Size=UDim2.new(1,0,1,-26), BackgroundTransparency=1, ScrollBarThickness=4, CanvasSize=UDim2.new(0,0,0,0), AutomaticCanvasSize=Enum.AutomaticSize.Y}, aLeft)
  mk("UIListLayout", {Padding=UDim.new(0,2), SortOrder=Enum.SortOrder.LayoutOrder}, aScroll)
  aNotes = mk("TextLabel", {Size=UDim2.new(1,-6,0,0), BackgroundTransparency=1, Font=FONT, TextSize=12, TextColor3=Color3.fromRGB(235,240,248), TextXAlignment=Enum.TextXAlignment.Left, TextYAlignment=Enum.TextYAlignment.Top, TextWrapped=true, AutomaticSize=Enum.AutomaticSize.Y, Text=[[KenuySwap -

Status:
- Development Version 0.3a Solara Support

Main Features:
- Visual Emote Changer
- Emote Database / List
- Emote Sound
- Emote Variant Support 
- Auto Detect Emote
- Unusual Changer
- Auto Detect Unusual
- All Unusual List
- Korblox & Headless Visual
- Avatar Loader
- Accessory Loader 

join our discord for update or suggestion

larp till u make it
@ackley]]}, aScroll)
  aRight = mk("Frame", {AnchorPoint=Vector2.new(1,0), Position=UDim2.fromScale(1,0), Size=UDim2.new(0.44,-6,1,0), BackgroundColor3=Color3.fromRGB(15,15,15), BackgroundTransparency=0.15, BorderSizePixel=0}, bodyAbout)
  evCorner(aRight, UDim.new(0,8))
  mk("UIPadding", {PaddingTop=UDim.new(0,8), PaddingLeft=UDim.new(0,8), PaddingRight=UDim.new(0,8), PaddingBottom=UDim.new(0,8)}, aRight)
  mk("TextLabel", {Size=UDim2.new(1,0,0,20), BackgroundTransparency=1, Text="DISCORD", Font=FONTB, TextSize=12, TextColor3=Color3.fromRGB(235,240,248), TextXAlignment=Enum.TextXAlignment.Left}, aRight)
  aLinkBox = mk("TextBox", {Position=UDim2.new(0,0,0,26), Size=UDim2.new(1,0,0,28), BackgroundColor3=Color3.fromRGB(33,43,63), TextColor3=Color3.fromRGB(45,212,191), Font=FONT, TextSize=11, Text=DISCORD_URL, TextEditable=false, ClearTextOnFocus=false}, aRight)
  evCorner(aLinkBox, UDim.new(0,6))
  aCopyBtn,_ = evadeButton(aRight, "Salin Link", Color3.fromRGB(45,212,191), Color3.fromRGB(140,140,140), 30) aCopyBtn.Position = UDim2.new(0,0,0,60)
  paintHover(aCopyBtn, function() return Pal.accent end, function() return Pal.applyH end)
  aJoinBtn,_ = evadeButton(aRight, "Join Discord", Color3.fromRGB(45,212,191), Color3.fromRGB(140,140,140), 30) aJoinBtn.Position = UDim2.new(0,0,0,96)
  paintHover(aJoinBtn, function() return Pal.accent end, function() return Pal.applyH end)
  aCopyBtn.MouseButton1Click:Connect(function() if copyLink() then setStatus("Link Discord disalin.") else setStatus("Clipboard tidak tersedia — salin manual.", true) end end)
  aJoinBtn.MouseButton1Click:Connect(function() copyLink() if openLink() then setStatus("Membuka Discord...") else setStatus("Browser tidak bisa dibuka — link sudah disalin.", true) end end)
  aMotto = mk("TextLabel", {Position=UDim2.new(0,0,0,134), Size=UDim2.new(1,0,1,-134), BackgroundTransparency=1, Font=FONTB, TextSize=13, TextColor3=Color3.fromRGB(150,163,184), TextWrapped=true, TextYAlignment=Enum.TextYAlignment.Top, Text="larp till u make it\n@ackley"}, aRight)
end
for _, p in ipairs({eLeft, eRight, uLeft, uRight, vLeft, vRight, tLeft, tRight, aLeft, aRight}) do
  local g = mk("UIGradient", {Rotation=Themes[themeIdx].gradRot or 45}, p)
  g.Transparency = NumberSequence.new({NumberSequenceKeypoint.new(0,0.85), NumberSequenceKeypoint.new(1,0.92)})
  table.insert(panelGrads, g)
end
paintGradients()
mk("UIStroke", {Color=Color3.fromRGB(45,212,191), Thickness=1, Transparency=0.9}, Center)
if IS_MOBILE then hintLbl.Text = "Ketuk K • bubble" end
updateBubble()
showTab("about")
if #emoteNames == 0 and #unusualNames == 0 then
  setStatus("Data emote + unusual kosong.", true)
else
  buildEmoteList("") buildUnusualList("") refreshEmote() refreshVariantBar() refreshUnusual() vRef()

  if COMPACT then
    pcall(function()
      for _, d in ipairs(main:GetDescendants()) do
        if d:IsA("TextLabel") or d:IsA("TextButton") or d:IsA("TextBox") then
          local s = d.TextSize
          if s >= 9 and s <= 15 then
            d.TextSize = math.min(s + 3, 18)
          end
        end
      end
    end)
  end
  status.Text = #emoteNames .. " emote + " .. #unusualNames .. " unusual terdeteksi. " .. (COMPACT and "Ketuk bubble K." or "Tekan RightCtrl, K = Visual.")
end
end
buildKenuyUI()

vAssertState()
task.spawn(function() while gui.Parent do task.wait(1.5) if _G.KenuyVisualKorblox or _G.KenuyVisualHeadless then pcall(vApplyAll) end end end)
VLP.CharacterAdded:Connect(function() task.wait(1) pcall(vApplyAll) end)

_G.AvatarLoaderLoop = true
task.spawn(function()
  local lastVisual = nil
  while _G.AvatarLoaderLoop and gui.Parent do
    task.wait(3)
    if avAuto and avDesc then
      pcall(function()
        local pc = workspace:FindFirstChild("PlayerCache")
        local hd = pc and pc:FindFirstChild(VLP.Name)
        if hd and hd:IsA("HumanoidDescription") and #hd:GetAccessories(true) ~= #avDesc:GetAccessories(true) then
          hd.Shirt, hd.Pants = avDesc.Shirt, avDesc.Pants
          pcall(function() hd:SetAccessories(avDesc:GetAccessories(true), true) end)
        end
      end)
      local visual = avGetRig()
      if visual and visual ~= lastVisual then
        lastVisual = visual
        local ok, _ = pcall(avCopy, visual, avDesc)
        if ok then avNotify("Auto-apply @" .. tostring(avName) .. " ke rig baru.") end
      end
    else
      lastVisual = avGetRig()
    end
  end
end)

if NO_HOOK then
  _G.KenuySoundSwap = _G.KenuySoundSwap or {}
  local function kenuyHookSoundPos(sp)
    if not (sp and typeof(sp) == "Instance") then return end
    local okA, tagged = pcall(function() return sp:GetAttribute("KenuyWatched") end)
    if okA and tagged then return end
    pcall(function() sp:SetAttribute("KenuyWatched", true) end)
    pcall(function()
      sp.ChildAdded:Connect(function(c)
        if not c or c.Name ~= "EmoteSound" or not c:IsA("Sound") then return end
        local map = _G.KenuySoundSwap
        if type(map) ~= "table" then return end
        local cur = tostring(c.SoundId)
        for _, m in pairs(map) do
          local olds = m.old
          if type(olds) == "table" then
            for _, oid in ipairs(olds) do
              if cur == oid then
                local news = m.new
                if type(news) == "table" and #news > 0 then
                  c.SoundId = news[math.random(1, #news)]
                end
                return
              end
            end
          end
        end
      end)
    end)
  end
  local function kenuyWatchSounds()
    pcall(function()
      for _, m in ipairs(vAllModels()) do
        local sp = m:FindFirstChild("SoundPos", true)
        if sp then kenuyHookSoundPos(sp) end
      end
    end)
    pcall(function()
      local ch = VLP.Character
      if ch then
        local sp = ch:FindFirstChild("SoundPos", true)
        if sp then kenuyHookSoundPos(sp) end
      end
    end)
  end
  task.spawn(function()
    while true do
      task.wait(3)
      if not (gui and gui.Parent) then break end
      pcall(paintUnusualSlot)
      pcall(function() if _G.KenuyPaintEmoteSlots then _G.KenuyPaintEmoteSlots() end end)
      pcall(function() if _G.KenuyPaintWheel then _G.KenuyPaintWheel() end end)
      pcall(kenuyWatchSounds)
    end
  end)
  pcall(kenuyWatchSounds)
end
pcall(function()
  game:GetService("StarterGui"):SetCore("SendNotification", {
    Title = "KenuySwap 0.3a Solara",
    Text = #emoteNames .. " emote + " .. #unusualNames .. " unusual siap." .. (NO_HOOK and " (mode Solara)" or ""),
    Duration = 5,
  })
end)
print("KenuySwap 0.3a Solara Loaded")
