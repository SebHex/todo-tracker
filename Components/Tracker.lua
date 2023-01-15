local addonName, addonTable = ...
local Metadata = addonTable.Metadata
local Utils = addonTable.Utils

local TrackerModule = ObjectiveTracker_GetModuleInfoTable("TrackerModule")
local Header = CreateFrame("Frame", addonName .. "Header", ObjectiveTrackerFrame.BlocksFrame, "ObjectiveTrackerHeaderTemplate")

TrackerModule.updateReasonModule = 4294967295
TrackerModule:SetHeader(Header, Metadata.Title)

hooksecurefunc("ObjectiveTracker_Initialize", function(self)
  tinsert(self.MODULES, TrackerModule)
  tinsert(self.MODULES_UI_ORDER, TrackerModule)
end)

local lineTypeAnim = {
  template = "QuestObjectiveAnimLineTemplate",
  freeLines = {}
}

-- Don't call this function directly, instead call "ObjectiveTracker_Update()"
function TrackerModule:Update()
  local todoList = addonTable.db.profile.todoList

  if (not todoList) then
    return
  end

  self:BeginLayout()

  -- For each segment, create a block and add it to TrackerModule
  for i, segment in ipairs(todoList) do
    local block = self:GetBlock(i)
    self:SetBlockHeader(block, segment.text)

    for i, item in ipairs(segment.items) do
      local dashStyle = item.completed and OBJECTIVE_DASH_STYLE_HIDE or OBJECTIVE_DASH_STYLE_SHOW
      local colorStyle = OBJECTIVE_TRACKER_COLOR[item.completed and "Complete" or "Normal"]
      self:AddObjective(block, i, item.text, lineTypeAnim, nil, dashStyle, colorStyle)
    end

    block:SetHeight(block.height)

    if (ObjectiveTracker_AddBlock(block)) then
      block:Show()
      self:FreeUnusedLines(block)
    else
      block.used = false
      break
    end
  end

  self:EndLayout()
end

local function ToggleDropDown(self, level)
  local block = self.activeFrame
  local blockTitle = block.HeaderText:GetText()

  local info = UIDropDownMenu_CreateInfo()
  info.text = blockTitle
  info.isTitle = 1
  info.notCheckable = 1
  UIDropDownMenu_AddButton(info, level)

  local info = UIDropDownMenu_CreateInfo()
  info.text = "Open Details"
  info.notCheckable = 1
  info.func = Utils.OpenConfigDialog
  UIDropDownMenu_AddButton(info, level)
end

function TrackerModule:OnBlockHeaderClick(block, button)
  if (button == "LeftButton") then
    Utils:ToggleConfigDialog()
  elseif (button == "RightButton") then
    ObjectiveTracker_ToggleDropDown(block, ToggleDropDown)
  end
end
