--[[[
@module Functions: Unit Castinfo
@description
Functions which handle casting & channeling stuff.
]]--

--------------------------
local L = MyLocalizationTable


--------------------------
-- CASTING SPELL
--------------------------

--name, subText, text, texture, startTime, endTime, isTradeSkill, notInterruptible = UnitChannelInfo("unit")
--name, subText, text, texture, startTime, endTime, isTradeSkill, castID, notInterruptible = UnitCastingInfo("unit")

--[[[
@function jps.CastTimeLeft
@description 
gets units cast time
[br][i]Usage:[/i][br]
[code]
jps.CastTimeLeft("player")

[/code]
@param unit: UnitID

@returns cast time in seconds or 0
]]--
function jps.CastTimeLeft(unit)
	if unit == nil then unit = "player" end
	local spellName,_,_,_,_,endTime,_,_,_ = UnitCastingInfo(unit)
	if endTime == nil then return 0 end
	return ((endTime - (GetTime() * 1000 ) )/1000), spellName
end
--[[[
@function jps.ChannelTimeLeft
@description 
gets units channel time
[br][i]Usage:[/i][br]
[code]
jps.ChannelTimeLeft("player")

[/code]
@param unit: UnitID

@returns channel time in seconds or 0
]]--
function jps.ChannelTimeLeft(unit)
	if unit == nil then unit = "player" end
	local spellName,_,_,_,_,endTime,_,_,_ = UnitChannelInfo(unit)
	if endTime == nil then return 0 end
	return ((endTime - (GetTime() * 1000 ) )/1000), spellName
end
--[[[
@function jps.spellCastTime
@description 
gets the cast time for a spell
[br][i]Usage:[/i][br]
[code]
jps.spellCastTime("Incinerate")

[/code]
@param spell: spellName or SpellID

@returns cast time in seconds or 0
]]--
function jps.spellCastTime(spell)
	local spellname = nil
	if type(spell) == "string" then spellname = spell end
	if type(spell) == "number" then spellname = tostring(select(1,GetSpellInfo(spell))) end
	castTime = select(4, GetSpellInfo(spellname)) 
	return (castTime/1000) or 0
end

function jps.IsCasting(unit)
	if unit == nil then unit = "player" end
	local enemycasting = false
	if jps.CastTimeLeft(unit) > 0 or jps.ChannelTimeLeft(unit) > 0 then -- WORKS FOR CASTING SPELL NOT CHANNELING SPELL
		enemycasting = true
	end
	return enemycasting
end

--[[[
@function jps.IsCastingSpell
@description 
checks if a unit cast a specific spell
[br][i]Usage:[/i][br]
[code]
jps.IsCastingSpell("Divine Hymn","target")

[/code]
@param spell: SpellName or SpellID
@param unit: UnitID
@returns boolean
]]--
function jps.IsCastingSpell(spell,unit)
	local spellname = nil
	if type(spell) == "string" then spellname = spell end
	if type(spell) == "number" then spellname = tostring(select(1,GetSpellInfo(spell))) end
	if unit == nil then unit = "player" end
	local name, _, _, _, startTime, endTime, _, _, interrupt = UnitCastingInfo(unit) -- WORKS FOR CASTING SPELL NOT CHANNELING SPELL
	if not name then return false end
	if spellname:lower() == name:lower() and jps.CastTimeLeft(unit) > 0 then return true end
	return false
end
--[[[
@function jps.IsChannelingSpell
@description 
checks if a unit cast a specific channel spell
[br][i]Usage:[/i][br]
[code]
jps.IsChannelingSpell("Divine Hymn","target")

[/code]
@param spell: SpellName or SpellID
@param unit: UnitID
@returns boolean
]]--
function jps.IsChannelingSpell(spell,unit)
	local spellname = nil
	if type(spell) == "string" then spellname = spell end
	if type(spell) == "number" then spellname = tostring(select(1,GetSpellInfo(spell))) end
	if unit == nil then unit = "player" end
	local name, _, _, _, startTime, endTime, _, interrupt = UnitChannelInfo(unit) -- WORKS FOR CASTING SPELL NOT CHANNELING SPELL
	if not name then return false end
	if spellname:lower() == name:lower() and jps.ChannelTimeLeft(unit) > 0 then return true end
	return false
end


jps.polySpellIds = {
	[51514] = "Hex" ,
	[118]	= "Polymorph" ,
	[61305] = "Polymorph: Black Cat" ,
	[28272] = "Polymorph: Pig" ,
	[61721] = "Polymorph: Rabbit" ,
	[61780] = "Polymorph: Turkey" ,
	[28271] = "Polymorph: Turtle" ,
}

jps.CCSpellIds = {
	-- Priest
	[605]=	"Mind Control",
	-- Druid
	[339] =		"Entangling Roots",
	[33786] =	"Cyclone",
	[2637] =	"Hibernate",
	-- Hunter
	[1499] =	"Freezing Trap",
	[13809] =	"Frost Trap",
	[34600] =	"Snake Trap",
	-- Mage
	[118] =		"Polymorph",
	[61305] = 	"Polymorph: Black Cat" ,
	[28272] = 	"Polymorph: Pig" ,
	[61721] = 	"Polymorph: Rabbit" ,
	[61780] = 	"Polymorph: Turkey" ,
	[28271] = 	"Polymorph: Turtle" ,
	-- Warlock
	[5782] =	"Fear",
	[5484] =	"Howl of Terror",
	-- Warrior

	-- Shaman
	[51514] =	"Hex"
}

-- Enemy Casting Polymorph Target is Player
--[[[
@function jps.IsCastingPoly
@description 
check's if a unit is casting polymorph
[br][i]Usage:[/i][br]
[code]
jps.IsCastingPoly("target")

[/code]
@param unit: UnitID

@returns boolean
]]--
function jps.IsCastingPoly(unit)
	if not jps.canDPS(unit) then return false end
	local delay = 0
	local spell, _, _, _, startTime, endTime = UnitCastingInfo(unit)

	for spellID,spellname in pairs(jps.polySpellIds) do
		if UnitIsUnit(unit.."target", "player") == 1 and spell == tostring(select(1,GetSpellInfo(spellID))) and jps.CastTimeLeft(unit) > 0 then
			delay = jps.CastTimeLeft(unit) - jps.Lag
		break end
	end

	if delay < 0 then return true end
	return false
end

-- Enemy casting CrowdControl Spell
--[[[
@function jps.IsCastingControl
@description 
check's if a unit is casting a cc spell
[br][i]Usage:[/i][br]
[code]
jps.IsCastingControl("target")

[/code]
@param unit: UnitID

@returns boolean
]]--
function jps.IsCastingControl(unit)
	if not jps.canDPS(unit) then return false end
	local delay = 0
	local spell, _, _, _, startTime, endTime = UnitCastingInfo(unit)

	for spellID,spellname in pairs(jps.CCSpellIds) do
		if spell == tostring(select(1,GetSpellInfo(spellID))) and jps.CastTimeLeft(unit) > 0 then
			delay = jps.CastTimeLeft(unit)
		break end
	end

	if delay > 0 then return true end
	return false
end

--[[[
@function jps.cooldown
@description 
get a spell cooldown
[br][i]Usage:[/i][br]
[code]
jps.cooldown("Bloodlust")

[/code]
@param spell: spellID or SpellName

@returns time in seconds
]]--
function jps.cooldown(spell) -- start, duration, enable = GetSpellCooldown("name") or GetSpellCooldown(id)
	local spellname = nil
	if type(spell) == "string" then spellname = spell end
	if type(spell) == "number" then spellname = tostring(select(1,GetSpellInfo(spell))) end
	if not IsUsableSpell(spellname) then return 999 end
	if jps.Lag == nil then jps.Lag = 0 end
	local start,duration,_ = GetSpellCooldown(spellname)
	if start == nil then return 0 end
	local cd = start+duration-GetTime() -- jps.Lag
	if cd < 0 then return 0 end
	return cd
end


function jps_IsSpellKnown(spell)
	local name, texture, offset, numSpells, isGuild = GetSpellTabInfo(2)
	local booktype = "spell"
	local mySpell = nil
	local spellname = nil
	if type(spell) == "string" then spellname = spell end
	if type(spell) == "number" then spellname = tostring(select(1,GetSpellInfo(spell))) end
	for index = offset+1, numSpells+offset do
		-- Get the Global Spell ID from the Player's spellbook
		local spellID = select(2,GetSpellBookItemInfo(index, booktype))
		local slotType = select(1,GetSpellBookItemInfo(index, booktype))
		local name = select(1,GetSpellBookItemName(index, booktype))
		if ((spellname:lower() == name:lower()) or (spellname == name)) and slotType ~= "FUTURESPELL" then
			mySpell = spellname
			break -- Breaking out of the for/do loop, because we have a match
		end
	end
		
	local name, texture, offset, numSpells, isGuild = GetSpellTabInfo(1)
	for index = offset+1, numSpells+offset do
		-- Get the Global Spell ID from the Player's spellbook
		local spellID = select(2,GetSpellBookItemInfo(index, booktype))
		local slotType = select(1,GetSpellBookItemInfo(index, booktype))
		local name = select(1,GetSpellBookItemName(index, booktype))
		if ((spellname:lower() == name:lower()) or (spellname == name)) and slotType ~= "FUTURESPELL" then
			mySpell = spellname
			break -- Breaking out of the for/do loop, because we have a match
		end
	end			
	return mySpell
end


function jps.IsSpellKnown(spell)
	if jps_IsSpellKnown(spell) == nil then return false end
return true
end
------------------------------
-- PLUA PROTECTED
------------------------------

function jps.groundClick()
	jps.Macro("/console deselectOnClick 0")
	CameraOrSelectOrMoveStart()
	CameraOrSelectOrMoveStop()
	jps.Macro("/console deselectOnClick 1")
end

function jps.faceTarget()
	InteractUnit("target")
end

function jps.moveToTarget()
	InteractUnit("target")
end

function jps.Macro(text)
	RunMacroText(text)
end


---------
-- timed casting
---------
--[[[
@function jps.castEverySeconds
@description 
allows you to repeat a cast every x seconds
[br][i]Usage:[/i][br]
[code]
jps.castEverySeconds("Blood Boil", 10)
-- casts blood boil every 10 seconds
[/code]
@param spell: spellName only!
@param time: time in seconds
@returns boolean
]]--
function jps.castEverySeconds(spell, seconds)
	if not jps.timedCasting[string.lower(spell)] then
		return true
	end
	if jps.timedCasting[string.lower(spell)] + seconds <= GetTime() then
		return true
	end
	return false
end



function jps.cancelCasting(hydraTable)
	if not hydraTable or type(hydraTable) ~= "table" then
		write("jps.cancelCasting() wrong params in rotation "..jps.Spec.."  -  "..jps.Class)
		return false
	end
	for _, spellTable in pairs(hydraTable) do
		spell = spellTable[1]
		conditions = spellTable[2]
		local isCasting = false
		if jps.CastTimeLeft("player") > 0 then
			castTimeLeft, castSpellName = jps.CastTimeLeft("player")
			isCasting = true
		elseif jps.ChannelTimeLeft("player") > 0 then
			castTimeLeft, castSpellName = jps.ChannelTimeLeft("player")
			isCasting = true
		end
		if isCasting == true then
			if spell == "" or spell == nil or not spell then
				spell = "all" -- matches every spell casted
			end
			if (spell == "all" or spell:lower() == castSpellName:lower()) and conditionsMatched(spell, conditions) then
				return true
			end
		end
	end
	return false
end
