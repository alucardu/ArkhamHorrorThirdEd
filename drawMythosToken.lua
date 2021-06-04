posZToken = 0
posXToken = 0
mythosCounter = 0
state = {}
drawnMythosTokens = {}

function onSave()
  local state = {
    posZToken = posZToken,
    posXToken = posXToken,
    mythosCounter = mythosCounter,
    drawnMythosTokens = drawnMythosTokens
  }
  return JSON.encode(state)
end

function onLoad(script_state)
  local state = JSON.decode(script_state)
  if state ~= nil then
    posXToken = state.posXToken
    posZToken = state.posZToken
    mythosCounter = state.mythosCounter
    drawnMythosTokens = state.drawnMythosTokens
  end

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
  if posXToken ~= 0 then
    mythosCupPos.x = posXToken + 0.4
    else
      mythosCupPos.x = mythosCupPos.x + 0.4
  end

  if self.getQuantity() == 0 then
    posZToken = 0

    for i, mythosToken in ipairs(drawnMythosTokens) do
      if getObjectFromGUID(mythosToken) ~= nill then
        self.putObject(getObjectFromGUID(mythosToken))
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

  posXToken = mythosCupPos.x
  table.insert(drawnMythosTokens, takenObject.guid)

  scenarioSetup = getObjectFromGUID('3e1179')

  if takenObject.hasTag('Blank') then getObjectFromGUID('50363f').call('blank') end
  if takenObject.hasTag('Reckoning') then getObjectFromGUID('432f00').call('reckoning') end 

  if takenObject.hasTag('Doom') then scenarioSetup.getVar('spreadDoom').call('spreadDoom') end
  if takenObject.hasTag('Spread Terror') then scenarioSetup.getVar('spreadTerror').call('mythosTerror') end
  if takenObject.hasTag('Read Headlines') then scenarioSetup.getVar('readHeadlinesToken').call('readHeadline') end
  if takenObject.hasTag('Spawn Monster') then scenarioSetup.getVar('spawnMonster').call('spawnMonster') end
  if takenObject.hasTag('Spawn Clue') then scenarioSetup.getVar('spawnClue').call('spawnClue') end
  if takenObject.hasTag('Gate Burst') then scenarioSetup.getVar('gateBurst').call('gateBurst') end

  mythosCounter = mythosCounter + 1
  broadcastToAll('Mythostokens ' .. mythosCounter .. ' of ' .. #numberOfInvestigators * 2 .. ' drawn', {0, 1, 0})

  for i = 1, #numberOfInvestigators, 1 do    
    if mythosCounter == i*2 then
      mythosCupPos.x = mythosCupPos.x + 1.5
      posXToken = mythosCupPos.x
    end
  end

  if mythosCounter == #numberOfInvestigators * 2 then
    mythosCounter = 0
    mythosCupPos.x = mythosCupPos.x - #numberOfInvestigators * 2.3
    posZToken = posZToken - 1.5
    posXToken = mythosCupPos.x
  end

end