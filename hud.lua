script_name("GTA San Andreas HUD for MoonLoader")
script_author("Developez (github.com/MirFlames)")
script_version('13.12.2020')
script_version_number(1)
script_description("Minimalistic interface for GTA San Andreas.")

require "lib.moonloader"
require "lib.sampfuncs"
local encoding = require 'encoding'
local inicfg = require 'inicfg'
local vkeys = require 'vkeys'
local sampev = require 'lib.samp.events'
local mem = require "memory"
local raknet = require 'lib.samp.raknet'
local font_flag = require('moonloader').font_flag
local sx, sy = getScreenResolution()
local shud = 1
local arial = renderCreateFont('Arial', 9)
local bold = renderCreateFont('BigNoodleTitlingCyr', 16)
local logo = renderCreateFont('BigNoodleTitlingCyr', 18, font_flag.BORDER)
local simple = renderCreateFont('Arial', 9, font_flag.BORDER)

local car = {
["speed"] = 0,
["fuel"] = "",
["health"] = "",
["engine"] = false,
["light"] = false,
["lock"] = false,
["sport"] = false
}

local weapons = {
	nil,
	"Brass knuckles",
	"Golf club",
	"Baton",
	"Huntsman Knife",
	"Bat",
	"Shovel",
	"Cue",
	"Katana",
	"Chainsaw",
	"Dildo",
	"Dildo",
	"Dildo",
	"Dildo",
	"Roses",
	"Cane",
	"HE",
	"Smoke",
	"Molotov",
	"","","",
	".45 ACP",
	".45 ACP Silencer",
	".50 AE",
	".410",
	"16 cal",
	".18,5",
	"Uzi .9x19",
	"MP5 .9x19",
	"AKM .7.62x39",
	"ACW-R .5.56x45",
	"Tec-Nine .9x19",
	"Scout .7,62?51",
	"Intervention SD .408",
	"RPG 40mm",
	"STINGER",
	"Flamethrower",
	"Minigun",
	"C4",
	"Detonator",
	"Spray paint can",
	"Fire extinguisher",
	"Canon EOS 5D Mark III",
	"NVS",
	"Visor",
	"A bag"
}
local messages = {
	"%[ Мысли %]: Теперь я не отображаюсь на карте. Нельзя привлекать внимание",
	"%[ Мысли %]: Нужно помнить о том, что так могут только Сектанты и Киллеры",
	"%{0088ff%}Вы изменили свой цвет на %{FFFFFF%}100."
}
local offcvet = false
local findet_id = -1
local takecontract = false

function sampGetDistanceLocalPlayerToPlayerByPlayerId(playerId)
	local playerId = tonumber(playerId, 10)
	if not playerId then return end
	local res, han = sampGetCharHandleBySampPlayerId(playerId)
	if res then
		local x, y, z = getCharCoordinates(playerPed)
		local xx, yy, zz = getCharCoordinates(han)
		return true, getDistanceBetweenCoords3d(x, y, z, xx, yy, zz)
	end
	return false
end

function sampev.onServerMessage(color, message)
	if string.find(message,messages[1]) then
		no_clist = true
		return false
	end
	if string.find(message,messages[2]) then
		return false
	end
	if string.find(message,messages[3]) then
		no_clist = false
		return false
	end
end

function sampev.onShowDialog(dialogId, style, title, button1, button2, text)
	if dialogId == 586 and offcvet then
			sampSendDialogResponse(586,1,0,-1)
		offcvet = false
		return false
	end
	if dialogId == 7763 and takecontract then
		sampSendDialogResponse(7763,0,0)
		takecontract = false
		--return false
	end
end

function sampev.onPlaySound(id)
	if id == tonumber('40405') and ( sampGetCurrentDialogId() == 586 or sampGetCurrentDialogId() == 8999 ) then return false end
end

function KeyCheck()
	while true do
		wait(0)
		if isKeyDown(88) and isKeyDown(90) and not sampIsChatInputActive() then
			if no_clist == true then sampSendChat('/cvet 100') wait(1000)
			else
				if sampGetCurrentDialogId() == 586 then sampSendDialogResponse(586,1,0,-1)
				else
				 	sampSendChat('/hmenu') offcvet = true end
				wait(1000)
			end
		end
		if isKeyDown(88) and isKeyDown(87) and not sampIsChatInputActive() then
			sampSendChat('/find '..findet_id)
			wait(500)
		end
		if isKeyDown(88) and isKeyDown(90) and not sampIsChatInputActive() then
			if not nicks_on then
				nicks_on = true;
				local pStSet = sampGetServerSettingsPtr()
				mem.setint8(pStSet + 56, 0)
			else
				nicks_on = false;
				local pStSet = sampGetServerSettingsPtr()
				NTshow = mem.getint8(pStSet + 56)
				mem.setint8(pStSet + 56, 1)
			end
			wait(500)
		end
	end
end

