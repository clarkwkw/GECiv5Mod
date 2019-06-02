-- This version of tech tree is adapted from https://forums.civfanatics.com/threads/smarter-techtree-pipes.391165/
-- Now it also supports prerequisite tech that is further than 4 rows apart
-------------------------------------------------
-- Tech Tree Popup
-------------------------------------------------
include( "InstanceManager" );

g_UseSmallIcons = true;

include( "TechButtonInclude" );
include( "TechHelpInclude" );

local m_PopupInfo = nil;
local stealingTechTargetPlayerID = -1;


local g_TectTreeManager = InstanceManager:new( "TechTreeInstance", "TechTreeScrollPanel", Controls.TechTreeVerticalScrollPanel );
local g_TechTree = g_TectTreeManager:GetInstance()
local g_PipeManager = InstanceManager:new( "TechPipeInstance", "TechPipeIcon", g_TechTree.TechTreeScrollPanel );
local g_EraManager = InstanceManager:new( "EraBlockInstance", "EraBlock", g_TechTree.EraStack );
local g_TechInstanceManager = InstanceManager:new( "TechButtonInstance", "TechButton", g_TechTree.TechTreeScrollPanel );

local g_NeedsFullRefreshOnOpen = false;
local g_NeedsFullRefresh = false;

local maxSmallButtons = 5;

-- I'll need these before I'm done
local playerID = Game.GetActivePlayer();	
local player = Players[playerID];
local civType = GameInfo.Civilizations[player:GetCivilizationType()].Type;
local activeTeamID = Game.GetActiveTeam();
local activeTeam = Teams[activeTeamID];

-- textures I'll be using
local right1Texture = "TechBranchH.dds"
local right2Texture = "TechBranches.dds"
local right2BTexture = "TechBranches.dds"
local right2TTexture = "TechBranches.dds"
local right3Texture = "TechBranches.dds"

local left1Texture = "TechBranchH.dds"
local left2Texture = "TechBranches.dds"
local left2TTexture = "TechBranches.dds"
local left2BTexture = "TechBranches.dds"

local topRightTexture = "TechBranches.dds"
local topLeftTexture = "TechBranches.dds"
local bottomRightTexture = "TechBranches.dds"
local bottomLeftTexture = "TechBranches.dds"

local hTexture = "TechBranchH.dds";
local vTexture = "TechBranchV.dds";

local connectorSize = { x = 32; y = 42; };

local pinkColor = {x = 2, y = 0, z = 2, w = 1};

local blockSpacingX = 270 + 96;
local blockSizeX = 270;
local blockSpacingY = 68;
local extraYOffset = 32;
local verticalPipeOffsetSize = -30;

local maxTechNameLength = 32 - Locale.Length(Locale.Lookup("TXT_KEY_TURNS"));

-------------------------------------------------
-- Do initial setup stuff here
-------------------------------------------------

local techButtons = {};
local eraBlocks = {};
local eraColumns = {};

function mod(a, b)
    return a - (math.floor(a/b)*b)
end

function isVerticalOffsetActivated(prereq)
	local config = GameInfo.TechTreeVerticalPipeConfig{PrereqTechType=prereq.Type}()
	return config ~= nil;
end

function registerConnection(tech, prereq, techPipes)
	local prereqOffsetActivated = isVerticalOffsetActivated(prereq)
	if tech.GridX - prereq.GridX > 1 then
		techPipes[tech.Type].leftConnectionCenter = true;
		if tech.GridY < prereq.GridY then
			techPipes[prereq.Type].rightConnectionUp = true;
			if prereqOffsetActivated then
				techPipes[tech.Type].leftleftOffsetConnectionDown = true;
			else
				techPipes[tech.Type].leftleftConnectionDown = true;
			end
		elseif tech.GridY > prereq.GridY then
			techPipes[prereq.Type].rightConnectionDown = true;
			if prereqOffsetActivated then
				techPipes[tech.Type].leftleftOffsetConnectionUp = true;
			else
				techPipes[tech.Type].leftleftConnectionUp = true;
			end
		else
			techPipes[prereq.Type].rightConnectionCenter = true;
			if prereqOffsetActivated then
				techPipes[tech.Type].leftleftOffsetConnectionCenter = true;
			else
				techPipes[tech.Type].leftleftConnectionCenter = true;
			end
		end
	elseif tech.GridX - prereq.GridX == 1 then
		if tech.GridY < prereq.GridY then
			if prereqOffsetActivated then
				techPipes[tech.Type].leftOffsetConnectionDown = true;
			else
				techPipes[tech.Type].leftConnectionDown = true;
			end
			techPipes[prereq.Type].rightConnectionUp = true;
		elseif tech.GridY > prereq.GridY then
			if prereqOffsetActivated then
				techPipes[tech.Type].leftOffsetConnectionUp = true;
			else
				techPipes[tech.Type].leftConnectionUp = true;
			end
			techPipes[prereq.Type].rightConnectionDown = true;
		else
			if prereqOffsetActivated then
				techPipes[tech.Type].leftOffsetConnectionCenter = true;
			else
				techPipes[tech.Type].leftConnectionCenter = true;
			end
			techPipes[prereq.Type].rightConnectionCenter = true;
		end
	end
	local xOffset = (tech.GridX - prereq.GridX) - 1;
	if xOffset > techPipes[tech.Type].xOffset then
		techPipes[tech.Type].xOffset = xOffset;
		techPipes[tech.Type].isFurthestTechOffsetActivated = prereqOffsetActivated;
	end
	return techPipes
end

