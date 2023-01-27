local addonName, addonTable = ...
local Metadata = addonTable.Metadata
local Utils = addonTable.Utils

-- Default options for AceDB database
local defaultDBOptions = {
  profile = {
    todoList = {},
    minimap = {
      hide = false
    },
    sound = {
      enabled = true,
      channel = "SFX"
    }
  }
}

-- See https://www.wowace.com/projects/libdbicon-1-0
local minimapIconOptions = {
  icon = Metadata.IconPath,
  OnTooltipShow = function(tooltip)
    tooltip:AddLine(Metadata.Title)
    tooltip:AddLine("Click to toggle the options menu")
  end,
  OnClick = function()
    Utils:ToggleConfigDialog()
  end
}

-- See https://www.wowace.com/projects/ace3/pages/ace-config-3-0-options-tables
local configDialogOptions = {
  name = Metadata.Title,
  type = "group",
  childGroups = "tab",
  args = {
    todoTab = {
      order = 1,
      type = "group",
      name = "Todo",
      args = {}
    },
    optionsTab = {
      order = 2,
      type = "group",
      name = "Options",
      args = {
        generalOptions = {
          order = 1,
          type = "group",
          name = "General",
          args = {
            minimapIconToggle = {
              name = "Minimap icon",
              desc = "Show the minimap icon",
              type = "toggle",
              get = function(info)
                return not addonTable.db.profile.minimap.hide
              end,
              set = function(info, value)
                addonTable.db.profile.minimap.hide = not value
                Utils:SetMinimapIconShown(value)
              end
            }
          }
        },
        soundOptions = {
          order = 2,
          type = "group",
          name = "Sound",
          args = {
            soundToggle = {
              order = 1,
              name = "Enable sound",
              desc = "Play a sound when an item is created, updated or abandoned",
              type = "toggle",
              get = function(info)
                return addonTable.db.profile.sound.enabled
              end,
              set = function(info, value)
                addonTable.db.profile.sound.enabled = value
              end
            },
            soundChannelDropdown = {
              order = 2,
              name = "Sound channel",
              desc = "Select the sound channel to play the sound on. Defaults to \"Effects\"",
              type = "select",
              values = {
                ["Master"] = "Master",
                ["SFX"] = "Effects",
                ["Music"] = "Music",
                ["Ambience"] = "Ambience",
                ["Dialog"] = "Dialog"
              },
              get = function(info)
                return addonTable.db.profile.sound.channel
              end,
              set = function(info, value)
                addonTable.db.profile.sound.channel = value
              end
            }
          }
        }
      }
    }
  }
}

addonTable.Addon = Utils:CreateAddon(addonName, defaultDBOptions)
local Addon = addonTable.Addon

function Addon:OnInitialize()
  addonTable.db = Utils:CreateDB(self, Metadata.DBName, defaultDBOptions)
  addonTable.MinimapIcon = Utils:CreateMinimapIcon(minimapIconOptions)
  addonTable.ConfigDialog = Utils:CreateConfigDialog(configDialogOptions, 800, 540)
  self:RegisterChatCommand(Metadata.Initials, "SlashCommand")
end

function Addon:RefreshConfig(event)
  Utils:SetMinimapIconShown(not addonTable.db.profile.minimap.hide)
  Utils:UpdateObjectiveTracker()
end

function Addon:SlashCommand(input)
  if (input == "") then
    Utils:ToggleConfigDialog()
  elseif (input == "logs") then
    Utils:ToggleLogsDialog()
  end
end

local Modules = {}
addonTable.Modules = Modules
Modules.Tracker = Addon:NewModule("Tracker", "AceEvent-3.0")
