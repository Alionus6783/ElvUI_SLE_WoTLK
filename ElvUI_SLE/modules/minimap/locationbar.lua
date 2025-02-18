﻿local SLE, T, E, L, V, P, G = unpack(select(2, ...))
local M = E.Minimap
local MM, DD = SLE.Minimap, SLE.Dropdowns
local LP = SLE.LocationPanel


local _G = _G
local format = format
local IsAddOnLoaded = IsAddOnLoaded
local GetScreenHeight = GetScreenHeight
local CreateFrame = CreateFrame
local ToggleFrame = ToggleFrame
local IsShiftKeyDown = IsShiftKeyDown
local GetBindLocation = GetBindLocation
local ChatEdit_ChooseBoxForSend, ChatEdit_ActivateChat = ChatEdit_ChooseBoxForSend, ChatEdit_ActivateChat
--local UNKNOWN, GARRISON_LOCATION_TOOLTIP, ITEMS, SPELLS, CLOSE, BACK = UNKNOWN, GARRISON_LOCATION_TOOLTIP, ITEMS, SPELLS, CLOSE, BACK
local DUNGEON_FLOOR_DALARAN1 = DUNGEON_FLOOR_DALARAN1
local CHALLENGE_MODE = CHALLENGE_MODE
local PlayerHasToy = PlayerHasToy
--local C_ToyBox = C_ToyBox
local RAID_CLASS_COLORS = RAID_CLASS_COLORS
local loc_panel
--local C_Garrison_IsPlayerInGarrison = C_Garrison.IsPlayerInGarrison

local collectgarbage = collectgarbage

LP.CDformats = {
	["DEFAULT"] = [[ (%s |TInterface\FriendsFrame\StatusIcon-Away:16|t)]],
	["DEFAULT_ICONFIRST"] = [[ (|TInterface\FriendsFrame\StatusIcon-Away:16|t %s)]],
}

LP.ReactionColors = {
	["sanctuary"] = {r = 0.41, g = 0.8, b = 0.94},
	["arena"] = {r = 1, g = 0.1, b = 0.1},
	["friendly"] = {r = 0.1, g = 1, b = 0.1},
	["hostile"] = {r = 1, g = 0.1, b = 0.1},
	["contested"] = {r = 1, g = 0.7, b = 0.10},
	["combat"] = {r = 1, g = 0.1, b = 0.1},
}

LP.MainMenu = {}
LP.SecondaryMenu = {}
LP.RestrictedArea = false

LP.ListUpdating = false
LP.ListBuilding = false
LP.ListBuildAttempts = 0
LP.InfoUpdatingTimer = nil

local function GetDirection()
	local y = select(2, _G.SLE_LocationPanel:GetCenter())
	local screenHeight = GetScreenHeight()
	local anchor, point = 'TOP', 'BOTTOM'

	if y and y < (screenHeight / 2) then
		anchor = 'BOTTOM'
		point = 'TOP'
	end

	return anchor, point
end

--{ItemID, ButtonText, isToy}
LP.Hearthstones = {
	{6948}, --Hearthstone
	{54452, nil, true}, --Etherial Portal
	{64488, nil, true}, --The Innkeeper's Daughter
	{93672, nil, true}, --Dark Portal
	{142542, nil, true}, --Tome of Town Portal (Diablo Event)
	{162973, nil, true}, --Winter HS
	{163045, nil, true}, --Hallow HS
	{165669, nil, true}, -- Lunar HS
	{165670, nil, true}, -- Love HS
	{165802, nil, true}, -- Noblegarden HS
	{166746, nil, true}, -- Midsummer HS
	{166747, nil, true}, -- Brewfest HS
	{168907, nil, true}, --Holographic Digitalization Hearthstone
	{172179, nil, true}, --Eternal Traveller
	--{183716, nil, true}, --Sinstone
	----{182773, nil, true}, --Necrolord HS
	--{180290, nil, true}, --Night Fae HS
	--{184353, nil, true}, --Kyrian HS
	--{188952, nil, true}, --Dominated HS
	--{190237, nil, true}, -- Broker Translocation Matrix
}

