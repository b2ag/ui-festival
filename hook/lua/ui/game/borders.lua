-- kate: space-indent on; indent-width 2;
local modpath = '/mods/ui-festival'
local UIP = import(modpath..'/modules/main.lua')

local baseSetLayout = SetLayout
function SetLayout(layout)
  baseSetLayout(layout)
  UipLog( 'SetLayout hook called with layout=' .. (layout and layout or 'nil') )
  status, result = pcall(ForkThread,UIP.ArrangeUI)
  if not status then
    UipLog( "Error in SetLayout " .. result )
  end
end
