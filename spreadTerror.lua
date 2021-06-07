terrorEvents = {
  'Northside',
  'Easttown',
  'MerchantDistrict',
  'MiskatonicUniversity',
  'Rivertown',
  'Southside',
  'Uptown',
  'KingsportHarbor',
  'InnsmouthVillage',
  'InnsmouthShore',
  'CentralKingsport'
}

iterations = 0
terrorCardMoving = false

function setData(object)
  terrorDeck = object[1]
  terrorDeckPos = terrorDeck.getPosition()
  neighborhoodTags = object[2]
  neighborhoodDecks = object[3]
end

function spreadTerror(object)
  -- check if a terror card is moving
  if terrorCardMoving == true then
    broadcastToAll('Spread terror is queued', {0, 1, 0})
    Wait.condition(
      function()
        spreadTerror(object)
        terrorCardMoving = false
      end,
    || not terrorCard.isSmoothMoving() and terrorCard == nil or terrorCard.resting)
    return
  end

  player_color = object[1]
  neighborhoodTile = object[3]

  neighborhoodTag = returnNeighbordhoodTag(neighborhoodTile)
  neighborhoodDeck = returnNeighborhoodDeck(neighborhoodTag)

  -- check if terror deck is empty
  if terrorDeck == nil then
    getObjectFromGUID('f807c7').takeObject({
      position = terrorDeckPos + Vector(3, 5, 0)
    })
    broadcastToAll('Add one Doom to the scenario!', {1, 0, 0})
    return
  end

  -- check if terror deck has 1 card left
  if terrorDeck.type == 'Card' then
    terrorCard = terrorDeck
    terrorDeck = nil
    else
      terrorCard = terrorDeck.takeObject()
  end

  if terrorDeck ~= nil and terrorDeck.remainder ~= nil then
    terrorDeck = terrorDeck.remainder 
  end

  -- place terror card on neighborhood deck
  terrorCard.setRotationSmooth({180, 90, 0})
  terrorCard.setPositionSmooth(neighborhoodDeck.getPosition() + Vector(0, 5, 0))
  terrorCardMoving = true

  -- check if neighborhood already has terror
  Wait.condition(function()
    local neighborhoodTag = neighborhoodTag:gsub("%s+", "")

    for i, terrorEvent in ipairs(terrorEvents) do
      if terrorEvent.type == 'Card' then
        terrorEvent = terrorEvent.putObject(terrorCard)
        terrorEvents[i] = { terrorEvent, neighborhoodTag}
        context = terrorEvent

        if not (context.getQuantity() > 2) then
          setContextToTerrorDeck(context, i)
        end
        return
      end

      if terrorEvent[2] == neighborhoodTag then
        -- Deck
        terrorEvent = terrorEvent[1].putObject(terrorCard)
        terrorEvent.setName(neighborhoodTag)
        terrorEvents[i] = { terrorEvent, neighborhoodTag}
        context = terrorEvent

        if not (context.getQuantity() > 2) then setContextToTerrorDeck(context, i) end
      end

      if terrorEvent == neighborhoodTag then
        if terrorEvent.type == nil then
          -- Card
          setContextToTerrorCard(terrorCard, neighborhoodTag, i)
          terrorEvents[i] = { terrorCard, neighborhoodTag}
        end
      end
    end
    
    terrorCardMoving = false
  end, || not terrorCard.isSmoothMoving())

  -- add event to neighborhood table
  -- add context to tile
  -- setContextToNeighborhoodTile(neighborhoodTile, neighborhoodTag)
  -- add context to card
end

function drawTerrorEncounter(player_color, neighborhoodTag)
  terrorTable = _G[neighborhoodTag:gsub("%s+", "")]

  for _, terrorEvent in ipairs(terrorTable) do
    terrorEvent.deal(1, player_color)
  end
end

