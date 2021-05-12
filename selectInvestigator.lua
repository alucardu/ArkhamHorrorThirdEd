selected = true
investigators = {
  '5244f1', '194c1c', 'ff211a'
}

function onLoad()
  for index, value in ipairs(investigators) do
    investigator = getObjectFromGUID(value)
    name = investigator.getName()
    params = {
      click_function = "click_func",
      function_owner = self,
      label          = "Select",
      position       = {0, 1, 0},
      rotation       = {0, 0, 0},
      width          = 800,
      height         = 400,
      font_size      = 340,
      color          = {0.5, 0.5, 0.5},
      font_color     = {1, 1, 1},
      tooltip        = "This text appears on mouseover.",
    }
    investigator.createButton(params)
  end
  
end

function click_func(obj, player_clicker_color, alt_click)
  investigatorsObj = getObjectFromGUID('02bfa6')
  if obj.getVar('selected') == true then 
    obj.setVar('selected', false)
    obj.editButton({label="Select"})
    else
      obj.setVar('selected', true)
      obj.editButton({label="Unselect"})
  end

  investigatorsObj.setTable('investigator', { obj.getName(), player_clicker_color })
  investigatorsObj.call('updateChildren')
  investigatorsObj.call('updateInvestigators')
end