scenarios = {
  getObjectFromGUID('d14543'),
  getObjectFromGUID('a4853a'),
}

neighborhoodDecks = {}
neighborhoodTiles = {}
anomaliesDeck = {}
monsterDeck = {}
eventDeck = {}

function updateSave(scenarioBag)
    local data_to_save = {["ml"]=memoryList}
    saved_data = JSON.encode(data_to_save)
    scenarioBag.script_state = saved_data
end

function onload()

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

  unpackBag(scenarioBag)

  Wait.frames(
    function()
      if scenarioBag.guid == 'd14543' then secondBag = '924d1a' end
      if scenarioBag.guid == 'a4853a' then secondBag = 'c2eec7' end

      function onObjectLeaveContainer(container, object)
        if object.getTags()[1] == 'Monsters' then
          investigatorsObj = getObjectFromGUID('69581b')
          investigatorsObj.setVar('monsters', object)
          investigatorsObj.call('updateMonsters', {'spawned', object})
        end
      end
  
      unpackBag(getObjectFromGUID(secondBag))
    end, 64
  )

  if headlinesToken ~= null then
    setHeadlines(headlinesToken.getDescription())
  end

  for i,o in ipairs(neighborhoodTiles) do
    local func = function(player_color) getObjectFromGUID('84ef85').call('drawNeighborhoodEncounter', {player_color, i, o}) end
    o.addContextMenuItem('Draw encounter', func)

    local func = function(player_color) getObjectFromGUID('84ef85').call('drawNeighborhoodAnomaly', {player_color, i, o}) end
    o.addContextMenuItem('Draw anomaly', func)
  end

  getObjectFromGUID('3fe222').call('removeInvestigatorsSelectButtons')

  broadcastToAll("Objects Placed", {1,1,1})

  Wait.frames(
    function()
      shuffleAllDecks()
    end, 32
  )

  Wait.frames(
    function()
      getObjectFromGUID('3e54de').call('spawnClue', 3)
    end, 64
  )

  Wait.frames(
    function()
      getObjectFromGUID('077454').call('spreadDoom')
    end, 96
  )

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
                local item = scenarioBag.takeObject({
                    guid=guid, position=entry.pos, rotation=entry.rot,
                })
                item.setLock(entry.lock)

                if item.getTags()[2] == 'Deck' then table.insert(neighborhoodDecks, item) end
                if item.getTags()[2] == 'Neighborhood' then table.insert(neighborhoodTiles, item) end
                if item.getTags()[1] == 'Anomalies' then anomaliesDeck = item end

                if item.getName() == 'Mythos Cup' then addButtonsToMythosCup(item.getGUID()) end
                if item.getName() == 'Monsters' then monsterDeck = getObjectFromGUID(item.getGUID()) end
                if item.getName() == 'Event' then eventDeck = getObjectFromGUID(item.getGUID()) end
                if item.getName() == 'Headlines' then headlinesToken = getObjectFromGUID(item.getGUID()) end
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

  anomaliesDeck.shuffle()
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

function addButtonsToMythosCup(guid)
  cup = getObjectFromGUID(guid)

  params = {
    label="Draw Mythos Token",
    click_function="draw_mythos_token",
    function_owner=getObjectFromGUID('6f210b'),
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

function setHeadlines(amount)
  headlinesDeckRef = getObjectFromGUID('f9b203')
  headlinesDeck = headlinesDeckRef
  
  headlinesDeckPos = headlinesDeck.getPosition()
  headlinesDeckPos = {x = headlinesDeckPos.x - 0.2, y = headlinesDeckPos.y, z = headlinesDeckPos.z - 15}
  headlinesDeck.shuffle()
  headlinesDeck.shuffle()
  headlinesDeck.shuffle()

  headlinesDeck = headlinesDeck.cut(tonumber(amount))
  
  Wait.frames(
    function()
      headlinesDeck = headlinesDeck[2]
      headlinesDeck.setPositionSmooth(
        headlinesDeckPos
      )
      headlinesDeck.setRotationSmooth(
        {180, 0, 0}
      )
      headlinesDeck.shuffle()
      headlinesToken = nil
    end,
    64
  )
end 