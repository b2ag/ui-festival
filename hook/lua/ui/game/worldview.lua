-- kate: space-indent on; indent-width 2;
local modpath = '/mods/ui-festival'
local UIP = import(modpath..'/modules/main.lua')

local baseCreateMainWorldView = CreateMainWorldView
function CreateMainWorldView(parent, mapGroup, mapGroupRight)
  UIP.PrimaryWorldViewRight = false
  UipLog( 'CreateMainWorldView hook called with parent='..(parent and 'something' or 'nil')..' mapGroup='..(mapGroup and 'something' or 'nil')..' mapGroupRight='..(mapGroupRight and 'something' or 'nil') )

  if not UIP.Enabled() or not UIP.GetSetting("primaryRight") or not mapGroupRight then 
    baseCreateMainWorldView( parent, mapGroup, mapGroupRight )
    return
  end

  if viewLeft then    
    viewLeft:Destroy()
    viewLeft = false  
  end
  if viewRight then
    viewRight:Destroy()
    viewRight = false
  end
  if view then
    view:Destroy()
    view = false
  end
  
  parentForFrame = parent
  viewRight = import('/lua/ui/controls/worldview.lua').WorldView(mapGroup, 'WorldCamera2', 1, false) -- depth value should be below minimap
  viewRight:Register('WorldCamera2', nil, '<LOC map_view_0004>Split View Left', 2)
  viewRight:SetRenderPass(UIUtil.UIRP_UnderWorld | UIUtil.UIRP_PostGlow) -- don't change this or the camera will lag one frame behind
  LayoutHelpers.FillParent(viewRight, mapGroup)
  viewRight:GetsGlobalCameraCommands(true)
  
  viewLeft = import('/lua/ui/controls/worldview.lua').WorldView(mapGroupRight, 'WorldCamera', 1, false) -- depth value should be below minimap
  viewLeft:Register('WorldCamera', nil, '<LOC map_view_0005>Split View Right', 2)
  viewLeft:SetRenderPass(UIUtil.UIRP_UnderWorld | UIUtil.UIRP_PostGlow) -- don't change this or the camera will lag one frame behind
  LayoutHelpers.FillParent(viewLeft, mapGroupRight)
  
  view = Group(viewLeft)
  view.Left:Set(viewRight.Left)
  view.Top:Set(viewLeft.Top)
  view.Bottom:Set(viewLeft.Bottom)
  view.Right:Set(viewLeft.Right)
  view:DisableHitTest()

  import('/lua/ui/game/multifunction.lua').RefreshMapDialog()

  UIP.PrimaryWorldViewRight = true
end