function returnTerrorCard(terrorEvent, neighborhood, i)
  if terrorEvent.type == 'Card' then
    terrorCard = terrorEvent
    terrorCard.setPositionSmooth(terrorDeckPos + Vector(0, 5, 0))
    terrorCard.setRotationSmooth({0, 180, 180})
    
    for i, terrorEvent in ipairs(terrorEvents) do
      if terrorEvent[2] == neighborhood then
        terrorEvents[i] = neighborhood
      end
    end
  end

  if terrorEvent.type == 'Deck' then
    randomIndex = math.random(terrorEvent.getQuantity())
    terrorCard = terrorEvent.takeObject({
      position = terrorDeckPos + Vector(0, 5, 0),
      index = randomIndex - 1
    })
    terrorCard.setRotationSmooth({0, 180, 180})
    neighborhood = terrorEvent.getName()
  end

  Wait.condition(
    function()
      -- create a new terror deck with a single card
      if terrorDeck == nil then
        terrorDeck = terrorCard
        else 
          terrorDeck = terrorDeck.putObject(terrorCard)
      end
    end,
  || not terrorCard.isSmoothMoving())
  
  if terrorEvent.getQuantity() == 0 then
    -- reset table to card
    terrorEvents[i] = { terrorEvent.remainder, neighborhood }
    setContextToTerrorCard(terrorEvent.remainder, neighborhood, i)
  end

  if terrorEvent.getQuantity() < 0 then
    -- reset table to tag
    terrorEvents[i] = neighborhood
  end
end

function setContextToTerrorCard(terrorCard, neighborhood, i)
  local func = function() returnTerrorCard(terrorCard, neighborhood, i) end
  terrorCard.addContextMenuItem('Return Card', func)
end

function setContextToTerrorDeck(terrorEvent, i)
  local func = function() returnTerrorCard(terrorEvent, neighborhood, i) end
  terrorEvent.addContextMenuItem('Return Card', func)
end

function setContextToNeighborhoodTile(neighborhoodTile, neighborhoodTag)
  local func = function(player_color) drawTerrorEncounter(player_color, neighborhoodTag) end
  neighborhoodTile.addContextMenuItem('Terror encounter', func)
end

function returnNeighbordhoodTag(neighborhoodTile)
  for _, neighborhoodTag in ipairs(neighborhoodTags) do
    if neighborhoodTile.hasTag(neighborhoodTag) then return neighborhoodTag end
  end
end

function returnNeighborhoodDeck(neighborhoodTag)
  for _, deck in ipairs(neighborhoodDecks) do
    if deck.hasTag(neighborhoodTag)then return deck end
  end
end




































-- activeTerrorEvents = {}

-- function onLoad()
--   local params = {
--     click_function="mythosTerror",
--     tooltip="Spread Terror",
--     function_owner = self,
--     height=1250,
--     width=1250,
--     color={0, 0, 0, 0},
--     position={0, 0.1, 0}
--   }
--   self.createButton(params)
-- end

-- function mythosTerror()
--   neighborhoodTags = getObjectFromGUID('3e1179').getTable('neighborhoodTags')

--   eventDiscardDeck = getObjectFromGUID('eaa6bd').getVar('discardDeck')
--   if eventDiscardDeck.getQuantity() < 0 then
--     -- single event discard card
--     for _, neighborhoodTag in ipairs(neighborhoodTags) do
--       if eventDiscardDeck.hasTag(neighborhoodTag) then
--         currentUnstableNeighborhoodTag = neighborhoodTag
--       end
--     end
--     else
--       -- multiple event discard cards
--       for i, eventDiscardCard in ipairs(eventDiscardDeck.getObjects()) do
--         topEventDiscardCard = eventDiscardCard
--       end
    
--       for _, tag in ipairs(topEventDiscardCard.tags) do
--         for _, neighborhoodTag in ipairs(neighborhoodTags) do
--           if tag == neighborhoodTag then
--             currentUnstableNeighborhoodTag = tag
--           end
--         end
--       end
--   end
--   spawnMythosTerror(currentUnstableNeighborhoodTag)
--   broadcastToAll('Terror spreaded on ' .. currentUnstableNeighborhoodTag .. ' !', {1, 0, 0})
-- end

-- function spawnMythosTerror(currentUnstableNeighborhoodTag)
--   neighborhoodTiles = getObjectFromGUID('3e1179').getTable('neighborhoodTiles')

