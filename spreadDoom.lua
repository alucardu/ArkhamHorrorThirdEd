discardDeck = nil

function spreadDoom()
  eventDeck = getObjectFromGUID('3e1179').getVar('eventDeck')
  neighborhoodTiles = getObjectFromGUID('3e1179').getTable('neighborhoodTiles')

  eventDeckPos = eventDeck.getPosition()
  doomPos = {x = eventDeckPos.x + 4, y = eventDeckPos.y, z = eventDeckPos.z}
  
  local takenObject = eventDeck.takeObject({
    index = eventDeck.getQuantity() - 1,
  })

  if discardDeck == nil then
    takenObject.flip()
    discardDeck = takenObject
    discardDeck.setPositionSmooth({x=doomPos.x, y=doomPos.y + 5, z=doomPos.z})
    print(discardDeck)
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