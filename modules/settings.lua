-- kate: space-indent off; indent-width 4;
local Prefs = import('/lua/user/prefs.lua')
local ThisModsPrefsSectionIdentifier = "UI-Festival Settings"
local savedPrefs = Prefs.GetFromCurrentProfile(ThisModsPrefsSectionIdentifier)
local settingDescriptions
local UIUtil = import('/lua/ui/uiutil.lua')
local SettingsUi = import('/mods/UI-Party/modules/settingsUi.lua')

function getSettingDescriptions()
	return settingDescriptions
end

function init()
	-- help settings ui quering settings model
	import('/mods/UI-Party/modules/linq.lua')

	-- settings
	if not savedPrefs then
		savedPrefs = {}
	end
	
	settingDescriptions = {
		{ name = "Split Screen", settings = {
			{ key="startSplitScreen", type="bool", default=true, name="Start Split Screen", description="The game starts in split screen mode.\n(restart required)" },
			{ key="splitRatio", type="number", default=50, name="Split Percentage", description="Split Percentage", min=20, max=80, valMult=1 },
			{ key="mainMenuPos", type="number", default=2, name="Main menu position", description="Main menu position\n1=left,2=middle,3=right", min=1, max=3, valMult=1  },
			{ key="controlClusterGroupPos", type="number", default=2, name="Control panel positions", description="Control panel positions\n1=left,2=middle,3=right\n(restart required)", min=1, max=3, valMult=1  },
			{ key="statusControlPos", type="number", default=1, name="Economy panel position", description="Economy panel position\n1=left,2=right\n(restart required)", min=1, max=2, valMult=1  },
			{ key="scorePos", type="number", default=2, name="Score board position", description="Score board position\n1=left,2=right", min=1, max=2, valMult=1  },
			{ key="avatarsPos", type="number", default=2, name="Avatars panel position", description="Avatars (idle engies pane) panel position\n1=left,2=right\n(restart required)", min=1, max=2, valMult=1  },
			{ key="controlGroupsPos", type="number", default=2, name="Control groups panel position", description="Control groups panel position\n1=left,2=right\n(restart required)", min=1, max=2, valMult=1  },
			{ key="primaryRight", type="bool", default=false, name="Make Right Screen Primary", description="Primary screen zooms in. Secondary screen zooms out.\n(restart required)" },
			{ key="initialZoomOverride", type="bool", default=false, name="Activate Initial Zoom Override", description="Activate Initial Zoom Override\n(restart required)" },
			{ key="primaryInitialZoomPercentage", type="number", default=95, name="Primary Initial Zoom Percent", description="Initial Zoom Percent of Primary Screen\n(restart required)", min=1, max=100, valMult=1  },
			{ key="secondaryInitialZoomPercentage", type="number", default=20, name="Secondary Initial Zoom Percent", description="Initial Zoom Percent of Secondary Screen\n(restart required)", min=1, max=100, valMult=1  },
		}},
		{ name = "Mod", settings = {
			{ key="modEnabled", type="bool", default=true, name="Mod Enabled", description="Turns off the entire mod.\n(restart required)" },
			{ key="logEnabled", type="bool", default=false, name="Mod Log Enabled", description="For diagnostic purposes", min=0, max=10, valMult=0.01  },

		}},	
		{ name = "Hidden", settings = {
			{ key="xOffset", default=345 },
			{ key="yOffset", default=50 },
		}},
		
		
	} 

	local tooltips = import('/lua/ui/help/tooltips.lua').Tooltips

	if not savedPrefs.global then
		savedPrefs.global = {}
	end
	
	local keys = from({})
	from(settingDescriptions).foreach(function(gk, kv) 
		from(kv.settings).foreach(function(sk, sv) 
	
			-- make defaults
			keys.addValue(sv.key)
			if savedPrefs.global[sv.key] == nil then
				UipLog("setting default " .. sv.key)
				savedPrefs.global[sv.key] = sv.default
			end
			
			-- add tooltips
			tooltips["UIP_"..sv.key] = {
				title = sv.name,
				description = sv.description,
				keyID = "UIP_"..sv.key,
			}
		end)
	end)

	-- clear old stuff
	local g = from(savedPrefs.global)
	g.foreach(function(gk, gv)
		if not keys.contains(gk) then
			UipLog("removing old key " .. gk)
			g.removeKey(gk)
		end
	end)

	-- correct x/y if outside the window
	if (savedPrefs.global.xOffset < 0 or savedPrefs.global.xOffset > GetFrame(0).Width()) then
		savedPrefs.global.xOffset = GetFrame(0).Width()/2
	end
	if (savedPrefs.global.yOffset < 0 or savedPrefs.global.yOffset > GetFrame(0).Height()) then
		savedPrefs.global.yOffset = GetFrame(0).Height()/2
	end
	
	savePreferences()
end

function savePreferences()
	Prefs.SetToCurrentProfile(ThisModsPrefsSectionIdentifier, savedPrefs)
	Prefs.SavePreferences()
end

function getPreferences()
	return savedPrefs
end

function setAllGlobalValues(t)
	for id, value in t do
		savedPrefs.global[id] = value
	end
	savePreferences()
end

function setXYvalues(posX, posY)
	savedPrefs.global.xOffset = posX
	savedPrefs.global.yOffset = posY
	savePreferences()
end

