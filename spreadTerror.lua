activeTerrorEvents = {}

function onLoad()
  local params = {
    click_function="mythosTerror",
    tooltip="Spread Terror",
    function_owner = self,
    height=1250,
    width=1250,
    color={0, 0, 0, 0},
    position={0, 0.1, 0}
  }
  self.createButton(params)
end

function mythosTerror()
  neighborhoodTags = getObjectFromGUID('3e1179').getTable('neighborhoodTags')

  eventDiscardDeck = getObjectFromGUID('077454').getVar('discardDeck')
  if eventDiscardDeck.getQuantity() < 0 then
    -- single event discard card
    for _, neighborhoodTag in ipairs(neighborhoodTags) do
      if eventDiscardDeck.hasTag(neighborhoodTag) then
        currentUnstableNeighborhoodTag = neighborhoodTag
      end
    end
    else
      -- multiple event discard cards
      for i, eventDiscardCard in ipairs(eventDiscardDeck.getObjects()) do
        topEventDiscardCard = eventDiscardCard
      end
    
      for _, tag in ipairs(topEventDiscardCard.tags) do
        for _, neighborhoodTag in ipairs(neighborhoodTags) do
          if tag == neighborhoodTag then
            currentUnstableNeighborhoodTag = tag
          end
        end
      end
  end
  spawnMythosTerror(currentUnstableNeighborhoodTag)
  broadcastToAll('Terror spreaded on ' .. currentUnstableNeighborhoodTag .. ' !', {1, 0, 0})
end

function spawnMythosTerror(currentUnstableNeighborhoodTag)
  neighborhoodTiles = getObjectFromGUID('3e1179').getTable('neighborhoodTiles')

  for _, neighborhoodTile in ipairs(neighborhoodTiles) do 
    if neighborhoodTile.hasTag(currentUnstableNeighborhoodTag) == true then
      terrorTile = neighborhoodTile
    end    
  end

  terrorDeck = getObjectFromGUID('3e1179').getVar('terrorDeck')
  terrorDeckPosition = terrorDeck.getPosition()
  terrorCard = terrorDeck.takeObject()

  terrorCard.setRotationSmooth({
    x=180,
    y=90,
    z=0
  })
  neighborhoodDecks = getObjectFromGUID('3e1179').getTable('neighborhoodDecks')

  for _, neighborhoodDeck in ipairs(neighborhoodDecks) do
    if neighborhoodDeck.hasTag(currentUnstableNeighborhoodTag) then
      currentNeighborhoodDeck = neighborhoodDeck
      currentNeighborhoodDeckPos = currentNeighborhoodDeck.getPosition()
    end
  end
  
  alreadyHasTerror = checkIfNeighborhoodAlreadyHasTerror(currentUnstableNeighborhoodTag, terrorCard, currentNeighborhoodDeck)

  if alreadyHasTerror ~= true then
    terrorCard.setPositionSmooth({
      x=currentNeighborhoodDeckPos.x,
      y=currentNeighborhoodDeckPos.y + 5,
      z=currentNeighborhoodDeckPos.z
    })
    table.insert(activeTerrorEvents, {currentNeighborhoodDeck, terrorCard})
    setTerrorContextToTile(terrorTile)
  end
  assignTerrorToken(terrorTile)
end

function spreadTerror(terror)
  terrorDeck = getObjectFromGUID('3e1179').getVar('terrorDeck')

  if terrorDeck == nil then
    getObjectFromGUID('f807c7').takeObject({
      position={
        x=terrorDeckPosition.x + 3,
        y=terrorDeckPosition.y + 5,
        z=terrorDeckPosition.z
      }
    })
    broadcastToAll('Add one Doom to the scenario!', {1, 0, 0})
    return
    else 
      terrorDeckPosition = terrorDeck.getPosition()
  end

  neighborhoodTag = returnNeighbordhoodTag(terror[3])

  neighborhoodDecks = getObjectFromGUID('3e1179').getTable('neighborhoodDecks')
  for i, deck in ipairs(neighborhoodDecks) do
    if deck.hasTag(neighborhoodTag) then
      neighborhoodDeck = deck
      neighborhoodDeckPos = neighborhoodDeck.getPosition()
    end
  end

  if terrorDeck.getQuantity() < 0 then
    -- single card
    terrorCard = terrorDeck
    terrorCard.setRotationSmooth({
      x=180,
      y=90,
      z=0
    })

    alreadyHasTerror = checkIfNeighborhoodAlreadyHasTerror(neighborhoodTag, terrorCard, neighborhoodDeck)

    if alreadyHasTerror ~= true then
      terrorCard.setPositionSmooth({
        x=neighborhoodDeckPos.x,
        y=neighborhoodDeckPos.y + 5,
        z=neighborhoodDeckPos.z
      })
      table.insert(activeTerrorEvents, {neighborhoodDeck, terrorCard})
      setTerrorContextToTile(terror[3])
    end

    getObjectFromGUID('3e1179').setVar('terrorDeck', nil)

    broadcastToAll('Terror spreaded on ' .. neighborhoodTag .. ' !', {1, 0, 0})
    assignTerrorToken(terror[3])

    else 
      -- deck
      terrorCard = terrorDeck.takeObject()
      isTerrorDeckEmpty()

      terrorCard.setRotationSmooth({
        x=180,
        y=90,
        z=0
      })

      alreadyHasTerror = checkIfNeighborhoodAlreadyHasTerror(neighborhoodTag, terrorCard, neighborhoodDeck)

      if alreadyHasTerror ~= true then
        terrorCard.setPositionSmooth({
          x=neighborhoodDeckPos.x,
          y=neighborhoodDeckPos.y + 5,
          z=neighborhoodDeckPos.z
        })
        table.insert(activeTerrorEvents, {neighborhoodDeck, terrorCard})
        setTerrorContextToTile(terror[3])
      end

      broadcastToAll('Terror spreaded on ' .. neighborhoodTag .. ' !', {1, 0, 0})
      assignTerrorToken(terror[3])
  end
