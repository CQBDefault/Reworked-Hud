
local hideHUDElements = {
	-- if you DarkRP_HUD this to true, ALL of DarkRP's HUD will be disabled. That is the health bar and stuff,
	-- but also the agenda, the voice chat icons, lockdown text, player arrested text and the names above players' heads
	["DarkRP_HUD"] = false,

	-- DarkRP_EntityDisplay is the text that is drawn above a player when you look at them.
	-- This also draws the information on doors and vehicles
	["DarkRP_EntityDisplay"] = true,

	-- DarkRP_ZombieInfo draws information about zombies for admins who use /showzombie.
	["DarkRP_ZombieInfo"] = false,

	-- This is the one you're most likely to replace first
	-- DarkRP_LocalPlayerHUD is the default HUD you see on the bottom left of the screen
	-- It shows your health, job, salary and wallet
	["DarkRP_LocalPlayerHUD"] = true,
	["DarkRP_Hungermod"] = true,

	["DarkRP_Agenda"] = false,
	["CHudAmmo"] = true,
}

local scale = ScrW() >= 2560 and 2 or 1

local shadow_x = 1*scale -- I left 1 to make it noticeble
local shadow_y = 1*scale

local col_face = Color(255,255,255,255)
local col_shadow = Color(0,0,0,255)
local col_half_shadow = Color(0,0,0,200)
local col_money = Color(0,228,0)

-- this is the code that actually disables the drawing.
hook.Add("HUDShouldDraw", "HideDefaultDarkRPHud", function(name)
	if hideHUDElements[name] then return false end
end)

surface.CreateFont("abs_hud_time", {
	size = 35 * scale,
	weight = 350 * scale,
	antialias = true,
	font = "Roboto"
})

surface.CreateFont("abs_hud_time_shadow", {
	size = 35 * scale,
	weight = 350 * scale,
	antialias = true,
	blursize = 3 * scale,
	font = "Roboto"
})

surface.CreateFont("abs_hud_ammo", {
	size = 42 * scale,
	weight = 350 * scale,
	antialias = true,
	font = "Roboto"
})

surface.CreateFont("abs_hud_ammo_shadow", {
	size = 42 * scale,
	weight = 350 * scale,
	antialias = true,
	blursize = 3 * scale,
	font = "Roboto"
})

surface.CreateFont("abs_hud", {
	size = 22 * scale,
	weight = 350 * scale,
	antialias = true,
	font = "Tahoma"
})

surface.CreateFont("abs_hud_shadow", {
	size = 22 * scale,
	weight = 350 * scale,
	antialias = true,
	blursize = 3 * scale,
	font = "Tahoma"
})

local ALIGN_LEFT = 0
local ALIGN_CENTER = 0.5
local ALIGN_RIGHT = 1
local ALIGN_TOP = 1
local ALIGN_BOTTOM = 0


local function SimpleText(str, font, ...)
	draw.SimpleText(str, font, ...)
	return surface.GetTextSize(str)
end

local function BeautyText( str, font, font_shadow, x, y, color, xalign, yalign )
	font = font or "abs_hud"
	surface.SetFont( font )
	local tw, th = surface.GetTextSize( str )
	x = (x or 0) - tw * (xalign or 0)
	y = (y or 0) - th * (yalign or 0)
	surface.SetTextPos( x, y )

	if font_shadow then
		surface.SetTextPos( x, y+3 )
		surface.SetTextColor( col_shadow )
		surface.SetFont( font_shadow )
		surface.DrawText( str )
		surface.SetTextPos( x, y )
	end

	surface.SetTextPos( x + shadow_x , y + shadow_y )
	surface.SetTextColor( col_half_shadow )
	surface.SetFont( font )
	surface.DrawText( str )
	surface.SetTextColor( color or col_face )
	surface.SetTextPos( x, y )
	surface.DrawText( str )

	return tw,th
end

local function HealthBar(num, max, w, color, x, y)
	local h = 22 * scale

	local o = BeautyText(num .. "%", "abs_hud", "abs_hud_shadow", x, y, color, ALIGN_LEFT, ALIGN_TOP) + 4 * scale
	x = x + o

	surface.SetDrawColor(ColorAlpha(color, 64))
	surface.DrawRect(x, y - h + h/4, w * scale, h/2)

	surface.SetDrawColor(color)
	surface.DrawRect(x, y - h + h/4, w * math.max(0, math.min(1, num/max)) * scale, h/2)

	return o + w * scale, h
end

