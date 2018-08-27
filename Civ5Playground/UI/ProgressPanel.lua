include( "IconSupport" );
include( "SupportFunctions"  );
include( "InstanceManager" );

local g_ProgressButtonIM = InstanceManager:new( "ProgressItemInstance", "ProgressItemButton", Controls.ProgressStack )

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

	g_ProgressButtonIM:ResetInstances();


	local localPlayer = Players[Game.GetActivePlayer()]
	print("Adding items..")
	LuaEvents.OnUpdateProgressItems(localPlayer)
	Controls.ProgressStack:CalculateSize()
	RecalcPanelSize()
end

function OnAddProgressItem(object, itemText, progressText)
	local progressItem = g_ProgressButtonIM:GetInstance()
	IconHookup( object.PortraitIndex, 64, object.IconAtlas, progressItem.Portrait )
	progressItem.ItemText:SetText(itemText)
	progressItem.ProgressText:SetText(progressText)
end
LuaEvents.OnAddProgressItem.Add(OnAddProgressItem)

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