end

function drawTerrorEncounter(o)
  print(self.guid)
  terrorDeck = getObjectFromGUID('3e1179').getVar('terrorDeck')
  player_color = o[1]
  o = o[3]
  i = i
  o.clearContextMenu()

  neighborhoodTag = returnNeighbordhoodTag(o)
  neighborhoodDeck = returnNeighborhoodDeck(returnNeighbordhoodTag(o))

  for q, activeTerror in ipairs(activeTerrorEvents) do
    if activeTerror[1].hasTag(neighborhoodTag) == true then
      if activeTerror[2].getQuantity() >= 0 then
          activeTerror[2].shuffle()
          terrorCard = activeTerror[2].takeObject()
          terrorCard.deal(1, player_color)

          local func = function(player_color) encounter(player_color, i, terrorCard) end
          terrorCard.addContextMenuItem('Encounter', func)
          if activeTerror[2].remainder ~= nil then
            table.insert(activeTerrorEvents, {neighborhoodDeck, activeTerror[2].remainder})
            table.remove(activeTerrorEvents, q)
            setContext(player_color, i, o)
            setTerrorContextToTile(o)
            return
          end
          setTerrorContextToTile(o)
        else
          terrorCard = activeTerror[2]

          local func = function(player_color) encounter(player_color, i, terrorCard) end
          terrorCard.addContextMenuItem('Encounter', func)

          activeTerror[2].deal(1, player_color)
          table.remove(activeTerrorEvents, q)          
      end
    end
  end

  setContext(player_color, i, o)

end

function setTerrorContextToTile(o)
  local func = function(player_color) self.call('drawTerrorEncounter', {player_color, i, o}) end
  o.addContextMenuItem('Terror Encounter', func)
end

function setContext(player_color, i, o)
  player_color = player_color
  o = o
  i = i
  local func = function(player_color) getObjectFromGUID('84ef85').call('drawNeighborhoodEncounter', {player_color, i, o}) end
  o.addContextMenuItem('Draw encounter', func)

  local func = function(player_color) self.call('spreadTerror', {player_color, i, o}) end
  o.addContextMenuItem('Trigger terror', func)
end

function encounter(player_color, i, encounterCard, deck)
  if terrorDeck == nil then
    z = 0
    else
      z = 5
  end
  encounterCard.setPosition({
    x=terrorDeckPosition.x,
    y=terrorDeckPosition.y,
    z=terrorDeckPosition.z - z
  })
  Wait.condition(
  function()
    encounterCard.flip()
    if terrorDeck == nil then
      getObjectFromGUID('3e1179').setVar('terrorDeck', encounterCard)
      else
        terrorDeck = terrorDeck.putObject(encounterCard)
        getObjectFromGUID('3e1179').setVar('terrorDeck', terrorDeck)
    end
  end , || not encounterCard.isSmoothMoving() and encounterCard.resting)
  broadcastToAll('Returned encounter card to the bottom of the encounter deck', {1, 1, 1})
end

function returnNeighbordhoodTag(neighborhoodTile)
  neighborhoodTags = getObjectFromGUID('3e1179').getTable('neighborhoodTags')

  for _, neighborhoodTag in ipairs(neighborhoodTags) do
    if neighborhoodTile.hasTag(neighborhoodTag) then return neighborhoodTag end
  end
end

function checkIfNeighborhoodAlreadyHasTerror(neighborhoodTag, terrorCard, neighborhoodDeck)
  for i, activeTerror in ipairs(activeTerrorEvents) do
    if activeTerror[1].hasTag(neighborhoodTag) == true then
      pos = activeTerror[2].getPosition()
      terrorCard.setPositionSmooth({
        x=pos.x,
        y=pos.y + 5,
        z=pos.z
      })
      Wait.condition(
        function() 
          terrorStack = activeTerror[2].putObject(terrorCard)
          table.remove(activeTerrorEvents, i)
          table.insert(activeTerrorEvents, {neighborhoodDeck, terrorStack})
        end, || not terrorCard.isSmoothMoving()
      )
      
      return true
    end
  end
end

function returnNeighborhoodDeck(neighborhoodTag)
  neighborhoodDecks = getObjectFromGUID('3e1179').getTable('neighborhoodDecks')
  for _, deck in ipairs(neighborhoodDecks) do
    if deck.hasTag(neighborhoodTag)then
      return deck
    end
  end
end

function assignTerrorToken(terrorTile)
  pos = terrorTile.getPosition()
  terrorTokenBag = getObjectFromGUID('f37ea1')
  local terrorToken = terrorTokenBag.takeObject({
    position={
      x=pos.x,
      y=pos.y + 5,
      z=pos.z
    }
  })

  local func = function(player_color) removeTerrorToken(terrorToken) end
  terrorToken.addContextMenuItem('Remove Terror!', func)
end

function removeTerrorToken(terrorToken)
  terrorToken.destruct()
  broadcastToAll('Terror removed!', {0, 1, 0})
end

function isTerrorDeckEmpty()
  if getObjectFromGUID('3e1179').getVar('terrorDeck').remainder ~= nil then
    lastTerrorCard = getObjectFromGUID('3e1179').getVar('terrorDeck').remainder
    getObjectFromGUID('3e1179').setVar('terrorDeck', lastTerrorCard)
    return true
    else
      return false
  end
end