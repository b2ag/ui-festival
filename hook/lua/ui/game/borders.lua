-- kate: space-indent on; indent-width 2;
local uif2DD0_modpath = '/mods/ui-festival'
local UIF = import(uif2DD0_modpath..'/modules/main.lua')

local uif2DD0_baseSetLayout = SetLayout
function SetLayout(layout)
  uif2DD0_baseSetLayout(layout)
  UifLog( 'SetLayout hook called with layout=' .. (layout and layout or 'nil') )
  status, result = pcall(ForkThread,UIF.ArrangeUI)
  if not status then
    UifLog( "Error in SetLayout " .. result )
  end
end
