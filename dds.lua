local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local TweenService = game:GetService("TweenService")
local UserInputService = game:GetService("UserInputService")
local VirtualInputManager = game:GetService("VirtualInputManager")

local placeIdResmi = 131378148336503
if game.PlaceId ~= placeIdResmi then
    return warn("Lu Main Game Apa Kocak!! Ini Script Drag Drive Simulator. PlaceID Terdeteksi : " .. tostring(game.PlaceId))
end

local localPlayer = Players.LocalPlayer

local faktorKecepatan = 0.28 * 3.6 * 0.928
local limitMinimal = 5
local limitMaksimal = 600
local limitKmh = 0
local limiterAktif = false
local autoJumpAktif = false
local tahanTombolT = true

local tombolTSedangDitekan = false
local sudahTekanDiKursi = false
local maxSpeedAsli = setmetatable({}, {__mode = "k"})

local skalaUI = 0.72

local warna = {
    utama = Color3.fromRGB(24, 25, 28),
    kartu = Color3.fromRGB(35, 38, 43),
    garis = Color3.fromRGB(50, 53, 58),
    putih = Color3.fromRGB(245, 245, 250),
    abu = Color3.fromRGB(150, 155, 165),
    aksen = Color3.fromRGB(70, 140, 255),
    merah = Color3.fromRGB(255, 65, 65),
    hijau = Color3.fromRGB(40, 200, 100)
}

local urlIkon = {
    logo = "3758662256",
    floating = "3758662256"
}

local function animasi(objek, waktu, properti)
    TweenService:Create(objek, TweenInfo.new(waktu, Enum.EasingStyle.Sine, Enum.EasingDirection.Out), properti):Play()
end

local function buat(class, props, parent)
    local o = Instance.new(class)
    for k, v in pairs(props) do o[k] = v end
    if parent then o.Parent = parent end
    return o
end

local function bulatkan(objek, radius)
    return buat("UICorner", { CornerRadius = radius or UDim.new(0, 10) }, objek)
end

local function garisTepi(objek, warnanya)
    return buat("UIStroke", {
        Color = warnanya or warna.garis,
        Thickness = 1,
        ApplyStrokeMode = Enum.ApplyStrokeMode.Border
    }, objek)
end

local function pasangIkonImage(parent, idImage, warnaIkon)
    local idAngka = string.match(tostring(idImage), "%d+") or "0"
    local finalUrl = "rbxthumb://type=Asset&id=" .. idAngka .. "&w=150&h=150"
    return buat("ImageLabel", {
        Size = UDim2.new(0.6, 0, 0.6, 0),
        Position = UDim2.new(0.5, 0, 0.5, 0),
        AnchorPoint = Vector2.new(0.5, 0.5),
        BackgroundTransparency = 1,
        Image = finalUrl,
        ImageColor3 = warnaIkon or warna.putih,
        ScaleType = Enum.ScaleType.Fit,
        ZIndex = 5
    }, parent)
end

local function buatIkonTeks(parent, tipe, warnaIkon)
    local holder = buat("Frame", {
        Size = UDim2.new(1, 0, 1, 0),
        BackgroundTransparency = 1,
        ZIndex = 5
    }, parent)

    local function garis(size, pos, rot)
        local l = buat("Frame", {
            Size = size,
            Position = pos,
            AnchorPoint = Vector2.new(0.5, 0.5),
            Rotation = rot,
            BackgroundColor3 = warnaIkon,
            BorderSizePixel = 0,
        }, holder)
        bulatkan(l, UDim.new(1, 0))
    end

    if tipe == "silang" then
        for _, rot in ipairs({45, -45}) do
            garis(UDim2.new(0.5, 0, 0, 2), UDim2.new(0.5, 0, 0.5, 0), rot)
        end
    elseif tipe == "minus" then
        garis(UDim2.new(0.5, 0, 0, 2), UDim2.new(0.5, 0, 0.5, 0), 0)
    elseif tipe == "plus" then
        for _, rot in ipairs({0, 90}) do
            garis(UDim2.new(0.5, 0, 0, 2), UDim2.new(0.5, 0, 0.5, 0), rot)
        end
    elseif tipe == "cek" then
        garis(UDim2.new(0, 2, 0.25, 0), UDim2.new(0.38, 0, 0.55, 0), -45)
        garis(UDim2.new(0, 2, 0.45, 0), UDim2.new(0.58, 0, 0.45, 0), 45)
    end
    return holder
