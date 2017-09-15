-- kate: space-indent off; indent-width 4;
local modpath = '/mods/ui-festival'
local Prefs = import('/lua/user/prefs.lua')
local ThisModsPrefsSectionIdentifier = "UI-Festival Settings"
local savedPrefs = Prefs.GetFromCurrentProfile(ThisModsPrefsSectionIdentifier)
local settingDescriptions
local UIUtil = import('/lua/ui/uiutil.lua')
local SettingsUi = import(modpath..'/modules/settingsUi.lua')

function getSettingDescriptions()
	return settingDescriptions
end

function init()
	-- help settings ui quering settings model
	import(modpath..'/modules/linq.lua')

	-- settings
	if not savedPrefs then
		savedPrefs = {}
	end
	
	settingDescriptions = {
		{ name = "Split Screen", settings = {
			{ key="startSplitScreen", type="bool", default=true, name="Start Split Screen", description="The game starts in split screen mode.\n(restart required)" },
			{ key="splitRatio", type="number", default=50, name="Split Percentage", description="Split Percentage", min=2000, max=8000, valMult=0.01 },
			{ key="mainMenuPos", type="number", default=1, name="Main menu position", description="Main menu position\n1=left,2=right", min=1, max=2, valMult=1  },
			{ key="statusControlPos", type="number", default=1, name="Economy panel position", description="Economy panel position\n1=left,2=right", min=1, max=2, valMult=1  },
			{ key="controlClusterGroupPos", type="number", default=1, name="Control panel positions", description="Control panel positions\n1=left,2=right", min=1, max=2, valMult=1  },
			{ key="scorePos", type="number", default=2, name="Score board position", description="Score board position\n1=left,2=right", min=1, max=2, valMult=1  },
			{ key="avatarsPos", type="number", default=2, name="Avatars panel position", description="Avatars (idle engies pane) panel position\n1=left,2=right", min=1, max=2, valMult=1  },
			{ key="controlGroupsPos", type="number", default=2, name="Control groups panel position", description="Control groups panel position\n1=left,2=right", min=1, max=2, valMult=1  },
			{ key="primaryRight", type="bool", default=false, name="Make right screen primary", description="Primary screen zooms in. Secondary screen zooms out.\n(restart required)" },
			{ key="initialZoomOverride", type="bool", default=false, name="Activate initial zoom override", description="Activate initial zoom override" },
			{ key="primaryInitialZoomPercentage", type="number", default=92.00, name="Primary initial zoom percent", description="Initial zoom percent of primary screen", min=1, max=10000, valMult=0.01  },
			{ key="primaryRelativeToMaxZoom", type="bool", default=false, name="Primary initial zoom percent relative to map size", description="Make Primary initial zoom percent relative to map size" },
			{ key="secondaryInitialZoomPercentage", type="number", default=20.00, name="Secondary initial zoom percent", description="Initial zoom percent of secondary screen", min=1, max=10000, valMult=0.01  },
			{ key="secondaryRelativeToMaxZoom", type="bool", default=true, name="Secondary initial zoom percent relative to map size", description="Make Primary initial zoom percent relative to map size" },
			{ key="leftOffsetTop", type="number", default=0.00, name="Top offset for left screen in percent", description="Top offset for left screen in percent", min=0, max=4000, valMult=0.01  },
			{ key="leftOffsetBottom", type="number", default=0.00, name="Bottom offset for left screen in percent", description="Bottom offset for left screen in percent", min=0, max=4000, valMult=0.01  },
			{ key="rightOffsetTop", type="number", default=0.00, name="Top offset for right screen in percent", description="Top offset for right screen in percent", min=0, max=4000, valMult=0.01  },
			{ key="rightOffsetBottom", type="number", default=0.00, name="Bottom offset for right screen in percent", description="Bottom offset for right screen in percent", min=0, max=4000, valMult=0.01  },
		}},
		{ name = "Mod", settings = {
			{ key="modEnabled", type="bool", default=true, name="Mod Enabled", description="Turns off the entire mod.\n(restart required)" },
			{ key="logEnabled", type="bool", default=false, name="Mod Log Enabled", description="For diagnostic purposes"  },

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
				UifLog("setting default " .. sv.key)
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
			UifLog("removing old key " .. gk)
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