LP.PortItems = {
	--{110560, GARRISON_LOCATION_TOOLTIP}, --Garrison Hearthstone
	--{128353}, --Admiral's Compass
	--{140192, DUNGEON_FLOOR_DALARAN1}, --Dalaran Hearthstone
	{37863}, --Grim Guzzler
	{52251}, --Jaina's Locket
	--{58487}, --Potion of Deepholm
	{43824, nil, true}, --The Schools of Arcane Magic - Mastery
	--{64457}, --The Last Relic of Argus
	--{141605}, --Flight Masters's Whistle
	--{128502}, --Hunter's Seeking Crystal
	--{128503}, --Master Hunter's Seeking Crystal
	{140324, nil, true}, --Mobile Telemancy Beacon
	{129276}, --Beginner's Guide to Dimensional Rifting
	{140493}, --Adept's Guide to Dimensional Rifting
	--{95567, nil, true}, --Kirin Tor beakon
	--{95568, nil, true}, --Sunreaver beakon
	--{87548}, --Pandaria Arch
	{180817}, --Cypher of Relocation
	{151016}, --Fractured Necrolyte Skull
}
LP.EngineerItems = {
	{18984, nil, true}, --Dimensional Ripper - Everlook
	{18986, nil, true}, --Ultrasafe Transporter: Gadgetzan
	{30542, nil, true}, --Dimensional Ripper - Area 52
	{30544, nil, true}, --Ultrasafe Transporter: Toshley's Station
	{48933, nil, true}, --Wormhole Generator: Northrend
	--{87215, nil, true}, --Wormhole Generator: Pandaria
	{112059, nil, true}, --Wormhole Centrifuge
	--{151652, nil, true}, --Wormhole Generator: Argus
	--{168807, nil, true}, --Wormhole Generator: Kul Tiras
	--{168808, nil, true}, --Wormhole Generator: Zandalar
	--{172924, nil, true}, --Wormhole Generator: Shadowlands
	--{198156, nil, true}, -- Wyrmhole Generator (Dragonflight)
}
LP.Spells = {
	DEATHKNIGHT = {
		[1] = {text =  GetSpellInfo(50977),icon = SLE:GetIconFromID('spell', 50977),secure = {buttonType = 'spell',ID = 50977}, UseTooltip = true},
	},
	--DEMONHUNTER = {},
	DRUID = {
		[1] = {text =  GetSpellInfo(18960),icon = SLE:GetIconFromID('spell', 18960),secure = {buttonType = 'spell',ID = 18960}, UseTooltip = true},--Moonglade
		[2] = {text =  GetSpellInfo(147420),icon = SLE:GetIconFromID('spell', 147420),secure = {buttonType = 'spell',ID = 147420}, UseTooltip = true},--One With Nature
		[3] = {text =  GetSpellInfo(193753),icon = SLE:GetIconFromID('spell', 193753),secure = {buttonType = 'spell',ID = 193753}, UseTooltip = true},--Druid ClassHall
	},
	--EVOKER = {},
	HUNTER = {},
	MAGE = {
		[1] = {text =  GetSpellInfo(193759),icon = SLE:GetIconFromID('spell', 193759),secure = {buttonType = 'spell',ID = 193759}, UseTooltip = true}, --Guardian place
	},
	MONK = {
		[1] = {text =  GetSpellInfo(126892),icon = SLE:GetIconFromID('spell', 126892),secure = {buttonType = 'spell',ID = 126892}, UseTooltip = true},-- Zen Pilgrimage
		[2] = {text =  GetSpellInfo(126895),icon = SLE:GetIconFromID('spell', 126895),secure = {buttonType = 'spell',ID = 126895}, UseTooltip = true},-- Zen Pilgrimage: Return
	},
	PALADIN = {},
	PRIEST = {},
	ROGUE = {},
	SHAMAN = {
		[1] = {text = GetSpellInfo(556), icon = SLE:GetIconFromID('spell', 556),secure = {buttonType = 'spell',ID = 556}, UseTooltip = true},
	},
	WARLOCK = {},
	WARRIOR = {},
	--racials = {
		--DarkIronDwarf = {
			--[1] = {text = GetSpellInfo(265225),icon = SLE:GetIconFromID('spell', 265225),secure = {buttonType = 'spell',ID = 265225}, UseTooltip = true}, -- Mole Machine (Dark Iron Dwarfs)
		--},
		--Vulpera = {
		--	[1] = {text = GetSpellInfo(312370),icon = SLE:GetIconFromID('spell', 312370),secure = {buttonType = 'spell',ID = 312370}, UseTooltip = true}, -- Make Camp
		--	[2] = {text = GetSpellInfo(312372),icon = SLE:GetIconFromID('spell', 312372),secure = {buttonType = 'spell',ID = 312372}, UseTooltip = true}, -- Return to Camp
		--},
	--},

	teleports = {
		Horde = {
			[1] = {text = GetSpellInfo(3563),icon = SLE:GetIconFromID('spell', 3563),secure = {buttonType = 'spell',ID = 3563}, UseTooltip = true},-- TP:Undercity
			[2] = {text = GetSpellInfo(3566),icon = SLE:GetIconFromID('spell', 3566),secure = {buttonType = 'spell',ID = 3566}, UseTooltip = true},-- TP:Thunder Bluff
			[3] = {text = GetSpellInfo(3567),icon = SLE:GetIconFromID('spell', 3567),secure = {buttonType = 'spell',ID = 3567}, UseTooltip = true},-- TP:Orgrimmar
			[4] = {text = GetSpellInfo(32272),icon = SLE:GetIconFromID('spell', 32272),secure = {buttonType = 'spell',ID = 32272}, UseTooltip = true},-- TP:Silvermoon
			[5] = {text = GetSpellInfo(49358),icon = SLE:GetIconFromID('spell', 49358),secure = {buttonType = 'spell',ID = 49358}, UseTooltip = true},-- TP:Stonard
			[6] = {text = GetSpellInfo(35715),icon = SLE:GetIconFromID('spell', 35715),secure = {buttonType = 'spell',ID = 35715}, UseTooltip = true},-- TP:Shattrath
			[7] = {text = GetSpellInfo(53140),icon = SLE:GetIconFromID('spell', 53140),secure = {buttonType = 'spell',ID = 53140}, UseTooltip = true},-- TP:Dalaran - Northrend
			--[8] = {text = GetSpellInfo(88344),icon = SLE:GetIconFromID('spell', 88344),secure = {buttonType = 'spell',ID = 88344}, UseTooltip = true},-- TP:Tol Barad
			--[9] = {text = GetSpellInfo(132627),icon = SLE:GetIconFromID('spell', 132627),secure = {buttonType = 'spell',ID = 132627}, UseTooltip = true},-- TP:Vale of Eternal Blossoms
			--[10] = {text = GetSpellInfo(120145),icon = SLE:GetIconFromID('spell', 120145),secure = {buttonType = 'spell',ID = 120145}, UseTooltip = true},-- TP:Ancient Dalaran
			--[11] = {text = GetSpellInfo(176242),icon = SLE:GetIconFromID('spell', 176242),secure = {buttonType = 'spell',ID = 176242}, UseTooltip = true},-- TP:Warspear
			--[12] = {text = GetSpellInfo(224869),icon = SLE:GetIconFromID('spell', 224869),secure = {buttonType = 'spell',ID = 224869}, UseTooltip = true},-- TP:Dalaran - BI
			--[13] = {text = GetSpellInfo(281404),icon = SLE:GetIconFromID('spell', 281404),secure = {buttonType = 'spell',ID = 281404}, UseTooltip = true},-- TP:Dazar'alor
			--[14] = {text = GetSpellInfo(344587),icon = SLE:GetIconFromID('spell', 344587),secure = {buttonType = 'spell',ID = 344587}, UseTooltip = true},-- TP:Oribos
			--[15] = {text = GetSpellInfo(395277),icon = SLE:GetIconFromID('spell', 395277),secure = {buttonType = 'spell',ID = 395277}, UseTooltip = true},-- TP:Valdrakken
		},
		Alliance = {
			[1] = {text = GetSpellInfo(3561),icon = SLE:GetIconFromID('spell', 3561),secure = {buttonType = 'spell',ID = 3561}, UseTooltip = true},-- TP:Stormwind
			[2] = {text = GetSpellInfo(3562),icon = SLE:GetIconFromID('spell', 3562),secure = {buttonType = 'spell',ID = 3562}, UseTooltip = true},-- TP:Ironforge
			[3] = {text = GetSpellInfo(3565),icon = SLE:GetIconFromID('spell', 3565),secure = {buttonType = 'spell',ID = 3565}, UseTooltip = true},-- TP:Darnassus
			[4] = {text = GetSpellInfo(32271),icon = SLE:GetIconFromID('spell', 32271),secure = {buttonType = 'spell',ID = 32271}, UseTooltip = true},-- TP:Exodar
			[5] = {text = GetSpellInfo(49359),icon = SLE:GetIconFromID('spell', 49359),secure = {buttonType = 'spell',ID = 49359}, UseTooltip = true},-- TP:Theramore
			[6] = {text = GetSpellInfo(33690),icon = SLE:GetIconFromID('spell', 33690),secure = {buttonType = 'spell',ID = 33690}, UseTooltip = true},-- TP:Shattrath
			[7] = {text = GetSpellInfo(53140),icon = SLE:GetIconFromID('spell', 53140),secure = {buttonType = 'spell',ID = 53140}, UseTooltip = true},-- TP:Dalaran - Northrend
			--[8] = {text = GetSpellInfo(88342),icon = SLE:GetIconFromID('spell', 88342),secure = {buttonType = 'spell',ID = 88342}, UseTooltip = true},-- TP:Tol Barad
			--[9] = {text = GetSpellInfo(132621),icon = SLE:GetIconFromID('spell', 132621),secure = {buttonType = 'spell',ID = 132621}, UseTooltip = true},-- TP:Vale of Eternal Blossoms
			--[10] = {text = GetSpellInfo(120145),icon = SLE:GetIconFromID('spell', 120145),secure = {buttonType = 'spell',ID = 120145}, UseTooltip = true},-- TP:Ancient Dalaran
			--[11] = {text = GetSpellInfo(176248),icon = SLE:GetIconFromID('spell', 176248),secure = {buttonType = 'spell',ID = 176248}, UseTooltip = true},-- TP:StormShield
			--[12] = {text = GetSpellInfo(224869),icon = SLE:GetIconFromID('spell', 224869),secure = {buttonType = 'spell',ID = 224869}, UseTooltip = true},-- TP:Dalaran - BI
			--[13] = {text = GetSpellInfo(281403),icon = SLE:GetIconFromID('spell', 281403),secure = {buttonType = 'spell',ID = 281403}, UseTooltip = true},-- TP:Boralus
			--[14] = {text = GetSpellInfo(344587),icon = SLE:GetIconFromID('spell', 344587),secure = {buttonType = 'spell',ID = 344587}, UseTooltip = true},-- TP:Oribos
			--[15] = {text = GetSpellInfo(395277),icon = SLE:GetIconFromID('spell', 395277),secure = {buttonType = 'spell',ID = 395277}, UseTooltip = true},-- TP:Valdrakken
		},
	},
	portals = {
		Horde = {
			[1] = {text = GetSpellInfo(11418),icon = SLE:GetIconFromID('spell', 11418),secure = {buttonType = 'spell',ID = 11418}, UseTooltip = true},-- P:Undercity
			[2] = {text = GetSpellInfo(11420),icon = SLE:GetIconFromID('spell', 11420),secure = {buttonType = 'spell',ID = 11420}, UseTooltip = true}, -- P:Thunder Bluff
			[3] = {text = GetSpellInfo(11417),icon = SLE:GetIconFromID('spell', 11417),secure = {buttonType = 'spell',ID = 11417}, UseTooltip = true},-- P:Orgrimmar
			[4] = {text = GetSpellInfo(32267),icon = SLE:GetIconFromID('spell', 32267),secure = {buttonType = 'spell',ID = 32267}, UseTooltip = true},-- P:Silvermoon
			[5] = {text = GetSpellInfo(49361),icon = SLE:GetIconFromID('spell', 49361),secure = {buttonType = 'spell',ID = 49361}, UseTooltip = true},-- P:Stonard
			[6] = {text = GetSpellInfo(35717),icon = SLE:GetIconFromID('spell', 35717),secure = {buttonType = 'spell',ID = 35717}, UseTooltip = true},-- P:Shattrath
			[7] = {text = GetSpellInfo(53142),icon = SLE:GetIconFromID('spell', 53142),secure = {buttonType = 'spell',ID = 53142}, UseTooltip = true},-- P:Dalaran - Northred
			[8] = {text = GetSpellInfo(88346),icon = SLE:GetIconFromID('spell', 88346),secure = {buttonType = 'spell',ID = 88346}, UseTooltip = true},-- P:Tol Barad
			--[9] = {text = GetSpellInfo(120146),icon = SLE:GetIconFromID('spell', 120146),secure = {buttonType = 'spell',ID = 120146}, UseTooltip = true},-- P:Ancient Dalaran
			--[10] = {text = GetSpellInfo(132626),icon = SLE:GetIconFromID('spell', 132626),secure = {buttonType = 'spell',ID = 132626}, UseTooltip = true},-- P:Vale of Eternal Blossoms
			--[11] = {text = GetSpellInfo(176244),icon = SLE:GetIconFromID('spell', 176244),secure = {buttonType = 'spell',ID = 176244}, UseTooltip = true},-- P:Warspear
			--[12] = {text = GetSpellInfo(224871),icon = SLE:GetIconFromID('spell', 224871),secure = {buttonType = 'spell',ID = 224871}, UseTooltip = true},-- P:Dalaran - BI
			--[13] = {text = GetSpellInfo(281402),icon = SLE:GetIconFromID('spell', 281402),secure = {buttonType = 'spell',ID = 281402}, UseTooltip = true},-- P:Dazar'alor
			--[14] = {text = GetSpellInfo(344597),icon = SLE:GetIconFromID('spell', 344597),secure = {buttonType = 'spell',ID = 344597}, UseTooltip = true},-- P:Oribos
			--[15] = {text = GetSpellInfo(395289),icon = SLE:GetIconFromID('spell', 395289),secure = {buttonType = 'spell',ID = 395289}, UseTooltip = true},-- P:Valdrakken
		},
		Alliance = {
			[1] = {text = GetSpellInfo(10059),icon = SLE:GetIconFromID('spell', 10059),secure = {buttonType = 'spell',ID = 10059}, UseTooltip = true},-- P:Stormwind
			[2] = {text = GetSpellInfo(11416),icon = SLE:GetIconFromID('spell', 11416),secure = {buttonType = 'spell',ID = 11416}, UseTooltip = true},-- P:Ironforge
			[3] = {text = GetSpellInfo(11419),icon = SLE:GetIconFromID('spell', 11419),secure = {buttonType = 'spell',ID = 11419}, UseTooltip = true},-- P:Darnassus
			[4] = {text = GetSpellInfo(32266),icon = SLE:GetIconFromID('spell', 32266),secure = {buttonType = 'spell',ID = 32266}, UseTooltip = true},-- P:Exodar
			[5] = {text = GetSpellInfo(49360),icon = SLE:GetIconFromID('spell', 49360),secure = {buttonType = 'spell',ID = 49360}, UseTooltip = true},-- P:Theramore
			[6] = {text = GetSpellInfo(33691),icon = SLE:GetIconFromID('spell', 33691),secure = {buttonType = 'spell',ID = 33691}, UseTooltip = true},-- P:Shattrath
			[7] = {text = GetSpellInfo(53142),icon = SLE:GetIconFromID('spell', 53142),secure = {buttonType = 'spell',ID = 53142}, UseTooltip = true},-- P:Dalaran - Northred
			--[8] = {text = GetSpellInfo(88345),icon = SLE:GetIconFromID('spell', 88345),secure = {buttonType = 'spell',ID = 88345}, UseTooltip = true},-- P:Tol Barad
			--[9] = {text = GetSpellInfo(120146),icon = SLE:GetIconFromID('spell', 120146),secure = {buttonType = 'spell',ID = 120146}, UseTooltip = true},-- P:Ancient Dalaran
			--[10] = {text = GetSpellInfo(132620),icon = SLE:GetIconFromID('spell', 132620),secure = {buttonType = 'spell',ID = 132620}, UseTooltip = true},-- P:Vale of Eternal Blossoms
			--[11] = {text = GetSpellInfo(176246),icon = SLE:GetIconFromID('spell', 176246),secure = {buttonType = 'spell',ID = 176246}, UseTooltip = true},-- P:StormShield
			--[12] = {text = GetSpellInfo(224871),icon = SLE:GetIconFromID('spell', 224871),secure = {buttonType = 'spell',ID = 224871}, UseTooltip = true},-- P:Dalaran - BI
			--[13] = {text = GetSpellInfo(281400),icon = SLE:GetIconFromID('spell', 281400),secure = {buttonType = 'spell',ID = 281400}, UseTooltip = true},-- P:Boralus
			--[14] = {text = GetSpellInfo(344597),icon = SLE:GetIconFromID('spell', 344597),secure = {buttonType = 'spell',ID = 344597}, UseTooltip = true},-- P:Oribos
			--[15] = {text = GetSpellInfo(395289),icon = SLE:GetIconFromID('spell', 395289),secure = {buttonType = 'spell',ID = 395289}, UseTooltip = true},-- P:Valdrakken
		},
	},
	--challenge = {
	--	[1] = {text = GetSpellInfo(131204),icon = SLE:GetIconFromID('spell', 131204),secure = {buttonType = 'spell',ID = 131204}, UseTooltip = true},	-- Temple of the Jade Serpent (Path of the Jade Serpent)
	--	[2] = {text = GetSpellInfo(131205),icon = SLE:GetIconFromID('spell', 131205),secure = {buttonType = 'spell',ID = 131205}, UseTooltip = true},	-- Stormstout Brewery (Path of the Stout Brew)
	--	[3] = {text = GetSpellInfo(131206),icon = SLE:GetIconFromID('spell', 131206),secure = {buttonType = 'spell',ID = 131206}, UseTooltip = true},	-- Shado-Pan Monastery (Path of the Shado-Pan)
	--	[4] = {text = GetSpellInfo(131222),icon = SLE:GetIconFromID('spell', 131222),secure = {buttonType = 'spell',ID = 131222}, UseTooltip = true},	-- Mogu'shan Palace (Path of the Mogu King)
	--	[5] = {text = GetSpellInfo(131225),icon = SLE:GetIconFromID('spell', 131225),secure = {buttonType = 'spell',ID = 131225}, UseTooltip = true},	-- Gate of the Setting Sun (Path of the Setting Sun)
	--	[6] = {text = GetSpellInfo(131231),icon = SLE:GetIconFromID('spell', 131231),secure = {buttonType = 'spell',ID = 131231}, UseTooltip = true},	-- Scarlet Halls (Path of the Scarlet Blade)
	--	[7] = {text = GetSpellInfo(131229),icon = SLE:GetIconFromID('spell', 131229),secure = {buttonType = 'spell',ID = 131229}, UseTooltip = true},	-- Scarlet Monastery (Path of the Scarlet Mitre)
	--	[8] = {text = GetSpellInfo(131232),icon = SLE:GetIconFromID('spell', 131232),secure = {buttonType = 'spell',ID = 131232}, UseTooltip = true},	-- Scholomance (Path of the Necromancer)
	--	[9] = {text = GetSpellInfo(131228),icon = SLE:GetIconFromID('spell', 131228),secure = {buttonType = 'spell',ID = 131228}, UseTooltip = true},	-- Siege of Niuzao (Path of the Black Ox)
	--	[10] = {text = GetSpellInfo(159895),icon = SLE:GetIconFromID('spell', 159895),secure = {buttonType = 'spell',ID = 159895}, UseTooltip = true},	-- Bloodmaul Slag Mines (Path of the Bloodmaul)
	--	[11] = {text = GetSpellInfo(159902),icon = SLE:GetIconFromID('spell', 159902),secure = {buttonType = 'spell',ID = 159902}, UseTooltip = true},	-- Upper Blackrock Spire (Path of the Burning Mountain)
	--	[12] = {text = GetSpellInfo(159899),icon = SLE:GetIconFromID('spell', 159899),secure = {buttonType = 'spell',ID = 159899}, UseTooltip = true},	-- Shadowmoon Burial Grounds (Path of the Crescent Moon)
	--	[13] = {text = GetSpellInfo(159900),icon = SLE:GetIconFromID('spell', 159900),secure = {buttonType = 'spell',ID = 159900}, UseTooltip = true},	-- Grimrail Depot (Path of the Dark Rail)
	--	[14] = {text = GetSpellInfo(159896),icon = SLE:GetIconFromID('spell', 159896),secure = {buttonType = 'spell',ID = 159896}, UseTooltip = true},	-- Iron Docks (Path of the Iron Prow)
        --      [15] = {text = GetSpellInfo(159898),icon = SLE:GetIconFromID('spell', 159898),secure = {buttonType = 'spell',ID = 159898}, UseTooltip = true},	-- Skyreach (Path of the Skies)
	--	[16] = {text = GetSpellInfo(159901),icon = SLE:GetIconFromID('spell', 159901),secure = {buttonType = 'spell',ID = 159901}, UseTooltip = true},	-- Everbloom (Path of the Verdant)
	--	[17] = {text = GetSpellInfo(159897),icon = SLE:GetIconFromID('spell', 159897),secure = {buttonType = 'spell',ID = 159897}, UseTooltip = true},	-- Auchindoun (Path of the Vigilant)
	--	[18] = {text = GetSpellInfo(354468),icon = SLE:GetIconFromID('spell', 354468),secure = {buttonType = 'spell',ID = 354468}, UseTooltip = true},	-- De Other Side (Path of the Scheming Loa)
	--	[19] = {text = GetSpellInfo(354465),icon = SLE:GetIconFromID('spell', 354465),secure = {buttonType = 'spell',ID = 354465}, UseTooltip = true},	-- Halls of Atonement (Path of the Sinful Soul)
	--	[20] = {text = GetSpellInfo(354464),icon = SLE:GetIconFromID('spell', 354464),secure = {buttonType = 'spell',ID = 354464}, UseTooltip = true},	-- Mists of Tirna Scithe (Path of the Misty Forest)
	--	[21] = {text = GetSpellInfo(354463),icon = SLE:GetIconFromID('spell', 354463),secure = {buttonType = 'spell',ID = 354463}, UseTooltip = true},	-- Plaguefall (Path of the Plagued)
	--	[22] = {text = GetSpellInfo(354469),icon = SLE:GetIconFromID('spell', 354469),secure = {buttonType = 'spell',ID = 354469}, UseTooltip = true},	-- Sanguine Depths (Path of the Stone Warden)
	--	[23] = {text = GetSpellInfo(354466),icon = SLE:GetIconFromID('spell', 354466),secure = {buttonType = 'spell',ID = 354466}, UseTooltip = true},	-- Spires of Ascension (Path of the Ascendant)
	--	[24] = {text = GetSpellInfo(354462),icon = SLE:GetIconFromID('spell', 354462),secure = {buttonType = 'spell',ID = 354462}, UseTooltip = true},	-- Necrotic Wake (Path of the Courageous)
	--	[25] = {text = GetSpellInfo(354467),icon = SLE:GetIconFromID('spell', 354467),secure = {buttonType = 'spell',ID = 354467}, UseTooltip = true},	-- Theater of Pain (Path of the Undefeated)
	--	[26] = {text = GetSpellInfo(367416),icon = SLE:GetIconFromID('spell', 367416),secure = {buttonType = 'spell',ID = 367416}, UseTooltip = true},	-- Tazavesh, the Veiled Market (Path of the Streetwise Merchant)
	--	[27] = {text = GetSpellInfo(373274),icon = SLE:GetIconFromID('spell', 373274),secure = {buttonType = 'spell',ID = 373274}, UseTooltip = true},	-- Mechagon (Path of the Scrappy Prince)
	--	[28] = {text = GetSpellInfo(373262),icon = SLE:GetIconFromID('spell', 373262),secure = {buttonType = 'spell',ID = 373262}, UseTooltip = true},	-- Karazhan (Path of the Fallen Guardian)
	--	[29] = {text = GetSpellInfo(373190),icon = SLE:GetIconFromID('spell', 373190),secure = {buttonType = 'spell',ID = 373190}, UseTooltip = true},	-- Castle Nathria (Path of the Sire)
	--	[30] = {text = GetSpellInfo(373191),icon = SLE:GetIconFromID('spell', 373191),secure = {buttonType = 'spell',ID = 373191}, UseTooltip = true},	-- Sanctum of Domination (Path of the Tormented Soul)
	--	[31] = {text = GetSpellInfo(373192),icon = SLE:GetIconFromID('spell', 373192),secure = {buttonType = 'spell',ID = 373192}, UseTooltip = true},	-- Sepulcher of the First Ones (Path of the First Ones)
	--	[32] = {text = GetSpellInfo(393222),icon = SLE:GetIconFromID('spell', 393222),secure = {buttonType = 'spell',ID = 393222}, UseTooltip = true},	-- Uldaman: Legacy of Tyr (Path of the Watcher's Legacy)
	--	[33] = {text = GetSpellInfo(393256),icon = SLE:GetIconFromID('spell', 393256),secure = {buttonType = 'spell',ID = 393256}, UseTooltip = true},	-- Ruby Life Pools (Path of the Clutch Defender)
	--	[34] = {text = GetSpellInfo(393262),icon = SLE:GetIconFromID('spell', 393262),secure = {buttonType = 'spell',ID = 393262}, UseTooltip = true},	-- The Nokhud Offensive (Path of the Windswept Plains)
	--	[35] = {text = GetSpellInfo(393267),icon = SLE:GetIconFromID('spell', 393267),secure = {buttonType = 'spell',ID = 393267}, UseTooltip = true},	-- Brackenhide (Path of the Rotting Woods)
	--	[36] = {text = GetSpellInfo(393273),icon = SLE:GetIconFromID('spell', 393273),secure = {buttonType = 'spell',ID = 393273}, UseTooltip = true},	-- Algeth'ar Academy (Path of the Draconic Diploma)
	--	[37] = {text = GetSpellInfo(393276),icon = SLE:GetIconFromID('spell', 393276),secure = {buttonType = 'spell',ID = 393276}, UseTooltip = true},	-- Neltharus (Path of the Obsidian Hoard)
	--	[38] = {text = GetSpellInfo(393283),icon = SLE:GetIconFromID('spell', 393283),secure = {buttonType = 'spell',ID = 393283}, UseTooltip = true},	-- Halls of Infusion (Path of the Titanic Reservoir)
	--	[39] = {text = GetSpellInfo(393764),icon = SLE:GetIconFromID('spell', 393764),secure = {buttonType = 'spell',ID = 393764}, UseTooltip = true},	-- Halls of Valor (Path of Proven Worth)
	--	[40] = {text = GetSpellInfo(393766),icon = SLE:GetIconFromID('spell', 393766),secure = {buttonType = 'spell',ID = 393766}, UseTooltip = true},	-- Court of Stars (Path of the Grand Magistrix)
	--},
}

function LP:CreateLocationPanel()
	loc_panel = CreateFrame('Frame', 'SLE_LocationPanel', E.UIParent, 'BackdropTemplate')
	loc_panel:Point('TOP', E.UIParent, 'TOP', 0, -E.mult -22)
	loc_panel:SetFrameStrata('MEDIUM')
	loc_panel:SetFrameLevel(2)
	loc_panel:EnableMouse(true)
	loc_panel:SetScript('OnMouseUp', LP.OnClick)
	loc_panel:SetScript('OnUpdate', LP.UpdateCoords)

	-- Location Text
	loc_panel.Text = loc_panel:CreateFontString(nil, 'BORDER')
	loc_panel.Text:Point('CENTER', 0, 0)
	loc_panel.Text:SetWordWrap(false)
	E.FrameLocks[loc_panel] = true

	--Coords
	loc_panel.Xcoord = CreateFrame('Frame', 'SLE_LocationPanel_X', loc_panel, 'BackdropTemplate')
	-- loc_panel.Xcoord:SetPoint('RIGHT', loc_panel, 'LEFT', 1 - 2*E.Spacing, 0)
	loc_panel.Xcoord:Point('RIGHT', loc_panel, 'LEFT', 1, 0)
	loc_panel.Xcoord.Text = loc_panel.Xcoord:CreateFontString(nil, 'BORDER')
	loc_panel.Xcoord.Text:Point('CENTER', 0, 0)

	loc_panel.Ycoord = CreateFrame('Frame', 'SLE_LocationPanel_Y', loc_panel, 'BackdropTemplate')
	-- loc_panel.Ycoord:SetPoint('LEFT', loc_panel, 'RIGHT', -1 + 2*E.Spacing, 0)
	loc_panel.Ycoord:Point('LEFT', loc_panel, 'RIGHT', -1, 0)
	loc_panel.Ycoord.Text = loc_panel.Ycoord:CreateFontString(nil, 'BORDER')
	loc_panel.Ycoord.Text:Point('CENTER', 0, 0)

	LP:Resize()
	-- Mover
	E:CreateMover(loc_panel, 'SLE_Location_Mover', L["Location Panel"], nil, nil, nil, 'ALL,S&L,S&L MISC')

	LP.Menu1 = CreateFrame('Frame', 'SLE_LocationPanel_RightClickMenu1', E.UIParent, 'BackdropTemplate')
	LP.Menu1:SetTemplate('Transparent', true)
	LP.Menu2 = CreateFrame('Frame', 'SLE_LocationPanel_RightClickMenu2', E.UIParent, 'BackdropTemplate')
	LP.Menu2:SetTemplate('Transparent', true)
	DD:RegisterMenu(LP.Menu1)
	DD:RegisterMenu(LP.Menu2)
	LP.Menu1:SetScript('OnHide', function() wipe(LP.MainMenu) end)
	LP.Menu2:SetScript('OnHide', function() wipe(LP.SecondaryMenu) end)
end

function LP:OnClick(btn)
	local zoneText = GetRealZoneText() or UNKNOWN
	if btn == 'LeftButton' then
		if IsShiftKeyDown() and LP.db.linkcoords then
			local edit_box = ChatEdit_ChooseBoxForSend()
			local message
			local coords = format(LP.db.format, E.MapInfo.xText or 0)..', '..format(LP.db.format, E.MapInfo.yText or 0)
				if zoneText ~= GetSubZoneText() then
					message = format('%s: %s (%s)', zoneText, GetSubZoneText(), coords)
				else
					message = format('%s (%s)', zoneText, coords)
				end
			ChatEdit_ActivateChat(edit_box)
			edit_box:Insert(message)
		else
			ToggleFrame(_G.WorldMapFrame)
		end
	elseif btn == 'RightButton' and LP.db.portals.enable and not InCombatLockdown() then
		if LP.ListBuilding then SLE:Print(L["Info for some items is not available yet. Please try again later"], 'info') return end
		LP:PopulateDropdown(true)
	end
end

function LP:UpdateCoords(elapsed)
	LP.elapsed = LP.elapsed + elapsed
	if LP.elapsed < (LP.db.throttle or 0.2) then return end
	if not LP.db.format then return end
	--Coords

	if E.MapInfo then
		loc_panel.Xcoord.Text:SetText(format(LP.db.format, E.MapInfo.xText or 0))
		loc_panel.Ycoord.Text:SetText(format(LP.db.format, E.MapInfo.yText or 0))
	else
		loc_panel.Xcoord.Text:SetText('-')
		loc_panel.Ycoord.Text:SetText('-')
	end
	--Coords coloring
	local colorC = {r = 1, g = 1, b = 1}
	if LP.db.colorType_Coords == 'REACTION' then
		local inInstance, _ = IsInInstance()
		if inInstance then
			colorC = {r = 1, g = 0.1, b = 0.1}
		else
			local pvpType = GetZonePVPInfo()
			colorC = LP.ReactionColors[pvpType] or {r = 1, g = 1, b = 0}
		end
	elseif LP.db.colorType_Coords == 'CUSTOM' then
		colorC = LP.db.customColor_Coords
	elseif LP.db.colorType_Coords == 'CLASS' then
		colorC = RAID_CLASS_COLORS[E.myclass]
	end
	loc_panel.Xcoord.Text:SetTextColor(colorC.r, colorC.g, colorC.b)
	loc_panel.Ycoord.Text:SetTextColor(colorC.r, colorC.g, colorC.b)

	--Location
	local subZoneText = GetMinimapZoneText() or ''
	local zoneText = GetRealZoneText() or UNKNOWN
	local displayLine
	if LP.db.zoneText then
		if (subZoneText ~= '') and (subZoneText ~= zoneText) then
			displayLine = zoneText .. ': ' .. subZoneText
		else
			displayLine = subZoneText
		end
	else
		displayLine = subZoneText
	end
	loc_panel.Text:SetText(displayLine)
	if LP.db.autowidth then loc_panel:Width(loc_panel.Text:GetStringWidth() + 10) end

	--Location Colorings
	if displayLine ~= '' then
		local color = {r = 1, g = 1, b = 1}
		if LP.db.colorType == 'REACTION' then
			local inInstance, _ = IsInInstance()
			if inInstance then
				color = {r = 1, g = 0.1,b =  0.1}
			else
				local pvpType = GetZonePVPInfo()
				color = LP.ReactionColors[pvpType] or {r = 1, g = 1, b = 0}
			end
		elseif LP.db.colorType == 'CUSTOM' then
			color = LP.db.customColor
		elseif LP.db.colorType == 'CLASS' then
			color = RAID_CLASS_COLORS[E.myclass]
		end
		loc_panel.Text:SetTextColor(color.r, color.g, color.b)
	end

	LP.elapsed = 0
end

function LP:Resize()
	if LP.db.autowidth then
		loc_panel:SetSize(loc_panel.Text:GetStringWidth() + 10, LP.db.height)
	else
		loc_panel:SetSize(LP.db.width, LP.db.height)
	end
	loc_panel.Text:Width(LP.db.width - 18)
	loc_panel.Xcoord:SetSize(LP.db.fontSize * 3, LP.db.height)
	loc_panel.Ycoord:SetSize(LP.db.fontSize * 3, LP.db.height)
end

function LP:Fonts()
	loc_panel.Text:SetFont(E.LSM:Fetch('font', LP.db.font), LP.db.fontSize, LP.db.fontOutline)
	loc_panel.Xcoord.Text:SetFont(E.LSM:Fetch('font', LP.db.font), LP.db.fontSize, LP.db.fontOutline)
	loc_panel.Ycoord.Text:SetFont(E.LSM:Fetch('font', LP.db.font), LP.db.fontSize, LP.db.fontOutline)
end

function LP:Template()
	loc_panel:SetTemplate(LP.db.template)
	loc_panel.Xcoord:SetTemplate(LP.db.template)
	loc_panel.Ycoord:SetTemplate(LP.db.template)
end

function LP:CheckForIncompatible()
	if IsAddOnLoaded('ElvUI_LocLite') and E.db.sle.minimap.locPanel.enable then
		SLE:IncompatibleAddOn('ElvUI_LocLite', 'Location Panel', E.db.sle.minimap.locPanel.enable, 'enable')
	end
end

function LP:Toggle()
	if LP.db.enable then
		LP:CheckForIncompatible()
		loc_panel:Show()
		E:EnableMover(loc_panel.mover:GetName())
	else
		loc_panel:Hide()
		E:DisableMover(loc_panel.mover:GetName())
	end
	LP:UNIT_AURA(nil, 'player')
end

function LP:PopulateItems()
	local noItem = false

	for _, data in pairs(LP.Hearthstones) do
		if select(2, GetItemInfo(data[1])) == nil then noItem = true end
	end
	for _, data in pairs(LP.PortItems) do
		if select(2, GetItemInfo(data[1])) == nil then noItem = true end
	end
	for _, data in pairs(LP.EngineerItems) do
		if select(2, GetItemInfo(data[1])) == nil then noItem = true end
	end

	if noItem and LP.ListBuildAttempts < 15 then
		LP.ListBuilding = true
		LP.ListBuildAttempts = LP.ListBuildAttempts + 1
		E:Delay(2, LP.PopulateItems)
	else
		LP.ListBuilding = false
		LP.ListBuildAttempts = 0
		for index, data in pairs(LP.Hearthstones) do
			local id, name, toy = data[1], data[2], data[3]
			if select(2, GetItemInfo(id)) then
				LP.Hearthstones[index] = {text = name or GetItemInfo(id), icon = SLE:GetIconFromID('item', id),secure = {buttonType = 'item',ID = id, isToy = toy}, UseTooltip = true,}
			else
				LP.EngineerItems[index] = { text = UNKNOWN }
			end
		end
		for index, data in pairs(LP.PortItems) do
			local id, name, toy = data[1], data[2], data[3]
			if select(2, GetItemInfo(id)) then
				LP.PortItems[index] = {text = name or GetItemInfo(id), icon = SLE:GetIconFromID('item', id),secure = {buttonType = 'item',ID = id, isToy = toy}, UseTooltip = true,}
			else
				LP.EngineerItems[index] = { text = UNKNOWN }
			end
		end
		for index, data in pairs(LP.EngineerItems) do
			local id, name, toy = data[1], data[2], data[3]
			if select(2, GetItemInfo(id)) then
				LP.EngineerItems[index] = { text = name or GetItemInfo(id), icon = SLE:GetIconFromID('item', id),secure = {buttonType = 'item',ID = id, isToy = toy}, UseTooltip = true,}
			else
				LP.EngineerItems[index] = { text = UNKNOWN }
			end
		end
	end
end

function LP:ItemList()
	if LP.db.portals.HSplace then tinsert(LP.MainMenu, {text = L["Hearthstone Location"]..": "..GetBindLocation(), title = true, nohighlight = true}) end
	tinsert(LP.MainMenu, {text = ITEMS..':', title = true, nohighlight = true})

	if LP.db.portals.showHearthstones then
		local priority = 100
		local ShownHearthstone
		local tmp = {}
		local hsPrio = {strsplit(',', E.db.sle.minimap.locPanel.portals.hsPrio)}
		local hsRealPrio = {}
		for key = 1, #hsPrio do hsRealPrio[hsPrio[key]] = key end
		for i = 1, #LP.Hearthstones do
			local data = LP.Hearthstones[i]
			local ID, isToy = data.secure.ID, data.secure.isToy
			isToy = (LP.db.portals.showToys and isToy)
			if not LP.db.portals.ignoreMissingInfo and ((isToy and PlayerHasToy(ID)) and C_ToyBox.IsToyUsable(ID) == nil) then return false end
			if (not isToy and (SLE:BagSearch(ID) and IsUsableItem(ID))) or (isToy and (PlayerHasToy(ID) and C_ToyBox.IsToyUsable(ID))) then
				if data.text then
					if not isToy then
						ShownHearthstone = data
						break
					else
						local curPriorirty = hsRealPrio[tostring(ID)]

						if curPriorirty and curPriorirty < priority then
							priority = curPriorirty
							ShownHearthstone = data
						end

						if priority == 1 then break end
					end
				end
			end
		end
		if ShownHearthstone then
			local data = ShownHearthstone
			-- local ID, isToy = data.secure.ID, data.secure.isToy  -- isToy isn't even used here
			local ID = data.secure.ID
			local cd = DD:GetCooldown('Item', ID)
			E:CopyTable(tmp, data)
			if cd or (tonumber(cd) and tonumber(cd) > 1.5) then
				tmp.text = '|cff636363'..tmp.text..'|r'..format(LP.CDformats[LP.db.portals.cdFormat], cd)
				tinsert(LP.MainMenu, tmp)
			else
				tinsert(LP.MainMenu, data)
			end
		end
	end

	for i = 1, #LP.PortItems do
		local tmp = {}
		local data = LP.PortItems[i]
		local ID, isToy = data.secure.ID, data.secure.isToy
		isToy = (LP.db.portals.showToys and isToy)
		if not LP.db.portals.ignoreMissingInfo and ((isToy and PlayerHasToy(ID)) and C_ToyBox.IsToyUsable(ID) == nil) then return false end
		if ((not isToy and (SLE:BagSearch(ID) and IsUsableItem(ID))) or (isToy and (PlayerHasToy(ID) and C_ToyBox.IsToyUsable(ID)))) then
			if data.text then
				local cd = DD:GetCooldown('Item', ID)
				E:CopyTable(tmp, data)
				if cd or (tonumber(cd) and tonumber(cd) > 2) then
					tmp.text = '|cff636363'..tmp.text..'|r'..format(LP.CDformats[LP.db.portals.cdFormat], cd)
					tinsert(LP.MainMenu, tmp)
				else
					tinsert(LP.MainMenu, data)
				end
			end
		end
	end

	if LP.db.portals.showEngineer and LP.isEngineer then
		tinsert(LP.MainMenu, {text = LP.EngineerName..':', title = true, nohighlight = true})
		for i = 1, #LP.EngineerItems do
			local tmp = {}
			local data = LP.EngineerItems[i]
			local ID, isToy = data.secure.ID, data.secure.isToy
			if not LP.db.portals.ignoreMissingInfo and ((isToy and PlayerHasToy(ID)) and C_ToyBox.IsToyUsable(ID) == nil) then return false end
			if (not isToy and (SLE:BagSearch(ID) and IsUsableItem(ID))) or (isToy and (PlayerHasToy(ID) and C_ToyBox.IsToyUsable(ID))) then
				if data.text then
					local cd = DD:GetCooldown('Item', ID)
					E:CopyTable(tmp, data)
					if cd or (tonumber(cd) and tonumber(cd) > 2) then
						tmp.text = '|cff636363'..tmp.text..'|r'..format(LP.CDformats[LP.db.portals.cdFormat], cd)
						tinsert(LP.MainMenu, tmp)
					else
						tinsert(LP.MainMenu, data)
					end

				end
			end
		end
	end

	return true
end

function LP:SpellList(list, dropdown, check)
	for i = 1, #list do
		local tmp = {}
		local data = list[i]
		if IsSpellKnown(data.secure.ID) then
			if check then
				return true
			else
				if data.text then
					local cd = DD:GetCooldown('Spell', data.secure.ID)
					if cd or (tonumber(cd) and tonumber(cd) > 1.5) then
						E:CopyTable(tmp, data)
						tmp.text = '|cff636363'..tmp.text..'|r'..format(LP.CDformats[LP.db.portals.cdFormat], cd)
						tinsert(dropdown, tmp)
					else
						tinsert(dropdown, data)
					end
				end
			end
		end
	end
end

function LP:PopulateDropdown(click)
	if LP.ListUpdating and click then
		SLE:Print(L["Update canceled."])
		LP.ListUpdating = false
		if LP.InfoUpdatingTimer then LP:CancelTimer(LP.InfoUpdatingTimer) end
		return
	end
	LP.InfoUpdatingTimer = nil
	if LP.Menu1:IsShown() then ToggleFrame(LP.Menu1) return end
	if LP.Menu2:IsShown() then ToggleFrame(LP.Menu2) return end
	local full_list = LP:ItemList()
	if not full_list then
		if not LP.ListUpdating then SLE:Print(L["Item info is not available. Waiting for it. This can take some time. Menu will be opened automatically when all info becomes available. Calling menu again during the update will cancel it."], "error"); LP.ListUpdating = true end
		if not LP.InfoUpdatingTimer then LP.InfoUpdatingTimer = LP:ScheduleTimer(LP.PopulateDropdown, 3) end
		wipe(LP.MainMenu)
		return
	end
	if LP.ListUpdating then LP.ListUpdating = false; SLE:Print(L["Update complete. Opening menu."]) end
	local anchor, point = GetDirection()
	local MENU_WIDTH

	if LP.db.portals.showSpells then
		if LP:SpellList(LP.Spells[E.myclass], nil, true) or LP:SpellList(LP.Spells.challenge, nil, true) or E.myclass == 'MAGE' or LP.Spells['racials'][E.myrace] then
			tinsert(LP.MainMenu, {text = SPELLS..':', title = true, nohighlight = true})
			LP:SpellList(LP.Spells[E.myclass], LP.MainMenu)
			if LP:SpellList(LP.Spells.challenge, nil, true) then
				tinsert(LP.MainMenu, {text = CHALLENGE_MODE..' >>',icon = SLE:GetIconFromID('achiev', 6378), func = function()
					wipe(LP.SecondaryMenu)
					MENU_WIDTH = LP.db.portals.customWidth and LP.db.portals.customWidthValue or _G.SLE_LocationPanel:GetWidth()
					tinsert(LP.SecondaryMenu, {text = '<< '..BACK, func = function() wipe(LP.MainMenu); ToggleFrame(LP.Menu2); LP:PopulateDropdown() end})
					tinsert(LP.SecondaryMenu, {text = CHALLENGE_MODE..':', title = true, nohighlight = true})
					LP:SpellList(LP.Spells.challenge, LP.SecondaryMenu)
					tinsert(LP.SecondaryMenu, {text = CLOSE, title = true, ending = true, func = function() wipe(LP.MainMenu); wipe(LP.SecondaryMenu); ToggleFrame(LP.Menu2) end})
					SLE:DropDown(LP.SecondaryMenu, LP.Menu2, anchor, point, 0, 1, _G.SLE_LocationPanel, MENU_WIDTH, LP.db.portals.justify)
				end})
			end
			if E.myclass == 'MAGE' then
				tinsert(LP.MainMenu, {text = L["Teleports"]..' >>', icon = SLE:GetIconFromID('spell', 53140), func = function()
					wipe(LP.SecondaryMenu)
					MENU_WIDTH = LP.db.portals.customWidth and LP.db.portals.customWidthValue or _G.SLE_LocationPanel:GetWidth()
					tinsert(LP.SecondaryMenu, {text = '<< '..BACK, func = function() wipe(LP.MainMenu); ToggleFrame(LP.Menu2); LP:PopulateDropdown() end})
					tinsert(LP.SecondaryMenu, {text = L["Teleports"]..':', title = true, nohighlight = true})
					LP:SpellList(LP.Spells['teleports'][E.myfaction], LP.SecondaryMenu)
					tinsert(LP.SecondaryMenu, {text = CLOSE, title = true, ending = true, func = function() wipe(LP.MainMenu); wipe(LP.SecondaryMenu); ToggleFrame(LP.Menu2) end})
					SLE:DropDown(LP.SecondaryMenu, LP.Menu2, anchor, point, 0, 1, _G.SLE_LocationPanel, MENU_WIDTH, LP.db.portals.justify)
				end})
				tinsert(LP.MainMenu, {text = L["Portals"]..' >>',icon = SLE:GetIconFromID('spell', 53142), func = function()
					wipe(LP.SecondaryMenu)
					MENU_WIDTH = LP.db.portals.customWidth and LP.db.portals.customWidthValue or _G.SLE_LocationPanel:GetWidth()
					tinsert(LP.SecondaryMenu, {text = '<< '..BACK, func = function() wipe(LP.MainMenu); ToggleFrame(LP.Menu2) LP:PopulateDropdown() end})
					tinsert(LP.SecondaryMenu, {text = L["Portals"]..':', title = true, nohighlight = true})
					LP:SpellList(LP.Spells['portals'][E.myfaction], LP.SecondaryMenu)
					tinsert(LP.SecondaryMenu, {text = CLOSE, title = true, ending = true, func = function() wipe(LP.MainMenu); wipe(LP.SecondaryMenu); ToggleFrame(LP.Menu2) end})
					SLE:DropDown(LP.SecondaryMenu, LP.Menu2, anchor, point, 0, 1, _G.SLE_LocationPanel, MENU_WIDTH, LP.db.portals.justify)
				end})
			end
			if LP.Spells['racials'][E.myrace] then
				LP:SpellList(LP.Spells['racials'][E.myrace], LP.MainMenu)
			end
		end
	end
	tinsert(LP.MainMenu, {text = CLOSE, title = true, ending = true, func = function() wipe(LP.MainMenu); wipe(LP.SecondaryMenu); ToggleFrame(LP.Menu1) end})
	MENU_WIDTH = LP.db.portals.customWidth and LP.db.portals.customWidthValue or _G.SLE_LocationPanel:GetWidth()
	SLE:DropDown(LP.MainMenu, LP.Menu1, anchor, point, 0, 1, _G.SLE_LocationPanel, MENU_WIDTH, LP.db.portals.justify)

	collectgarbage('collect')
end

function LP:GetProf()
	LP.EngineerName = GetSpellInfo(4036)
	LP:CHAT_MSG_SKILL()
end

function LP:CHAT_MSG_SKILL()
	local prof1, prof2 = GetProfessions()
	local name

	if prof1 then
		name = GetProfessionInfo(prof1)
		if name == LP.EngineerName then LP.isEngineer = true return end
	end
	if prof2 then
		name = GetProfessionInfo(prof2)
		if name == LP.EngineerName then LP.isEngineer = true return end
	end
end

function LP:PLAYER_REGEN_DISABLED()
	if LP.db.combathide then loc_panel:SetAlpha(0) end
end

function LP:PLAYER_REGEN_ENABLED()
	if LP.db.enable then loc_panel:SetAlpha(1) end
end

function LP:UNIT_AURA(_, unit)
	if unit ~= 'player' then return end
	if LP.db.enable and LP.db.orderhallhide then
		local inOrderHall = C_Garrison_IsPlayerInGarrison(Enum.GarrisonType.Type_7_0)
		if inOrderHall then
			loc_panel:SetAlpha(0)
		else
			loc_panel:SetAlpha(1)
		end
	end
end

function LP:Initialize()
	LP.db = E.db.sle.minimap.locPanel
	if not SLE.initialized then return end
	LP.elapsed = 0

	LP:PopulateItems()
	LP:GetProf()
	LP:CreateLocationPanel()
	LP:Template()
	LP:Fonts()
	LP:Toggle()

	function LP:ForUpdateAll()
		LP.db = E.db.sle.minimap.locPanel
		LP:Resize()
		LP:Template()
		LP:Fonts()
		LP:Toggle()
	end

	LP:RegisterEvent('PLAYER_REGEN_DISABLED')
	LP:RegisterEvent('PLAYER_REGEN_ENABLED')
	LP:RegisterEvent('UNIT_AURA')
	LP:RegisterEvent('CHAT_MSG_SKILL')

	LP:CreatePortalButtons()
end

SLE:RegisterModule(LP:GetName())
