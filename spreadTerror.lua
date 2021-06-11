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
  neighborhoodTiles = getObjectFromGUID('3e1179').getTable('neighborhoodTiles')
end

function onObjectLeaveContainer(container, terrorToken)
  if container ==  getObjectFromGUID('51b302') then
    local func = function() destroyObject(terrorToken) end
    terrorToken.addContextMenuItem('Remove terror', func)
  end
end

function mythosTerror()
  unstableSpace = getObjectFromGUID('3e1179').getVar('unstableSpace')
  neighborhoodTile = returnNeighborhoodTile(unstableSpace)
  spreadTerror({white, 1, neighborhoodTile})
end

function spreadTerror(object)
  if terrorCardMoving == true then
    broadcastToAll('Spread terror is already spreading!', {0, 1, 0})
    return
  end

  player_color = object[1]
  neighborhoodTile = object[3]

  neighborhoodTag = returnNeighbordhoodTag(neighborhoodTile)
  neighborhoodTagOg = neighborhoodTag
  neighborhoodDeck = returnNeighborhoodDeck(neighborhoodTag)
  neighborhoodTag = neighborhoodTag:gsub("%s+", "")

  -- check if terror deck is empty
  if terrorDeck == nil then
    getObjectFromGUID('f807c7').takeObject({position = terrorDeckPos + Vector(3, 5, 0)})
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

  broadcastToAll('Terror spreaded on ' .. neighborhoodTagOg, {1, 0, 0})
  placeTerrorToken(neighborhoodTile)

  -- wait for terror card to stop moving
  Wait.condition(function()
    for i, terrorEvent in ipairs(terrorEvents) do

      if terrorEvents[i] == neighborhoodTag or terrorEvent[2] == neighborhoodTag then
        if checkIfNeighborhoodAlreadyHasTerror(neighborhoodTag) == true then
          terrorEvent = terrorEvent[1].putObject(terrorCard)
          terrorEvents[i] = { terrorEvent, neighborhoodTag}
          terrorEvent.setName(neighborhoodTag)

          -- don't add context items if the neighborhood terror deck already has context
          if not (terrorEvent.getQuantity() > 2) then setContextToTerrorDeck(terrorEvent, i) end

          terrorCardMoving = false
          return
        end

        if checkIfNeighborhoodAlreadyHasTerror(neighborhoodTag) == false then
          terrorEvents[i] = { terrorCard, neighborhoodTag}
          context = terrorEvent
          setContextToNeighborhoodTile(neighborhoodTile, neighborhoodTag)
          setContextToTerrorDeck(terrorCard, i, neighborhoodTile)

          terrorCardMoving = false
          return
        end
      end
    
    end

    terrorCardMoving = false

  end, || not terrorCard.isSmoothMoving())
end

function drawTerrorEncounter(player_color, neighborhoodTag)
  broadcastToAll('Dealt ' .. neighborhoodTag .. ' terror card to '  .. player_color, {0, 1, 1})
  currentNeighborhood = neighborhoodTag
  neighborhoodTag = neighborhoodTag:gsub("%s+", "")
  for i, terrorEvent in ipairs(terrorEvents) do
    if neighborhoodTag == terrorEvent[2] then
      
      if terrorEvent[1].type == 'Card' then
        terrorEvent[1].deal(1, player_color)
        -- sets clicked neighborhood tile for returning cards
        neighborhoodTile = returnNeighborhoodTile(currentNeighborhood)
        terrorEvent[1].clearContextMenu()
        setContextToTerrorCard(terrorEvent[1], currentNeighborhood, i)
        terrorEvents[i] = { null, neighborhoodTag}
      end

      if terrorEvent[1].type == 'Deck' then
        terrorEvent[1].shuffle()
        Wait.frames(function()
          terrorCard = terrorEvent[1].takeObject()
          terrorCard.deal(1, player_color)
          setContextToTerrorCard(terrorCard, neighborhoodTag, i)
          if terrorEvent[1].remainder ~= nil then
            terrorEvents[i] = { terrorEvent[1].remainder, neighborhoodTag }
            setContextToTerrorCard(terrorEvent[1].remainder, neighborhoodTag, i)
          end
        end, 32)
      end

    end
  end
end

