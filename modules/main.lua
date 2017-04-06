-- kate: space-indent on; indent-width 2;
local modpath = '/mods/ui-festival'
local settings = import(modpath..'/modules/settings.lua')
local GameMain = import('/lua/ui/game/gamemain.lua')
local LayoutHelpers = import('/lua/maui/layouthelpers.lua')
local UIUtil = import('/lua/ui/uiutil.lua')

local orgPos = {}

PrimaryWorldViewRight = false

-- log function with prefix
_G.UifLog = function(a)
  if GetSettings().global.logEnabled then 
    LOG( "ui-festival: " .. a )
  end
end

function CreateUI()
--   ConExecute("cam_ZoomSpeedLarge = 32")
--   ConExecute("cam_ZoomSpeedSmall = 32")
  import(modpath..'/modules/settings.lua').init()
  import(modpath..'/modules/ui.lua').init()
  status, result = pcall(function ()
    local Borders = import('/lua/ui/game/borders.lua')
    ForkThread(function ()
      local timeout = 42
      while GetCurrentUIState() != "game" or import('/lua/ui/game/worldview.lua').IsInputLocked() or import('/lua/ui/game/gamemain.lua').gameUIHidden do
        WaitSeconds(0.1)
        timeout = timeout - 1
        if timeout == 0 then return end
      end
      if import('/lua/ui/game/gamemain.lua').IsNISMode() then
        UifLog( 'CreateUI NISMode Active')
        import('/lua/ui/game/gamemain.lua').preNISSettings.restoreSplitScreen = true
      else
        Borders.SplitMapGroup(true, false)
      end
    end)
  end)
  if not status then
    UifLog( "Error in CreateUI " .. result )
  end
end

function CreateLobby(protocol, localPort, desiredPlayerName, localPlayerUID, natTraversalProvider, over, exitBehavior, playerHasSupcom)
  local splitRatio = GetSplitRatio()
  if GetSetting("primaryRight") then
    import('/lua/ui/lobby/lobby.lua').GUI.Left:Set( function() return( GetFrame(0).Left() + GetFrame(0).Width() * splitRatio / 100 )end )
    import('/lua/ui/lobby/lobby.lua').GUI.Right:Set( GetFrame(0).Right )
  else
    import('/lua/ui/lobby/lobby.lua').GUI.Left:Set( GetFrame(0).Left )
    import('/lua/ui/lobby/lobby.lua').GUI.Right:Set( function() return( GetFrame(0).Left() + GetFrame(0).Width() * splitRatio / 100 )end )
  end
end

function OnFirstUpdate()
  if not Enabled() or not GetSetting("startSplitScreen") then 
    return
  end
  status, result = pcall(function ()
    ForkThread(function ()
      local timeout = 42
      while not import('/lua/ui/game/borders.lua').mapSplitState do
        WaitSeconds(0.1)
        timeout = timeout - 1
        if timeout == 0 then return end
      end
      WaitSeconds(1.2)
      ArrangeZoom()
    end)
  end)
  if not status then
    UifLog( "Error in OnFirstUpdate " .. result )
  end
end

function OnSettingsUpdate()
  status, result = pcall(function ()
    ArrangeUI()
    ArrangeZoom()
  end)
  if not status then
    UifLog( "Error in OnSettingsUpdate " .. result )
  end
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
    UifLog("Setting not found: " .. key)
    UifLog("Settings are: " .. repr(GetSettings()))
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

function SaveOriginalPositions()
  if orgPos.run then
    return
  end
  orgPos.mainMenuLeft = import('/lua/ui/game/tabs.lua').controls.parent.Left()
  orgPos.mainMenuCollapseArrowTop = import('/lua/ui/game/tabs.lua').controls.collapseArrow.Top()
  orgPos.economyCollapseArrowTop = import('/lua/ui/game/economy.lua').GUI.collapseArrow.Top()
  orgPos.multifunctionCollapseArrowTop = import('/lua/ui/game/multifunction.lua').controls.collapseArrow.Top()
  orgPos.avatarsCollapseArrowTop = import('/lua/ui/game/avatars.lua').controls.collapseArrow.Top()
  orgPos.controlgroupsCollapseArrowTop = import('/lua/ui/game/controlgroups.lua').controls.collapseArrow.Top()
  orgPos.run = true
end

