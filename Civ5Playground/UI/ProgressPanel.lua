include( "IconSupport" );
include( "SupportFunctions"  );
include( "InstanceManager" );

local g_ProgressButtonIM = InstanceManager:new( "ProgressItemInstance", "ProgressItemButton", Controls.ProgressStack )
local g_TimeSpentButtonIM = InstanceManager:new( "TimeSpentItemInstance", "TimeSpentItemButton", Controls.TimeSpentStack )

print("-- PROGRESS PANEL INIT --")
-----------------------------------------------------------------
-- Adjust for resolution
-----------------------------------------------------------------
local TOP_COMPENSATION = Controls.OuterGrid:GetOffsetY();
local PANEL_OFFSET = Controls.ScrollPanel:GetOffsetY() + 48;
local BOTTOM_COMPENSATION = 226;
local _, screenY = UIManager:GetScreenSizeVal();
local MAX_SIZE = screenY - (TOP_COMPENSATION + BOTTOM_COMPENSATION);

Controls.OuterGrid:SetSizeY( MAX_SIZE );
Controls.ScrollPanel:SetSizeY( MAX_SIZE - PANEL_OFFSET );

Controls.ScrollPanel:CalculateInternalSize();
Controls.OuterGrid:ReprocessAnchoring();

function UpdateDisplay()
	
	if (ContextPtr:IsHidden()) then
		return;
	end
	
	if (IsGameCoreBusy()) then
		return;
	end

	g_ProgressButtonIM:ResetInstances()
	local localPlayer = Players[Game.GetActivePlayer()]
	LuaEvents.OnUpdateProgressItems(localPlayer)
	Controls.ProgressStack:CalculateSize()


	LuaEvents.OnUpdateTimeSpentItem()
	RecalcPanelSize()
end
Events.ActivePlayerTurnStart.Add(UpdateDisplay)

function OnAddIntProgressItem(object, itemText, current, required)
	local progressText = string.format("%d/%d", current, required)
	if current >= required then
		progressText = string.format("[COLOR_FONT_GREEN]%s[ENDCOLOR]", progressText)
	else
		progressText = string.format("[COLOR_FONT_RED]%s[ENDCOLOR]", progressText)
	end
	OnAddTextProgressItem(object, itemText, progressText)
end
LuaEvents.OnAddIntProgressItem.Add(OnAddIntProgressItem)

function OnAddTextProgressItem(object, itemText, progressText)
	local progressItem = g_ProgressButtonIM:GetInstance()
	IconHookup( object.PortraitIndex, 64, object.IconAtlas, progressItem.Portrait )
	progressItem.ItemText:SetText(itemText)
	progressItem.ProgressText:SetText(progressText)
end
LuaEvents.OnAddTextProgressItem.Add(OnAddTextProgressItem)

function OnUpdateTimeSpentItem()
	if (ContextPtr:IsHidden()) then
		return;
	end
	
	if (IsGameCoreBusy()) then
		return;
	end
	
	g_TimeSpentButtonIM:ResetInstances()
	local timeSpentItem = g_TimeSpentButtonIM:GetInstance()
	local table = {}
	LuaEvents.OnGetTotalTimeSpent(table)

	local secSpent = table["value"]
	local hrSpent = math.floor(secSpent/3600)
	local minSpent = math.floor((secSpent - 3600*hrSpent)/60)

	IconHookup( GameInfo.Units.UNIT_SCOUT.PortraitIndex, 64, GameInfo.Units.UNIT_SCOUT.IconAtlas, timeSpentItem.Portrait )
	timeSpentItem.ItemText:SetText(Locale.Lookup("TXT_KEY_GEF_PROGRESS_TOTALTIME"))
	timeSpentItem.ProgressText:SetText(string.format("%02.0f:%02.0f", hrSpent, minSpent) )

	Controls.TimeSpentStack:CalculateSize()
end
LuaEvents.OnUpdateTimeSpentItem.Add(OnUpdateTimeSpentItem)

function InputHandler( uiMsg, wParam, lParam )
	if uiMsg == KeyEvents.KeyDown then
	
		if wParam == Keys.VK_ESCAPE then
    	    OnClose();
			return true;
		end
    end
end
ContextPtr:SetInputHandler( InputHandler );

function RecalcPanelSize()
	Controls.OuterStack:CalculateSize();
	local size = math.min( MAX_SIZE, Controls.OuterStack:GetSizeY() + 250 );
    Controls.OuterGrid:SetSizeY( size );
    Controls.ScrollPanel:SetSizeY( size - PANEL_OFFSET );
	Controls.ScrollPanel:CalculateInternalSize();
	Controls.ScrollPanel:ReprocessAnchoring();
end

function ShowHideHandler( bIsHide )
    if( not bIsHide ) then
        UpdateDisplay();
    end
end
ContextPtr:SetShowHideHandler( ShowHideHandler );


function OnClose()
    ContextPtr:SetHide( true );
end
Controls.CloseButton:RegisterCallback( Mouse.eLClick, OnClose )