function setpoint(p)
if type(p) == "number" then
abs = tostring(p)
rabs = abs:reverse()
i = {}
for s in rabs:gmatch(".") do
table.insert(i, s)
end
for k, v in pairs(i) do
if math.fmod(k, 4) == 0 then
table.insert(i, k, ".")
end
end
str = ""
for k, v in pairs(i) do
str = str..v
end
return str:reverse()
elseif type(p) == "string" then
abs = p
rabs = abs:reverse()
i = {}
for s in rabs:gmatch(".") do
table.insert(i, s)
end
for k, v in pairs(i) do
if math.fmod(k, 4) == 0 then
table.insert(i, k, ".")
end
end
str = ""
for k, v in pairs(i) do
str = str..v
end
return str:reverse()
else
return 0
end
end

function sampev.onShowTextDraw(id, data)
	if sampGetCurrentServerAddress(PLAYER_PED) == "176.32.37.62" and shud == 1 then
		if id == 2258 then car.speed = string.sub(tostring(data["text"]),tostring(data["text"]):find("%d+")) return false end -- Скорость
		if id == 2263 then car.fuel = string.sub(tostring(data["text"]),tostring(data["text"]):find("%d+")) return false end -- Бенз
		if id == 2262 then car.health = string.sub(tostring(data["text"]),tostring(data["text"]):find("%d+")) return false end -- ХП
		if id == 2264 then if data["boxColor"] == -1207232 then car.engine = true else car.engine = false return false end end -- ДВИГ
		if id == 2265 then if data["boxColor"] == -1207232 then car.light = true else car.light = false return false end end -- ФАРЫ
		if id == 2266 then if data["boxColor"] == -1207232 then car.lock = true else car.lock = false return false end end -- ЛОК
		if id == 2267 then if data["boxColor"] == -1207232 then car.sport = true else car.sport = false return false end end -- СПОРТ
		if id >= 2255 and id <= 2272 then return false end
	end
end