function returnTerrorCard(terrorEvent, neighborhoodTag, i, neighborhoodTile)
  broadcastToAll('Returned terror card to terror deck', {0, 1, 0})
  neighborhoodTag = neighborhoodTag:gsub("%s+", "")
  local fromHand = false

  for _,zone in ipairs(terrorEvent.getZones()) do
    if zone.type == 'Hand' then fromHand = true end      
  end

  if checkIfNeighborhoodAlreadyHasTerror(neighborhoodTag) == false then
    resetContextToNeighborhoodTile(player_color, i, neighborhoodTile)
  end

  if terrorEvent.type == 'Card' and fromHand == false then
    resetContextToNeighborhoodTile(player_color, i, neighborhoodTile)

    terrorCard = terrorEvent
    terrorCard.setPositionSmooth(terrorDeckPos + Vector(4, 5, 0))
    terrorCard.setRotationSmooth({0, 180, 180})

    Wait.condition(
      function() terrorCard.setPositionSmooth(terrorDeckPos + Vector(0, -0.1, 0)) end,
    || not terrorCard.isSmoothMoving() and terrorCard.resting)

    for i, terrorEvent in ipairs(terrorEvents) do
      if terrorEvent[2] == neighborhood then
        terrorEvents[i] = {terrorEvent[1], neighborhood}
      end
    end
  end

  if terrorEvent.type == 'Card' and fromHand == true then
    -- error card bottom deck
    terrorCard = terrorEvent

    local d = terrorCard.getData()
    d.Hands = false
    destroyObject(terrorCard)
    terrorCard = spawnObjectData({data = d})
    terrorCard.setPositionSmooth(terrorDeckPos + Vector(4, 0, 0))
    terrorCard.setRotationSmooth({0, 180, 180})
    
    Wait.condition(function() terrorDeck.putObject(terrorCard) end,
    || not terrorCard.isSmoothMoving())

    -- remove context if neighborhood has no terror
    for i, terrorEvent in ipairs(terrorEvents) do
      if terrorEvent[1] == nil and terrorEvent[2] == neighborhoodTag then
        -- error
        terrorEvents[i] = {terrorEvent[1], neighborhoodTag}
        resetContextToNeighborhoodTile(player_color, i, neighborhoodTile)
      end
    end
  end

  -- card came from a neighborhood terror deck
  if terrorEvent.type == 'Deck' then
    terrorEvent.shuffle()
    Wait.frames(function() 
      terrorCard = terrorEvent.takeObject({position = terrorDeckPos + Vector(0, 5, 0)})
      if terrorEvent.remainder ~= nil then
        terrorEvents[i] = { terrorEvent.remainder, neighborhoodTag }
        setContextToTerrorCard(terrorEvent.remainder, neighborhoodTag, i)
      end
      terrorCard.setRotationSmooth({0, 180, 180})

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
    end, 32)
    
    neighborhood = terrorEvent.getName()
  end
  
  if terrorEvent.getQuantity() == 0 then
    -- reset table to card
    terrorEvents[i] = { terrorEvent.remainder, neighborhood }
    setContextToTerrorCard(terrorEvent.remainder, neighborhood, i)
  end
end

function placeTerrorToken(neighborhoodTile)
  getObjectFromGUID('51b302').takeObject({position = neighborhoodTile.getPosition() + Vector(0, 5, 0)})
end

function resetContextToNeighborhoodTile(player_color, i, neighborhoodTile)
  neighborhoodTile.clearContextMenu()
  
  local func = function(player_color) getObjectFromGUID('84ef85').call('drawNeighborhoodEncounter', {player_color, i, neighborhoodTile}) end
  neighborhoodTile.addContextMenuItem('Draw encounter', func)
  
  local func = function(player_color) spreadTerror({player_color, i, neighborhoodTile}) end
  neighborhoodTile.addContextMenuItem('Trigger terror', func)
end

function setContextToTerrorCard(terrorCard, neighborhoodTag, i)
  local func = function() returnTerrorCard(terrorCard, neighborhoodTag, i, neighborhoodTile) end
  terrorCard.addContextMenuItem('Return Card', func)
end

function setContextToTerrorDeck(terrorEvent, i, neighborhoodTile)
  local func = function() returnTerrorCard(terrorEvent, neighborhoodTag, i, neighborhoodTile) end
  terrorEvent.addContextMenuItem('Return Card', func)
end

function setContextToNeighborhoodTile(neighborhoodTile, neighborhoodTag)
  local func = function(player_color) drawTerrorEncounter(player_color, returnNeighbordhoodTag(neighborhoodTile)) end
  neighborhoodTile.addContextMenuItem('Terror encounter', func)
end

function checkIfNeighborhoodAlreadyHasTerror(neighborhoodTag)
  value = false
  for i, terrorEvent in ipairs(terrorEvents) do
    if terrorEvent[1] ~= null and terrorEvent[2] == neighborhoodTag then
      value = true
    end
  end
  return value
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

function returnNeighborhoodTile(neighborhoodTag)
  for _, tile in ipairs(neighborhoodTiles) do
    if tile.hasTag(neighborhoodTag)then  return tile end
  end
end