function createLeftBranchIcon(techGridX, connectionType, xOffsetFurthest, xOffsetFromVertical, yOffset)
	local pipe = g_PipeManager:GetInstance();
	if connectionType == 1 then
		pipe.TechPipeIcon:SetOffsetVal( (techGridX-xOffsetFurthest)*blockSpacingX + xOffsetFromVertical, yOffset );
		pipe.TechPipeIcon:SetTexture(left1Texture);
	elseif connectionType == 2 then
		pipe.TechPipeIcon:SetOffsetVal( (techGridX-xOffsetFurthest)*blockSpacingX + xOffsetFromVertical, yOffset - 15);
		pipe.TechPipeIcon:SetTexture(bottomLeftTexture);
		pipe.TechPipeIcon:SetTextureOffset(Vector2(0,72));
	elseif connectionType == 3 then
		pipe.TechPipeIcon:SetOffsetVal( (techGridX-xOffsetFurthest)*blockSpacingX + xOffsetFromVertical, yOffset );
		pipe.TechPipeIcon:SetTexture(left1Texture);
		pipe = g_PipeManager:GetInstance();	
		pipe.TechPipeIcon:SetOffsetVal( (techGridX-xOffsetFurthest)*blockSpacingX + xOffsetFromVertical, yOffset - 15);
		pipe.TechPipeIcon:SetTexture(bottomLeftTexture);
		pipe.TechPipeIcon:SetTextureOffset(Vector2(0,72));
	elseif connectionType == 4 then
		pipe.TechPipeIcon:SetOffsetVal( (techGridX-xOffsetFurthest)*blockSpacingX + xOffsetFromVertical, yOffset );
		pipe.TechPipeIcon:SetTexture(topLeftTexture);
		pipe.TechPipeIcon:SetTextureOffset(Vector2(0,0));
	elseif connectionType == 5 then
		pipe.TechPipeIcon:SetOffsetVal( (techGridX-xOffsetFurthest)*blockSpacingX + xOffsetFromVertical, yOffset );
		pipe.TechPipeIcon:SetTexture(left1Texture);
		pipe = g_PipeManager:GetInstance();	
		pipe.TechPipeIcon:SetOffsetVal( (techGridX-xOffsetFurthest)*blockSpacingX + xOffsetFromVertical, yOffset );
		pipe.TechPipeIcon:SetTexture(topLeftTexture);
		pipe.TechPipeIcon:SetTextureOffset(Vector2(0,0));
	elseif connectionType == 6 then
		pipe.TechPipeIcon:SetOffsetVal( (techGridX-xOffsetFurthest)*blockSpacingX + xOffsetFromVertical, yOffset - 15);
		pipe.TechPipeIcon:SetTexture(bottomLeftTexture);
		pipe.TechPipeIcon:SetTextureOffset(Vector2(0,72));
		pipe = g_PipeManager:GetInstance();	
		pipe.TechPipeIcon:SetOffsetVal( (techGridX-xOffsetFurthest)*blockSpacingX + xOffsetFromVertical, yOffset );
		pipe.TechPipeIcon:SetTexture(topLeftTexture);
		pipe.TechPipeIcon:SetTextureOffset(Vector2(0,0));
	else --connectionType == 7 then
		pipe.TechPipeIcon:SetOffsetVal( (techGridX-xOffsetFurthest)*blockSpacingX + xOffsetFromVertical, yOffset );
		pipe.TechPipeIcon:SetTexture(left1Texture);
		pipe = g_PipeManager:GetInstance();	
		pipe.TechPipeIcon:SetOffsetVal( (techGridX-xOffsetFurthest)*blockSpacingX + xOffsetFromVertical, yOffset - 15);
		pipe.TechPipeIcon:SetTexture(bottomLeftTexture);
		pipe.TechPipeIcon:SetTextureOffset(Vector2(0,72));
		pipe = g_PipeManager:GetInstance();	
		pipe.TechPipeIcon:SetOffsetVal( (techGridX-xOffsetFurthest)*blockSpacingX + xOffsetFromVertical, yOffset );
		pipe.TechPipeIcon:SetTexture(topLeftTexture);
		pipe.TechPipeIcon:SetTextureOffset(Vector2(0,0));
	end
end

