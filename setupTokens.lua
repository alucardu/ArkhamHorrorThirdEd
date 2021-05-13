healthTokens = {
  '4d1c83',
  'a8f895',
  '2767a6',
  'ff446b',
  'e9e423',
  '503919',
  '35d114',
  '036575',
  '827f0a',
  '39f2ef',
  '4f1567',
  '684fca',
  '4d5926',
  '786991',
  '3a02f4',
  '5bf90d',
  'ce99cd',
  '4b7ce4',
  '5c0f98',
  '59a5bb',
  '467c9f',
  'e8e5a8',
  '68b737',
  'd0c1a5',
  '60322c',
  '819244',
  '59ab4a',
  '3df13c',
}

sanityTokens = {
  'b36d54',
  'bcb642',
  '621816',
  'f8f7fb',
  '1148bc',
  'ff01c1',
  'f9cda7',
  'af94a1',
  '502e72',
  '224c53',
  'e8419a',
  '0cbcb2',
  '3d5a05',
  'bcdad0',
  'a0376b',
  'f18015',
  '6c60ca',
  'd396bc',
  '708d9a',
  'e492d3',
  'eb3642',
  'aa08bd',
  'f308c0',
  'f307c8',
  '06d154',
  'bf6549',
  'd0926e',
  'beb96f',

}

moneyTokens = {
  '61778a',
  '13cbe4',
  '167cfd',
  'd1428a',
  'b80541',
  '2e4919',
  'd3a6b2',
  'fc1570',
  '3bda3b',
  '03331d',
  'f7a4e8',
  'd41abd',
  '1ed90b',
  'e09691',
  '807d2e',
  'c326ff',
  'd174fb',
  '8fbc75',
  '104fdc',
  '55ff8a',
  '5b09e0',
  '859910',
  '584564',
  '9450bd',
  '38fbc2',
  '547a11',
  '4faf21',
  'eb9226',
}

MIN_VALUE = 0
MAX_VALUE = 30

function onload(saved_data)
  createButtons(healthTokens, {1,0,0,255})
  createButtons(sanityTokens, {0,0,1,255})
  createButtons(moneyTokens, {0.192, 0.312, 0.168,255})
end

function createButtons(tokens, font_color)
  for index, tokenGUID in ipairs(tokens) do
    healthToken = getObjectFromGUID(tokenGUID)
    saved_data = getObjectFromGUID(tokenGUID).script_state

    if saved_data ~= "" then
      print(saved_data)
      local loaded_data = JSON.decode(saved_data)
      --Set up information off of loaded_data
      healthToken.setVar('value', loaded_data[1])
    else
        --Set up information for if there is no saved saved data
        value = 0
    end


    params = {
      label=tostring(healthToken.getVar('value')),
      click_function="click_func",
      function_owner = self,
      position={0,0.1,0.2},
      height=500,
      width=500,
      font_size=500,
      scale={x=3, y=3, z=3},
      font_color=font_color, 
      color = {0,0,0,0}
    }
  
    healthToken.createButton(params)
  end
end

function click_func(obj, player_clicker_color, alt_click)
  mod = alt_click and -1 or 1
  new_value = math.min(math.max(obj.getVar('value') + mod, MIN_VALUE), MAX_VALUE)
  if obj.getVar('value') ~= new_value then
    obj.setVar('value', new_value)
    updateDisplay(obj)
    updateSave(obj)
  end
end

function updateDisplay(obj)
  obj.editButton({index = 0, label = tostring(obj.getVar('value'))})
end

function updateSave(obj)
  local data_to_save = {value}
  saved_data = JSON.encode(data_to_save)
  obj.script_state = saved_data
end