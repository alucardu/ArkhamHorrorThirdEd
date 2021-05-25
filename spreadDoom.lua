function onLoad()
  doomTokenBag = getObjectFromGUID('f807c7')

  neighborhoodTags = {
    'Rivertown',
    'Downtown',
    'Northside',
    'Easttown',
    'Merchant District',
    'Miskatonic University'
  }

  discardDeck = nil
end

-- Called when a Doom token leaves the Doom token container
function onObjectLeaveContainer(container, doom_token)
  if container == doomTokenBag then
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
  
    --Spawn Doom token on the assigned neighborhood tile
    doomToken = doomTokenBag.takeObject()
    doomToken.setPositionSmooth({
      x=neighborhoodTilePosition.x,
      y=neighborhoodTilePosition.y + 4,
      z=neighborhoodTilePosition.z,
    })
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