function InitialSetup()

	-- make the scroll bar the correct size for the display size
	g_TechTree.TechTreeScrollBar:SetSizeX( g_TechTree.TechTreeScrollPanel:GetSize().x - 150 );
	Controls.TechTreeVerticalScrollBar:SetSizeY( Controls.TechTreeVerticalScrollPanel:GetSize().y - 57 );
	Controls.VScrollDownButton:SetOffsetY( 19 + Controls.TechTreeVerticalScrollPanel:GetSize().y - 57 );

	print("Sizes:")
	print(Controls.TechTreeVerticalScrollPanel:GetSize().y)
	print(Controls.VScrollUpButton:GetSize().y)
	print(Controls.VScrollDownButton:GetSize().y)
	
	-- gather info about this player's unique units and buldings
	GatherInfoAboutUniqueStuff( civType );

	-- add the Era panels to the background
	AddEraPanels();

	-- add the pipes
	local techPipes = {};
	for row in GameInfo.Technologies() do
		techPipes[row.Type] = 
		{
			leftConnectionUp = false;
			leftConnectionDown = false;
			leftConnectionCenter = false;
			leftConnectionType = 0;

			leftOffsetConnectionUp = false;
			leftOffsetConnectionDown = false;
			leftOffsetConnectionCenter = false;
			leftOffsetConnectionType = 0;

			rightConnectionUp = false;
			rightConnectionDown = false;
			rightConnectionCenter = false;
			rightConnectionType = 0;
			-- Morlark - Change pipe system so that brances converge at source tech rather than destination tech. 101012.
			leftleftConnectionUp = false;
			leftleftConnectionDown = false;
			leftleftConnectionCenter = false;
			leftleftConnectionType = 0;

			leftleftOffsetConnectionUp = false;
			leftleftOffsetConnectionDown = false;
			leftleftOffsetConnectionCenter = false;
			leftleftOffsetConnectionType = 0;
			-- End of Morlark's additions.
			xOffset = 0;
			isFurthestTechOffsetActivated = false;
			techType = row.Type;
		};
	end
	
	local cnxCenter = 1
	local cnxUp = 2
	local cnxDown = 4
	local getConnectionType = function(up, down, center)
		local upInt = up and 1 or 0;
		local downInt = down and 1 or 0;
		local centerInt = center and 1 or 0;
		return upInt*cnxUp + downInt*cnxDown + centerInt*cnxCenter
	end
	
	for row in GameInfo.Technology_PrereqTechs() do
		local prereq = GameInfo.Technologies[row.PrereqTech];
		local tech = GameInfo.Technologies[row.TechType];
		if tech and prereq then
			techPipes = registerConnection(tech, prereq, techPipes)
		end
	end
	for row in GameInfo.Technology_ORPrereqTechs() do
		local prereq = GameInfo.Technologies[row.PrereqTech];
		local tech = GameInfo.Technologies[row.TechType];
		if tech and prereq then
			techPipes = registerConnection(tech, prereq, techPipes)
		end
	end
	-- End of Morlark's changes.

	for pipeIndex, thisPipe in pairs(techPipes) do
		thisPipe.leftConnectionType = getConnectionType(thisPipe.leftConnectionUp, thisPipe.leftConnectionDown, thisPipe.leftConnectionCenter)
		thisPipe.rightConnectionType = getConnectionType(thisPipe.rightConnectionUp, thisPipe.rightConnectionDown, thisPipe.rightConnectionCenter)
		thisPipe.leftleftConnectionType = getConnectionType(thisPipe.leftleftConnectionUp, thisPipe.leftleftConnectionDown, thisPipe.leftleftConnectionCenter)
		thisPipe.leftleftOffsetConnectionType = getConnectionType(thisPipe.leftleftOffsetConnectionUp, thisPipe.leftleftOffsetConnectionDown, thisPipe.leftleftOffsetConnectionCenter)
		thisPipe.leftOffsetConnectionType = getConnectionType(thisPipe.leftOffsetConnectionUp, thisPipe.leftOffsetConnectionDown, thisPipe.leftOffsetConnectionCenter)
		
	end

	for row in GameInfo.Technology_PrereqTechs() do
		local prereq = GameInfo.Technologies[row.PrereqTech];
		local tech = GameInfo.Technologies[row.TechType];
		if tech and prereq then
			local xOffset = isVerticalOffsetActivated(prereq) and verticalPipeOffsetSize or 0;
			if tech.GridX - prereq.GridX > 1 then
				local hConnection = g_PipeManager:GetInstance();
				hConnection.TechPipeIcon:SetOffsetVal(prereq.GridX*blockSpacingX + blockSizeX + 128 + xOffset, (tech.GridY-5)*blockSpacingY + 12 + extraYOffset);
				hConnection.TechPipeIcon:SetTexture(hTexture);
				local size = { x = (tech.GridX-prereq.GridX - 1)*blockSpacingX - 12 + xOffset; y = 42; };
				hConnection.TechPipeIcon:SetSize(size);
			end
			
			if tech.GridY - prereq.GridY == 1 or tech.GridY - prereq.GridY == -1 then
				local vConnection = g_PipeManager:GetInstance();
				vConnection.TechPipeIcon:SetOffsetVal((prereq.GridX)*blockSpacingX + blockSizeX + 96 + xOffset, ((tech.GridY-5)*blockSpacingY) - (((tech.GridY-prereq.GridY) * blockSpacingY) / 2) + extraYOffset);
				vConnection.TechPipeIcon:SetTexture(vTexture);
				local size = { x = 32; y = (blockSpacingY / 2) + 8; };
				vConnection.TechPipeIcon:SetSize(size);
			end

			if tech.GridY - prereq.GridY == 2 or tech.GridY - prereq.GridY == -2 then
				local vConnection = g_PipeManager:GetInstance();
				vConnection.TechPipeIcon:SetOffsetVal((prereq.GridX)*blockSpacingX + blockSizeX + 96 + xOffset, (tech.GridY-5)*blockSpacingY - (((tech.GridY-prereq.GridY) * blockSpacingY) / 2) + extraYOffset);
				vConnection.TechPipeIcon:SetTexture(vTexture);
				local size = { x = 32; y = (blockSpacingY * 3 / 2) + 8; };
				vConnection.TechPipeIcon:SetSize(size);
			end

			if tech.GridY - prereq.GridY == 3 or tech.GridY - prereq.GridY == -3 then
				local vConnection = g_PipeManager:GetInstance();
				vConnection.TechPipeIcon:SetOffsetVal((prereq.GridX)*blockSpacingX + blockSizeX + 96 + xOffset, ((tech.GridY-5)*blockSpacingY) - (((tech.GridY-prereq.GridY) * blockSpacingY) / 2) + extraYOffset);
				vConnection.TechPipeIcon:SetTexture(vTexture);
				local size = { x = 32; y = blockSpacingY * 2 + 20; };
				vConnection.TechPipeIcon:SetSize(size);
			end

			if tech.GridY - prereq.GridY == 4 or tech.GridY - prereq.GridY == -4 then
				local vConnection = g_PipeManager:GetInstance();
				vConnection.TechPipeIcon:SetOffsetVal((prereq.GridX)*blockSpacingX + blockSizeX + 96 + xOffset, ((tech.GridY-5)*blockSpacingY) - (((tech.GridY-prereq.GridY) * blockSpacingY) / 2) + extraYOffset);
				vConnection.TechPipeIcon:SetTexture(vTexture);
				local size = { x = 32; y = blockSpacingY * 3 + 20; };
				vConnection.TechPipeIcon:SetSize(size);
			end
			
			if math.abs(tech.GridY - prereq.GridY) >= 5 then
				local vConnection = g_PipeManager:GetInstance();

				vConnection.TechPipeIcon:SetOffsetVal((prereq.GridX)*blockSpacingX + blockSizeX + 96 + xOffset, ((tech.GridY-5)*blockSpacingY) - (((tech.GridY-prereq.GridY) * blockSpacingY) / 2) + extraYOffset + 5);
				vConnection.TechPipeIcon:SetTexture(vTexture);
				local size = { x = 32; y = blockSpacingY * (math.abs(tech.GridY - prereq.GridY) - 1) + 11; };
				vConnection.TechPipeIcon:SetSize(size);
			end
		
		end
	end

	for row in GameInfo.Technology_ORPrereqTechs() do
		local prereq = GameInfo.Technologies[row.PrereqTech];
		local tech = GameInfo.Technologies[row.TechType];
		if tech and prereq then
			local xOffset = isVerticalOffsetActivated(prereq) and verticalPipeOffsetSize or 0;
			if tech.GridX - prereq.GridX > 1 then
				local hConnection = g_PipeManager:GetInstance();
				hConnection.TechPipeIcon:SetOffsetVal(prereq.GridX*blockSpacingX + blockSizeX + 128 + xOffset, (tech.GridY-5)*blockSpacingY + 12 + extraYOffset);
				hConnection.TechPipeIcon:SetTexture(hTexture);
				local size = { x = (tech.GridX-prereq.GridX - 1)*blockSpacingX - 12 + xOffset; y = 42; };
				hConnection.TechPipeIcon:SetSize(size);
			end
			
			if tech.GridY - prereq.GridY == 1 or tech.GridY - prereq.GridY == -1 then
				local vConnection = g_PipeManager:GetInstance();
				vConnection.TechPipeIcon:SetOffsetVal((prereq.GridX)*blockSpacingX + blockSizeX + 96 + xOffset, ((tech.GridY-5)*blockSpacingY) - (((tech.GridY-prereq.GridY) * blockSpacingY) / 2) + extraYOffset);
				vConnection.TechPipeIcon:SetTexture(vTexture);
				local size = { x = 32; y = (blockSpacingY / 2) + 8; };
				vConnection.TechPipeIcon:SetSize(size);
			end

			if tech.GridY - prereq.GridY == 2 or tech.GridY - prereq.GridY == -2 then
				local vConnection = g_PipeManager:GetInstance();
				vConnection.TechPipeIcon:SetOffsetVal((prereq.GridX)*blockSpacingX + blockSizeX + 96 + xOffset, (tech.GridY-5)*blockSpacingY - (((tech.GridY-prereq.GridY) * blockSpacingY) / 2) + extraYOffset);
				vConnection.TechPipeIcon:SetTexture(vTexture);
				local size = { x = 32; y = (blockSpacingY * 3 / 2) + 8; };
				vConnection.TechPipeIcon:SetSize(size);
			end

			if tech.GridY - prereq.GridY == 3 or tech.GridY - prereq.GridY == -3 then
				local vConnection = g_PipeManager:GetInstance();
				vConnection.TechPipeIcon:SetOffsetVal((prereq.GridX)*blockSpacingX + blockSizeX + 96 + xOffset, ((tech.GridY-5)*blockSpacingY) - (((tech.GridY-prereq.GridY) * blockSpacingY) / 2) + extraYOffset);
				vConnection.TechPipeIcon:SetTexture(vTexture);
				local size = { x = 32; y = blockSpacingY * 2 + 20; };
				vConnection.TechPipeIcon:SetSize(size);
			end
			
			if tech.GridY - prereq.GridY == 4 or tech.GridY - prereq.GridY == -4 then
				local vConnection = g_PipeManager:GetInstance();
				vConnection.TechPipeIcon:SetOffsetVal((prereq.GridX)*blockSpacingX + blockSizeX + 96 + xOffset, ((tech.GridY-5)*blockSpacingY) - (((tech.GridY-prereq.GridY) * blockSpacingY) / 2) + extraYOffset);
				vConnection.TechPipeIcon:SetTexture(vTexture);
				local size = { x = 32; y = blockSpacingY * 3 + 20; };
				vConnection.TechPipeIcon:SetSize(size);
			end

			if math.abs(tech.GridY - prereq.GridY) >= 5 then
				local vConnection = g_PipeManager:GetInstance();

				vConnection.TechPipeIcon:SetOffsetVal((prereq.GridX)*blockSpacingX + blockSizeX + 96 + xOffset, ((tech.GridY-5)*blockSpacingY) - (((tech.GridY-prereq.GridY) * blockSpacingY) / 2) + extraYOffset + 5);
				vConnection.TechPipeIcon:SetTexture(vTexture);
				local size = { x = 32; y = blockSpacingY * (math.abs(tech.GridY - prereq.GridY) - 1) - 11; };
				vConnection.TechPipeIcon:SetSize(size);
			end
		
		end
	end
	-- End of Morlark's changes.

	for pipeIndex, thisPipe in pairs(techPipes) do
	
		local tech = GameInfo.Technologies[thisPipe.techType];
		
		local yOffset = (tech.GridY-5)*blockSpacingY + 12 + extraYOffset;

		local rightOffsetFromVertical = isVerticalOffsetActivated(tech) and verticalPipeOffsetSize or 0;
		
		if thisPipe.rightConnectionType >= 1 then
			
			local startPipe = g_PipeManager:GetInstance();
			local startPipeExtendsion = mod(thisPipe.rightConnectionType, 2) == 0 and rightOffsetFromVertical or 0;
			startPipe.TechPipeIcon:SetOffsetVal( tech.GridX*blockSpacingX + blockSizeX + 64, yOffset );
			startPipe.TechPipeIcon:SetTexture(right1Texture);
			startPipe.TechPipeIcon:SetSize({x = connectorSize.x + startPipeExtendsion; y = connectorSize.y});
			
			local pipe = g_PipeManager:GetInstance();			
			if thisPipe.rightConnectionType == 1 then
				pipe.TechPipeIcon:SetOffsetVal( (tech.GridX)*blockSpacingX + blockSizeX + 96 + rightOffsetFromVertical, yOffset );
				pipe.TechPipeIcon:SetTexture(right1Texture);
			elseif thisPipe.rightConnectionType == 2 then
				pipe.TechPipeIcon:SetOffsetVal( (tech.GridX)*blockSpacingX + blockSizeX + 96 - 12 + rightOffsetFromVertical, yOffset - 15 );
				pipe.TechPipeIcon:SetTexture(bottomRightTexture);
				pipe.TechPipeIcon:SetTextureOffset(Vector2(72,72));
			elseif thisPipe.rightConnectionType == 3 then
				--pipe.TechPipeIcon:SetOffsetVal( (tech.GridX)*blockSpacingX + blockSizeX + 96 - 6, yOffset - 15 );
				--pipe.TechPipeIcon:SetTexture(right2BTexture);
				--pipe.TechPipeIcon:SetTextureOffset(Vector2(36,72));
				pipe.TechPipeIcon:SetOffsetVal( (tech.GridX)*blockSpacingX + blockSizeX + 96 + rightOffsetFromVertical, yOffset );
				pipe.TechPipeIcon:SetTexture(right1Texture);
				pipe = g_PipeManager:GetInstance();			
				pipe.TechPipeIcon:SetOffsetVal( (tech.GridX)*blockSpacingX + blockSizeX + 96 - 12 + rightOffsetFromVertical, yOffset - 15 );
				pipe.TechPipeIcon:SetTexture(bottomRightTexture);
				pipe.TechPipeIcon:SetTextureOffset(Vector2(72,72));
			elseif thisPipe.rightConnectionType == 4 then
				pipe.TechPipeIcon:SetOffsetVal( (tech.GridX)*blockSpacingX + blockSizeX + 96 - 12 + rightOffsetFromVertical, yOffset );
				pipe.TechPipeIcon:SetTexture(topRightTexture);
				pipe.TechPipeIcon:SetTextureOffset(Vector2(72,0));
			elseif thisPipe.rightConnectionType == 5 then
				--pipe.TechPipeIcon:SetOffsetVal( (tech.GridX)*blockSpacingX + blockSizeX + 96 - 6, yOffset );
				--pipe.TechPipeIcon:SetTexture(right2TTexture);
				--pipe.TechPipeIcon:SetTextureOffset(Vector2(36,0));
				pipe.TechPipeIcon:SetOffsetVal( (tech.GridX)*blockSpacingX + blockSizeX + 96 + rightOffsetFromVertical, yOffset );
				pipe.TechPipeIcon:SetTexture(right1Texture);
				pipe = g_PipeManager:GetInstance();			
				pipe.TechPipeIcon:SetOffsetVal( (tech.GridX)*blockSpacingX + blockSizeX + 96 - 12 + rightOffsetFromVertical, yOffset );
				pipe.TechPipeIcon:SetTexture(topRightTexture);
				pipe.TechPipeIcon:SetTextureOffset(Vector2(72,0));
			elseif thisPipe.rightConnectionType == 6 then
				--pipe.TechPipeIcon:SetOffsetVal( (tech.GridX)*blockSpacingX + blockSizeX + 96 - 12, yOffset - 6 );
				--pipe.TechPipeIcon:SetTexture(right2Texture);
				--pipe.TechPipeIcon:SetTextureOffset(Vector2(72,36));
				pipe.TechPipeIcon:SetOffsetVal( (tech.GridX)*blockSpacingX + blockSizeX + 96 - 12 + rightOffsetFromVertical, yOffset );
				pipe.TechPipeIcon:SetTexture(topRightTexture);
				pipe.TechPipeIcon:SetTextureOffset(Vector2(72,0));
				pipe = g_PipeManager:GetInstance();			
				pipe.TechPipeIcon:SetOffsetVal( (tech.GridX)*blockSpacingX + blockSizeX + 96 - 12 + rightOffsetFromVertical, yOffset - 15 );
				pipe.TechPipeIcon:SetTexture(bottomRightTexture);
				pipe.TechPipeIcon:SetTextureOffset(Vector2(72,72));
			else-- thisPipe.rightConnectionType == 7 then
				--pipe.TechPipeIcon:SetOffsetVal( (tech.GridX)*blockSpacingX + blockSizeX + 96 - 6, yOffset - 6 );
				--pipe.TechPipeIcon:SetTexture(right3Texture);
				--pipe.TechPipeIcon:SetTextureOffset(Vector2(36,36));
				pipe.TechPipeIcon:SetOffsetVal( (tech.GridX)*blockSpacingX + blockSizeX + 96 + rightOffsetFromVertical, yOffset );
				pipe.TechPipeIcon:SetTexture(right1Texture);
				pipe = g_PipeManager:GetInstance();			
				pipe.TechPipeIcon:SetOffsetVal( (tech.GridX)*blockSpacingX + blockSizeX + 96 - 12 + rightOffsetFromVertical, yOffset );
				pipe.TechPipeIcon:SetTexture(topRightTexture);
				pipe.TechPipeIcon:SetTextureOffset(Vector2(72,0));
				pipe = g_PipeManager:GetInstance();			
				pipe.TechPipeIcon:SetOffsetVal( (tech.GridX)*blockSpacingX + blockSizeX + 96 - 12 + rightOffsetFromVertical, yOffset - 15 );
				pipe.TechPipeIcon:SetTexture(bottomRightTexture);
				pipe.TechPipeIcon:SetTextureOffset(Vector2(72,72));
			end
		end


		if thisPipe.leftConnectionType >= 1 or thisPipe.leftOffsetConnectionType >= 1 then
			local startPipeExtendsion = thisPipe.leftOffsetConnectionType >= 1  and rightOffsetFromVertical or 0;
			startPipeExtendsion = startPipeExtendsion + (thisPipe.leftOffsetConnectionType == 1 and -1*connectorSize.x or 0);
			local startPipe = g_PipeManager:GetInstance();
			startPipe.TechPipeIcon:SetOffsetVal( tech.GridX*blockSpacingX + 26 + startPipeExtendsion, yOffset );
			startPipe.TechPipeIcon:SetTexture(left1Texture);
			startPipe.TechPipeIcon:SetSize(	Vector2(40 - startPipeExtendsion, 42) );
		end

		if thisPipe.leftConnectionType >= 1 then
			createLeftBranchIcon(tech.GridX, thisPipe.leftConnectionType, 0, 0, yOffset)
		end

		-- Morlark - Change pipe system so that branches converge at source tech rather than destination tech. 101012.
		if thisPipe.leftleftConnectionType >= 1 then
			createLeftBranchIcon(tech.GridX, thisPipe.leftleftConnectionType, thisPipe.xOffset, 0, yOffset)
		end

		if thisPipe.leftOffsetConnectionType >= 1 then
			createLeftBranchIcon(tech.GridX, thisPipe.leftOffsetConnectionType, 0, verticalPipeOffsetSize, yOffset)
		end

		if thisPipe.leftleftOffsetConnectionType >= 1 then
			createLeftBranchIcon(tech.GridX, thisPipe.leftleftOffsetConnectionType, thisPipe.xOffset, verticalPipeOffsetSize, yOffset)
		end
		-- End of Morlark's changes.
			
	end

	techPediaSearchStrings = {};

	-- add the instances of the tech panels
	for tech in GameInfo.Technologies() do
		AddTechButton( tech );
	end

	-- resize the panel to fit the contents
	g_TechTree.EraStack:CalculateSize();
	g_TechTree.EraStack:ReprocessAnchoring();
    g_TechTree.TechTreeScrollPanel:CalculateInternalSize();
    
    --initialized = true;		
