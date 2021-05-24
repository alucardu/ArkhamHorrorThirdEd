posXToken = -35
posZToken = 0
drawnMythosTokens = {}
mythosCounter = 0

function draw_mythos_token(obj)
  ui = UI.getXmlTable()
  numberOfInvestigators = ui[1].children[2].children
  posXToken = posXToken + 0.4

  if obj.getQuantity() == 0 then
    posXToken = -35
    posZToken = 0

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
    position = {x = posXToken, y = 2, z = posZToken},
  })

  table.insert(drawnMythosTokens, takenObject)

  if takenObject.hasTag('Doom') then getObjectFromGUID('077454').call('spreadDoom') end
  if takenObject.getName() == 'Read Headline' then getObjectFromGUID('4e81c7').call('readHeadline') end
  if takenObject.getName() == 'Blank' then getObjectFromGUID('50363f').call('blank') end 
  if takenObject.getName() == 'Spawn Monster' then getObjectFromGUID('85fc44').call('spawnMonster') end
  if takenObject.getName() == 'Spawn Clue' then getObjectFromGUID('3e54de').call('spawnClue', 1) end
  if takenObject.getName() == 'Gate Burst' then getObjectFromGUID('f3944a').call('gateBurst') end
  if takenObject.getName() == 'Reckoning' then getObjectFromGUID('432f00').call('reckoning') end 
  if takenObject.getName() == 'Spread Terror' then getObjectFromGUID('02db23').call('spreadTerror') end

  mythosCounter = mythosCounter + 1
  broadcastToAll('Mythostokens ' .. mythosCounter .. ' of 2 drawn', {0, 1, 0})

  for i = 1, #numberOfInvestigators, 1 do    
    if mythosCounter == i*2 then
      posXToken = posXToken + 1.5
    end
  end

  if mythosCounter == #numberOfInvestigators * 2 then
    mythosCounter = 0
    posXToken = - 35
    posZToken = posZToken - 1.5
  end

end