function main()
	if not isSampLoaded() or not isSampfuncsLoaded() then return end
	while not isSampAvailable() do wait(100) end
	----------
	sampAddChatMessage("[ Мысли ]: /shud, /gfd id (исп: X+W), невидимка (X+Z)",-1)
	if shud > 0 then displayHud(false) end
	sampRegisterChatCommand('shud', function(n)
		n = tonumber(n)
		if n == nil then return sampAddChatMessage("Введите значение от 0 до 2, 0 - стандартный худ, 1 - стандартный минималистичный, 2 - выкл худ.", -1) end
		if n >= 0 and n <= 3 then
			if n == 0 then displayHud(true) end
			if n >= 1 then displayHud(false) end
			shud = n
			print(shud)
		end
	end)
	sampRegisterChatCommand('gfd', function(id)
		findet_id = id
		if tonumber(id) == -1 then findet_id = nil end
	end)

	lua_thread.create(KeyCheck)
	while true do
		if tonumber(mem.getint8(0xBA6769)) == 1 then
			if shud == 1 then
				if getCharHealth(playerPed) > 160 then health = 160 else health = getCharHealth(playerPed) end
				renderDrawBox(sx-359, sy-48, 357, 30, 0xAA000000)
				--renderDrawBox(sx-359, sy-48, 357, 35, 0xAA000000)
				-------------------------------------------------
				--renderDrawBox(sx-359, sy-15, 357, 5, 0xFF2d2d2d)
				--renderDrawBox(sx-2-math.ceil(357/100*health), sy-15, math.ceil(357/100*health), 5, 0xFFce7c7c)
				-------------------------------------------------
				if getCharArmour(playerPed) ~= 0 then
					renderDrawBox(sx-359, sy-21, 357, 5, 0xFF2d2d2d)
					renderDrawBox(sx-2-math.ceil(357/100*getCharArmour(playerPed)), sy-21, math.ceil(357/100*getCharArmour(playerPed)), 5, 0xFFc7d3e2)
					renderDrawBox(sx-359, sy-15, 357, 5, 0xFF2d2d2d)
					renderDrawBox(sx-2-math.ceil(357/160*health), sy-15, math.ceil(357/160*health), 5, 0xFFce7c7c)
				else
					renderDrawBox(sx-359, sy-21, 357, 5, 0xFF2d2d2d)
					renderDrawBox(sx-2-math.ceil(357/160*health), sy-21, math.ceil(357/160*health), 5, 0xFFce7c7c)
				end
				-------------------------------------------------
				renderDrawLine(sx-359, sy-49, sx-2, sy-49, 1, 0xFFFFFFFF)
				-------------------------------------------------
				if weapons[getCurrentCharWeapon(playerPed)+1] ~= nil then
					renderFontDrawText(bold, setpoint(getPlayerMoney(localPlayer)).."$", sx-357, sy-46, 0xFFFFFFFF)
					weaponline = weapons[getCurrentCharWeapon(playerPed)+1].." ("..getAmmoInClip().."/"..getAmmoInCharWeapon(playerPed, getCurrentCharWeapon(playerPed)) - getAmmoInClip()..")"
					if getCurrentCharWeapon(playerPed) < 17 then weaponline = weapons[getCurrentCharWeapon(playerPed)+1] end
					renderFontDrawText(bold, weaponline, sx-4-renderGetFontDrawTextLength(bold, weaponline), sy-46, 0xFFFFFFFF)
				else
					if isCharInAnyCar(PLAYER_PED) and PLAYER_PED == getDriverOfCar(storeCarCharIsInNoSave(playerPed)) then
						renderFontDrawText(bold, setpoint(getPlayerMoney(localPlayer)).."$", sx-357, sy-46, 0xFFFFFFFF)
					else renderFontDrawText(bold, setpoint(getPlayerMoney(localPlayer)).."$", sx-357+178-renderGetFontDrawTextLength(bold, setpoint(getPlayerMoney(localPlayer)))/2, sy-46, 0xFFFFFFFF) end
				end
				if no_clist then renderFontDrawText(bold, "Invisibility", sx-357, sy-46-renderGetFontDrawHeight(bold)-4, 0xAAFFFFFF) end
				if findet_id ~= -1 then
					renderFontDrawText(bold, "ПОИСК: "..findet_id.." ID", sx-4-renderGetFontDrawTextLength(bold, "ПОИСК: "..findet_id.." ID"), sy-46-renderGetFontDrawHeight(bold)-4, 0xAAFFFFFF)
				end
				--
				if isCharInAnyCar(PLAYER_PED) and PLAYER_PED == getDriverOfCar(storeCarCharIsInNoSave(playerPed)) then
					if car.sport then
						renderFontDrawText(bold, "S", sx-4-6-renderGetFontDrawTextLength(bold, "E"), sy-46, 0xFFce7c7c)
					else
						renderFontDrawText(bold, "S", sx-4-6-renderGetFontDrawTextLength(bold, "E"), sy-46, 0xFFFFFFFF)
						--renderFontDrawText(bold, "двиг ВКЛ", sx-4-2*renderGetFontDrawTextLength(bold, "ПОИСК: "..findet_id.." ID"), sy-46-8*renderGetFontDrawHeight(bold)-4, 0xAAFFFFFF)
					end
					if car.lock then
						renderFontDrawText(bold, "C", sx-4-2*6-2*renderGetFontDrawTextLength(bold, "E"), sy-46, 0xFFce7c7c)
					else
						renderFontDrawText(bold, "C", sx-4-2*6-2*renderGetFontDrawTextLength(bold, "E"), sy-46, 0xFFFFFFFF)
					end
					if car.light then
						renderFontDrawText(bold, "L", sx-4-3*6-3*renderGetFontDrawTextLength(bold, "E"), sy-46, 0xFFce7c7c)
					else
						renderFontDrawText(bold, "L", sx-4-3*6-3*renderGetFontDrawTextLength(bold, "E"), sy-46, 0xFFFFFFFF)
					end
					if car.engine then
						renderFontDrawText(bold, "E", sx-4-4*6-4*renderGetFontDrawTextLength(bold, "E"), sy-46, 0xFFce7c7c)
					else
						renderFontDrawText(bold, "E", sx-4-4*6-4*renderGetFontDrawTextLength(bold, "E"), sy-46, 0xFFFFFFFF)
					end
					--------------
					renderFontDrawText(bold, "—", sx-78, sy-46, 0xAAFFFFFF)
					renderFontDrawText(bold, "—", sx-345+renderGetFontDrawTextLength(bold, setpoint(getPlayerMoney(localPlayer)).."$"), sy-46, 0xAAFFFFFF)
					--------------
					renderFontDrawText(bold, car.speed.." km/h", sx-345+renderGetFontDrawTextLength(bold, setpoint(getPlayerMoney(localPlayer)).."$")+20, sy-46, 0xFFFFFFFF)
					renderFontDrawText(bold, car.fuel.." L", sx-89-renderGetFontDrawTextLength(bold, car.fuel.." l"), sy-46, 0xFFFFFFFF)
					renderFontDrawText(bold,car.health.." HP", sx-345+renderGetFontDrawTextLength(bold, setpoint(getPlayerMoney(localPlayer)).."$")+20 + renderGetFontDrawTextLength(bold,car.speed.." mh/h")+((sx-89-renderGetFontDrawTextLength(bold, car.fuel.." l")) - (sx-345+renderGetFontDrawTextLength(bold, setpoint(getPlayerMoney(localPlayer)).."$")+20+ renderGetFontDrawTextLength(bold,car.speed.." mh/h")))/2 - renderGetFontDrawTextLength(bold, car.health.." HP")/2, sy-46, 0xFFFFFFFF)
				end
			end
		end
		wait(0)
	end
	wait(0)
end

function getAmmoInClip()
	local weapon = getCurrentCharWeapon(playerPed)
	local struct = getCharPointer(playerPed) + 0x5A0 + getWeapontypeSlot(weapon) * 0x1C
	return getStructElement(struct, 0x8, 4)
end

function sampGetPlayerIdByNickname(nick)
	if type(nick) == "string" then
        for id = 0, 1000 do
            local _, myid = sampGetPlayerIdByCharHandle(PLAYER_PED)
            if sampIsPlayerConnected(id) or id == myid then
                local name = sampGetPlayerNickname(id)
                if nick == name then
                    return id
                end
            end
        end
    end
end
