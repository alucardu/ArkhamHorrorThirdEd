investigatorsObj = getObjectFromGUID('69581b')
selectedInvestigators = {}
investigators = {
  getObjectFromGUID('5244f1'),
  getObjectFromGUID('194c1c'),
  getObjectFromGUID('ff211a')
}

function onSave()
  local state = {
    selectedInvestigators = returnSelectedInvestigatorGuid()
  }
  return JSON.encode(state)
end

function onLoad(script_state)
  state = JSON.decode(script_state)

  for index, investigator in ipairs(investigators) do
    local investigator = investigator
    name = investigator.getName()

    setSelectBtn(investigator)
    
    local func = function(player_color) setStatus('White', investigator) end
    investigator.addContextMenuItem('Normal', func)

    local func = function(player_color) setStatus('Green', investigator) end
    investigator.addContextMenuItem('Blessed', func)

    local func = function(player_color) setStatus('Orange', investigator) end
    investigator.addContextMenuItem('Cursed', func)
  end

  if state ~= nil then
    for _, selectedInvestigatorGuid in ipairs(state.selectedInvestigators) do
      table.insert(selectedInvestigators, getObjectFromGUID(selectedInvestigatorGuid))
      getObjectFromGUID(selectedInvestigatorGuid).clearButtons()
    end
  end
end

function click_func(obj, player_clicker_color, alt_click)
  table.insert(selectedInvestigators, obj)

  investigatorsObj.setTable('investigator', { obj, player_clicker_color })
  investigatorsObj.call('updateInvestigators')
  obj.clearButtons()
end

function removeInvestigatorsSelectButtons()
  for i, investigator in ipairs(selectedInvestigators) do
    investigator.clearButtons()
  end
end

function setStatus(status, investigator)
  investigatorsObj.call('setInvestigatorStatus', {status, investigator})
end

function setSelectBtn(investigator)
  local params = {
    click_function = "click_func",
    function_owner = self,
    width          = 1000,
    height         = 1400,
    color          = {255, 255, 255, 0},
    tooltip        = 'Click to select ' .. name .. ' as your investigator',
  }
  investigator.createButton(params)
end

function resetBtn(id)
  for i, investigator in ipairs(investigators) do
    if investigator.getName() == id then
      setSelectBtn(investigator)
    end
  end
end

function returnSelectedInvestigatorGuid()
  local t = {}
  for i, investigator in ipairs(selectedInvestigators) do
    t[i] = investigator.guid
  end
  return t
end