local function ArmourBar(num, max, w, color, x, y)
	local h = 22 * scale

	local o = BeautyText(num .. "%", "abs_hud", "abs_hud_shadow", x, y, color, ALIGN_LEFT, ALIGN_TOP) + 4 * scale
	x = x + o

	surface.SetDrawColor(ColorAlpha(Color(0, 140, 200), 64))
	surface.DrawRect(x, y - h + h/4, w * scale, h/2)

	surface.SetDrawColor(Color(0, 140, 200))
	surface.DrawRect(x, y - h + h/4, w * math.max(0, math.min(1, num/max)) * scale, h/2)

	return o + w * scale, h
end

local function HungerBar(num, max, w, color, x, y)
	local h = 22 * scale

	local o = BeautyText(num .. "%", "abs_hud", "abs_hud_shadow", x, y, color, ALIGN_LEFT, ALIGN_TOP) + 4 * scale
	x = x + o

	surface.SetDrawColor(ColorAlpha(Color(220, 200, 0), 64))
	surface.DrawRect(x, y - h + h/4, w * scale, h/2)

	surface.SetDrawColor(Color (220, 200, 0))
	surface.DrawRect(x, y - h + h/4, w * math.max(0, math.min(1, num/max)) * scale, h/2)

	return o + w * scale, h
end

local x, y, i_am_the_greatest, seen_anything = 0, 0, 0

local function yield(w, h)
	x = x + w
	i_am_the_greatest = math.max(i_am_the_greatest, h)
	seen_anything = true
end

local function space()
	x = x + 8 * scale
end

local hud = {}
local function Row(...)
	table.insert(hud, {...})
end



local hunger_alpha = 0

Row (




	function()
		yield(BeautyText("Здоровье: ", "abs_hud", "abs_hud_shadow", x, y, color_white, ALIGN_LEFT, ALIGN_TOP))


		yield(WideBar(LocalPlayer():Health(), LocalPlayer():GetMaxHealth(), 100, HSVToColor(math.Clamp(LocalPlayer():Health(), 0, LocalPlayer():GetMaxHealth()) / LocalPlayer():GetMaxHealth() * 120, 1, 1), x, y))
	end,
	
	function()
		if LocalPlayer():Armor() > 0 then
			yield(BeautyText("Броня: ", "abs_hud", "abs_hud_shadow", x, y, color_white, ALIGN_LEFT, ALIGN_TOP))
			
			yield(ArmBar(LocalPlayer():Armor(), 100, 100, HSVToColor(math.Clamp(LocalPlayer():Armor(), 100, 100) * 1.2, 1, 1), x, y))
		end	
	end,
	
	function()
		local energy = LocalPlayer():getDarkRPVar("Energy") or 0
		if energy > 0 then
			yield(BeautyText("Голод: ", "abs_hud", "abs_hud_shadow", x, y, color_white, ALIGN_LEFT, ALIGN_TOP))
			yield(HunBar((0 + energy), 100, 100, HSVToColor(math.Clamp(LocalPlayer():getDarkRPVar("Energy"), 0, 100) * 1.2, 1, 1), x, y))
		else
			yield(BeautyText("ГОЛОДАНИЕ", "abs_hud", "abs_hud_shadow", x, y, RealTime()%0.3 < 0.15 and Color(255, 0, 0) or color_black, ALIGN_LEFT, ALIGN_TOP))
		end
	end
		or nil
)

local money_last = 0
local money_alpha = 0
local money_alpha_positive = true

local color_blend = Color(64, 128, 64)

local function getmoney()
	if LocalPlayer():GetNWBool("fun_money111") then
		return 0
	else
		return LocalPlayer():getDarkRPVar("money", 0)
	end
end
Row (
	function()
		yield(BeautyText(LocalPlayer():getDarkRPVar("job") or "", "abs_hud", "abs_hud_shadow", x, y, team.GetColor(LocalPlayer():Team()), ALIGN_LEFT, ALIGN_TOP))

		space()

		if money_last ~= getmoney() then
				color_blend.r = 0
				color_blend.g = 150
				color_blend.b = 215
			money_last = getmoney()
		end

		local dt = FrameTime() * 0.5
		color_blend.r = Lerp(dt, color_blend.r, 0)
		color_blend.g = Lerp(dt, color_blend.g, 228)
		color_blend.b = Lerp(dt, color_blend.b, 60)

		yield(BeautyText(DarkRP.formatMoney(getmoney()), "abs_hud", "abs_hud_shadow", x, y, color_blend, ALIGN_LEFT, ALIGN_TOP))
	end
)