end

local uiLama = localPlayer:WaitForChild("PlayerGui"):FindFirstChild("RoundedMinimalistUI")
if uiLama then uiLama:Destroy() end

local gui = buat("ScreenGui", {
    Name = "RoundedMinimalistUI",
    ResetOnSpawn = false,
    ZIndexBehavior = Enum.ZIndexBehavior.Sibling,
    IgnoreGuiInset = true,
}, localPlayer:WaitForChild("PlayerGui"))

local notifWadah = buat("Frame", {
    Size = UDim2.new(1, 0, 0, 100),
    Position = UDim2.new(0, 0, 0, 20),
    BackgroundTransparency = 1,
    ZIndex = 100,
}, gui)

local function buatNotifikasi(pesan, tipeWarna)
    local notif = buat("Frame", {
        Size = UDim2.new(0, 280, 0, 36),
        Position = UDim2.new(0.5, 0, 0, -50),
        AnchorPoint = Vector2.new(0.5, 0),
        BackgroundColor3 = warna.kartu,
        ZIndex = 101,
    }, notifWadah)
    bulatkan(notif, UDim.new(0, 8))
    garisTepi(notif, tipeWarna or warna.aksen)

    buat("TextLabel", {
        Size = UDim2.new(1, 0, 1, 0),
        BackgroundTransparency = 1,
        Text = pesan,
        TextColor3 = warna.putih,
        Font = Enum.Font.GothamMedium,
        TextSize = 12,
        ZIndex = 102,
    }, notif)

    animasi(notif, 0.4, {Position = UDim2.new(0.5, 0, 0, 10)})

    task.delay(2.2, function()
        animasi(notif, 0.4, {Position = UDim2.new(0.5, 0, 0, -50), BackgroundTransparency = 1})
        task.wait(0.4)
        notif:Destroy()
    end)
end

local tombolMengambang = buat("TextButton", {
    Size = UDim2.new(0, 52, 0, 52),
    Position = UDim2.new(1, -24, 0.5, -80),
    AnchorPoint = Vector2.new(1, 0),
    BackgroundColor3 = warna.utama,
    Text = "",
    AutoButtonColor = false,
    Active = true,
    ZIndex = 1
}, gui)
bulatkan(tombolMengambang, UDim.new(1, 0))
garisTepi(tombolMengambang, warna.garis)
pasangIkonImage(tombolMengambang, urlIkon.floating, warna.putih)

local panelHolder = buat("Frame", {
    Size = UDim2.new(0, 300, 0, 378),
    Position = UDim2.new(0.5, 0, 0.5, 0),
    AnchorPoint = Vector2.new(0.5, 0.5),
    BackgroundTransparency = 1,
    Visible = false,
    Active = true,
}, gui)
buat("UIScale", { Scale = skalaUI }, panelHolder)

local panel = buat("Frame", {
    Size = UDim2.new(1, 0, 1, 0),
    BackgroundColor3 = warna.utama,
    BorderSizePixel = 0,
}, panelHolder)
bulatkan(panel, UDim.new(0, 16))
garisTepi(panel, warna.garis)

local kepala = buat("Frame", {
    Size = UDim2.new(1, 0, 0, 46),
    BackgroundTransparency = 1,
}, panel)

local ikonLogo = buat("Frame", {
    Size = UDim2.new(0, 22, 0, 22),
    Position = UDim2.new(0, 14, 0.5, 0),
    AnchorPoint = Vector2.new(0, 0.5),
    BackgroundTransparency = 1,
}, kepala)
pasangIkonImage(ikonLogo, urlIkon.logo, warna.putih)

buat("TextLabel", {
    Size = UDim2.new(0, 160, 0, 46),
    Position = UDim2.new(0, 44, 0, 0),
    BackgroundTransparency = 1,
    Text = "Drag Drive Simulator",
    TextColor3 = warna.putih,
    Font = Enum.Font.GothamBold,
    TextSize = 12,
    TextXAlignment = Enum.TextXAlignment.Left,
}, kepala)