end

function AddEraPanels()
	-- find the range of columns that each era takes
	-- Morlark - Change to allow for disabled techs placed at -1,-1, and to allow empty eras. 101008.
	--for tech in GameInfo.Technologies() do
	--	local eraID = GameInfo.Eras[tech.Era].ID;
	--	if not eraColumns[eraID] then
	--		eraColumns[eraID] = { minGridX = tech.GridX; maxGridX = tech.GridX; researched = false; };
	--	else
	--		if tech.GridX < eraColumns[eraID].minGridX then
	--			eraColumns[eraID].minGridX = tech.GridX;
	--		end
	--		if tech.GridX > eraColumns[eraID].maxGridX then
	--			eraColumns[eraID].maxGridX = tech.GridX;
	--		end
	--	end
	--end
	for era in GameInfo.Eras() do
		eraColumns[era.ID] = { minGridX = -1; maxGridX = -1; researched = false; };
	end
	for tech in GameInfo.Technologies() do
		local eraID = GameInfo.Eras[tech.Era].ID;
		if (tech.GridX < eraColumns[eraID].minGridX or eraColumns[eraID].minGridX == -1) and tech.Disable == false then
			eraColumns[eraID].minGridX = tech.GridX;
		end
		if (tech.GridX > eraColumns[eraID].maxGridX or eraColumns[eraID].maxGridX == -1) and tech.Disable == false then
			eraColumns[eraID].maxGridX = tech.GridX;
		end
	end
	-- End of Morlark's changes.

	-- add the era panels
	for era in GameInfo.Eras() do
	
		local thisEraBlockInstance = g_EraManager:GetInstance();
		-- store this panel off for later
		eraBlocks[era.ID] = thisEraBlockInstance;
		
		-- add the correct text for this era panel
		local textString = era.Description;
		local localizedLabel = Locale.ConvertTextKey( textString );
		thisEraBlockInstance.OldLabel:SetText( localizedLabel );
		thisEraBlockInstance.CurrentLabel:SetText( localizedLabel );
		thisEraBlockInstance.FutureLabel:SetText( localizedLabel );
		
		-- adjust the sizes of the era panels
		local blockWidth;
		if (eraColumns[era.ID] ~= nil) then
			blockWidth = (eraColumns[era.ID].maxGridX - eraColumns[era.ID].minGridX + 1);
		else
			blockWidth = 1;
		end
			
		blockWidth = (blockWidth * blockSpacingX);
		if era.ID == 0 then
			blockWidth = blockWidth + 32;
		end
		local blockSize = thisEraBlockInstance.EraBlock:GetSize();
		blockSize.x = blockWidth;
		thisEraBlockInstance.EraBlock:SetSize( blockSize );
		blockSize = thisEraBlockInstance.FrameBottom:GetSize();
		blockSize.x = blockWidth;
		thisEraBlockInstance.FrameBottom:SetSize( blockSize );	
		
		blockSize = thisEraBlockInstance.OldBar:GetSize();
		blockSize.x = blockWidth;
		thisEraBlockInstance.OldBar:SetSize( blockSize );
		blockSize = thisEraBlockInstance.OldBlock:GetSize();
		blockSize.x = blockWidth;
		thisEraBlockInstance.OldBlock:SetSize( blockSize );
		
		blockSize = thisEraBlockInstance.CurrentBlock:GetSize();
		blockSize.x = blockWidth;
		thisEraBlockInstance.CurrentBlock:SetSize( blockSize );
		blockSize = thisEraBlockInstance.CurrentBlock1:GetSize();
		blockSize.x = blockWidth;
		thisEraBlockInstance.CurrentBlock1:SetSize( blockSize );
		blockSize = thisEraBlockInstance.CurrentBlock2:GetSize();
		blockSize.x = blockWidth;
		thisEraBlockInstance.CurrentBlock2:SetSize( blockSize );
				
		blockSize = thisEraBlockInstance.CurrentTop:GetSize();
		blockSize.x = blockWidth;
		thisEraBlockInstance.CurrentTop:SetSize( blockSize );
		blockSize = thisEraBlockInstance.CurrentTop1:GetSize();
		blockSize.x = blockWidth;
		thisEraBlockInstance.CurrentTop1:SetSize( blockSize );
		blockSize = thisEraBlockInstance.CurrentTop2:GetSize();
		blockSize.x = blockWidth;
		thisEraBlockInstance.CurrentTop2:SetSize( blockSize );
				
		blockSize = thisEraBlockInstance.FutureBlock:GetSize();
		blockSize.x = blockWidth;
		thisEraBlockInstance.FutureBlock:SetSize( blockSize );
	end