--   for _, neighborhoodTile in ipairs(neighborhoodTiles) do 
--     if neighborhoodTile.hasTag(currentUnstableNeighborhoodTag) == true then
--       terrorTile = neighborhoodTile
--     end    
--   end

--   terrorDeck = getObjectFromGUID('3e1179').getVar('terrorDeck')
--   terrorDeckPosition = terrorDeck.getPosition()
--   terrorCard = terrorDeck.takeObject()

--   terrorCard.setRotationSmooth({
--     x=180,
--     y=90,
--     z=0
--   })
--   neighborhoodDecks = getObjectFromGUID('3e1179').getTable('neighborhoodDecks')

--   for _, neighborhoodDeck in ipairs(neighborhoodDecks) do
--     if neighborhoodDeck.hasTag(currentUnstableNeighborhoodTag) then
--       currentNeighborhoodDeck = neighborhoodDeck
--       currentNeighborhoodDeckPos = currentNeighborhoodDeck.getPosition()
--     end
--   end
  
--   alreadyHasTerror = checkIfNeighborhoodAlreadyHasTerror(currentUnstableNeighborhoodTag, terrorCard, currentNeighborhoodDeck)

--   if alreadyHasTerror ~= true then
--     terrorCard.setPositionSmooth({
--       x=currentNeighborhoodDeckPos.x,
--       y=currentNeighborhoodDeckPos.y + 5,
--       z=currentNeighborhoodDeckPos.z
--     })
--     table.insert(activeTerrorEvents, {currentNeighborhoodDeck, terrorCard})
--     print('a')
--     setTerrorContextToTile(terrorTile)
--     setRemoveContextToTerrorCard(terrorCard)
--   end
--   assignTerrorToken(terrorTile)
-- end

-- function spreadTerror(terror)
--   terrorDeck = getObjectFromGUID('3e1179').getVar('terrorDeck')

--   if terrorDeck == nil then
--     getObjectFromGUID('f807c7').takeObject({
--       position={
--         x=terrorDeckPosition.x + 3,
--         y=terrorDeckPosition.y + 5,
--         z=terrorDeckPosition.z
--       }
--     })
--     broadcastToAll('Add one Doom to the scenario!', {1, 0, 0})
--     return
--     else 
--       terrorDeckPosition = terrorDeck.getPosition()
--   end

--   neighborhoodTag = returnNeighbordhoodTag(terror[3])

--   neighborhoodDecks = getObjectFromGUID('3e1179').getTable('neighborhoodDecks')
--   for i, deck in ipairs(neighborhoodDecks) do
--     if deck.hasTag(neighborhoodTag) then
--       neighborhoodDeck = deck
--       neighborhoodDeckPos = neighborhoodDeck.getPosition()
--     end
--   end

--   if terrorDeck.getQuantity() < 0 then
--     -- single card
--     terrorCard = terrorDeck
--     terrorCard.setRotationSmooth({
--       x=180,
--       y=90,
--       z=0
--     })

--     alreadyHasTerror = checkIfNeighborhoodAlreadyHasTerror(neighborhoodTag, terrorCard, neighborhoodDeck)

--     if alreadyHasTerror ~= true then
--       terrorCard.setPositionSmooth({
--         x=neighborhoodDeckPos.x,
--         y=neighborhoodDeckPos.y + 5,
--         z=neighborhoodDeckPos.z
--       })
--       table.insert(activeTerrorEvents, {neighborhoodDeck, terrorCard})
--       print('b')
--       setTerrorContextToTile(terror[3])
--     end

--     getObjectFromGUID('3e1179').setVar('terrorDeck', nil)

--     broadcastToAll('Terror spreaded on ' .. neighborhoodTag .. ' !', {1, 0, 0})
--     assignTerrorToken(terror[3])

--     else 
--       -- deck
--       print('y')
--       terrorCard = terrorDeck.takeObject()
--       setRemoveContextToTerrorCard(terrorCard)
--       isTerrorDeckEmpty()