local tombolMinimize = buat("TextButton", {
    Size = UDim2.new(0, 30, 0, 30),
    Position = UDim2.new(1, -52, 0.5, 0),
    AnchorPoint = Vector2.new(1, 0.5),
    BackgroundColor3 = warna.kartu,
    Text = "",
    AutoButtonColor = false,
    ZIndex = 1
}, kepala)
bulatkan(tombolMinimize, UDim.new(0, 6))
garisTepi(tombolMinimize, warna.garis)
buatIkonTeks(tombolMinimize, "minus", warna.putih)

local tombolKeluar = buat("TextButton", {
    Size = UDim2.new(0, 30, 0, 30),
    Position = UDim2.new(1, -14, 0.5, 0),
    AnchorPoint = Vector2.new(1, 0.5),
    BackgroundColor3 = warna.kartu,
    Text = "",
    AutoButtonColor = false,
    ZIndex = 1
}, kepala)
bulatkan(tombolKeluar, UDim.new(0, 6))
garisTepi(tombolKeluar, warna.garis)
buatIkonTeks(tombolKeluar, "silang", warna.merah)

buat("Frame", {
    Size = UDim2.new(1, 0, 0, 1),
    Position = UDim2.new(0, 0, 0, 46),
    BackgroundColor3 = warna.garis,
    BorderSizePixel = 0,
}, panel)

local kartuKecepatan = buat("Frame", {
    Size = UDim2.new(1, -28, 0, 85),
    Position = UDim2.new(0.5, 0, 0, 56),
    AnchorPoint = Vector2.new(0.5, 0),
    BackgroundColor3 = warna.kartu,
    BorderSizePixel = 0,
}, panel)
bulatkan(kartuKecepatan, UDim.new(0, 10))
garisTepi(kartuKecepatan, warna.garis)

local labelKecepatan = buat("TextLabel", {
    Size = UDim2.new(1, 0, 0, 45),
    Position = UDim2.new(0, 0, 0, 8),
    BackgroundTransparency = 1,
    Text = "0",
    TextColor3 = warna.putih,
    Font = Enum.Font.GothamMedium,
    TextSize = 38,
    TextXAlignment = Enum.TextXAlignment.Center,
}, kartuKecepatan)

local barLatar = buat("Frame", {
    Size = UDim2.new(1, -28, 0, 5),
    Position = UDim2.new(0.5, 0, 1, -14),
    AnchorPoint = Vector2.new(0.5, 0),
    BackgroundColor3 = warna.utama,
    BorderSizePixel = 0,
}, kartuKecepatan)
bulatkan(barLatar, UDim.new(1, 0))

local barIsi = buat("Frame", {
    Size = UDim2.new(0, 0, 1, 0),
    BackgroundColor3 = warna.aksen,
    BorderSizePixel = 0,
}, barLatar)
bulatkan(barIsi, UDim.new(1, 0))

local function buatSaklar(parent, pos, teks)
    local wadah = buat("Frame", {
        Size = UDim2.new(1, -28, 0, 50),
        Position = pos,
        AnchorPoint = Vector2.new(0.5, 0),
        BackgroundColor3 = warna.kartu,
        BorderSizePixel = 0,
    }, parent)
    bulatkan(wadah, UDim.new(0, 10))
    garisTepi(wadah, warna.garis)

    buat("TextLabel", {
        Size = UDim2.new(0, 150, 1, 0),
        Position = UDim2.new(0, 14, 0, 0),
        BackgroundTransparency = 1,
        Text = teks,
        TextColor3 = warna.putih,
        Font = Enum.Font.Gotham,
        TextSize = 12,
        TextXAlignment = Enum.TextXAlignment.Left,
    }, wadah)

    local tombol = buat("TextButton", {
        Size = UDim2.new(0, 48, 0, 26),
        Position = UDim2.new(1, -14, 0.5, 0),
        AnchorPoint = Vector2.new(1, 0.5),
        BackgroundColor3 = warna.utama,
        Text = "",
        AutoButtonColor = false,
    }, wadah)
    bulatkan(tombol, UDim.new(1, 0))
    garisTepi(tombol, warna.garis)

    local knop = buat("Frame", {
        Size = UDim2.new(0, 18, 0, 18),
        Position = UDim2.new(0, 4, 0.5, 0),
        AnchorPoint = Vector2.new(0, 0.5),
        BackgroundColor3 = warna.putih,
        BorderSizePixel = 0,
    }, tombol)
    bulatkan(knop, UDim.new(1, 0))

    return tombol, knop
