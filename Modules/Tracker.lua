local addonName, addonTable = ...
local Metadata = addonTable.Metadata
local Utils = addonTable.Utils
local Tracker = addonTable.Modules.Tracker

function Tracker:OnInitialize()
  self:RegisterEvent("BAG_UPDATE", Utils.UpdateObjectiveTracker)
  self:RegisterEvent("PLAYER_MONEY", Utils.UpdateObjectiveTracker)
  self:RegisterEvent("CURRENCY_DISPLAY_UPDATE", Utils.UpdateObjectiveTracker)
end
