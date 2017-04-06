-- kate: space-indent on; indent-width 2;
local uif2DD0_modpath = '/mods/ui-festival'
local UIF = import(uif2DD0_modpath..'/modules/main.lua')

local uif2DD0_baseCreateUI = CreateUI
function CreateUI(isReplay)
  uif2DD0_baseCreateUI(isReplay)
  UifLog( 'CreateUI hook called with isReplay=' .. repr(isReplay) )
  status, result = pcall(ForkThread,UIF.CreateUI)
  if not status then
    UifLog( "Error in CreateUI " .. result )
  end
end

local uif2DD0_baseOnFirstUpdate = OnFirstUpdate 
function OnFirstUpdate()
  uif2DD0_baseOnFirstUpdate()
  UifLog( 'OnFirstUpdate hook called' )
  status, result = pcall(ForkThread,UIF.OnFirstUpdate)
  if not status then
    UifLog( "Error in OnFirstUpdate " .. result )
  end
end
