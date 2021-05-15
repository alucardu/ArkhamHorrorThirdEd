
neighborhoodTiles = {}
neighborhoodDecks = {}

headlines = getObjectFromGUID('f9b203')
headlinesDeck = {}
headlinesDeckPos = {}
discardDeck = nil
monsterDeck = ''
eventDeck = ''
posToken = -35
drawnMythosTokenGuids = {}
scenarios = {
  'd14543',
  '924d1a',
  'a4853a',
  'c2eec7',
  '8ab878',
  '38a061',
  '88f120',
  'c3bc3c',
  'c73dd8',
  '23fe4c',
  '1de1e0',
  '6c3d2b',
  'ba40c5',
  'eaf3e6',
  '786f08',
  '9420c2',
  '0e6d75',
  '75b4bb',
  '8434b9',
  'fd4ab7',
}

function onload(saved_data)

  for index, scenarioGUID in ipairs(scenarios) do
    scenario = getObjectFromGUID(scenarioGUID)
    saved_data = getObjectFromGUID(scenarioGUID).script_state

    if saved_data ~= "" then
      local loaded_data = JSON.decode(saved_data)
      --Set up information off of loaded_data
      scenario.setTable('memoryList', loaded_data.ml)
      -- memoryList = loaded_data.ml
    else
        --Set up information for if there is no saved saved data
        memoryList = {}
    end

    if next(scenario.getTable('memoryList')) == nil then

      params = {
        label="Setup",
        click_function="buttonClick_setup",
        function_owner=self,
        position={0,0.3,-2},
        rotation={0,180,0},
        height=350,
        width=800,
        font_size=250,
        color={0,0,0},
        font_color={1,1,1}
      }

      scenario.createButton(params)
    else
        createMemoryActionButtons(scenario)
    end
  end
end


--Beginning Setup


--Make setup button
function createSetupButton()
  self.createButton({
      label="Setup", click_function="buttonClick_setup", function_owner=self,
      position={0,0.3,-2}, rotation={0,180,0}, height=350, width=800,
      font_size=250, color={0,0,0}, font_color={1,1,1}
  })
end

--Triggered by setup button,
function buttonClick_setup()
  memoryListBackup = duplicateTable(memoryList)
  memoryList = {}
  self.clearButtons()
  createButtonsOnAllObjects()
  createSetupActionButtons()
end

--Creates selection buttons on objects
function createButtonsOnAllObjects()
  local howManyButtons = 0
  for _, obj in ipairs(getAllObjects()) do
      if obj ~= self then
          local dummyIndex = howManyButtons
          --On a normal bag, the button positions aren't the same size as the bag.
          globalScaleFactor = 1.25 * 1/self.getScale().x
          --Super sweet math to set button positions
          local selfPos = self.getPosition()
          local objPos = obj.getPosition()
          local deltaPos = findOffsetDistance(selfPos, objPos, obj)
          local objPos = rotateLocalCoordinates(deltaPos, self)
          objPos.x = -objPos.x * globalScaleFactor
          objPos.y = objPos.y * globalScaleFactor
          objPos.z = objPos.z * globalScaleFactor
          --Offset rotation of bag
          local rot = self.getRotation()
          rot.y = -rot.y + 180
          --Create function
          local funcName = "selectButton_" .. howManyButtons
          local func = function() buttonClick_selection(dummyIndex, obj) end
          self.setVar(funcName, func)
          self.createButton({
              click_function=funcName, function_owner=self,
              position=objPos, rotation=rot, height=1000, width=1000,
              color={0.75,0.25,0.25,0.6},
          })
          howManyButtons = howManyButtons + 1
      end
  end
end

--Creates submit and cancel buttons
function createSetupActionButtons()
  self.createButton({
      label="Cancel", click_function="buttonClick_cancel", function_owner=self,
      position={0,0.3,-2}, rotation={0,180,0}, height=350, width=1100,
      font_size=250, color={0,0,0}, font_color={1,1,1}
  })
  self.createButton({
      label="Submit", click_function="buttonClick_submit", function_owner=self,
      position={0,0.3,-2.8}, rotation={0,180,0}, height=350, width=1100,
      font_size=250, color={0,0,0}, font_color={1,1,1}
  })
  self.createButton({
      label="Reset", click_function="buttonClick_reset", function_owner=self,
      position={-2,0.3,0}, rotation={0,270,0}, height=350, width=800,
      font_size=250, color={0,0,0}, font_color={1,1,1}
  })
