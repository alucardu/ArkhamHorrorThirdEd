scenarios = {
  getObjectFromGUID('d14543'),
  getObjectFromGUID('a4853a'),
  getObjectFromGUID('8ab878'),
  getObjectFromGUID('88f120'),
  getObjectFromGUID('c73dd8'),
  getObjectFromGUID('1de1e0'),
  getObjectFromGUID('ba40c5'),
  getObjectFromGUID('786f08'),
  getObjectFromGUID('0e6d75'),
  getObjectFromGUID('8434b9'),
}

underDarkWaves = {
  'ba40c5'
}

neighborhoodTags = {
  'Rivertown',
  'Downtown',
  'Northside',
  'Easttown',
  'Merchant District',
  'Miskatonic University',
  'Uptown',
  'Southside',
  'Innsmouth Shore',
  'Innsmouth Village',
  'Kingsport Harbor',
  'Central Kingsport',
  'Street Tile',
  'Travel Route',
  'Devil Reef',
  'Strange High House'
}

neighborhoodDecks = {}
neighborhoodTiles = {}
travelRoutes = nil
streetTiles= {}
anomaliesDeck = nil
monsterDeck = {}
eventDeck = {}
setupDone = false
devilReefTile = {}
highHouseTile = {}
terrorDeck = nil

function onSave()
  if #neighborhoodDecks > 0 then
    local state = {
        neighborhoodDecks = returnGuid(neighborhoodDecks),
        neighborhoodTiles = returnGuid(neighborhoodTiles),
        streetTiles = returnGuid(streetTiles),

        anomaliesDeck = anomaliesDeck ~= nil and anomaliesDeck.guid or nil,
        monsterDec = monsterDeck.guid,
        eventDeck = eventDeck.guid,

        travelRoutes = travelRoutes ~= nil and returnGuid(travelRoutes) or nil,
        terrorDeck = terrorDeck ~= nil and terrorDeck.guid or nil,
        
        devilReefTile = devilReefTile ~= nil and  devilReefTile.guid or nil,
        highHouseTile = highHouseTile ~= nil and  highHouseTile.guid or nil,

        setupDone = setupDone,

    }
    return JSON.encode(state)
  end
end

function updateSave(scenarioBag)
  local data_to_save = {["ml"]=scenarioBag.getTable('memoryList')}
  saved_data = JSON.encode(data_to_save)
  scenarioBag.script_state = saved_data
end

function onLoad(script_state)
  local state = JSON.decode(script_state)
  if state ~= nil then
    neighborhoodDecks = returnObj(state.neighborhoodDecks)
    neighborhoodTiles = returnObj(state.neighborhoodTiles)
    streetTiles = returnObj(state.streetTiles)

    anomaliesDeck = anomaliesDeck ~= nil or getObjectFromGUID(state.anomaliesDeck)
    monsterDeck = getObjectFromGUID(state.monsterDeck)
    eventDeck = getObjectFromGUID(state.eventDeck)

    travelRoutes = state.travelRoutes ~= nil and returnObj(state.travelRoutes) or {}
    terrorDeck = getObjectFromGUID(state.terrorDeck)

    devilReefTile = getObjectFromGUID(state.devilReefTile)
    highHouseTile = getObjectFromGUID(state.highHouseTile)

    -- buttons
    readHeadlines = getObjectFromGUID('e6b052')
    spawnClue = getObjectFromGUID('6f6053')
    spawnMonster = getObjectFromGUID('8fceae')
    gateBurst = getObjectFromGUID('1eb030')
    spreadTerror = getObjectFromGUID('3df97d')
    spreadDoom = getObjectFromGUID('eaa6bd')

    setupDone = state.setupDone

    allObjects = getAllObjects()
    setContextToTiles()
    setContextToMonsters(allObjects)
    setContextToDoom(allObjects)
    setContextToAnomalies(allObjects)
  end

  for i, scenarioBag in ipairs(scenarios) do
    zxc = scenarioBag
    saved_data = scenarioBag.script_state
    if saved_data ~= "" then
      local loaded_data = JSON.decode(saved_data)

      --Set up information off of loaded_data
      scenarioBag.setTable('memoryList', loaded_data.ml)
      memoryList = scenarioBag.getTable('memoryList')
    else
      --Set up information for if there is no saved saved data
      memoryList = {}
    end
    if next(memoryList) == nil then
      createSetupButton()
    else
      createMemoryActionButtons(zxc)
    end
  end
end

--Beginning Setup

