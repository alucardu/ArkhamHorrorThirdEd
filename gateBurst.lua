function onLoad()
  local params = {
    click_function="gateBurst",
    tooltip="Resolve a Gate burst",
    function_owner = self,
    height=1250,
    width=1250,
    color={0, 0, 0, 0},
    position={0, 0.1, 0}
  }
  self.createButton(params)
end

function gateBurst()
  eventDeck = getObjectFromGUID('3e1179').getVar('eventDeck')
  eventDeckPos = eventDeck.getPosition()
  discardDeck = getObjectFromGUID('eaa6bd').getVar('discardDeck')
  neighborhoodTiles = getObjectFromGUID('3e1179').getTable('neighborhoodTiles')

  local eventCard = eventDeck.takeObject()
  eventCard.flip()
  eventCard.setPositionSmooth({
    x=eventDeckPos.x + 4,
    y=eventDeckPos.y + 4,
    z=eventDeckPos.z
  })
  
  if discardDeck == nil then
    Wait.condition(function()
      eventDeck.putObject(eventCard)
    end , || eventCard.resting)
  end

  if discardDeck ~= nil then
    Wait.condition(function() 
      discardDeck = discardDeck.putObject(eventCard)
      Wait.frames(function() reshuffleDiscardDeck(discardDeck, eventDeck) end, 32)
    end, || not eventCard.isSmoothMoving())
  end

  placeDoomTokens(eventCard)
  originalUnstablePlace = getObjectFromGUID('3e1179').getVar('originalUnstableSpace')
  getObjectFromGUID('3e1179').setVar('unstableSpace', originalUnstablePlace)

end

function reshuffleDiscardDeck(discardDeck, eventDeck)
  discardDeck.flip()
  discardDeck.shuffle()
  eventDeck.putObject(discardDeck)
end

function placeDoomTokens(eventCard)
  broadcastToAll('Gate burst!', {1,0,0})
  broadcastToAll('Add doom to each part of ' .. returnNeighborhoodTag(eventCard), {1,0,0})

  for i, neighborhoodTile in ipairs(neighborhoodTiles) do
    if neighborhoodTile.hasTag(returnNeighborhoodTag(eventCard)) then
      neighborhoodPosition = neighborhoodTile.getPosition()
    end
  end

  for i = 3 , 1, -1 do
    getObjectFromGUID('f807c7').takeObject({
      position={
        x=neighborhoodPosition.x, 
        y=neighborhoodPosition.y + 5, 
        z=neighborhoodPosition.z}
    })
  end
end

function returnNeighborhoodTag(eventCard)
  neighborhoodTags = getObjectFromGUID('3e1179').getTable('neighborhoodTags')
  for _, neighborhoodTag in ipairs(neighborhoodTags) do
    if eventCard.hasTag(neighborhoodTag) then 
      return neighborhoodTag
    end
  end
end 