function ArrangeUI()
  if not import('/lua/ui/game/borders.lua').controls.mapGroupRight or not import('/lua/ui/game/borders.lua').controls.mapGroupLeft then
    return
  end

  UifLog( "ArrangeUI()" )

  SaveOriginalPositions()
  
  local mapGroupLeft
  local mapGroupRight
  mapGroupLeft = import('/lua/ui/game/borders.lua').controls.mapGroupLeft
  mapGroupRight = import('/lua/ui/game/borders.lua').controls.mapGroupRight

  -- apply top/bottom adjustments
  mapGroupLeft.Top:Set(function() return ( GetFrame(0).Height() * GetSetting("leftOffsetTop") / 100 ) end)
  mapGroupLeft.Bottom:Set(function() return ( GetFrame(0).Height() * ( 100 - GetSetting("leftOffsetBottom") ) / 100 ) end)
  mapGroupRight.Top:Set(function() return ( GetFrame(0).Height() * GetSetting("rightOffsetTop") / 100 ) end)
  mapGroupRight.Bottom:Set(function() return ( GetFrame(0).Height() * ( 100 - GetSetting("rightOffsetBottom") ) / 100 ) end)
  
  local splitRatio = GetSplitRatio()

  -- apply split screen ratio
  mapGroupLeft.Right:Set( GetFrame(0).Width() * splitRatio / 100 )
  mapGroupRight.Left:Set( GetFrame(0).Width() * splitRatio / 100 )
  if GetSetting("primaryRight") then
    import('/lua/ui/game/borders.lua').controls.mapGroup.Left:Set(mapGroupRight.Left)
    import('/lua/ui/game/borders.lua').controls.mapGroup.Right:Set(mapGroupRight.Right)
    import('/lua/ui/game/borders.lua').controls.mapGroup.Top:Set(mapGroupRight.Top)
    import('/lua/ui/game/borders.lua').controls.mapGroup.Bottom:Set(mapGroupRight.Bottom)
  else
    import('/lua/ui/game/borders.lua').controls.mapGroup.Left:Set(mapGroupLeft.Left)
    import('/lua/ui/game/borders.lua').controls.mapGroup.Right:Set(mapGroupLeft.Right)
    import('/lua/ui/game/borders.lua').controls.mapGroup.Top:Set(mapGroupLeft.Top)
    import('/lua/ui/game/borders.lua').controls.mapGroup.Bottom:Set(mapGroupLeft.Bottom)
  end

  if GetSetting("mainMenuPos") == 1 then
    import('/lua/ui/game/tabs.lua').controls.parent.Top:Set(mapGroupLeft.Top)
    import('/lua/ui/game/tabs.lua').controls.parent.Left:Set(function() return ( GetFrame(0).Width() * splitRatio / 100 / 2 ) end)
    import('/lua/ui/game/tabs.lua').controls.collapseArrow.Top:Set( function() return ( mapGroupLeft.Top() + orgPos.mainMenuCollapseArrowTop ) end )
  elseif GetSetting("mainMenuPos") == 2 then 
    import('/lua/ui/game/tabs.lua').controls.parent.Top:Set(mapGroupRight.Top)
    import('/lua/ui/game/tabs.lua').controls.parent.Left:Set(function() return ( GetFrame(0).Width() * ( 100 - splitRatio ) / 100 / 2 + GetFrame(0).Width() * splitRatio / 100 ) end)
    import('/lua/ui/game/tabs.lua').controls.collapseArrow.Top:Set( function() return ( mapGroupRight.Top() + orgPos.mainMenuCollapseArrowTop ) end )
  end

  local MagicOffset = 14

  if import('/lua/ui/game/economy.lua') and import('/lua/ui/game/economy.lua').GUI.bg and import('/lua/ui/game/economy.lua').GUI.collapseArrow then
    if GetSetting("statusControlPos") == 1 then 
      import('/lua/ui/game/economy.lua').savedParent = mapGroupLeft
      import('/lua/ui/game/economy.lua').SetLayout()
      import('/lua/ui/game/economy.lua').GUI.bg:SetParent( mapGroupLeft )
      -- stop animation (if any)
      import('/lua/ui/game/economy.lua').GUI.bg.OnFrame = function(self, delta) self:SetNeedsFrameUpdate(false); end
      import('/lua/ui/game/economy.lua').GUI.bg.Left:Set( MagicOffset )
      import('/lua/ui/game/economy.lua').GUI.collapseArrow:SetParent( mapGroupLeft )
      import('/lua/ui/game/economy.lua').GUI.collapseArrow.Left:Set( mapGroupLeft.Left )
      import('/lua/ui/game/economy.lua').GUI.collapseArrow.Top:Set( function() return ( mapGroupLeft.Top() + orgPos.economyCollapseArrowTop ) end )
    elseif GetSetting("statusControlPos") == 2 then 
      import('/lua/ui/game/economy.lua').savedParent = mapGroupRight
      import('/lua/ui/game/economy.lua').SetLayout()
      import('/lua/ui/game/economy.lua').GUI.bg:SetParent( mapGroupRight )
      -- stop animation (if any)
      import('/lua/ui/game/economy.lua').GUI.bg.OnFrame = function(self, delta) self:SetNeedsFrameUpdate(false); end
      import('/lua/ui/game/economy.lua').GUI.bg.Left:Set( function() return mapGroupRight.Left() + MagicOffset end )
      import('/lua/ui/game/economy.lua').GUI.collapseArrow:SetParent( mapGroupRight )
      import('/lua/ui/game/economy.lua').GUI.collapseArrow.Left:Set( mapGroupRight.Left )
      import('/lua/ui/game/economy.lua').GUI.collapseArrow.Top:Set( function() return ( mapGroupRight.Top() + orgPos.economyCollapseArrowTop ) end )
    end
  end

  -- TODO FIXME create own settings for unitviewDetail.lua and unitview.lua
  if GetSetting("controlClusterGroupPos") == 1 then 
    import('/lua/ui/game/unitviewDetail.lua').View:SetParent( mapGroupLeft )
    import('/lua/ui/game/unitviewDetail.lua').SetLayout()
    import('/lua/ui/game/unitview.lua').controls.parent = mapGroupLeft
    import('/lua/ui/game/unitview.lua').SetLayout()
    import('/lua/ui/game/multifunction.lua').savedParent = mapGroupLeft
    import('/lua/ui/game/multifunction.lua').SetLayout()