--Make setup button
function createSetupButton(scenarioBag)
  scenarioBag.createButton({
    label="Setup", click_function="buttonClick_setup", function_owner=self,
    position={-2,0.3,0}, rotation={0,270,0}, height=350, width=800,
    font_size=250, color={0,0,0}, font_color={1,1,1}
  })
end

--Triggered by setup button,
function buttonClick_setup(scenarioBag)
  memoryListBackup = duplicateTable(scenarioBag.getTable('memoryList'))
  scenarioBag.setTable('memoryListBackup', memoryListBackup)
  scenarioBag.setTable('memoryList', {})
  scenarioBag.clearButtons()
  createButtonsOnAllObjects(scenarioBag)
  createSetupActionButtons(scenarioBag)
end

--Creates selection buttons on objects
function createButtonsOnAllObjects(scenarioBag)
  scenarioBag.highlightOn('Yellow', 20)

  local howManyButtons = 0
  for _, obj in ipairs(getAllObjects()) do
    if obj ~= self then
        local dummyIndex = howManyButtons
        --On a normal bag, the button positions aren't the same size as the bag.
        globalScaleFactor = 1.25 * 1/scenarioBag.getScale().x
        --Super sweet math to set button positions
        local selfPos = scenarioBag.getPosition()
        local objPos = obj.getPosition()
        local deltaPos = findOffsetDistance(selfPos, objPos, obj)
        local objPos = rotateLocalCoordinates(deltaPos, scenarioBag)
        objPos.x = -objPos.x * globalScaleFactor
        objPos.y = objPos.y * globalScaleFactor
        objPos.z = objPos.z * globalScaleFactor

        --Offset rotation of bag
        local rot = scenarioBag.getRotation()
        rot.y = -rot.y + 180
        --Create function
        local funcName = "selectButton_" .. howManyButtons
        local func = function() buttonClick_selection(dummyIndex, obj, scenarioBag) end
        self.setVar(funcName, func)
        scenarioBag.createButton({
          click_function=funcName,
          function_owner=self,
          position=objPos,
          height=1000,
          width=1000,
          color={0.75,0.25,0.25,0.6},
        })
        howManyButtons = howManyButtons + 1
    end
  end
end

--Creates submit and cancel buttons
function createSetupActionButtons(zxc)
  zxc.createButton({
    label="Cancel", click_function="buttonClick_cancel", function_owner=self,
    position={0,0.3,-2}, rotation={0,180,0}, height=350, width=1100,
    font_size=250, color={0,0,0}, font_color={1,1,1}
  })
  zxc.createButton({
    label="Submit", click_function="buttonClick_submit", function_owner=self,
    position={0,0.3,-2.8}, rotation={0,180,0}, height=350, width=1100,
    font_size=250, color={0,0,0}, font_color={1,1,1}
  })
  zxc.createButton({
    label="Reset", click_function="buttonClick_reset", function_owner=self,
    position={-2,0.3,0}, rotation={0,270,0}, height=350, width=800,
    font_size=250, color={0,0,0}, font_color={1,1,1}
  })
end


--During Setup

--Checks or unchecks buttons
function buttonClick_selection(index, obj, scenarioBag)
    local color = {0,1,0,0.6}
    if scenarioBag.getTable('memoryList')[obj.getGUID()] == nil then
      scenarioBag.editButton({index=index, color=color})
        --Adding pos/rot to memory table
        local pos, rot = obj.getPosition(), obj.getRotation()
        --I need to add it like this or it won't save due to indexing issue
        meme = scenarioBag.getTable('memoryList')
        meme[obj.getGUID()] = {
            pos={x=round(pos.x,4), y=round(pos.y,4), z=round(pos.z,4)},
            rot={x=round(rot.x,4), y=round(rot.y,4), z=round(rot.z,4)},
            lock=obj.getLock()
        }
        scenarioBag.setTable('memoryList', meme)
        obj.highlightOn({0,1,0})
    else
      color = {0.75,0.25,0.25,0.6}
      scenarioBag.editButton({index=index, color=color})
      scenarioBag.getTable('memoryList')[obj.getGUID()] = nil
      obj.highlightOff()
    end
end

--Cancels selection process
function buttonClick_cancel(scenarioBag)
    memoryList = scenarioBag.getTable('memoryListBackup')
    scenarioBag.setTable('memoryList', memoryList)
    scenarioBag.clearButtons()
    if next(scenarioBag.getTable('memoryList')) == nil then
        createSetupButton(scenarioBag)
        createMemoryActionButtons(scenarioBag)
    else
        createMemoryActionButtons(scenarioBag)
    end
    removeAllHighlights()
    broadcastToAll("Selection Canceled", {1,1,1})
end

