posZToken = 0
drawnMythosTokens = {}
mythosCounter = 0

function onLoad()
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

  self.createButton(params)
end

function draw_mythos_token()
  if mythosCupPos == null then 
    mythosCupPos = self.getPosition()
    mythosCupPos = {
      x=mythosCupPos.x + 4,
      y=mythosCupPos.y,
      z=mythosCupPos.z
    }
  end

  ui = UI.getXmlTable()
  numberOfInvestigators = ui[1].children[2].children
  mythosCupPos.x = mythosCupPos.x + 0.4

  if self.getQuantity() == 0 then
    posZToken = 0

    for i, mythosToken in ipairs(drawnMythosTokens) do
      if mythosToken ~= nill then
        self.putObject(mythosToken)
      end
    end

    drawnMythosTokens = {}
    self.shuffle()
    return
  end

  local takenObject = self.takeObject({
    position = {
      x=mythosCupPos.x,
      y=2,
      z=posZToken
    }
  })

  table.insert(drawnMythosTokens, takenObject)

  scenarioSetup = getObjectFromGUID('3e1179')

  if takenObject.hasTag('Doom') then getObjectFromGUID('077454').call('spreadDoom') end
  if takenObject.hasTag('Blank') then getObjectFromGUID('50363f').call('blank') end
  if takenObject.hasTag('Reckoning') then getObjectFromGUID('432f00').call('reckoning') end 
  if takenObject.hasTag('Spread Terror') then getObjectFromGUID('02db23').call('spreadTerror') end

  if takenObject.hasTag('Read Headlines') then scenarioSetup.getVar('readHeadlinesToken').call('readHeadline') end
  if takenObject.hasTag('Spawn Monster') then scenarioSetup.getVar('spawnMonster').call('spawnMonster') end
  if takenObject.hasTag('Spawn Clue') then scenarioSetup.getVar('spawnClue').call('spawnClue') end
  if takenObject.hasTag('Gate Burst') then scenarioSetup.getVar('gateBurst').call('gateBurst') end

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