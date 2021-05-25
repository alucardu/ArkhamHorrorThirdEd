posZToken = 0
drawnMythosTokens = {}
mythosCounter = 0

function onObjectLeaveContainer(container, leave_object)
  if leave_object.hasTag('Mythos Cup') then
    local params = {
      label="Draw Mythos Token",
      click_function="draw_mythos_token",
      function_owner=self,
      position={0,0.3,-2},
      rotation={0,180,0},
      height=350,
      width=800,
      font_size=250,
      color={0,0,0},
      font_color={1,1,1}
    }
  
    leave_object.createButton(params)
  end
end

function draw_mythos_token(obj)
  if mythosCupPos == null then 
    mythosCupPos = getObjectFromGUID('3e1179').getVar('mythosCup').getPosition()
    mythosCupPos = {
      x=mythosCupPos.x + 4,
      y=mythosCupPos.y,
      z=mythosCupPos.z
    }
  end

  ui = UI.getXmlTable()
  numberOfInvestigators = ui[1].children[2].children
  mythosCupPos.x = mythosCupPos.x + 0.4

  if obj.getQuantity() == 0 then
    posZToken = 0

    for i, mythosToken in ipairs(drawnMythosTokens) do
      if mythosToken ~= nill then
        obj.putObject(mythosToken)
      end
    end

    drawnMythosTokens = {}
    obj.shuffle()
    return
  end

  local takenObject = obj.takeObject({
    position = {
      x=mythosCupPos.x,
      y=2,
      z=posZToken
    }
  })

  table.insert(drawnMythosTokens, takenObject)

  if takenObject.hasTag('Doom') then getObjectFromGUID('077454').call('spreadDoom') end
  if takenObject.hasTag('Read Headlines') then getObjectFromGUID('3e1179').getVar('readHeadlinesToken').call('readHeadline') end
  if takenObject.hasTag('Blank') then getObjectFromGUID('50363f').call('blank') end 
  if takenObject.hasTag('Spawn Monster') then getObjectFromGUID('0d44f6').call('spawnMonster') end
  if takenObject.hasTag('Spawn Clue') then getObjectFromGUID('98bc78').call('spawnClue') end
  if takenObject.hasTag('Gate Burst') then getObjectFromGUID('151eec').call('gateBurst') end
  if takenObject.hasTag('Reckoning') then getObjectFromGUID('432f00').call('reckoning') end 
  if takenObject.hasTag('Spread Terror') then getObjectFromGUID('02db23').call('spreadTerror') end

  mythosCounter = mythosCounter + 1
  broadcastToAll('Mythostokens ' .. mythosCounter .. ' of ' .. #numberOfInvestigators * 2 .. ' drawn', {0, 1, 0})

  for i = 1, #numberOfInvestigators, 1 do    
    if mythosCounter == i*2 then
      mythosCupPos.x = mythosCupPos.x + 1.5
    end
  end

  if mythosCounter == #numberOfInvestigators * 2 then
    mythosCounter = 0
    mythosCupPos.x = mythosCupPos.x - #numberOfInvestigators * 2.3
    posZToken = posZToken - 1.5
  end

end