end


--During Setup


--Checks or unchecks buttons
function buttonClick_selection(index, obj)
  local color = {0,1,0,0.6}
  if memoryList[obj.getGUID()] == nil then
      self.editButton({index=index, color=color})
      --Adding pos/rot to memory table
      local pos, rot = obj.getPosition(), obj.getRotation()
      --I need to add it like this or it won't save due to indexing issue
      memoryList[obj.getGUID()] = {
          pos={x=round(pos.x,4), y=round(pos.y,4), z=round(pos.z,4)},
          rot={x=round(rot.x,4), y=round(rot.y,4), z=round(rot.z,4)},
          lock=obj.getLock()
      }
      obj.highlightOn({0,1,0})
  else
      color = {0.75,0.25,0.25,0.6}
      self.editButton({index=index, color=color})
      memoryList[obj.getGUID()] = nil
      obj.highlightOff()
  end
end

--Cancels selection process
function buttonClick_cancel()
  memoryList = memoryListBackup
  self.clearButtons()
  if next(memoryList) == nil then
      createSetupButton()
  else
      createMemoryActionButtons()
  end
  removeAllHighlights()
  broadcastToAll("Selection Canceled", {1,1,1})
end

--Saves selections
function buttonClick_submit()
  if next(memoryList) == nil then
      broadcastToAll("You cannot submit without any selections.", {0.75, 0.25, 0.25})
  else
      self.clearButtons()
      createMemoryActionButtons()
      local count = 0
      for guid in pairs(memoryList) do
          count = count + 1
          local obj = getObjectFromGUID(guid)
          if obj ~= nil then obj.highlightOff() end
      end
      broadcastToAll(count.." Objects Saved", {1,1,1})
      updateSave(obj)
  end
end

--Resets bag to starting status
function buttonClick_reset()
  memoryList = {}
  self.clearButtons()
  createSetupButton()
  removeAllHighlights()
  broadcastToAll("Tool Reset", {1,1,1})
  updateSave(obj)
end


--After Setup


--Creates recall and place buttons
function createMemoryActionButtons(scenario)
  scenario.createButton({
      label="Place",
      click_function="buttonClick_place",
      function_owner=self,
      position={0,0.3,-2},
      rotation={0,180,0},
      height=350,
      width=800,
      font_size=250,
      color={0,0,0},
      font_color={1,1,1}
  })
  scenario.createButton({
      label="Recall",
      click_function="buttonClick_recall",
      function_owner=self,
      position={0,0.3,-2.8},
      rotation={0,180,0},
      height=350, width=800,
      font_size=250,
      color={0,0,0},
      font_color={1,1,1}
  })
  scenario.createButton({
      label="Setup",
      click_function="buttonClick_setup",
      function_owner=self,
      position={-2,0.3,0},
      rotation={0,270,0},
      height=350,
      width=800,
      font_size=250,
      color={0,0,0},
      font_color={1,1,1}
  })
end

--Sends objects from bag/table to their saved position/rotation
function buttonClick_place(obj)

  local bagObjList = obj.getObjects()
  for guid, entry in pairs(obj.getTable('memoryList')) do
      local scenario = getObjectFromGUID(guid)
      --If obj is out on the table, move it to the saved pos/rot
      if scenario ~= nil then
        scenario.setPositionSmooth(entry.pos)
        scenario.setRotationSmooth(entry.rot)
        scenario.setLock(entry.lock)
      else
        --If obj is inside of the bag
        for _, bagObj in ipairs(bagObjList) do
          if bagObj.guid == guid then
            local item = obj.takeObject({
                guid=guid, position=entry.pos, rotation=entry.rot,
            })
            item.setLock(entry.lock)

            if (item.getTags()[2]) == 'Deck' then table.insert(neighborhoodDecks, item) end
            if item.getTags()[2] == 'Neighborhood' then table.insert(neighborhoodTiles, item) end

            if item.getName() == 'Mythos Cup' then addButtonsToMythosCup(item.getGUID()) end
            if item.getName() == 'Monsters' then monsterDeck = getObjectFromGUID(item.getGUID()) end
            if item.getName() == 'Event' then eventDeck = getObjectFromGUID(item.getGUID()) end
            if item.getName() == 'Headlines' then headlines = getObjectFromGUID(item.getGUID()) end

            break
          end
        end
      end
  end
  Wait.frames(
    function()
      local headlines = obj.takeObject({
        position={20, 20, 20},
      })
      setHeadlines(headlines.getDescription())
      headlines.destroyObject()
    end,
    24
  )

  for i,o in ipairs(neighborhoodTiles) do
    local func = function(player_color) drawNeighborhoodEncounter(player_color, i, o) end
    o.addContextMenuItem('Draw encounter', func)
  end

  broadcastToAll("Objects Placed", {1,1,1})