--       terrorCard.setRotationSmooth({
--         x=180,
--         y=90,
--         z=0
--       })

--       alreadyHasTerror = checkIfNeighborhoodAlreadyHasTerror(neighborhoodTag, terrorCard, neighborhoodDeck)

--       if alreadyHasTerror ~= true then
--         terrorCard.setPositionSmooth({
--           x=neighborhoodDeckPos.x,
--           y=neighborhoodDeckPos.y + 5,
--           z=neighborhoodDeckPos.z
--         })
--         table.insert(activeTerrorEvents, {neighborhoodDeck, terrorCard})
--         print('c')
--         setTerrorContextToTile(terror[3])
--       end

--       setRemoveContextToTerrorCard(terrorCard)
--       broadcastToAll('Terror spreaded on ' .. neighborhoodTag .. ' !', {1, 0, 0})
--       assignTerrorToken(terror[3])
--   end
-- end

-- function drawTerrorEncounter(o)
--   terrorDeck = getObjectFromGUID('3e1179').getVar('terrorDeck')
--   player_color = o[1]
--   o = o[3]
--   i = i
--   o.clearContextMenu()

--   neighborhoodTag = returnNeighbordhoodTag(o)
--   neighborhoodDeck = returnNeighborhoodDeck(returnNeighbordhoodTag(o))

--   for q, activeTerror in ipairs(activeTerrorEvents) do
--     if activeTerror[1].hasTag(neighborhoodTag) == true then
--       if activeTerror[2].getQuantity() >= 0 then
--           activeTerror[2].shuffle()
--           print('z')
--           terrorCard = activeTerror[2].takeObject()
--           terrorCard.deal(1, player_color)

--           local func = function(player_color) encounter(player_color, i, terrorCard) end
--           terrorCard.addContextMenuItem('Encounter', func)
--           if activeTerror[2].remainder ~= nil then
--             table.insert(activeTerrorEvents, {neighborhoodDeck, activeTerror[2].remainder})
--             print('d')
--             table.remove(activeTerrorEvents, q)
--             setContext(player_color, i, o)
--             setTerrorContextToTile(o)
--             return
--           end
--           setTerrorContextToTile(o)
--         else
--           terrorCard = activeTerror[2]

--           local func = function(player_color) encounter(player_color, i, terrorCard) end
--           terrorCard.addContextMenuItem('Encounter', func)

--           activeTerror[2].deal(1, player_color)
--           table.remove(activeTerrorEvents, q)          
--       end
--     end
--   end

--   setContext(player_color, i, o)

-- end

-- function setTerrorContextToTile(o)
--   local func = function(player_color) self.call('drawTerrorEncounter', {player_color, i, o}) end
--   o.addContextMenuItem('Terror Encounter', func)
-- end

-- function setContext(player_color, i, o)
--   player_color = player_color
--   o = o
--   i = i
--   local func = function(player_color) getObjectFromGUID('84ef85').call('drawNeighborhoodEncounter', {player_color, i, o}) end
--   o.addContextMenuItem('Draw encounter', func)

--   local func = function(player_color) self.call('spreadTerror', {player_color, i, o}) end
--   o.addContextMenuItem('Trigger terror', func)
-- end

-- function encounter(player_color, i, encounterCard, deck)
--   if terrorDeck == nil then
--     z = 0
--     else
--       z = 5
--   end
--   encounterCard.setPosition({
--     x=terrorDeckPosition.x,
--     y=terrorDeckPosition.y,
--     z=terrorDeckPosition.z - z
--   })
--   Wait.condition(
--   function()
--     encounterCard.flip()
--     if terrorDeck == nil then
--       getObjectFromGUID('3e1179').setVar('terrorDeck', encounterCard)
--       else
--         terrorDeck = terrorDeck.putObject(encounterCard)
--         getObjectFromGUID('3e1179').setVar('terrorDeck', terrorDeck)
--     end
--   end , || not encounterCard.isSmoothMoving() and encounterCard.resting)
--   broadcastToAll('Returned encounter card to the bottom of the encounter deck', {1, 1, 1})
-- end

