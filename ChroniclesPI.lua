function Round(num, dp)
    --[[
    round a number to so-many decimal of places, which can be negative, 
    e.g. -1 places rounds to 10's,  
    
    examples
        173.2562 rounded to 0 dps is 173.0
        173.2562 rounded to 2 dps is 173.26
        173.2562 rounded to -1 dps is 170.0
    ]]--
    local mult = 10^(dp or 0)
    return math.floor(num * mult + 0.5)/mult
end

local function print(text)
	DEFAULT_CHAT_FRAME:AddMessage("[PI] " .. text, 1, 0.3, 0.5)
end

local function formatname(name)
	return string.gsub(string.lower(name), "^%l", string.upper)
end

local buffed_frame = CreateFrame("GameTooltip", "CPI_GameTooltip", nil, "GameTooltipTemplate")
buffed_frame:SetOwner(WorldFrame, "ANCHOR_NONE")
buffed_frame:Hide()
local buffed_name = getglobal(buffed_frame:GetName().."TextLeft1")

local function buffed(searchBuff, unit)
	for i = 1, 32 do
		buffed_frame:SetOwner(UIParent, "ANCHOR_NONE")
		buffed_frame:SetUnitBuff(unit, i)
		if buffed_name:GetText() == searchBuff then
			return true
		end
	end
	return false
end

local buffsThatDontStack = {"Arcane Power"}

local function cast(name)

	if not name or name == "" then
		name = CPI_Name
	end

	if not name then
		print("Noone has requested Power Infusion.")
		return
	end

	name = formatname(name)

	local spellName = "Power Infusion"
	local spellID = nil
	for s = 1, 300 do
		n = GetSpellName(s, BOOKTYPE_SPELL)
		if not n then break end
		if (n == spellName) then
			spellID = s
			break
		end
	end

	if not spellID then
		print("Power Infusion spell not found.")
		return
	end

	local CDStart, CDDur = GetSpellCooldown(spellID, BOOKTYPE_SPELL)
	local CDRemain = (CDDur - (GetTime() - CDStart))
	if CDRemain > 0.25 then
		SendChatMessage("Cooldown Remaining: " .. Round(CDRemain, 2) .. " seconds." ,"WHISPER" ,nil ,name)
		-- Return the Cooldown Remaining rounded to two decimal points
		return
	end

	local retarget = false

	if UnitName("target") ~= name then
		retarget = true
		TargetByName(name, true)
	end

	if UnitName("target") == name then
		if not UnitIsDeadOrGhost("target") then
			local alreadyBuffed = false
			for _, testBuff in buffsThatDontStack do
				if buffed(testBuff, "target") then
					alreadyBuffed = true
				end
			end

			if alreadyBuffed then
				SendChatMessage("ANOTHER EMPOWERMENT IS ALREADY UP!" ,"WHISPER" ,nil ,name)
			else
				SendChatMessage("-- Power Infusion Active --" ,"WHISPER" ,nil ,name)
				CastSpellByName(spellName)
			end
		else
			print("Target is dead.")
		end

		if retarget then
			TargetLastTarget()
		end
	else
		print("Cannot find player '" .. name .. "'.")
	end
end

local function setpi(name)
	if not name or name == "" then
		print("Usage: /setpi Name")
		return
	end

	CPI_Name = formatname(name)
	print("New PI target: " .. CPI_Name)
end

local frame = CreateFrame("frame")
frame:RegisterEvent("CHAT_MSG_WHISPER")
frame:SetScript("OnEvent", function()
	local text = arg1
	local name = arg2
	if text and name then
		if strfind(text, "POWER INFUSION") then
			if CPI_Name ~= name then
				print("New PI target: " .. name)
				CPI_Name = name
			end
		end
	end
end)

SLASH_CPI1 = "/pi"
SlashCmdList["CPI"] = cast

SLASH_CSETPI1 = "/setpi"
SlashCmdList["CSETPI"] = setpi