--     import('/lua/ui/game/borders.lua').controls.controlClusterGroup.Top:Set( mapGroupLeft.Top )
    import('/lua/ui/game/borders.lua').controls.controlClusterGroup.Left:Set( mapGroupLeft.Left )
    import('/lua/ui/game/borders.lua').controls.controlClusterGroup.Right:Set( mapGroupLeft.Right )
    import('/lua/ui/game/borders.lua').controls.controlClusterGroup.Bottom:Set( mapGroupLeft.Bottom )
    import('/lua/ui/game/multifunction.lua').controls.collapseArrow.Left:Set( mapGroupLeft.Left )
    import('/lua/ui/game/multifunction.lua').controls.collapseArrow.Top:Set( function() return ( mapGroupLeft.Top() + orgPos.multifunctionCollapseArrowTop ) end )
  elseif GetSetting("controlClusterGroupPos") == 2 then
    import('/lua/ui/game/unitviewDetail.lua').View:SetParent( mapGroupRight )
    import('/lua/ui/game/unitviewDetail.lua').SetLayout()
    import('/lua/ui/game/unitview.lua').controls.parent = mapGroupRight
    import('/lua/ui/game/unitview.lua').SetLayout()
    import('/lua/ui/game/multifunction.lua').savedParent = mapGroupRight
    import('/lua/ui/game/multifunction.lua').SetLayout()