-- function returnNeighbordhoodTag(neighborhoodTile)
--   neighborhoodTags = getObjectFromGUID('3e1179').getTable('neighborhoodTags')

--   for _, neighborhoodTag in ipairs(neighborhoodTags) do
--     if neighborhoodTile.hasTag(neighborhoodTag) then return neighborhoodTag end
--   end
-- end

-- function checkIfNeighborhoodAlreadyHasTerror(neighborhoodTag, terrorCard, neighborhoodDeck)
--   for i, activeTerror in ipairs(activeTerrorEvents) do
--     if activeTerror[1].hasTag(neighborhoodTag) == true then
--       pos = activeTerror[2].getPosition()
--       terrorCard.setPositionSmooth({
--         x=pos.x,
--         y=pos.y + 5,
--         z=pos.z
--       })
--       Wait.condition(
--         function() 
--           terrorStack = activeTerror[2].putObject(terrorCard)
--           table.remove(activeTerrorEvents, i)
--           table.insert(activeTerrorEvents, {neighborhoodDeck, terrorStack})
--           print('f')
--           setRemoveContextToTerrorCard(terrorCard)
--         end, || not terrorCard.isSmoothMoving()
--       )
      
--       return true
--     end
--   end
-- end

-- function returnNeighborhoodDeck(neighborhoodTag)
--   neighborhoodDecks = getObjectFromGUID('3e1179').getTable('neighborhoodDecks')
--   for _, deck in ipairs(neighborhoodDecks) do
--     if deck.hasTag(neighborhoodTag)then
--       return deck
--     end
--   end
-- end

-- function assignTerrorToken(terrorTile)
--   pos = terrorTile.getPosition()
--   terrorTokenBag = getObjectFromGUID('f37ea1')
--   local terrorToken = terrorTokenBag.takeObject({
--     position={
--       x=pos.x,
--       y=pos.y + 5,
--       z=pos.z
--     }
--   })

--   local func = function(player_color) removeTerrorToken(terrorToken) end
--   terrorToken.addContextMenuItem('Remove Terror!', func)
-- end

-- function removeTerrorToken(terrorToken)
--   terrorToken.destruct()
--   broadcastToAll('Terror removed!', {0, 1, 0})
-- end

-- function isTerrorDeckEmpty()
--   if getObjectFromGUID('3e1179').getVar('terrorDeck').remainder ~= nil then
--     lastTerrorCard = getObjectFromGUID('3e1179').getVar('terrorDeck').remainder
--     getObjectFromGUID('3e1179').setVar('terrorDeck', lastTerrorCard)
--     return true
--     else
--       return false
--   end
-- end

-- function setRemoveContextToTerrorCard(terrorCard)
--   for i, activeTerror in ipairs(activeTerrorEvents) do

--     if activeTerror[2] == terrorCard then
--       print(activeTerror[1].guid)
--     end

--     -- if activeTerror[2].type == 'Card' then
--     --   print('Card')
--     --   else
--     --     print('Deck')
--     -- end
--   end

--   local func = function() manuallyRemoveTerrorCard(terrorCard, deck) end
--   terrorCard.addContextMenuItem('Remove encounter', func)
-- end

-- function manuallyRemoveTerrorCard(terrorCard)
--   for i, activeTerrorEvent in ipairs(activeTerrorEvents) do
--     if activeTerrorEvent[2] == terrorCard then
--       table.remove(activeTerrorEvents, i)
--       moveTerrorCardToTerrorDeck(terrorCard)
--     end
--   end
-- end

-- function moveTerrorCardToTerrorDeck(terrorCard)
--   terrorDeck = getObjectFromGUID('3e1179').getVar('terrorDeck')
--   terrorDeckPos = terrorDeck.getPosition() + Vector(4, 0, 0)

--   terrorCard.setPositionSmooth(terrorDeckPos)
--   terrorCard.setRotationSmooth({x=0, y=180, z=180})

--   Wait.condition(
--     function() terrorDeck.putObject(terrorCard) end,
--   || not terrorCard.isSmoothMoving() )
  
-- end