--Saves selections
function buttonClick_submit(scenarioBag)
    if next(scenarioBag.getTable('memoryList')) == nil then
        broadcastToAll("You cannot submit without any selections.", {0.75, 0.25, 0.25})
    else
        scenarioBag.clearButtons()
        createMemoryActionButtons(scenarioBag)
        local count = 0
        for guid in pairs(scenarioBag.getTable('memoryList')) do
            count = count + 1
            local obj = getObjectFromGUID(guid)
            if obj ~= nil then obj.highlightOff() end
        end
        broadcastToAll(count.." Objects Saved", {1,1,1})
        updateSave(scenarioBag)
    end
end

--Resets bag to starting status
function buttonClick_reset()
    memoryList = {}
    self.clearButtons()
    createSetupButton()
    removeAllHighlights()
    broadcastToAll("Tool Reset", {1,1,1})
    updateSave(scenarioBag)
end


--After Setup


--Creates recall and place buttons
function createMemoryActionButtons(zxc)
  zxc.createButton({
    label="Place", click_function="buttonClick_place", function_owner=self,
    position={0,0.3,-2}, rotation={0,180,0}, height=350, width=800,
    font_size=250, color={0,0,0}, font_color={1,1,1}
  })
  zxc.createButton({
    label="Setup", click_function="buttonClick_setup", function_owner=self,
    position={-2,0.3,0}, rotation={0,270,0}, height=350, width=800,
    font_size=250, color={0,0,0}, font_color={1,1,1}
  })
end

--Sends objects from bag/table to their saved position/rotation
function buttonClick_place(scenarioBag)

  for i, button in ipairs(scenarioBag.getButtons()) do
    if button.label == 'Place' then
      scenarioBag.removeButton(i - 1)
    end
  end

  scenarioBag.createButton({
    label="Recall", click_function="buttonClick_recall", function_owner=self,
    position={0,0.3,-2.8}, rotation={0,180,0}, height=350, width=800,
    font_size=250, color={0,0,0}, font_color={1,1,1}
  })

  function onObjectLeaveContainer(container, object)
    if object.hasTag('Monsters') and container ~= monsterDeck then
      Wait.frames(
        function() spawnMonster.call('addMonster', object)
        end, 64
      )
    end

    if object.hasTag('Doom') and object.hasTag('setup') then
      Wait.frames(
        function()
          getObjectFromGUID('eaa6bd').call('spreadDoom', object) 
        end, 64 
      )
    end
  end
  
  unpackBag(scenarioBag)
  setContextToTiles()

  getObjectFromGUID('3fe222').call('removeInvestigatorsSelectButtons')

  broadcastToAll("Objects Placed", {1,1,1})

  Wait.frames(
    function()
      shuffleAllDecks()
    end, 32
  )
  
  Wait.frames(
    function() for i = 3 , 1, -1 do spawnClue.call('spawnClue') end 
    end, 64
  )

  Wait.frames(
    function()
      getObjectFromGUID('eaa6bd').call('spreadDoom')
    end, 96
  )

  Wait.frames(
    function()
      selectDifficulty()
      getObjectFromGUID('1b9f8c').call('placeItems', 5)
      readHeadlines.call('setHeadlines', readHeadlines.getDescription())
      setupDone = true
    end, 512
  )

end

function selectDifficulty()
  getObjectFromGUID('496863').call('selectDifficulty')
end

function unpackBag(scenarioBag)

  local bagObjList = scenarioBag.getObjects()
  for guid, entry in pairs(scenarioBag.getTable('memoryList')) do
      local obj = getObjectFromGUID(guid)
      --If obj is out on the table, move it to the saved pos/rot
      if obj ~= nil then
          obj.setPositionSmooth(entry.pos)
          obj.setRotationSmooth(entry.rot)
          obj.setLock(entry.lock)
      else
          --If obj is inside of the bag
          for _, bagObj in ipairs(bagObjList) do
              if bagObj.guid == guid then
                local item = scenarioBag.takeObject(
                  {
                    guid=guid,
                    position=entry.pos,
                    rotation=entry.rot,
                  })

                  if item.hasTag('Setup') then
                  item.setPositionSmooth(
                    {
                      x=entry.pos.x,
                      y=entry.pos.y + 5,
                      z=entry.pos.z
                    })
                end

                Wait.condition(function() item.setLock(entry.lock) end, || item.resting)                
                if item.hasTag('Neighborhood Deck') then table.insert(neighborhoodDecks, item) end
                if item.hasTag('Neighborhood Tile') then table.insert(neighborhoodTiles, item) end
                if item.hasTag('Street Tile') then table.insert(streetTiles, item) end
                if item.hasTag('Travel Route Tile') then table.insert(travelRoutes, item) end
                if item.hasTag('Devil Reef Tile') then devilReefTile = item end
                if item.hasTag('Strange High House Tile') then strangeHighHouseTile = item end

                if item.hasTag('Mythos Cup') then mythosCup = item end

                if item.hasTag('Anomalies') then anomaliesDeck = item end
                if item.hasTag('Terror Deck') then terrorDeck = item end
                
                if item.hasTag('Monster Deck') and item.hasTag('Setup') then monsterDeck = item end
                if item.hasTag('Event Deck') then eventDeck = item end
                break
              end
          end
      end
  end
