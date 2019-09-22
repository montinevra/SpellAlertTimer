local BAR_LENGTH = 128
local BAR_WIDTH = 4
--[[
local barColorR 
local barColorG 
local barColorB 
--]]

local barColors = {
-- todo: custom color for every spell
	["WARRIOR"] 	= {1.0, 0.4, 0.1}, --bloodsurge; {1,.2,1} --sword and board; {1, .9, .8} --ultimatum
	["MAGE"] 		= {1.4, 0.7, 1.0},
	["ROGUE"] 		= {1.0, 0.5, 1.0},
	["DRUID"] 		= {0.7, 0.5, 1.0}, --shooting stars (balance;top); {0.7, 1.0, 0.1} --omen of clarity/clearcasting (restoration;sides)
	["HUNTER"] 		= {0.7, 0.8, 0.2},
	["SHAMAN"] 		= {0.3, 0.4, 1.0},
	["PRIEST"] 		= {1.0, 1.0, 0.8},
	["WARLOCK"] 	= {0.4, 0.1, 1.0},
	["PALADIN"] 	= {1.0, 0.8, 0.1},
	["DEATHKNIGHT"] = {0.1, 1.0, 1.0},
	["MONK"] 		= {0.1, 0.9, 0.4},
}

LeftTimerFrame:RegisterEvent("PLAYER_LOGIN")
LeftTimerFrame:SetScript("OnEvent", function()
	local class = select(2,UnitClass("player"))

	LeftTimerFrame:SetStatusBarColor(unpack(barColors[class]))
	RightTimerFrame:SetStatusBarColor(unpack(barColors[class]))
	TopTimerFrame:SetStatusBarColor(unpack(barColors[class]))
end)

LeftTimerFrame:SetSize(BAR_WIDTH,BAR_LENGTH)
LeftGcdWarning:SetSize(BAR_WIDTH*2,8)
LeftGcdWarning:SetRotation(math.pi/2)

RightTimerFrame:SetSize(BAR_WIDTH,BAR_LENGTH)
RightGcdWarning:SetSize(BAR_WIDTH*2,8)
RightGcdWarning:SetRotation(math.pi/2)

TopTimerFrame:SetSize(BAR_LENGTH,BAR_WIDTH)
TopGcdWarning:SetSize(8,BAR_WIDTH*2)


TopTimerFrame:RegisterEvent("SPELL_ACTIVATION_OVERLAY_SHOW")
TopTimerFrame:SetScript("OnEvent", function(self, event, ...)
	local overlayPosition = (select(3,...)) -- "Top", "Left + Right (Flipped)" , "Left" , "Right (Flipped)"

							--[[
							druid:restoration:Clearcasting: "Left + Right (Flipped)" triggered by spell "Omen of Clarity"
							warlock:demonology:Molten Core: "Left" at first stack, spellID = 122355; "Right (Flipped)" at 2 stacks, spellID = 126090; 3+ does not trigger event
							]]

---[[debugging code
	print(" ")
	print("event = ",event)
	print("event arguments = " , ...)
	print("spell info = " , GetSpellInfo((...)))
	print("overlayPosition = " , overlayPosition)
--]]
	
	local spellID = (...)---[[
	if spellID == 93426 then	--Dark Transformation
		spellID = 49572		--Shadow Infusion
	end--]]
								--[[
									122355 Molten Core (1 stack)
									126090 Molten Core (2 stacks)
								]]


	local spellName = GetSpellInfo(spellID)
	local spellDuration = (select(6, UnitBuff("player",spellName) ))
		--[[debugging code
		print("UnitBuff = " , UnitBuff("player",spellName))
		--]]

	if spellDuration and spellID ~= 126090 then 					--Molten Core 2 stacks
		--[[ debugging code
		print("spellName = " .. spellName,  "spellDuration = " , spellDuration)
		--]]

		if overlayPosition == "Top" then
			
			startTimer(TopTimerFrame, TopGcdWarning, spellName, spellDuration)
		elseif overlayPosition == "Left + Right (Flipped)" then
	
			startTimer(LeftTimerFrame, LeftGcdWarning, spellName, spellDuration)
			startTimer(RightTimerFrame, RightGcdWarning, spellName, spellDuration)
		elseif overlayPosition == "Left" then

			startTimer(LeftTimerFrame, LeftGcdWarning, spellName, spellDuration)
		elseif overlayPosition == "Right (Flipped)" then

			startTimer(RightTimerFrame, RightGcdWarning, spellName, spellDuration)
		end
	end
end)

function startTimer(timerFrame, gcdWarning, spellName, spellDuration)
	--[[timerFrame:SetMinMaxValues(0, spellDuration )
	if timerFrame == TopTimerFrame then
		gcdWarning:SetWidth(BAR_LENGTH*1.5/spellDuration)
	else
		gcdWarning:SetHeight(BAR_LENGTH*1.5/spellDuration)
	end]]

	timerFrame:Show()
	timerFrame:SetScript("OnUpdate",function()
		if UnitBuff("player", spellName) == nil then
			timerFrame:Hide()
			--timerFrame:SetMinMaxValues(0, 0)
			--timerFrame:SetScript("OnUpdate", nil)
		else
			local spellExpiration = (select(7, UnitBuff("player",spellName) ))
			local timeRemaining = spellExpiration -GetTime()
			local timerLength = select(2,timerFrame:GetMinMaxValues())
			timerFrame:SetValue(timeRemaining)
			if timeRemaining <= 6 and timerLength ~= 6 then
				timerFrame:SetMinMaxValues(0, 6)
				if timerFrame == TopTimerFrame then
					timerFrame:SetHeight(BAR_WIDTH*2)
					gcdWarning:SetSize(BAR_LENGTH/4,BAR_WIDTH*4)
				else
					timerFrame:SetWidth(BAR_WIDTH*2)
					gcdWarning:SetSize(BAR_WIDTH*4,BAR_LENGTH/4)
				end
			elseif timeRemaining >= 6 and timerLength ~= spellDuration then
				timerFrame:SetMinMaxValues(0, spellDuration )
				if timerFrame == TopTimerFrame then
					timerFrame:SetHeight(BAR_WIDTH)
					gcdWarning:SetSize(BAR_LENGTH*1.5/spellDuration, BAR_WIDTH*2)
				else
					timerFrame:SetWidth(BAR_WIDTH)
					gcdWarning:SetSize(BAR_WIDTH*2, BAR_LENGTH*1.5/spellDuration)
				end
			end
		end
	end)
end
--[[
function setBarColors(barR, barG, barB, colorR, colorG, colorB)
	barR = colorR
	barG = colorG
	barB = colorB
end
--]]