end

local tombolLimiter, knopLimiter = buatSaklar(panel, UDim2.new(0.5, 0, 0, 153), "Limit Kecepatan")
local tombolJump, knopJump = buatSaklar(panel, UDim2.new(0.5, 0, 0, 211), "Auto Jumping")

local kartuBatas = buat("Frame", {
    Size = UDim2.new(1, -28, 0, 90),
    Position = UDim2.new(0.5, 0, 0, 269),
    AnchorPoint = Vector2.new(0.5, 0),
    BackgroundColor3 = warna.kartu,
    BorderSizePixel = 0,
}, panel)
bulatkan(kartuBatas, UDim.new(0, 10))
garisTepi(kartuBatas, warna.garis)

local nilaiBatas = buat("TextLabel", {
    Size = UDim2.new(1, 0, 0, 18),
    Position = UDim2.new(0.5, 0, 0, 12),
    AnchorPoint = Vector2.new(0.5, 0),
    BackgroundTransparency = 1,
    Text = "0 KM/H",
    TextColor3 = warna.putih,
    Font = Enum.Font.Gotham,
    TextSize = 11,
    TextXAlignment = Enum.TextXAlignment.Center,
}, kartuBatas)

local areaInput = buat("Frame", {
    Size = UDim2.new(1, -24, 0, 38),
    Position = UDim2.new(0.5, 0, 0, 36),
    AnchorPoint = Vector2.new(0.5, 0),
    BackgroundTransparency = 1,
}, kartuBatas)

local layoutInput = buat("UIListLayout", {
    FillDirection = Enum.FillDirection.Horizontal,
    HorizontalAlignment = Enum.HorizontalAlignment.Center,
    VerticalAlignment = Enum.VerticalAlignment.Center,
    SortOrder = Enum.SortOrder.LayoutOrder,
    Padding = UDim.new(0, 6),
}, areaInput)

local tombolKurang = buat("TextButton", {
    Size = UDim2.new(0, 38, 0, 38),
    BackgroundColor3 = warna.utama,
    Text = "",
    AutoButtonColor = false,
    ZIndex = 1,
    LayoutOrder = 1
}, areaInput)
bulatkan(tombolKurang, UDim.new(0, 8))
garisTepi(tombolKurang, warna.garis)
buatIkonTeks(tombolKurang, "minus", warna.putih)

local kotakIsi = buat("TextBox", {
    Size = UDim2.new(0, 92, 0, 38),
    BackgroundColor3 = warna.utama,
    Text = "",
    PlaceholderText = "KM/H",
    PlaceholderColor3 = warna.abu,
    TextColor3 = warna.putih,
    Font = Enum.Font.Gotham,
    TextSize = 12,
    ClearTextOnFocus = true,
    BorderSizePixel = 0,
    ZIndex = 1,
    LayoutOrder = 2
}, areaInput)
bulatkan(kotakIsi, UDim.new(0, 8))
garisTepi(kotakIsi, warna.garis)

local tombolSet = buat("TextButton", {
    Size = UDim2.new(0, 38, 0, 38),
    BackgroundColor3 = warna.utama,
    Text = "",
    AutoButtonColor = false,
    ZIndex = 1,
    LayoutOrder = 3
}, areaInput)
bulatkan(tombolSet, UDim.new(0, 8))
garisTepi(tombolSet, warna.garis)
buatIkonTeks(tombolSet, "cek", warna.aksen)

local tombolTambah = buat("TextButton", {
    Size = UDim2.new(0, 38, 0, 38),
    BackgroundColor3 = warna.utama,
    Text = "",
    AutoButtonColor = false,
    ZIndex = 1,
    LayoutOrder = 4
}, areaInput)
bulatkan(tombolTambah, UDim.new(0, 8))
garisTepi(tombolTambah, warna.garis)
buatIkonTeks(tombolTambah, "plus", warna.putih)

