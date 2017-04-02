-- kate: space-indent off; indent-width 4;
local modpath = '/mods/ui-festival'
local settings = import(modpath..'/modules/settings.lua')
local GameMain = import('/lua/ui/game/gamemain.lua')

local originalMainMenuLeft

WorldViewPrimaryIsRight = false

-- log function with prefix
_G.UipLog = function(a)
	if GetSettings().global.logEnabled then 
		LOG("ui-festival:", a)
	end
end

function CreateUI(isReplay)
	import(modpath..'/modules/settings.lua').init()
	import(modpath..'/modules/ui.lua').init()
	originalMainMenuLeft = import('/lua/ui/game/tabs.lua').controls.parent.Left.compute()
	if Enabled() then 
		ForkThread(FinishCreateUI,isReplay)
	end
end

function FinishCreateUI(isReplay)
	ArrangeSplit()
	ArrangeUI()
	WaitSeconds(1.2)
	ArrangeZoom()
end

function UpdateUIAfterSave()
	ArrangeSplit()
	ArrangeUI()
	ArrangeZoom()
end

function ToggleEnabled()
	GetSettings().global.modEnabled = not GetSettings().global.modEnabled
end

function GetSettings()
	return settings.getPreferences()
end

function GetSetting(key)
	local val = GetSettings().global[key]
	if val == nil then
		UipLog("Setting not found: " .. key)
		UipLog("Settings are: " .. repr(GetSettings()))
	end
	return  val
end

function Enabled()
	return GetSettings().global.modEnabled
end

function GetSplitRatio()
	local splitRatio = GetSetting("splitRatio")
	if splitRatio > 80 then 
		splitRatio = 80
	elseif splitRatio < 20 then
		splitRatio = 20
	end
	return splitRatio
end

