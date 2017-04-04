-- kate: space-indent on; indent-width 2;
local modpath = '/mods/ui-festival'
local UIP = import(modpath..'/modules/main.lua')

local baseCreateUI = CreateUI
function CreateUI(isReplay)
  baseCreateUI(isReplay)
  UipLog( 'CreateUI hook called with isReplay=' .. repr(isReplay) )
  UIP.CreateUI(isReplay)
end

local baseOnFirstUpdate = OnFirstUpdate 
function OnFirstUpdate()
  baseOnFirstUpdate()
  UipLog( 'OnFirstUpdate hook called' )
  UIP.OnFirstUpdate()
end
