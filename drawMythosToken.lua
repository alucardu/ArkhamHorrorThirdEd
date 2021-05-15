posToken = -35
drawnMythosTokens = {}

function draw_mythos_token(obj)
  posToken = posToken + 0.4

  if obj.getQuantity() == 0 then
    posToken = -35

    for i, mythosToken in ipairs(drawnMythosTokens) do
      if mythosToken ~= nill then
        obj.putObject(mythosToken)
      end
    end

    drawnMythosTokens = {}
    obj.shuffle()
    obj.shuffle()
    obj.shuffle()
    obj.shuffle()
    return
  end

  local takenObject = obj.takeObject({
    position = {x = posToken, y = 2, z = 0},
  })

  table.insert(drawnMythosTokens, takenObject)

  if takenObject.getName() == 'Spread Doom' then getObjectFromGUID('077454').call('spreadDoom') end
  if takenObject.getName() == 'Read Headline' then getObjectFromGUID('4e81c7').call('readHeadline') end
  if takenObject.getName() == 'Blank' then getObjectFromGUID('50363f').call('blank') end 
  if takenObject.getName() == 'Spawn Monster' then getObjectFromGUID('85fc44').call('spawnMonster') end
  if takenObject.getName() == 'Spawn Clue' then getObjectFromGUID('3e54de').call('spawnClue') end
  if takenObject.getName() == 'Gate Burst' then getObjectFromGUID('f3944a').call('gateBurst') end
  if takenObject.getName() == 'Reckoning' then getObjectFromGUID('432f00').call('reckoning') end 
  if takenObject.getName() == 'Spread Terror' then getObjectFromGUID('02db23').call('spreadTerror') end 

end