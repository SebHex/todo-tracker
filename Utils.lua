local addonName, addonTable = ...
local Metadata = addonTable.Metadata
local Libs = addonTable.Libs
local AceAddon = Libs.AceAddon
local AceDB = Libs.AceDB
local LibDataBroker = Libs.LibDataBroker
local LibDBIcon = Libs.LibDBIcon
local AceDBOptions = Libs.AceDBOptions
local AceConfig = Libs.AceConfig
local AceConfigDialog = Libs.AceConfigDialog
local viragAddonName = "ViragDevTool"
local viragFailedToLoad = false

local Utils = {}
addonTable.Utils = Utils

--[[
  Log data to the ViragDevTool addon.
  Recommended for debugging and addon development.

  See https://github.com/brittyazel/ViragDevTool
]]
function Utils:Log(data, name)
  if (not IsAddOnLoaded(viragAddonName)) then
    local loaded, reason = LoadAddOn(viragAddonName)

    if (not loaded and not viragFailedToLoad) then
      local warningIcon = CreateAtlasMarkup("services-icon-warning", 16, 16)
      local message = format(ADDON_LOAD_FAILED, viragAddonName, _G["ADDON_" .. reason])
      print(warningIcon .. "|cfff8e928", message, "|r")
      viragFailedToLoad = true
      return
    end
  end

  name = name or tostring(data)

  if (ViragDevToolFrame) then
    ViragDevTool:AddData(data, name)
  else
    ViragDevTool.list:AddNode(data, name)
  end
end

--[[
  Create an addon using Ace3.

  See https://www.wowace.com/projects/ace3/pages/api/ace-addon-3-0
]]
function Utils:CreateAddon(name)
  return AceAddon:NewAddon(name, "AceConsole-3.0")
end

--[[
  Create a db using Ace3.

  See https://www.wowace.com/projects/ace3/pages/api/ace-db-3-0
]]
function Utils:CreateDB(addon, name, defaultOptions)
  local db = AceDB:New(name, defaultOptions, true)
  db.RegisterCallback(addon, "OnProfileChanged", "RefreshConfig")
  db.RegisterCallback(addon, "OnProfileCopied", "RefreshConfig")
  db.RegisterCallback(addon, "OnProfileReset", "RefreshConfig")

  return db
end

--[[
  Create a minimap icon using LibDataBroker and LibDBIcon.
]]
function Utils:CreateMinimapIcon(options)
  local minimapIconData = LibDataBroker:NewDataObject(addonName, options)
  LibDBIcon:Register(addonName, minimapIconData, addonTable.db.profile.minimap)

  return LibDBIcon
end

--[[
  Create a config dialog using Ace3.
]]
function Utils:CreateConfigDialog(options, width, height)
  options.args.profile = AceDBOptions:GetOptionsTable(addonTable.db)
  AceConfig:RegisterOptionsTable(addonName, options)
  AceConfigDialog:AddToBlizOptions(addonName, Metadata.Title)
  AceConfigDialog:SetDefaultSize(addonName, width, height)

  return AceConfigDialog
end

--[[
  Set the minimap icon to shown or hidden.
]]
function Utils:SetMinimapIconShown(shown)
  if (shown) then
    LibDBIcon:Show(addonName)
  else
    LibDBIcon:Hide(addonName)
  end
end

local configDialogStatusText = format("|cff808080Version: %s • Author: %s|r", Metadata.Version, Metadata.Author)

--[[
  Open the config dialog.
]]
function Utils:OpenConfigDialog()
  if (AceConfigDialog.OpenFrames[addonName]) then
    return
  end

  AceConfigDialog:Open(addonName)
  DoEmote("READ", nil, true)
  Utils:PlaySound(SOUNDKIT.IG_QUEST_LOG_OPEN)
  
  local dialog = AceConfigDialog.OpenFrames[addonName]
  local dialogFrame = dialog and dialog.frame

  dialog:SetStatusText(configDialogStatusText)

  if (dialogFrame.hooked) then
    return
  end

  dialogFrame.hooked = true
  dialogFrame:HookScript("OnHide", function()
    CancelEmote()
    Utils:PlaySound(SOUNDKIT.IG_QUEST_LOG_CLOSE)
  end)
end

--[[
  Close the config dialog.
]]
function Utils:CloseConfigDialog()
  AceConfigDialog:Close(addonName)
end

--[[
  Toggle the config dialog.
]]
function Utils:ToggleConfigDialog()
  local isOpen = AceConfigDialog.OpenFrames[addonName]

  if (isOpen) then
    Utils:CloseConfigDialog()
  else
    Utils:OpenConfigDialog()
  end
end

--[[
  Play a sound by id if sound is enabled.
]]
function Utils:PlaySound(id, channel)
  local soundOptions = addonTable.db.profile.sound
  if (not soundOptions.enabled) then
    return
  end

  channel = channel or soundOptions.channel
  PlaySound(id, channel)
end

local questAddedSoundId = 618

--[[
  Add a new todo item to the todo list.
]]
function Utils:AddTodoItem(todoItem)
  tinsert(addonTable.db.profile.todoList, todoItem)
  Utils:PlaySound(questAddedSoundId)
  Utils:UpdateObjectiveTracker()
end

--[[
  Update the objective tracker.
]]
function Utils:UpdateObjectiveTracker()
  ObjectiveTracker_Update()
end
