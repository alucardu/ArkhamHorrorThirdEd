selected = true
investigatorsObj = getObjectFromGUID('69581b')
selectedInvestigators = {}
investigators = {
  '5244f1', '194c1c', 'ff211a'
}

function onLoad()
  for index, value in ipairs(investigators) do
    local investigator = getObjectFromGUID(value)
    name = investigator.getName()
    params = {
      click_function = "click_func",
      function_owner = self,
      width          = 1000,
      height         = 1400,
      color          = {255, 255, 255, 0},
      tooltip        = 'Click to select ' .. name .. ' as your investigator',
    }
    investigator.createButton(params)
    
    local func = function(player_color) setStatus('White', investigator) end
    investigator.addContextMenuItem('Normal', func)

    local func = function(player_color) setStatus('Green', investigator) end
    investigator.addContextMenuItem('Blessed', func)

    local func = function(player_color) setStatus('Orange', investigator) end
    investigator.addContextMenuItem('Cursed', func)
  end
  
end

function click_func(obj, player_clicker_color, alt_click)
  if obj.getVar('selected') == true then 
    obj.setVar('selected', false)
    obj.editButton({tooltip='Click to select ' .. obj.getName() .. ' as your investigator'})    
    else
      obj.setVar('selected', true)
      obj.editButton({tooltip='Click to unselect ' .. obj.getName() .. ' as your investigator'})
  end

  table.insert(selectedInvestigators, obj)

  investigatorsObj.setTable('investigator', { obj, player_clicker_color })
  investigatorsObj.call('updateInvestigators')
end

function removeInvestigatorsSelectButtons()
  for i, investigator in ipairs(selectedInvestigators) do
    investigator.clearButtons()
  end
end

function setStatus(status, investigator)
  investigatorsObj.call('setInvestigatorStatus', {status, investigator})
end