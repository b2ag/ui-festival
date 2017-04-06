-- kate: space-indent on; indent-width 2;
local uif2DD0_modpath = '/mods/ui-festival'
local UIF = import(uif2DD0_modpath..'/modules/main.lua')

local uif2DD0_baseCreateMainWorldView = CreateMainWorldView
function CreateMainWorldView(parent, mapGroup, mapGroupRight)
  UIF.PrimaryWorldViewRight = false
  UifLog( 'CreateMainWorldView hook called with parent='..(parent and 'something' or 'nil')..' mapGroup='..(mapGroup and 'something' or 'nil')..' mapGroupRight='..(mapGroupRight and 'something' or 'nil') )

  uif2DD0_baseCreateMainWorldView( parent, mapGroup, mapGroupRight )

  if not UIF.Enabled() or not UIF.GetSetting("primaryRight") or not mapGroupRight then 
    return
  end

  local wordView = import('/lua/ui/game/worldview.lua')
  -- reset
  wordView.viewLeft.Left:Set(GetFrame(0).Left)
  wordView.viewRight.Right:Set(GetFrame(0).Right)
  wordView.viewLeft.Right:Set(GetFrame(0).Right)
  wordView.viewRight.Left:Set(GetFrame(0).Left)
--   wordView.viewLeft.Top:Set(GetFrame(0).Top)
--   wordView.viewRight.Top:Set(GetFrame(0).Top)
--   wordView.viewLeft.Bottom:Set(GetFrame(0).Bottom)
--   wordView.viewRight.Bottom:Set(GetFrame(0).Bottom)
  -- switch left & right
  wordView.viewLeft.Left:Set(mapGroupRight.Left)
  wordView.viewRight.Right:Set(mapGroupRight.Left)
  wordView.viewLeft.Top:Set(function() return ( GetFrame(0).Height() * UIF.GetSetting("rightOffsetTop") / 100 ) end)
  wordView.viewLeft.Bottom:Set(function() return ( GetFrame(0).Height() * ( 100 - UIF.GetSetting("rightOffsetBottom") ) / 100 ) end)
  wordView.viewRight.Top:Set(function() return ( GetFrame(0).Height() * UIF.GetSetting("leftOffsetTop") / 100 ) end)
  wordView.viewRight.Bottom:Set(function() return ( GetFrame(0).Height() * ( 100 - UIF.GetSetting("leftOffsetBottom") ) / 100 ) end)
--   wordView.viewRight.Width:Set(function() return wordView.viewRight.Right() - wordView.viewRight.Left() end)
--   wordView.viewRight.Height:Set(function() return wordView.viewRight.Bottom() - wordView.viewRight.Top() end)
--   wordView.viewLeft.Width:Set(function() return wordView.viewLeft.Right() - wordView.viewLeft.Left() end)
--   wordView.viewLeft.Height:Set(function() return wordView.viewLeft.Bottom() - wordView.viewLeft.Top() end)

  UIF.PrimaryWorldViewRight = true
end
