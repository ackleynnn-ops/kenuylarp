local function _syba7ZR(...) local a={...} local r={} for i=1,#a do r[i]=string.char(a[i]) end return table.concat(r) end
local _cA9P5Nd = game:GetService("Players")
local _uDwyenw = game:GetService("UserInputService")
local _uucbIMm = _cA9P5Nd.LocalPlayer
local _vw4zzZV, _ztQb1wM = 101851696, 101851254
local _yQ36xgB = "rbxassetid://15093053680"
local __Oz5eGS, _xkX0vyO = true, true
local _n7kTENS, _vRPMqTn, _q0M6yic = {}, {}, {}
local function _o8I1q4d()
local _psbjjD_ = {}
local function _bBsV_jd(_gkRmgfk) if _gkRmgfk and typeof(_gkRmgfk) == "Instance" and _gkRmgfk:IsA("Model") then table.insert(_psbjjD_, _gkRmgfk) end end
if _uucbIMm.Character and (_uucbIMm.Character:FindFirstChild("Right Leg") or _uucbIMm.Character:FindFirstChild("RightLeg")) then _bBsV_jd(_uucbIMm.Character) end
pcall(function() local _uZCDTZz = workspace:FindFirstChild("Rigs") if _uZCDTZz and _uZCDTZz:FindFirstChild(_uucbIMm.Name) then _bBsV_jd(_uZCDTZz[_uucbIMm.Name]) end end)
pcall(function() local _vptdFYT = workspace:FindFirstChild("PlayerCache") if _vptdFYT and _vptdFYT:FindFirstChild(_uucbIMm.Name) then local _yLQPcPJ = _vptdFYT[_uucbIMm.Name]:FindFirstChild("R6") if _yLQPcPJ then _bBsV_jd(_yLQPcPJ) end end end)
pcall(function() for _, _c2PQixr in ipairs(_uucbIMm.PlayerGui:GetDescendants()) do if _c2PQixr:IsA("Model") and _c2PQixr.Name == "VisualRigClassic" and _c2PQixr:FindFirstChild("Right Leg") then table.insert(_psbjjD_, _c2PQixr) end end end)
return _psbjjD_
end
local function _aY7NvBK(_gkRmgfk)
pcall(function()
local _uZCDTZz = _gkRmgfk:FindFirstChild("Right Leg") or _gkRmgfk:FindFirstChild("RightLeg")
local _oVUblYm = _gkRmgfk:FindFirstChild("Left Leg") or _gkRmgfk:FindFirstChild("LeftLeg")
if _uZCDTZz and _oVUblYm and _uZCDTZz:IsA("BasePart") and _oVUblYm:IsA("BasePart") then _uZCDTZz.Color = _oVUblYm.Color _uZCDTZz.Material = _oVUblYm.Material _uZCDTZz.Reflectance = 0 end
end)
end
local function _fHHHlXQ(_gkRmgfk)
_aY7NvBK(_gkRmgfk)
for _, _bBoRYAv in ipairs(_gkRmgfk:GetChildren()) do if _bBoRYAv:IsA("CharacterMesh") and _bBoRYAv.BodyPart == Enum.BodyPart.RightLeg and _bBoRYAv.MeshId == _vw4zzZV then return end end
local _uBtW89I = Instance.new("CharacterMesh")
_uBtW89I.Name = _syba7ZR(75,111,114,98,108,111,120,32,68,101,97,116,104,115,112,101,97,107,101,114,32,82,105,103,104,116,32,76,101,103)
_uBtW89I.BodyPart = Enum.BodyPart.RightLeg
_uBtW89I.MeshId = _vw4zzZV
_uBtW89I.OverlayTextureId = _ztQb1wM
_uBtW89I.Parent = _gkRmgfk
end
local function _vbOmmgs(_gkRmgfk)
for _, _bBoRYAv in ipairs(_gkRmgfk:GetChildren()) do if _bBoRYAv:IsA("CharacterMesh") and _bBoRYAv.BodyPart == Enum.BodyPart.RightLeg and (_bBoRYAv.MeshId == _vw4zzZV or _bBoRYAv.Name:lower():find("korblox")) then _bBoRYAv:Destroy() end end
end
local function _zoJcX_J(_gkRmgfk)
local _c63PUNF = _gkRmgfk:FindFirstChild("Head")
if not _c63PUNF or not _c63PUNF:IsA("BasePart") or _c63PUNF:IsA("MeshPart") then return end
local _mjN0rWV = _c63PUNF:FindFirstChildOfClass("SpecialMesh")
if _mjN0rWV then if _n7kTENS[_mjN0rWV] == nil then _n7kTENS[_mjN0rWV] = _mjN0rWV.MeshId end _mjN0rWV.MeshId = _yQ36xgB end
if _vRPMqTn[_c63PUNF] == nil then _vRPMqTn[_c63PUNF] = _c63PUNF.Transparency end
_c63PUNF.Transparency = 1
for _, _c2PQixr in ipairs(_c63PUNF:GetChildren()) do if _c2PQixr:IsA("Decal") then if _q0M6yic[_c2PQixr] == nil then _q0M6yic[_c2PQixr] = _c2PQixr.Transparency end _c2PQixr.Transparency = 1 end end
end
local function _gCV6ZKu(_gkRmgfk)
local _c63PUNF = _gkRmgfk:FindFirstChild("Head")
if not _c63PUNF then return end
if _vRPMqTn[_c63PUNF] ~= nil then pcall(function() _c63PUNF.Transparency = _vRPMqTn[_c63PUNF] end) end
local _mjN0rWV = _c63PUNF:FindFirstChildOfClass("SpecialMesh")
if _mjN0rWV and _n7kTENS[_mjN0rWV] ~= nil then pcall(function() _mjN0rWV.MeshId = _n7kTENS[_mjN0rWV] end) end
for _, _c2PQixr in ipairs(_c63PUNF:GetChildren()) do if _c2PQixr:IsA("Decal") and _q0M6yic[_c2PQixr] ~= nil then pcall(function() _c2PQixr.Transparency = _q0M6yic[_c2PQixr] end) end end
end
local function _kRS66MD()
for _, _gkRmgfk in ipairs(_o8I1q4d()) do pcall(function()
if __Oz5eGS then _fHHHlXQ(_gkRmgfk) end
if _xkX0vyO then _zoJcX_J(_gkRmgfk) end
end) end
end
pcall(function() local _wa6tOQ2 = _uucbIMm.PlayerGui:FindFirstChild(_syba7ZR(75,101,110,117,121,76,97,114,112)) if _wa6tOQ2 then _wa6tOQ2:Destroy() end end)
pcall(function() local _wa6tOQ2 = _uucbIMm.PlayerGui:FindFirstChild(_syba7ZR(86,105,115,117,97,108,76,111,99,97,108,71,117,105)) if _wa6tOQ2 then _wa6tOQ2:Destroy() end end)
local _j5CLy9O = Color3.fromRGB(17, 17, 19)
local _q_N_KXc = Color3.fromRGB(24, 24, 28)
local _t7ITxKL = Color3.fromRGB(34, 34, 40)
local _xPt25nN = Color3.fromRGB(46, 46, 54)
local _rjBwMT4 = Color3.fromRGB(240, 240, 245)
local _aZHFIWP = Color3.fromRGB(160, 162, 170)
local _dDp9kY2 = Color3.fromRGB(22, 163, 74)
local _ikoT1vz = Instance.new("ScreenGui")
_ikoT1vz.Name = _syba7ZR(75,101,110,117,121,76,97,114,112)
_ikoT1vz.ResetOnSpawn = false
_ikoT1vz.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
_ikoT1vz.Parent = _uucbIMm.PlayerGui
local _rP6zKMp = Instance.new("Frame")
_rP6zKMp.Size = UDim2.new(0, 240, 0, 216)
_rP6zKMp.Position = UDim2.new(0, 20, 0.5, -108)
_rP6zKMp.BackgroundColor3 = _j5CLy9O
_rP6zKMp.BorderSizePixel = 0
_rP6zKMp.Active = true
_rP6zKMp.Draggable = true
_rP6zKMp.Parent = _ikoT1vz
local _kXz3wo6 = Instance.new("UICorner") _kXz3wo6.CornerRadius = UDim.new(0, 10) _kXz3wo6.Parent = _rP6zKMp
local _hy0TfDS = Instance.new("UIStroke") _hy0TfDS.Color = _xPt25nN _hy0TfDS.Thickness = 1 _hy0TfDS.Parent = _rP6zKMp
local _bVFTVLD = Instance.new("TextLabel")
_bVFTVLD.Size = UDim2.new(1, -40, 0, 34)
_bVFTVLD.Position = UDim2.new(0, 12, 0, 0)
_bVFTVLD.BackgroundTransparency = 1
_bVFTVLD.Text = _syba7ZR(75,101,110,117,121,32,76,97,114,112,32,48,46,49)
_bVFTVLD.TextColor3 = _rjBwMT4
_bVFTVLD.Font = Enum.Font.GothamBold
_bVFTVLD.TextSize = 15
_bVFTVLD.TextXAlignment = Enum.TextXAlignment.Left
_bVFTVLD.Parent = _rP6zKMp
local _fpWoPcT = Instance.new("TextButton")
_fpWoPcT.Size = UDim2.new(0, 24, 0, 24)
_fpWoPcT.Position = UDim2.new(1, -30, 0, 6)
_fpWoPcT.Text = "X"
_fpWoPcT.Font = Enum.Font.GothamBold
_fpWoPcT.TextSize = 13
_fpWoPcT.BackgroundColor3 = _t7ITxKL
_fpWoPcT.TextColor3 = _rjBwMT4
_fpWoPcT.Parent = _rP6zKMp
local _avf17rF = Instance.new("UICorner") _avf17rF.CornerRadius = UDim.new(0, 6) _avf17rF.Parent = _fpWoPcT
local _gwIv7rL = Instance.new("UIStroke") _gwIv7rL.Color = _xPt25nN _gwIv7rL.Thickness = 1 _gwIv7rL.Parent = _fpWoPcT
local function _tqZmJeO(_lYOgYkf)
local _bBoRYAv = Instance.new("UICorner") _bBoRYAv.CornerRadius = UDim.new(0, 8) _bBoRYAv.Parent = _lYOgYkf
local _rDEVmee = Instance.new("UIStroke") _rDEVmee.Color = _xPt25nN _rDEVmee.Thickness = 1 _rDEVmee.Parent = _lYOgYkf
end
local _qLymOCh = Instance.new("TextButton")
_qLymOCh.Size = UDim2.new(1, -24, 0, 40)
_qLymOCh.Position = UDim2.new(0, 12, 0, 40)
_qLymOCh.Font = Enum.Font.GothamBold
_qLymOCh.TextSize = 14
_qLymOCh.TextColor3 = _rjBwMT4
_qLymOCh.BackgroundColor3 = _q_N_KXc
_qLymOCh.Parent = _rP6zKMp
_tqZmJeO(_qLymOCh)
local _dR2R8jG = Instance.new("TextButton")
_dR2R8jG.Size = UDim2.new(1, -24, 0, 40)
_dR2R8jG.Position = UDim2.new(0, 12, 0, 86)
_dR2R8jG.Font = Enum.Font.GothamBold
_dR2R8jG.TextSize = 14
_dR2R8jG.TextColor3 = _rjBwMT4
_dR2R8jG.BackgroundColor3 = _q_N_KXc
_dR2R8jG.Parent = _rP6zKMp
_tqZmJeO(_dR2R8jG)
local _uqqeTi8 = Instance.new("TextLabel")
_uqqeTi8.Size = UDim2.new(1, -24, 0, 18)
_uqqeTi8.Position = UDim2.new(0, 12, 0, 132)
_uqqeTi8.BackgroundTransparency = 1
_uqqeTi8.Text = _syba7ZR(80,114,101,115,115,32,75,32,116,111,32,116,111,103,103,108,101)
_uqqeTi8.TextColor3 = _aZHFIWP
_uqqeTi8.Font = Enum.Font.Gotham
_uqqeTi8.TextSize = 12
_uqqeTi8.Parent = _rP6zKMp
local _b5ku0fm = Instance.new("TextLabel")
_b5ku0fm.Size = UDim2.new(1, -24, 0, 18)
_b5ku0fm.Position = UDim2.new(0, 12, 0, 152)
_b5ku0fm.BackgroundTransparency = 1
_b5ku0fm.Text = _syba7ZR(109,97,100,101,32,98,121,32,64,97,99,107,108,101,121,110)
_b5ku0fm.TextColor3 = _aZHFIWP
_b5ku0fm.Font = Enum.Font.Gotham
_b5ku0fm.TextSize = 12
_b5ku0fm.Parent = _rP6zKMp
local function _zx6tzSn(_vtWubSB)
_rP6zKMp.Visible = _vtWubSB
end
local function _giEzNBJ()
if __Oz5eGS then _qLymOCh.Text = _syba7ZR(75,111,114,98,108,111,120,32,58,32,79,78) _qLymOCh.BackgroundColor3 = _dDp9kY2
else _qLymOCh.Text = _syba7ZR(75,111,114,98,108,111,120,32,58,32,79,70,70) _qLymOCh.BackgroundColor3 = _q_N_KXc end
if _xkX0vyO then _dR2R8jG.Text = _syba7ZR(72,101,97,100,108,101,115,115,32,58,32,79,78) _dR2R8jG.BackgroundColor3 = _dDp9kY2
else _dR2R8jG.Text = _syba7ZR(72,101,97,100,108,101,115,115,32,58,32,79,70,70) _dR2R8jG.BackgroundColor3 = _q_N_KXc end
end
_qLymOCh.MouseButton1Click:Connect(function()
__Oz5eGS = not __Oz5eGS
if __Oz5eGS then _kRS66MD() else for _, _gkRmgfk in ipairs(_o8I1q4d()) do pcall(_vbOmmgs, _gkRmgfk) end end
_giEzNBJ()
end)
_dR2R8jG.MouseButton1Click:Connect(function()
_xkX0vyO = not _xkX0vyO
if _xkX0vyO then _kRS66MD() else for _, _gkRmgfk in ipairs(_o8I1q4d()) do pcall(_gCV6ZKu, _gkRmgfk) end end
_giEzNBJ()
end)
_fpWoPcT.MouseButton1Click:Connect(function() _zx6tzSn(false) end)
_uDwyenw.InputBegan:Connect(function(_x7wVJZK, _tmZW9N7)
if _tmZW9N7 then return end
if _x7wVJZK.KeyCode == Enum.KeyCode.K then
_zx6tzSn(not _rP6zKMp.Visible)
end
end)
_giEzNBJ()
_kRS66MD()
task.spawn(function() while _ikoT1vz.Parent do task.wait(1.5) if __Oz5eGS or _xkX0vyO then pcall(_kRS66MD) end end end)
_uucbIMm.CharacterAdded:Connect(function() task.wait(1) pcall(_kRS66MD) end)