end

function TechSelected( eTech, iDiscover)
	--print("eTech:"..tostring(eTech));
	print("stealingTechTargetPlayerID: " .. stealingTechTargetPlayerID);
	print("player:GetNumFreeTechs(): " ..  player:GetNumFreeTechs());
	if eTech > -1 then
		if (stealingTechTargetPlayerID ~= -1) then
			Network.SendResearch(eTech, 0, stealingTechTargetPlayerID, UIManager:GetShift());
		else
	   		Network.SendResearch(eTech, player:GetNumFreeTechs(), -1, UIManager:GetShift());
		end
   	end
end

function AddTechButton( tech )
	local thisTechButtonInstance = g_TechInstanceManager:GetInstance();
	if thisTechButtonInstance then
		
		-- store this instance off for later
		techButtons[tech.ID] = thisTechButtonInstance;
		
		-- add the input handler to this button
		thisTechButtonInstance.TechButton:SetVoid1( tech.ID ); -- indicates tech to add to queue
		thisTechButtonInstance.TechButton:SetVoid2( 0 ); -- how many free techs
		techPediaSearchStrings[tostring(thisTechButtonInstance.TechButton)] = tech.Description;
		thisTechButtonInstance.TechButton:RegisterCallback( Mouse.eRClick, GetTechPedia );

		local scienceDisabled = Game.IsOption(GameOptionTypes.GAMEOPTION_NO_SCIENCE);
 		if (not scienceDisabled) then
			thisTechButtonInstance.TechButton:RegisterCallback( Mouse.eLClick, TechSelected );
		end
		
		-- position this instance
		thisTechButtonInstance.TechButton:SetOffsetVal( tech.GridX*blockSpacingX + 64, (tech.GridY-5)*blockSpacingY + extraYOffset);
		
		-- update the name of this instance
		local techName = Locale.ConvertTextKey( tech.Description );
		
		techName = Locale.TruncateString(techName, maxTechNameLength, true);
		thisTechButtonInstance.AlreadyResearchedTechName:SetText( techName );
		thisTechButtonInstance.CurrentlyResearchingTechName:SetText( techName );
		thisTechButtonInstance.AvailableTechName:SetText( techName );
		thisTechButtonInstance.UnavailableTechName:SetText( techName );
		thisTechButtonInstance.LockedTechName:SetText( techName );
		thisTechButtonInstance.FreeTechName:SetText( techName );
		
		thisTechButtonInstance.TechButton:SetToolTipString( GetHelpTextForTech(tech.ID) );
		
		-- update the picture
		if IconHookup( tech.PortraitIndex, 64, tech.IconAtlas, thisTechButtonInstance.TechPortrait ) then
			thisTechButtonInstance.TechPortrait:SetHide( false );
		else
			thisTechButtonInstance.TechPortrait:SetHide( true );
		end
		
		-- add the small pictures and their tooltips
		AddSmallButtonsToTechButton( thisTechButtonInstance, tech, maxSmallButtons, 45 );
		
	end