end

function setHeadlines(amount)
  headlinesDeckPos = headlines.getPosition()
  headlinesDeckPos = {x = headlinesDeckPos.x - 0.2, y = headlinesDeckPos.y, z = headlinesDeckPos.z - 15}
  headlines.shuffle()
  headlines.shuffle()
  headlines.shuffle()

  headlinesDeck = headlines.cut(tonumber(amount))
  
  Wait.frames(
    function()
      headlinesDeck = headlinesDeck[2]
      headlinesDeck.setPositionSmooth(
        headlinesDeckPos
      )
      headlinesDeck.setRotationSmooth(
        {180, 0, 0}
      )
    end,
    64
  )
end 

function addButtonsToMythosCup(guid)
  cup = getObjectFromGUID(guid)

  params = {
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

  cup.createButton(params)
end

function draw_mythos_token(obj)

  posToken = posToken + 0.4

  if obj.getQuantity() == 0 then
    posToken = -35
    for i, tokenGuid in ipairs(drawnMythosTokenGuids) do
      local token = getObjectFromGUID(tokenGuid)
      if token ~= nill then
        obj.putObject(token)
      end
    end
    drawnMythosTokenGuids = {}
    obj.shuffle()
    obj.shuffle()
    obj.shuffle()
    obj.shuffle()
    return
  end

  local takenObject = obj.takeObject({
    position = {x = posToken, y = 2, z = 0},
  })

  table.insert(drawnMythosTokenGuids, takenObject.getGUID())

  if takenObject.getName() == 'Spread Doom' then spreadDoom() end
  if takenObject.getName() == 'Read Headline' then readHeadline() end
  if takenObject.getName() == 'Blank' then blank() end
  if takenObject.getName() == 'Spawn Monster' then spawnMonster() end
  if takenObject.getName() == 'Spawn Clue' then spawnClue() end
  if takenObject.getName() == 'Gate Burst' then gateBurst() end
  if takenObject.getName() == 'Reckoning' then reckoning() end
  if takenObject.getName() == 'Spread Terror' then spreadTerror() end

end

--Recalls objects to bag from table
function buttonClick_recall(obj)
  for guid, entry in pairs(obj.getTable('memoryList')) do
      local scenario = getObjectFromGUID(guid)
      if scenario ~= nil then obj.putObject(scenario) end
  end
  broadcastToAll("Objects Recalled", {1,1,1})
end


--Utility functions


--Find delta (difference) between 2 x/y/z coordinates
function findOffsetDistance(p1, p2, obj)
  local deltaPos = {}
  local bounds = obj.getBounds()
  deltaPos.x = (p2.x-p1.x)
  deltaPos.y = (p2.y-p1.y) + (bounds.size.y - bounds.offset.y)
  deltaPos.z = (p2.z-p1.z)
  return deltaPos
end

--Used to rotate a set of coordinates by an angle
function rotateLocalCoordinates(desiredPos, obj)
local objPos, objRot = obj.getPosition(), obj.getRotation()
  local angle = math.rad(objRot.y)
local x = desiredPos.x * math.cos(angle) - desiredPos.z * math.sin(angle)
local z = desiredPos.x * math.sin(angle) + desiredPos.z * math.cos(angle)
--return {x=objPos.x+x, y=objPos.y+desiredPos.y, z=objPos.z+z}
  return {x=x, y=desiredPos.y, z=z}
end

--Coroutine delay, in seconds
function wait(time)
  local start = os.time()
  repeat coroutine.yield(0) until os.time() > start + time
end

--Duplicates a table (needed to prevent it making reference to the same objects)
function duplicateTable(oldTable)
  local newTable = {}
  for k, v in pairs(oldTable) do
      newTable[k] = v
  end
  return newTable
end

--Moves scripted highlight from all objects
function removeAllHighlights()
  for _, obj in ipairs(getAllObjects()) do
      obj.highlightOff()
  end
end

--Round number (num) to the Nth decimal (dec)
function round(num, dec)
  local mult = 10^(dec or 0)
  return math.floor(num * mult + 0.5) / mult
end

function updateSave(obj)
  local data_to_save = {["ml"]=memoryList}
  saved_data = JSON.encode(data_to_save)
  obj.script_state = saved_data
end

function shuffleFn(deck) 
  deck.shuffle()

  Wait.frames(
    function()
      deck.shuffle()
    end,
    32
  )

  Wait.frames(
    function()
      deck.shuffle()
    end,
    64
  )

  Wait.frames(
    function()
      selection[2].setPositionSmooth({x = neighborhoodDeckPos.x, y=neighborhoodDeckPos.y + 5, z=neighborhoodDeckPos.z}) 
    end,
    96
  )
end

function shuffleDeck(deck, iteration)
  local frames = 0
  for i = iteration , 1 ,-1 do
    frames = frames + 32
    Wait.frames(
    function()
      deck.shuffle()
    end,
    frames
  )
  end
end

function gateBurst()
  eventDeckPos = eventDeck.getPosition()
  doomPos = {x = eventDeckPos.x + 4, y = eventDeckPos.y, z = eventDeckPos.z}

  if discardDeck == nil then
    local takenObject = eventDeck.takeObject({
      position = doomPos
    })
    broadcastToAll('Add doom to ' .. takenObject.getTags()[1], {1,0,0})
    placeDoomTokens(takenObject)
    Wait.frames(
      function()
        eventDeck.putObject(takenObject)
      end, 64
    )
    return
  end
  
  local takenObject = eventDeck.takeObject({
    position = doomPos
  })

  takenObject.flip()
  takenObject.setPositionSmooth({x=doomPos.x, y=doomPos.y + 5, z=doomPos.z})

  local flipCard = function() discardDeck = discardDeck.putObject(takenObject) someFn(discardDeck, 4) end
  moveWatch = function() return not takenObject.isSmoothMoving() end
  Wait.condition(flipCard, moveWatch)

  placeDoomTokens(takenObject)
end

function placeDoomTokens(takenObject)
  broadcastToAll('Gate burst!', {1,0,0})
  broadcastToAll('Add doom to each part of ' .. takenObject.getTags()[1], {1,0,0})

  for i, deck in ipairs(neighborhoodTiles) do
    if takenObject.getTags()[1] == deck.getTags()[1] then
      neighborhoodPosition = deck.getPosition()
    end
  end

  -- doom token
  for i = 3 , 1, -1 do
    getObjectFromGUID('f807c7').takeObject({
      position={x=neighborhoodPosition.x, y=neighborhoodPosition.y + 5, z=neighborhoodPosition.z}
    })
  end
end

function someFn(discardDeck, shuffleIterations)
  local frames = 32

  -- Wait for decks to be merged then flip the deck
  Wait.frames(
    function()
      discardDeck.flip()

      -- Wait for deck to flip
      Wait.frames(
        function()
          shuffleDeck(discardDeck, shuffleIterations)

          -- Wait for deck to be shuffled
          Wait.frames(
            function()
              eventDeck.putObject(discardDeck)
            end, frames * shuffleIterations
          )
        end, 32
      )
    end, 32
  )
end

function blank()
  broadcastToAll('Nothing happens!', {0, 1, 0})
end

function spreadDoom()
  eventDeckPos = eventDeck.getPosition()
  doomPos = {x = eventDeckPos.x + 4, y = eventDeckPos.y, z = eventDeckPos.z}
  
  local takenObject = eventDeck.takeObject({
    index = eventDeck.getQuantity() - 1,
  })

  if discardDeck == nil then
    takenObject.flip()
    discardDeck = takenObject
    discardDeck.setPositionSmooth({x=doomPos.x, y=doomPos.y + 5, z=doomPos.z})
    else
      takenObject.flip()
      takenObject.setPositionSmooth({x=doomPos.x, y=doomPos.y + 5, z=doomPos.z})

      local flipCard = function() discardDeck = discardDeck.putObject(takenObject) end
      moveWatch = function() return not takenObject.isSmoothMoving() end
      Wait.condition(flipCard, moveWatch)
  end

  for i, deck in ipairs(neighborhoodTiles) do
    if takenObject.getTags()[1] == deck.getTags()[1] then
      neighborhoodPosition = deck.getPosition()
    end
  end

  -- doomtoken
  getObjectFromGUID('f807c7').takeObject({
    position={x=neighborhoodPosition.x, y=neighborhoodPosition.y + 5, z=neighborhoodPosition.z}
  })

  broadcastToAll('Add doom to ' .. takenObject.getTags()[1], {1,0,0})
end

function readHeadline()

  if headlinesDeck == null then
    if lastCard == nill then
      broadcastToAll("Add Doom", {1,0,0})
      getObjectFromGUID('f807c7').takeObject({
        position={x = headlinesDeckPos.x + 3, y = headlinesDeckPos.y, z = headlinesDeckPos.z }
      })
      return
    end
    lastCard.setPositionSmooth(
      {x = headlinesDeckPos.x + 3, y = headlinesDeckPos.y, z = headlinesDeckPos.z }
    )

    local flipCard = function() lastCard.flip() lastCard = nill end
    moveWatch = function() return not lastCard.isSmoothMoving() end
    Wait.condition(flipCard, moveWatch)
    return
  end

  if headlinesDeck.remainder == nill then
    headlineCard = headlinesDeck.takeObject({
      position={x = headlinesDeckPos.x + 3, y = headlinesDeckPos.y, z = headlinesDeckPos.z},
      callback_function = function()
        headlineCard.flip()
      end
    })
  end

  if headlinesDeck.remainder ~= nill then
    lastCard = headlinesDeck.remainder
  end
  
end

function spawnClue()
  deckPos = eventDeck.getPosition()
  pos = {x = deckPos.x, y = deckPos.y, z = deckPos.z + - 5}
  
  local takenObject = eventDeck.takeObject({
    position = pos
  })

  for i, deck in ipairs(neighborhoodDecks) do
    if takenObject.getTags()[1] == deck.getTags()[1] then
      neighborhoodDeck = deck
    end
  end

  neighborhoodDeckPos = neighborhoodDeck.getPosition()

  selection = neighborhoodDeck.cut(2)
  Wait.frames(
    function()
      selection[2].setPositionSmooth(
        pos
      )
      selection[2].setRotationSmooth(
        {180, 0, 0}
      )
      local shuffle = function() Wait.frames(function() shuffleFn(selection[2]) end, 64) end
      moveWatch = function() return not selection[2].isSmoothMoving() end
      Wait.condition(shuffle, moveWatch)
    end,
    64
  )

  for i, tile in ipairs(neighborhoodTiles) do
    if takenObject.getTags()[1] == tile.getTags()[1] then
      neighborhoodPosition = tile.getPosition()
    end
  end

   -- cluetoken
   getObjectFromGUID('c896e0').takeObject({
    position={x=neighborhoodPosition.x, y=neighborhoodPosition.y + 5, z=neighborhoodPosition.z}
  })
end

function spawnMonster()
  monsterDeckPos = monsterDeck.getPosition()

  spawnedMonster = monsterDeck.takeObject({
    position = {x = monsterDeckPos.x + 2.5, y = monsterDeckPos.y, z = monsterDeckPos.z},
    index=monsterDeck.getQuantity() - 1
  })
  
  investigatorsObj = getObjectFromGUID('69581b')
  investigatorsObj.setTable('monsters', { spawnedMonster })
  investigatorsObj.call('updateMonsters')
  investigatorsObj.call('updateInvestigators')

  for i,o in ipairs(investigatorsObj.getTable('monsters')) do
    local func = function(player_color) defeatMonster(player_color, i, o) end
    o.addContextMenuItem('Defeat Monstes', func)
  end

end

function defeatMonster(player_color, i, o)
  investigatorsObj.call('updateMonsters')
  investigatorsObj.call('updateInvestigators')
  spawnedMonster.setPositionSmooth({x=monsterDeckPos.x, y=monsterDeckPos.y + 5, z=monsterDeckPos.z})
  broadcastToAll(player_color .. ' has defeated ' .. o.getName(), {0, 1, 0})
end

function spreadTerror()
end

function reckoning()
  broadcastToAll('Check reckoning effects!', {1, 0, 0})
end

function drawNeighborhoodEncounter(player_color, i, o)
  
  for i, deck in ipairs(neighborhoodDecks) do
    if o.getTags()[1] == deck.getTags()[1] then
      deck.takeObject().deal(1, player_color)
      broadcastToAll('Dealt encounter card to ' .. player_color, {0,1,0})
    end
  end
    
end