Row ( -- Wanted
	function()
		if LocalPlayer():getDarkRPVar("wanted") then
			local sin = math.sin(RealTime() * 8)
			local flash = HSVToColor(sin > 0 and 0 or 240, math.abs(sin), 1)

			yield(BeautyText("В розыске: " .. LocalPlayer():getDarkRPVar("wantedReason"), "abs_hud", "abs_hud_shadow", x, y - 20, flash, ALIGN_LEFT, ALIGN_TOP))
		end
	end
)

Row ( -- Arrested
	function()
		if LocalPlayer():isArrested() then			yield(BeautyText("В тюрьме.", "abs_hud", "abs_hud_shadow", x, y, color_white, ALIGN_LEFT, ALIGN_TOP))
		end
	end
)


Row ( -- License
 function()
  if LocalPlayer():getDarkRPVar("HasGunlicense") then -- cps supposed to have license amirite?? write a workaround
   yield(BeautyText("Имеется лицензия", "abs_hud", "abs_hud_shadow", x, y, color_white, ALIGHN_LEFT, ALIGN_TOP))
  end
 end
)

Row ( -- Lockdown
	function()
		if GetGlobalBool("LockDown1") then
			local cin = (math.sin(CurTime()) + 1) / 2
			yield(BeautyText("Мэр объявил комендантский час", "abs_hud", "abs_hud_shadow", x, y, Color(cin * 255, 0, 255 - (cin * 255)), 0, ALIGN_TOP))
		end
	end
)

hook.Add("HUDPaint", "DarkRP_Mod_HUDPaint", function()
	if hook.Run("HUDShouldDraw", "Noiwex HUD") == false then
		return
	end

	local offy, offx, space_width = ScrH() - 8, 8, 8

	x, y = offx, offy

	for _, row in pairs(hud) do
		for _, fn in pairs(row) do
			seen_anything = false
			xpcall(fn, Error)
			if seen_anything then
				space()
			end
		end
		offy = offy - i_am_the_greatest
		i_am_the_greatest = 0
		y = offy
		x = offx
	end
end)

local insuff_ammo1, insuff_ammo2 = 1, 1
hook.Add("HUDPaint", "DarkRP_Mod_HUDPaint_Ammo", function()
	if hook.Run("HUDShouldDraw", "Noiwex HUD Ammo") == false then
		return
	end

	local wep = LocalPlayer():GetActiveWeapon()

	if not IsValid(wep) or wep:GetPrimaryAmmoType() < 0 then
		return
	end

	local ammo1 = wep:Clip1()
	local ammo2 = LocalPlayer():GetAmmoCount(wep:GetPrimaryAmmoType())

	if ammo1 < 0 then
		ammo1 = nil
	end

	local offy, offx, space_width = ScrH() - 8, ScrW() - 256 - 24, 8

	if ammo1 == 0 then
		insuff_ammo1 = math.max(insuff_ammo1 - FrameTime(), 0)
	else
		insuff_ammo1 = math.min(insuff_ammo1 + FrameTime(), 1)
	end

	if ammo2 == 0 then
		insuff_ammo2 = math.max(insuff_ammo2 - FrameTime(), 0)
	else
		insuff_ammo2 = math.min(insuff_ammo2 + FrameTime(), 1)
	end

	offx = offx - BeautyText((ammo1 and " / " or  "") .. ammo2, "abs_hud_ammo", "abs_hud_ammo_shadow", offx, offy, Color(255, insuff_ammo2 * 255, insuff_ammo2 * 255), ALIGN_RIGHT, ALIGN_TOP)
	offx = offx - BeautyText(ammo1 or "", "abs_hud_time", "abs_hud_time_shadow", offx, offy - 3, Color(255, insuff_ammo1 * 255, insuff_ammo1 * 255), ALIGN_RIGHT, ALIGN_TOP)
end)

usermessage.Hook("AteFoodIcon", function()
	hunger_alpha = RealTime()
end)

--[[---------------------------------------------------------------------------
Remove some elements from the HUD in favour of the DarkRP HUD
---------------------------------------------------------------------------]]
function GM:HUDShouldDraw(name)
    if name == "CHudHealth" or
        name == "CHudBattery" or
        name == "CHudSuitPower" or
        (HelpToggled and name == "CHudChat") then
            return false
    else
        return self.Sandbox.HUDShouldDraw(self, name)
    end
end

--[[---------------------------------------------------------------------------
Disable players' names popping up when looking at them
---------------------------------------------------------------------------]]
function GM:HUDDrawTargetID()
    return false
end