end


-------------------------------------------------
-- On Display
-------------------------------------------------
local g_isOpen = false;

function OnDisplay( popupInfo )

	if popupInfo.Type ~= ButtonPopupTypes.BUTTONPOPUP_TECH_TREE then
		return;
	end

	m_PopupInfo = popupInfo;

	print("popupInfo.Data1: " .. popupInfo.Data1);
	print("popupInfo.Data2: " .. popupInfo.Data2);
	print("popupInfo.Data3: " .. popupInfo.Data3);

    g_isOpen = true;
    if not g_NeedsFullRefresh then
		g_NeedsFullRefresh = g_NeedsFullRefreshOnOpen;
	end
	g_NeedsFullRefreshOnOpen = false;

	if( m_PopupInfo.Data1 == 1 ) then
    	if( ContextPtr:IsHidden() == false ) then
    	    OnCloseButtonClicked();
    	    return;
    	else
        	UIManager:QueuePopup( ContextPtr, PopupPriority.eUtmost );
    	end
	else
        UIManager:QueuePopup( ContextPtr, PopupPriority.TechTree );
    end
    
    stealingTechTargetPlayerID = popupInfo.Data2;
    
	Events.SerialEventGameMessagePopupShown(m_PopupInfo);
		
  	RefreshDisplay();
  	
end
Events.SerialEventGameMessagePopup.Add( OnDisplay );

function RefreshDisplay()

	for tech in GameInfo.Technologies() do
		RefreshDisplayOfSpecificTech( tech );
	end
	
	-- update the era panels
	local highestEra = 0;
	for thisEra = 0, #eraBlocks, 1  do
		if eraColumns[thisEra] then
			if eraColumns[thisEra].researched == true then
				highestEra = thisEra;
			end
		end
	end
	for thisEra = 0, #eraBlocks, 1  do
		local thisEraBlockInstance = eraBlocks[thisEra];
		if thisEra < highestEra then
			thisEraBlockInstance.OldBar:SetHide( false );
			thisEraBlockInstance.CurrentBlock:SetHide( true );
			thisEraBlockInstance.CurrentTop:SetHide( true );
			thisEraBlockInstance.FutureBlock:SetHide( true );
		elseif thisEra == highestEra then
			thisEraBlockInstance.OldBar:SetHide( true );
			thisEraBlockInstance.CurrentBlock:SetHide( false );
			thisEraBlockInstance.CurrentTop:SetHide( false );
			thisEraBlockInstance.FutureBlock:SetHide( true );
		else
			thisEraBlockInstance.OldBar:SetHide( true );
			thisEraBlockInstance.CurrentBlock:SetHide( true );
			thisEraBlockInstance.CurrentTop:SetHide( true );
			thisEraBlockInstance.FutureBlock:SetHide( false );
		end
	end
	
	g_NeedsFullRefresh = false;
