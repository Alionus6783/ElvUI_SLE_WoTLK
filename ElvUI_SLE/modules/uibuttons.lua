﻿local E, L, V, P, G = unpack(ElvUI); 
local UB = E:GetModule('SLE_UIButtons');
local ACD = LibStub("AceConfigDialog-3.0")
local lib = LibStub("LibElv-UIButtons-1.0")
local SLE = E:GetModule("SLE")
local S = E:GetModule("Skins")

local function CustomRollCall()
	local min, max = tonumber(E.db.sle.uibuttons.customroll.min), tonumber(E.db.sle.uibuttons.customroll.max)
	if min <= max then
		RandomRoll(min, max)
	else
		SLE:Print(L["Custom roll limits are set incorrectly! Minimum should be smaller then or equial to maximum."])
	end
end

function UB:ClassicSetup(menu)
	local button

	button = menu.Config
	button:SetScript("OnClick", function(self)
		E:ToggleConfig()
	end)
	button:HookScript('OnEnter', function(self) OnEnter(self, menu) end)
	button:HookScript('OnLeave', function(self) OnLeave(self, menu) end)

	button = menu.Reload
	button:SetScript("OnClick", function(self)
		ReloadUI()
	end)
	button:HookScript('OnEnter', function(self) OnEnter(self, menu) end)
	button:HookScript('OnLeave', function(self) OnLeave(self, menu) end)

	button = menu.MoveUI
	button:SetScript("OnClick", function(self)
		E:ToggleConfigMode()
	end)
	button:HookScript('OnEnter', function(self) OnEnter(self, menu) end)
	button:HookScript('OnLeave', function(self) OnLeave(self, menu) end)

	button = menu.Boss
	button:SetScript("OnClick", function(self)
		if IsAddOnLoaded("DBM-Core") then
			DBM:LoadGUI()
		elseif IsAddOnLoaded("VEM-Core") then
			VEM:LoadGUI()
		end
	end)
	button:HookScript('OnEnter', function(self) OnEnter(self, menu) end)
	button:HookScript('OnLeave', function(self) OnLeave(self, menu) end)

	button = menu.Addon
	button:SetScript("OnClick", function(self)
		GameMenuButtonAddons:Click()
	end)
	button:HookScript('OnEnter', function(self) OnEnter(self, menu) end)
	button:HookScript('OnLeave', function(self) OnLeave(self, menu) end)
end

function UB:ConfigSetup(menu)
	--UB:CreateSeparator("Config", "SLE_StartSeparator", 1, 2)
	menu:CreateDropdownButton("Config", "Elv", "ElvUI", L["ElvUI Config"], L["Click to toggle config window"],  function() E:ToggleConfig() end, nil, true)
	menu:CreateDropdownButton("Config", "SLE", "S&L", L["S&L Config"], L["Click to toggle Shadow & Light config group"],  function() E:ToggleConfig(); ACD:SelectGroup("ElvUI", "sle", "options") end, nil, true)
	menu:CreateSeparator("Config", "First", 4, 2)
	menu:CreateDropdownButton( "Config", "Reload", "/reloadui", L["Reload UI"], L["Click to reload your interface"],  function() ReloadUI() end, nil, true)
	menu:CreateDropdownButton("Config", "MoveUI", "/moveui", L["Move UI"], L["Click to unlock moving ElvUI elements"],  function() E:ToggleConfigMode() end, nil, true)
	--UB:CreateSeparator("Config", "SLE_EndSeparator", 1, 2)
end

function UB:AddonSetup(menu)
	--UB:CreateSeparator("Addon", "SLE_StartSeparator", 1, 2)
	menu:CreateDropdownButton("Addon", "Manager", L["AddOns"], L["AddOns Manager"], L["Click to toggle the AddOn Manager frame."],  function() GameMenuButtonAddons:Click() end, nil, true)

	menu:CreateDropdownButton("Addon", "DBM", L["Boss Mod"], L["Boss Mod"], L["Click to toggle the Configuration/Option Window from the Bossmod you have enabled."], function() DBM:LoadGUI() end, "DBM-Core")
	menu:CreateDropdownButton("Addon", "VEM", L["Boss Mod"], L["Boss Mod"], L["Click to toggle the Configuration/Option Window from the Bossmod you have enabled."], function() VEM:LoadGUI() end, "VEM-Core")
	menu:CreateSeparator("Addon", "First", 4, 2)
	menu:CreateDropdownButton("Addon", "Altoholic", "Altoholic", nil, nil, function() Altoholic:ToggleUI() end, "Altoholic")
	menu:CreateDropdownButton("Addon", "AtlasLoot", "AtlasLoot", nil, nil, function() AtlasLoot.GUI:Toggle() end, "AtlasLoot")
	menu:CreateDropdownButton("Addon", "WeakAuras", "WeakAuras", nil, nil, function() SlashCmdList.WEAKAURAS() end, "WeakAuras")
	menu:CreateDropdownButton("Addon", "xCT", "xCT+", nil, nil, function() xCT_Plus:ToggleConfigTool() end, "xCT+")
	menu:CreateDropdownButton("Addon", "Swatter", "Swatter", nil, nil, function() Swatter.ErrorShow() end, "!Swatter")


	--Always keep at the bottom--
	menu:CreateDropdownButton("Addon", "WowLua", "WowLua", nil, nil, function() SlashCmdList["WOWLUA"]("") end, "WowLua", false)
	--UB:CreateSeparator("Addon", "SLE_EndSeparator", 1, 2)