local function aturSpeed(speed)
    speed = math.clamp(math.floor(speed + 0.5), limitMinimal, limitMaksimal)
    limitKmh = speed
    nilaiBatas.Text = speed .. " KM/H"
end

local function ambilKursi()
    local char = localPlayer.Character
    local humanoid = char and char:FindFirstChildOfClass("Humanoid")
    local kursi = humanoid and humanoid.SeatPart
    if kursi and kursi:IsDescendantOf(workspace) then
        return kursi
    end
    return nil
end

local function perbaruiToggle()
    animasi(tombolLimiter, 0.2, { BackgroundColor3 = limiterAktif and warna.aksen or warna.utama })
    animasi(knopLimiter, 0.2, { 
        Position = limiterAktif and UDim2.new(1, -22, 0.5, 0) or UDim2.new(0, 4, 0.5, 0),
    })
    
    local pesan = limiterAktif and "Limit Kecepatan Diaktifkan" or "Limit Kecepatan Dinonaktifkan"
    local warnaNotif = limiterAktif and warna.hijau or warna.merah
    buatNotifikasi(pesan, warnaNotif)
end

local function perbaruiToggleJump()
    animasi(tombolJump, 0.2, { BackgroundColor3 = autoJumpAktif and warna.aksen or warna.utama })
    animasi(knopJump, 0.2, { 
        Position = autoJumpAktif and UDim2.new(1, -22, 0.5, 0) or UDim2.new(0, 4, 0.5, 0),
    })
    
    local pesan = autoJumpAktif and "Auto Jumping Diaktifkan" or "Auto Jumping Dinonaktifkan"
    local warnaNotif = autoJumpAktif and warna.hijau or warna.merah
    buatNotifikasi(pesan, warnaNotif)
end

local function tekanT()
    if tombolTSedangDitekan then return end
    tombolTSedangDitekan = true
    pcall(function() 
        VirtualInputManager:SendKeyEvent(true, Enum.KeyCode.T, false, game) 
    end)
end

local function lepasT()
    if not tombolTSedangDitekan then return end
    tombolTSedangDitekan = false
    pcall(function() 
        VirtualInputManager:SendKeyEvent(false, Enum.KeyCode.T, false, game) 
    end)
end

tombolLimiter.MouseButton1Click:Connect(function()
    limiterAktif = not limiterAktif
    perbaruiToggle()
end)

tombolJump.MouseButton1Click:Connect(function()
    local kursi = ambilKursi()
    if not autoJumpAktif and not kursi then
        buatNotifikasi("Naik Kendaraan Dulu Baru Bisa Diaktifkan!", warna.merah)
        return
    end

    autoJumpAktif = not autoJumpAktif
    perbaruiToggleJump()
    if not autoJumpAktif then
        lepasT()
        sudahTekanDiKursi = false
    end
end)

tombolKurang.MouseButton1Click:Connect(function() 
    aturSpeed(limitKmh - 5) 
    buatNotifikasi("Limit Diatur ke " .. limitKmh .. " KM/H", warna.aksen)
end)

tombolTambah.MouseButton1Click:Connect(function() 
    aturSpeed(limitKmh + 5) 
    buatNotifikasi("Limit Diatur ke " .. limitKmh .. " KM/H", warna.aksen)
end)

local function simpanIsi()
    local angka = tonumber(kotakIsi.Text)
    if angka then 
        aturSpeed(angka)
        buatNotifikasi("Limit Diatur ke " .. angka .. " KM/H", warna.aksen)
    end
    kotakIsi.Text = ""
end

tombolSet.MouseButton1Click:Connect(simpanIsi)
kotakIsi.FocusLost:Connect(function(enterDitekan) if enterDitekan then simpanIsi() end end)

local panelTerbuka = false
local function aturBuka(status)
    panelTerbuka = status
    if status then
        panelHolder.Visible = true
        tombolMengambang.Visible = false
    else
        panelHolder.Visible = false
        tombolMengambang.Visible = true
    end
end

tombolMinimize.MouseButton1Click:Connect(function() aturBuka(false) end)