end

function RefreshDisplayOfSpecificTech( tech )
	local techID = tech.ID;
	local thisTechButton = techButtons[techID];
  	local numFreeTechs = player:GetNumFreeTechs();
 	local researchTurnsLeft = player:GetResearchTurnsLeft( techID, true );
 	local turnText = tostring( researchTurnsLeft ).." "..turnsString;
	local isAllowedToStealTech = false;
	local isAllowedToGetTechFree = false;
	
	-- Espionage - stealing a tech!
 	if stealingTechTargetPlayerID ~= -1 then
 		if player:CanResearch( techID ) then
			opponentPlayer = Players[stealingTechTargetPlayerID];
			local opponentTeam = Teams[opponentPlayer:GetTeam()];
			if (opponentTeam:IsHasTech(techID)) then
				isAllowedToStealTech = true;
			end
		end
	end
	
	-- Choosing a free tech - extra conditions may apply
	if (numFreeTechs > 0) then
		if (player:CanResearchForFree(techID)) then
			isAllowedToGetTechFree = true;
		end
	end
 	
 	local potentiallyBlockedFromStealing = (stealingTechTargetPlayerID ~= -1) and ((not isAllowedToStealTech) or player:GetNumTechsToSteal(stealingTechTargetPlayerID) <= 0);
 	
 	-- Rebuild the small buttons if needed
 	if (g_NeedsFullRefresh) then
		AddSmallButtonsToTechButton( thisTechButton, tech, maxSmallButtons, 45 );
 	end
 	
 	thisTechButton.TechButton:SetToolTipString( GetHelpTextForTech(techID) );
 	
 	local scienceDisabled = Game.IsOption(GameOptionTypes.GAMEOPTION_NO_SCIENCE);
 	if (scienceDisabled) then
 		turnText = "";
 	end
 	
 	
	if(not scienceDisabled) then
		thisTechButton.TechButton:SetVoid1( techID ); -- indicates tech to add to queue
		thisTechButton.TechButton:SetVoid2( numFreeTechs ); -- how many free techs
		AddCallbackToSmallButtons( thisTechButton, maxSmallButtons, techID, numFreeTechs, Mouse.eLClick, TechSelected );
	end
	
 	if activeTeam:GetTeamTechs():HasTech(techID) then -- the player (or more accurately his team) has already researched this one
 		thisTechButton.AlreadyResearched:SetHide( false );
 		thisTechButton.FreeTech:SetHide( true );
 		thisTechButton.CurrentlyResearching:SetHide( true );
 		thisTechButton.Available:SetHide( true );
 		thisTechButton.Unavailable:SetHide( true );
		thisTechButton.Locked:SetHide( true );
 
 		-- figure out if we need the first place dingus
 
 		-- update the era marker for this tech
 		local eraID = GameInfo.Eras[tech.Era].ID;
		if eraColumns[eraID] then
			eraColumns[eraID].researched = true;
		end
		
  		-- hide advisor icon
 		--thisTechButton.AdvisorIcon:SetHide( true );
 				
		if(not scienceDisabled) then
			thisTechButton.TechQueue:SetHide( true );
			thisTechButton.TechButton:SetVoid2( 0 ); -- num free techs
			thisTechButton.TechButton:SetVoid1( -1 ); -- indicates tech is invalid
			AddCallbackToSmallButtons( thisTechButton, maxSmallButtons, -1, 0, Mouse.eLClick, TechSelected );
 		end
 		
 	elseif player:GetCurrentResearch() == techID and (not potentiallyBlockedFromStealing) then -- the player is currently researching this one
 		thisTechButton.AlreadyResearched:SetHide( true );
 		thisTechButton.Available:SetHide( true );
 		thisTechButton.Unavailable:SetHide( true );
		thisTechButton.Locked:SetHide( true );
		-- deal with free tech
		if (isAllowedToGetTechFree) or (stealingTechTargetPlayerID ~= -1 and isAllowedToStealTech) then
  			thisTechButton.FreeTech:SetHide( false );
 			thisTechButton.CurrentlyResearching:SetHide( true );
			-- update number of turns to research
 			if 	player:GetScience() > 0 and stealingTechTargetPlayerID == -1 then
  				thisTechButton.FreeTurns:SetText( turnText );
  				thisTechButton.FreeTurns:SetHide( false );
  			else
  				thisTechButton.FreeTurns:SetHide( true );
  			end
			thisTechButton.TechQueueLabel:SetText( freeString );
			thisTechButton.TechQueue:SetHide( false );
		else
  			thisTechButton.FreeTech:SetHide( true );
 			thisTechButton.CurrentlyResearching:SetHide( false );
			-- update number of turns to research
 			if 	player:GetScience() > 0 then
  				thisTechButton.CurrentlyResearchingTurns:SetText( turnText );
  				thisTechButton.CurrentlyResearchingTurns:SetHide( false );
  			else
  				thisTechButton.CurrentlyResearchingTurns:SetHide( true );
  			end
			thisTechButton.TechQueue:SetHide( true );
		end
 		-- turn on the meter
		local teamTechs = activeTeam:GetTeamTechs();
		local researchProgressPercent = 0;
		local researchProgressPlusThisTurnPercent = 0;
		local researchTurnsLeft = player:GetResearchTurnsLeft(techID, true);
		local currentResearchProgress = player:GetResearchProgress(techID);
		local researchNeeded = player:GetResearchCost(techID);
		local researchPerTurn = player:GetScience();
		local currentResearchPlusThisTurn = currentResearchProgress + researchPerTurn;		
		researchProgressPercent = currentResearchProgress / researchNeeded;
		researchProgressPlusThisTurnPercent = currentResearchPlusThisTurn / researchNeeded;		
		if (researchProgressPlusThisTurnPercent > 1) then
			researchProgressPlusThisTurnPercent = 1
		end
 		-- update advisor icon if needed
 		--thisTechButton.AdvisorIcon:SetHide( true );
 	elseif (player:CanResearch( techID ) and not scienceDisabled and (not potentiallyBlockedFromStealing)) then -- the player research this one right now if he wants
 		thisTechButton.AlreadyResearched:SetHide( true );
 		thisTechButton.CurrentlyResearching:SetHide( true );
 		thisTechButton.Unavailable:SetHide( true );
		thisTechButton.Locked:SetHide( true );
 		-- deal with free 		
		if (isAllowedToGetTechFree)  or (stealingTechTargetPlayerID ~= -1 and isAllowedToStealTech) then
 			thisTechButton.FreeTech:SetHide( false );
 			thisTechButton.Available:SetHide( true );
			-- update number of turns to research
 			if 	player:GetScience() > 0 and stealingTechTargetPlayerID == -1 then
  				thisTechButton.FreeTurns:SetText( turnText );
  				thisTechButton.FreeTurns:SetHide( false );
  			else
  				thisTechButton.FreeTurns:SetHide( true );
  			end
			-- update queue number to say "FREE"
			thisTechButton.TechQueueLabel:SetText( freeString );
			thisTechButton.TechQueue:SetHide( false );
		else
 			thisTechButton.FreeTech:SetHide( true );
 			thisTechButton.Available:SetHide( false );
			-- update number of turns to research
 			if 	player:GetScience() > 0 then
  				thisTechButton.AvailableTurns:SetText( turnText );
  				thisTechButton.AvailableTurns:SetHide( false );
  			else
  				thisTechButton.AvailableTurns:SetHide( true );
  			end
			-- update queue number if needed
			local queuePosition = player:GetQueuePosition( techID );
			if queuePosition == -1 then
				thisTechButton.TechQueue:SetHide( true );
			else
				thisTechButton.TechQueueLabel:SetText( tostring( queuePosition-1 ) );
				thisTechButton.TechQueue:SetHide( false );
			end
		end
  		-- update advisor icon if needed
 		--thisTechButton.AdvisorIcon:SetHide( true );
 	elseif (not player:CanEverResearch( techID ) or isAllowedToGetTechFree or stealingTechTargetPlayerID ~= -1) then
 		thisTechButton.AlreadyResearched:SetHide( true );
 		thisTechButton.CurrentlyResearching:SetHide( true );
 		thisTechButton.Available:SetHide( true );
 		thisTechButton.Unavailable:SetHide( true );
		thisTechButton.Locked:SetHide( false );
  		thisTechButton.FreeTech:SetHide( true );
		-- have queue number say "LOCKED"
		thisTechButton.TechQueueLabel:SetText( lockedString );
		thisTechButton.TechQueue:SetHide( false );
		-- hide the advisor icon
 		--thisTechButton.AdvisorIcon:SetHide( true );
		if(not scienceDisabled) then
			thisTechButton.TechButton:SetVoid1( -1 ); 
			thisTechButton.TechButton:SetVoid2( 0 ); -- num free techs
			AddCallbackToSmallButtons( thisTechButton, maxSmallButtons, -1, 0, Mouse.eLClick, TechSelected );
 		end
 	else -- currently unavailable
 		thisTechButton.AlreadyResearched:SetHide( true );
 		thisTechButton.CurrentlyResearching:SetHide( true );
 		thisTechButton.Available:SetHide( true );
 		thisTechButton.Unavailable:SetHide( false );
		thisTechButton.Locked:SetHide( true );
  		thisTechButton.FreeTech:SetHide( true );
 		-- update number of turns to research
 		if 	player:GetScience() > 0 then
  			thisTechButton.UnavailableTurns:SetText( turnText );
  			thisTechButton.UnavailableTurns:SetHide( false );
  		else
  			thisTechButton.UnavailableTurns:SetHide( true );
  		end
  		
		-- update queue number if needed
		local queuePosition = player:GetQueuePosition( techID );
		if queuePosition == -1 then
			thisTechButton.TechQueue:SetHide( true );
		else
			thisTechButton.TechQueueLabel:SetText( tostring( queuePosition-1 ) );
			thisTechButton.TechQueue:SetHide( false );
		end
		
 		-- update advisor icon if needed
 		--thisTechButton.AdvisorIcon:SetHide( true );

		if (isAllowedToGetTechFree) then
			thisTechButton.TechButton:SetVoid1( -1 ); 
			AddCallbackToSmallButtons( thisTechButton, maxSmallButtons, -1, 0, Mouse.eLClick, OnTechnologyButtonClicked );
		else
			if(not scienceDisabled) then
				thisTechButton.TechButton:SetVoid1( tech.ID );
				AddCallbackToSmallButtons( thisTechButton, maxSmallButtons, techID, numFreeTechs, Mouse.eLClick, TechSelected );
			end
		end
	end