end

function shuffleAllDecks()
  for i, neighbordhoodDeck in ipairs(neighborhoodDecks) do
    neighbordhoodDeck.shuffle()
  end

  if anomaliesDeck ~= nil then anomaliesDeck.shuffle() end
  monsterDeck.shuffle()
  eventDeck.shuffle()
end

--Recalls objects to bag from table
function buttonClick_recall(scenarioBag)

  scenarioBag.removeButton(1)

  scenarioBag.createButton({
    label="Place", click_function="buttonClick_place", function_owner=self,
    position={0,0.3,-2}, rotation={0,180,0}, height=350, width=800,
    font_size=250, color={0,0,0}, font_color={1,1,1}
  })

  -- check for reset
  for guid, entry in pairs(scenarioBag.getTable('memoryList')) do
    local obj = getObjectFromGUID(guid)
    if obj ~= nil then scenarioBag.putObject(obj) end
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

function mapObj(tbl, func)
  local t = {}
  for k, v in ipairs(tbl) do
    t[k] = getObjectFromGUID(v)
  end
  return t
end

function map(tbl, func)
  local t = {}
  for k,v in pairs(tbl) do
    t[k] = func(v)
  end
  return t
end

function returnGuid(tbl)
  local t = {}
  for i, v in ipairs(tbl) do
    t[i] = v.guid
  end
  return t
end

function returnObj(tbl)
  local t = {}
  for i, v in ipairs(tbl) do
    t[i] = getObjectFromGUID(v)
  end
  return t
end

function setContextToTiles()
  for i,o in ipairs(neighborhoodTiles) do
    local func = function(player_color) getObjectFromGUID('84ef85').call('drawNeighborhoodEncounter', {player_color, i, o}) end
    o.addContextMenuItem('Draw encounter', func)

    if anomaliesDeck ~= nil then
      local func = function(player_color) getObjectFromGUID('0f8883').call('spawnAnomaly', {player_color, i, o}) end
      o.addContextMenuItem('Spawn anomaly', func)
    end

    if terrorDeck ~= nil then
      local func = function(player_color) getObjectFromGUID('3df97d').call('spreadTerror', {player_color, i, o}) end
      o.addContextMenuItem('Trigger terror', func)
    end
  end

  for i,o in ipairs(streetTiles) do
    local func = function(player_color) getObjectFromGUID('84ef85').call('drawNeighborhoodEncounter', {player_color, i, o}) end
    o.addContextMenuItem('Draw encounter', func)
  end

  for i,o in ipairs(travelRoutes) do
    local func = function(player_color) getObjectFromGUID('84ef85').call('drawNeighborhoodEncounter', {player_color, i, o}) end
    o.addContextMenuItem('Draw encounter', func)
  end

  if devilReefTile ~= nil then
    local func = function(player_color) getObjectFromGUID('84ef85').call('drawNeighborhoodEncounter', {player_color, i, devilReefTile}) end
    devilReefTile.addContextMenuItem('Draw encounter', func)
  end

  if strangeHighHouseTile ~= nil then
    local func = function(player_color) getObjectFromGUID('84ef85').call('drawNeighborhoodEncounter', {player_color, i, strangeHighHouseTile}) end
    strangeHighHouseTile.addContextMenuItem('Draw encounter', func)
  end

end

function setContextToMonsters(allObjects)
  for _, obj in ipairs(allObjects) do
    if obj.hasTag('Monsters') then
      spawnMonster.call('setContextToMonster', obj)
    end
  end
end

function setContextToDoom()
  for _, obj in ipairs(allObjects) do
    if obj.hasTag('Doom') then
      getObjectFromGUID('eaa6bd').call('addContextMenu', obj)
    end
  end
end

function setContextToAnomalies()
  for _, obj in ipairs(allObjects) do
    if obj.hasTag('Anomaly') then
      getObjectFromGUID('0f8883').call('addContextMenu', obj)
    end
  end
end