local function bisaDigeser(pegangan, target, saatKlik)
    local sedangGeser, posisiAwal, targetAwal, bergerak = false, nil, nil, false
    pegangan.InputBegan:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
            sedangGeser, bergerak = true, false
            posisiAwal, targetAwal = input.Position, target.Position
            input.Changed:Connect(function()
                if input.UserInputState == Enum.UserInputState.End then
                    sedangGeser = false
                    if not bergerak and saatKlik then saatKlik() end
                end
            end)
        end
    end)
    UserInputService.InputChanged:Connect(function(input)
        if sedangGeser and (input.UserInputType == Enum.UserInputType.MouseMovement or input.UserInputType == Enum.UserInputType.Touch) then
            local delta = input.Position - posisiAwal
            if delta.Magnitude > 6 then bergerak = true end
            if bergerak then
                target.Position = UDim2.new(
                    targetAwal.X.Scale, targetAwal.X.Offset + delta.X,
                    targetAwal.Y.Scale, targetAwal.Y.Offset + delta.Y
                )
            end
        end
    end)
end

bisaDigeser(tombolMengambang, tombolMengambang, function() aturBuka(true) end)
bisaDigeser(kepala, panelHolder, nil)

local function batasiKecepatan(kursi)
    if not (limiterAktif and kursi) then return end
    local akar = kursi.AssemblyRootPart or kursi
    local v = akar.AssemblyLinearVelocity
    local datar = Vector3.new(v.X, 0, v.Z)
    local maks = limitKmh / faktorKecepatan
    if datar.Magnitude > maks then
        local b = datar.Unit * maks
        akar.AssemblyLinearVelocity = Vector3.new(b.X, v.Y, b.Z)
    end
end

local koneksiStep = RunService.Stepped:Connect(function()
    batasiKecepatan(ambilKursi())
end)

local loopKoneksi
loopKoneksi = RunService.Heartbeat:Connect(function()
    local kursi = ambilKursi()
    local sedangDuduk = (kursi ~= nil and kursi:IsA("VehicleSeat"))

    if autoJumpAktif then
        if sedangDuduk then
            if not sudahTekanDiKursi then
                sudahTekanDiKursi = true
            end
            tekanT()
        else
            if sudahTekanDiKursi then
                sudahTekanDiKursi = false
                lepasT()
            end
        end
    else
        if tombolTSedangDitekan then
            lepasT()
        end
    end

    if not kursi then
        labelKecepatan.Text = "0"
        barIsi.Size = UDim2.new(0, 0, 1, 0)
        return
    end

    local akar = kursi.AssemblyRootPart or kursi
    local kecepatan = akar.AssemblyLinearVelocity
    local datar = Vector3.new(kecepatan.X, 0, kecepatan.Z)
    local kmh = datar.Magnitude * faktorKecepatan
    local aktif = limiterAktif and limitKmh ~= nil

    if kursi:IsA("VehicleSeat") then
        if not maxSpeedAsli[kursi] then maxSpeedAsli[kursi] = kursi.MaxSpeed end
        if aktif then
            kursi.MaxSpeed = (limitKmh / faktorKecepatan)
        else
            kursi.MaxSpeed = maxSpeedAsli[kursi]
        end
    end

    if aktif and kmh > limitKmh and datar.Magnitude > 0 then
        local targetVelReal = limitKmh / faktorKecepatan
        local b = datar.Unit * targetVelReal
        akar.AssemblyLinearVelocity = Vector3.new(b.X, kecepatan.Y, b.Z)
        kmh = limitKmh
    end

    labelKecepatan.Text = tostring(math.floor(kmh + 0.5))
    local rasio = math.clamp(kmh / (limitKmh or 200), 0, 1)
    barIsi.Size = UDim2.new(rasio, 0, 1, 0)

    local warnaAktif = (aktif and kmh >= limitKmh - 1) and warna.merah or warna.putih
    labelKecepatan.TextColor3 = warnaAktif
    barIsi.BackgroundColor3 = warnaAktif
end)

tombolKeluar.MouseButton1Click:Connect(function()
    if koneksiLoop then koneksiLoop:Disconnect() end
    if koneksiStep then koneksiStep:Disconnect() end
    lepasT()
    gui:Destroy()
end)

aturSpeed(0)