function ArrangeUI()
	if not import('/lua/ui/game/worldview.lua').viewRight then
		return
	end

	-- TODO FIXME remove this left is right hack, if all mods use "primary" instead of left
	local viewLeft
	local viewRight
	if WorldViewPrimaryIsRight then 
		viewLeft = import('/lua/ui/game/worldview.lua').viewRight
		viewRight = import('/lua/ui/game/worldview.lua').viewLeft
	else
		viewLeft = import('/lua/ui/game/worldview.lua').viewLeft
		viewRight = import('/lua/ui/game/worldview.lua').viewRight
	end

	local splitRatio = GetSplitRatio()

	local tabs = import('/lua/ui/game/tabs.lua')
	local mainMenuGroup = tabs.controls.parent

	if GetSetting("mainMenuPos") == 1 then 
		mainMenuGroup.Left:Set(function() return ( GetFrame(0).Width() * splitRatio / 100 / 2 ) end)
	elseif GetSetting("mainMenuPos") == 2 then
		mainMenuGroup.Left:Set( originalMainMenuLeft )
	elseif GetSetting("mainMenuPos") == 3 then 
		mainMenuGroup.Left:Set(function() return ( GetFrame(0).Width() * ( 100 - splitRatio ) / 100 / 2 + GetFrame(0).Width() * splitRatio / 100 ) end)
	end

	local borders = import('/lua/ui/game/borders.lua')
	local MagicOffset = 14

	if GetSetting("statusControlPos") == 1 then 
		import('/lua/ui/game/economy.lua').savedParent = viewLeft
		import('/lua/ui/game/economy.lua').GUI.bg.Left:Set( MagicOffset )
		import('/lua/ui/game/economy.lua').GUI.collapseArrow.Left:Set( 0 )
	elseif GetSetting("statusControlPos") == 2 then 
		import('/lua/ui/game/economy.lua').savedParent = viewRight
		import('/lua/ui/game/economy.lua').GUI.bg.Left:Set( function() return  viewRight.Left() + MagicOffset end )
		import('/lua/ui/game/economy.lua').GUI.collapseArrow.Left:Set( viewRight.Left )
	end

	if GetSetting("controlClusterGroupPos") == 1 then 
		import('/lua/ui/game/unitviewDetail.lua').View:SetParent( viewLeft )
		import('/lua/ui/game/unitviewDetail.lua').SetLayout()
		import('/lua/ui/game/multifunction.lua').savedParent = viewLeft
		borders.controls.controlClusterGroup.Left:Set( 0 )
		borders.controls.controlClusterGroup.Right:Set( viewLeft.Right )
		import('/lua/ui/game/multifunction.lua').controls.bg.Left:Set( MagicOffset )
		import('/lua/ui/game/multifunction.lua').controls.collapseArrow.Left:Set( 0 )
	elseif GetSetting("controlClusterGroupPos") == 2 then
		import('/lua/ui/game/unitviewDetail.lua').View:SetParent( GameFrame(0) )
		import('/lua/ui/game/unitviewDetail.lua').SetLayout()
		import('/lua/ui/game/multifunction.lua').savedParent = GameFrame(0)
		borders.controls.controlClusterGroup.Left:Set( 0 )
		borders.controls.controlClusterGroup.Right:Set( viewRight.Right )
		import('/lua/ui/game/multifunction.lua').controls.bg.Left:Set( MagicOffset )
		import('/lua/ui/game/multifunction.lua').controls.collapseArrow.Left:Set( 0 )
	elseif GetSetting("controlClusterGroupPos") == 3 then
		import('/lua/ui/game/unitviewDetail.lua').View:SetParent( viewRight )
		import('/lua/ui/game/unitviewDetail.lua').SetLayout()
		import('/lua/ui/game/multifunction.lua').savedParent = viewRight
		borders.controls.controlClusterGroup.Left:Set( viewRight.Left )
		borders.controls.controlClusterGroup.Right:Set( viewRight.Right )
		import('/lua/ui/game/multifunction.lua').controls.bg.Left:Set( function() return viewRight.Left() + MagicOffset end )
		import('/lua/ui/game/multifunction.lua').controls.collapseArrow.Left:Set( viewRight.Left )
	end

	if GetSetting("scorePos") == 1 then 
		import('/lua/ui/game/score.lua').savedParent = viewLeft
		import('/lua/ui/game/score.lua').controls.bg.Right:Set( function() return viewLeft.Right() - MagicOffset end )
		import('/lua/ui/game/score.lua').controls.collapseArrow.Right:Set( viewLeft.Right )
	elseif GetSetting("scorePos") == 2 then
		import('/lua/ui/game/score.lua').savedParent = viewRight
		import('/lua/ui/game/score.lua').controls.bg.Right:Set( function() return viewRight.Right() - MagicOffset end )
		import('/lua/ui/game/score.lua').controls.collapseArrow.Right:Set( viewRight.Right )
	end

	if GetSetting("avatarsPos") == 1 then 
		import('/lua/ui/game/avatars.lua').controls.parent = viewLeft
		import('/lua/ui/game/avatars.lua').controls.avatarGroup.Right:Set( function() return viewLeft.Right() - MagicOffset end )
		import('/lua/ui/game/avatars.lua').controls.collapseArrow.Right:Set( viewLeft.Right )
	elseif GetSetting("avatarsPos") == 2 then
		import('/lua/ui/game/avatars.lua').controls.parent = viewRight
		import('/lua/ui/game/avatars.lua').controls.avatarGroup.Right:Set( function() return viewRight.Right() - MagicOffset end )
		import('/lua/ui/game/avatars.lua').controls.collapseArrow.Right:Set( viewRight.Right )
	end

	if GetSetting("controlGroupsPos") == 1 then
		import('/lua/ui/game/controlgroups.lua').controls.parent = viewLeft
		import('/lua/ui/game/controlgroups.lua').controls.container.Right:Set( function() return viewLeft.Right() - MagicOffset end )
		import('/lua/ui/game/controlgroups.lua').controls.collapseArrow.Right:Set( viewLeft.Right )
	elseif GetSetting("controlGroupsPos") == 2 then
		import('/lua/ui/game/controlgroups.lua').controls.parent = viewRight
		import('/lua/ui/game/controlgroups.lua').controls.container.Right:Set( function() return viewRight.Right() - MagicOffset end )
		import('/lua/ui/game/controlgroups.lua').controls.collapseArrow.Right:Set( viewRight.Right )
	end
end

function ArrangeSplit()
	if not import('/lua/ui/game/worldview.lua').viewRight then
		return
	end

	-- TODO FIXME remove this left is right hack, if all mods use "primary" instead of left
	local viewLeft
	local viewRight
	if WorldViewPrimaryIsRight then 
		viewLeft = import('/lua/ui/game/worldview.lua').viewRight
		viewRight = import('/lua/ui/game/worldview.lua').viewLeft
	else
		viewLeft = import('/lua/ui/game/worldview.lua').viewLeft
		viewRight = import('/lua/ui/game/worldview.lua').viewRight
	end

	-- apply split screen ratio
	if import('/lua/ui/game/worldview.lua').viewRight then
		local splitRatio = GetSplitRatio()
		viewLeft.Right:Set( GetFrame(0).Width() * splitRatio / 100 )
		viewRight.Left:Set( GetFrame(0).Width() * splitRatio / 100 )
	end
end

function ArrangeZoom()
	if not GetSetting('initialZoomOverride') then
		return
	end
    
	local cam1 = GetCamera("WorldCamera")
	cam1:SetZoom(cam1:GetMaxZoom()*(101-GetSetting('primaryInitialZoomPercentage'))/100,0)
	cam1:RevertRotation()

	if not import('/lua/ui/game/worldview.lua').viewRight then
		return
	end
	local cam2 = GetCamera("WorldCamera2")
	cam2:SetZoom(cam2:GetMaxZoom()*(101-GetSetting('secondaryInitialZoomPercentage'))/100,0)
	cam2:RevertRotation()
end