end

function UB:StatusSetup(menu)
	menu:CreateDropdownButton("Status", "AFK", L["AFK"], nil, nil,  function() SendChatMessage("" ,"AFK" ) end)
	menu:CreateDropdownButton("Status", "DND", L["DND"], nil, nil,  function() SendChatMessage("" ,"DND" ) end)
end

function UB:RollSetup(menu)
	menu:CreateDropdownButton("Roll", "Ten", "1-10", nil, nil,  function() RandomRoll(1, 10) end)
	menu:CreateDropdownButton("Roll", "Twenty", "1-20", nil, nil,  function() RandomRoll(1, 20) end)
	menu:CreateDropdownButton("Roll", "Thirty", "1-30", nil, nil,  function() RandomRoll(1, 30) end)
	menu:CreateDropdownButton("Roll", "Forty", "1-40", nil, nil,  function() RandomRoll(1, 40) end)
	menu:CreateDropdownButton("Roll", "Hundred", "1-100", nil, nil,  function() RandomRoll(1, 100) end)
	menu:CreateDropdownButton("Roll", "Custom", L["Custom"], nil, nil,  function() CustomRollCall() end)
end

function UB:SetupBar(menu)
	if E.private.sle.uiButtonStyle == "classic" then
		menu:CreateCoreButton("Config", "C")
		menu:CreateCoreButton("Reload", "R")
		menu:CreateCoreButton("MoveUI", "M")
		menu:CreateCoreButton("Boss", "B")
		menu:CreateCoreButton("Addon", "A")
		UB:ClassicSetup(menu)
	else
		menu:CreateCoreButton("Config", "C")
		UB:ConfigSetup(menu)

		menu:CreateCoreButton("Addon", "A")
		UB:AddonSetup(menu)

		menu:CreateCoreButton("Status", "S")
		UB:StatusSetup(menu)

		menu:CreateCoreButton("Roll", "R")
		UB:RollSetup(menu)
	end
end

function UB:RightClicks(menu)
	for i = 1, #menu.ToggleTable do
		menu.ToggleTable[i]:RegisterForClicks("LeftButtonDown", "RightButtonDown")
	end
	menu.Config.Toggle:HookScript("OnClick", function(self, button, down)
		if button == "RightButton" and E.db.sle.uibuttons.Config.enable then
			menu.Config[menu.db.Config.called]:Click()
		end
	end)
	menu.Addon.Toggle:HookScript("OnClick", function(self, button, down)
		if button == "RightButton" and E.db.sle.uibuttons.Addon.enable then
			menu.Addon[menu.db.Addon.called]:Click()
		end
	end)
	menu.Status.Toggle:HookScript("OnClick", function(self, button, down)
		if button == "RightButton" and E.db.sle.uibuttons.Status.enable then
			menu.Status[menu.db.Status.called]:Click()
		end
	end)
	menu.Roll.Toggle:HookScript("OnClick", function(self, button, down)
		if button == "RightButton" and E.db.sle.uibuttons.Roll.enable then
			menu.Roll[menu.db.Roll.called]:Click()
		end
	end)
end

function UB:Initialize()
	UB.Holder = lib:CreateFrame("SLE_UIButtons", E.db.sle.uibuttons, P.sle.uibuttons, E.private.sle.uiButtonStyle, "dropdown")
	local menu = UB.Holder
	menu:SetupMover(L["S&L UI Buttons"], "ALL,S&L,S&L MISC,UIButtons")

	UB:SetupBar(menu)

	menu:FrameSize()
	menu:ToggleShow()

	UB.FrameSize = menu.FrameSize

	UB:RightClicks(menu)
end