end

----------------------------------------------------------------        
-- Input processing
----------------------------------------------------------------        

-------------------------------------------------------------------------------
-------------------------------------------------------------------------------
function OnCloseButtonClicked ()
	UIManager:DequeuePopup( ContextPtr );
    Events.SerialEventGameMessagePopupProcessed.CallImmediate(ButtonPopupTypes.BUTTONPOPUP_TECH_TREE, 0);
    g_isOpen = false;	
end
g_TechTree.CloseButton:RegisterCallback( Mouse.eLClick, OnCloseButtonClicked );

-------------------------------------------------------------------------------
-------------------------------------------------------------------------------

function InputHandler( uiMsg, wParam, lParam )
    if g_isOpen and uiMsg == KeyEvents.KeyDown then
        if wParam == Keys.VK_ESCAPE or wParam == Keys.VK_RETURN then
            UIManager:DequeuePopup( ContextPtr );
            g_isOpen = false;
            return true;
        end
    end
end
ContextPtr:SetInputHandler( InputHandler );


function ShowHideHandler( bIsHide, bIsInit )
    if( not bIsInit ) then
        if( not bIsHide ) then
        	UI.incTurnTimerSemaphore();
        else
        	UI.decTurnTimerSemaphore();
        end
    end
end
ContextPtr:SetShowHideHandler( ShowHideHandler );

----------------------------------------------------------------
-- 'Active' (local human) player has changed
----------------------------------------------------------------
function OnTechTreeActivePlayerChanged( iActivePlayer, iPrevActivePlayer )
	playerID = Game.GetActivePlayer();	
	player = Players[playerID];
	civType = GameInfo.Civilizations[player:GetCivilizationType()].Type;
	activeTeamID = Game.GetActiveTeam();
	activeTeam = Teams[activeTeamID];	
	-- Rebuild some tables	
	GatherInfoAboutUniqueStuff( civType );	
	
	-- So some extra stuff gets re-built on the refresh call
	if not g_isOpen then
		g_NeedsFullRefreshOnOpen = true;	
	else
		g_NeedsFullRefresh = true;
	end
	
	-- Close it, so the next player does not have to.
	OnCloseButtonClicked();
end
Events.GameplaySetActivePlayer.Add(OnTechTreeActivePlayerChanged);

-------------------------------------------------------------------------------
-------------------------------------------------------------------------------
function OnEventResearchDirty()
	if (g_isOpen) then
		RefreshDisplay();
	end
end
Events.SerialEventResearchDirty.Add(OnEventResearchDirty);

-------------------------------------------------------------------------------
-------------------------------------------------------------------------------

-- One time initialization
InitialSetup()