--     import('/lua/ui/game/borders.lua').controls.controlClusterGroup.Top:Set( mapGroupRight.Top )
    import('/lua/ui/game/borders.lua').controls.controlClusterGroup.Left:Set( mapGroupRight.Left )
    import('/lua/ui/game/borders.lua').controls.controlClusterGroup.Right:Set( mapGroupRight.Right )
    import('/lua/ui/game/borders.lua').controls.controlClusterGroup.Bottom:Set( mapGroupRight.Bottom )
    import('/lua/ui/game/multifunction.lua').controls.collapseArrow.Left:Set( mapGroupRight.Left )
    import('/lua/ui/game/multifunction.lua').controls.collapseArrow.Top:Set( function() return ( mapGroupRight.Top() + orgPos.multifunctionCollapseArrowTop ) end )
  end

  if import('/lua/ui/game/score.lua').savedParent then
    if GetSetting("scorePos") == 1 then 
      import('/lua/ui/game/score.lua').savedParent = mapGroupLeft
      import('/lua/ui/game/score.lua').SetLayout()
    elseif GetSetting("scorePos") == 2 then
      import('/lua/ui/game/score.lua').savedParent = mapGroupRight
      import('/lua/ui/game/score.lua').SetLayout()
    end
  -- TODO FIXME create own setting for that:
  elseif import('/lua/ui/campaign/campaignmanager.lua').campaignMode then
    if GetSetting("scorePos") == 1 then 
      import('/lua/ui/game/objectives2.lua').controls.parent = mapGroupLeft
      import('/lua/ui/game/objectives2.lua').SetLayout()
    elseif GetSetting("scorePos") == 2 then
      import('/lua/ui/game/objectives2.lua').controls.parent = mapGroupRight
      import('/lua/ui/game/objectives2.lua').SetLayout()
    end
  end
  
  if import('/lua/ui/game/avatars.lua').controls then
    if GetSetting("avatarsPos") == 1 then 
      import('/lua/ui/game/avatars.lua').controls.parent = mapGroupLeft
      import('/lua/ui/game/avatars.lua').controls.avatarGroup.Right:Set( function() return mapGroupLeft.Right() - MagicOffset end )
      import('/lua/ui/game/avatars.lua').controls.collapseArrow.Right:Set( mapGroupLeft.Right )
      import('/lua/ui/game/avatars.lua').controls.collapseArrow.Top:Set( function() return ( mapGroupLeft.Top() + orgPos.avatarsCollapseArrowTop ) end )
    elseif GetSetting("avatarsPos") == 2 then
      import('/lua/ui/game/avatars.lua').controls.parent = mapGroupRight
      import('/lua/ui/game/avatars.lua').controls.avatarGroup.Right:Set( function() return mapGroupRight.Right() - MagicOffset end )
      import('/lua/ui/game/avatars.lua').controls.collapseArrow.Right:Set( mapGroupRight.Right )
      import('/lua/ui/game/avatars.lua').controls.collapseArrow.Top:Set( function() return ( mapGroupRight.Top() + orgPos.avatarsCollapseArrowTop ) end )
    end
  end
  
  if import('/lua/ui/game/controlgroups.lua').controls then
    if GetSetting("controlGroupsPos") == 1 then
      import('/lua/ui/game/controlgroups.lua').controls.parent = mapGroupLeft
      import('/lua/ui/game/controlgroups.lua').controls.container.Right:Set( function() return mapGroupLeft.Right() - MagicOffset end )
      import('/lua/ui/game/controlgroups.lua').controls.collapseArrow.Right:Set( mapGroupLeft.Right )
      import('/lua/ui/game/controlgroups.lua').controls.collapseArrow.Top:Set( function() return ( mapGroupLeft.Top() + orgPos.controlgroupsCollapseArrowTop ) end )
    elseif GetSetting("controlGroupsPos") == 2 then
      import('/lua/ui/game/controlgroups.lua').controls.parent = mapGroupRight
      import('/lua/ui/game/controlgroups.lua').controls.container.Right:Set( function() return mapGroupRight.Right() - MagicOffset end )
      import('/lua/ui/game/controlgroups.lua').controls.collapseArrow.Right:Set( mapGroupRight.Right )
      import('/lua/ui/game/controlgroups.lua').controls.collapseArrow.Top:Set( function() return ( mapGroupRight.Top() + orgPos.controlgroupsCollapseArrowTop ) end )
    end
  end
 
end

function ArrangeZoom()
  if not GetSetting('initialZoomOverride') or not import('/lua/ui/game/borders.lua').mapSplitState then
    return
  end

  UifLog( "ArrangeZoom()" )
  
  local primaryZoomFactor = (101-GetSetting('primaryInitialZoomPercentage'))/100
  local secondaryZoomFactor = (101-GetSetting('secondaryInitialZoomPercentage'))/100
  
  local cam1 = GetCamera("WorldCamera")
  if GetSetting("primaryRelativeToMaxZoom") then
    cam1:SetZoom(cam1:GetMaxZoom()*primaryZoomFactor,0)
  else
    cam1:SetZoom(1000*primaryZoomFactor,0)
  end
  cam1:RevertRotation()

  local cam2 = GetCamera("WorldCamera2")
  if GetSetting("secondaryRelativeToMaxZoom") then
    cam2:SetZoom(cam2:GetMaxZoom()*secondaryZoomFactor,0)
  else
    cam2:SetZoom(1000*secondaryZoomFactor,0)
  end
  cam2:RevertRotation()


end
