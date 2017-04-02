-- kate: space-indent off; indent-width 4;
local modpath = '/mods/ui-festival'
local UIP = import(modpath..'/modules/main.lua')

local oldCreateUI = CreateUI
function CreateUI(isReplay)
 
	oldCreateUI(isReplay)

	UIP.CreateUI(isReplay)

end

local baseSetLayout = SetLayout
function SetLayout(layout)
    baseSetLayout(layout)
    ForkThread(UIP.ArrangeUI)
end

local oldOnFirstUpdate = OnFirstUpdate 
function OnFirstUpdate()

	oldOnFirstUpdate()

	if not UIP.Enabled() or not UIP.GetSetting("startSplitScreen") then 
		return
	end

	-- start with split screen
	local Borders = import('/lua/ui/game/borders.lua')
	Borders.SplitMapGroup(true, true)
end
