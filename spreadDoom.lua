function onSave()
  if discardDeck ~= nil then
    local state = {
      discardDeck = discardDeck.guid
    }
    return JSON.encode(state)
  end
end

function onLoad(script_state)
  discardDeck = nil
  local state = JSON.decode(script_state)
  if state ~= nil then
    discardDeck = getObjectFromGUID(state.discardDeck)
  end

  doomTokenBag = getObjectFromGUID('f807c7')

  neighborhoodTags = getObjectFromGUID('3e1179').getTable('neighborhoodTags')
end

-- Called when a Doom token leaves the Doom token container
function onObjectLeaveContainer(container, doom_token)
  if container == doomTokenBag then
    doom_token.addTag('Doom')
    addContextMenu(doom_token)
  end
end

function spreadDoom(doomToken)
  eventDeck = getObjectFromGUID('3e1179').getVar('eventDeck')
  neighborhoodTiles = getObjectFromGUID('3e1179').getTable('neighborhoodTiles')
  eventDeckPos = eventDeck.getPosition()

  --Called from scenario setup steps or Mythos Cup
  if doomToken == nil then
    eventCard = returnEventCard()

    Wait.condition(
      function()addToDiscardPile(eventCard) end, 
      || not eventCard.isSmoothMoving()
    )

    neighborhoodTag = returnNeighborhoodTag(eventCard)
    neighborhoodTilePosition = returnNeighborhoodTile(neighborhoodTag).getPosition()

    iteration = 1
    if eventCard.hasTag('Number of Doom 2') then
      iteration = 2
    end
    
    for i = iteration , 1, -1 do
      --Spawn Doom token on the assigned neighborhood tile
      frames = i*32
      Wait.frames(
        function()
          doomToken = doomTokenBag.takeObject()
          doomToken.setPositionSmooth({
            x=neighborhoodTilePosition.x,
            y=neighborhoodTilePosition.y + 4,
            z=neighborhoodTilePosition.z,
          })
          doomToken.addTag('Doom')
        end, frames
      )
    end
    broadcastToAll(iteration .. ' Doom spreaded on '  .. neighborhoodTag .. '!', {1, 0, 0})
    return
  end

  --Called from scenario setup bag
  if doomToken.hasTag('Setup') then
    addContextMenu(doomToken) 
  end

end

--Helper functions
function addContextMenu(doomToken)
  local func = function() removeDoomToken(doomToken) end
  doomToken.addContextMenuItem('Remove doom', func)  
end

function removeDoomToken(token)
  token.destruct()
  broadcastToAll('Doom has been removed!', {0, 1, 0})
end

function returnEventCard()
  eventCard = eventDeck.takeObject()
  eventCard.flip()
  eventCard.setPositionSmooth(
    {
      x=eventDeckPos.x + 4,
      y=eventDeckPos.y + 4,
      z=eventDeckPos.z
    }
  )
  return eventCard
end

function returnNeighborhoodTag(encounterCard)
  for _, neighborhoodTag in ipairs(neighborhoodTags) do
    if encounterCard.hasTag(neighborhoodTag) then 
      return neighborhoodTag
    end
  end
end

function returnNeighborhoodTile(neighborhoodTag)
  for _, tile in ipairs(neighborhoodTiles) do
    if tile.hasTag(neighborhoodTag)then
      return tile
    end
  end
end

function addToDiscardPile(eventCard)
  if discardDeck == nil then
    discardDeck = eventCard
    else
      discardDeck = discardDeck.putObject(eventCard)
  end
end