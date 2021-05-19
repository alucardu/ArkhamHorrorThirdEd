discardDeck = nil

function spreadDoom(doomToken)
  someVal = doomToken
  eventDeck = getObjectFromGUID('3e1179').getVar('eventDeck')
  neighborhoodTiles = getObjectFromGUID('3e1179').getTable('neighborhoodTiles')

  eventDeckPos = eventDeck.getPosition()
  doomPos = {x = eventDeckPos.x + 4, y = eventDeckPos.y, z = eventDeckPos.z}

  if doomToken == 'setup' or doomToken == nil  then
    takenObject = eventDeck.takeObject({
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
    doomBag = getObjectFromGUID('f807c7')
    doomToken = doomBag.takeObject({
      position={x=neighborhoodPosition.x, y=neighborhoodPosition.y + 5, z=neighborhoodPosition.z}
    })

    broadcastToAll('Add doom to ' .. takenObject.getTags()[1], {1,0,0})
  end
  

  if someVal == 'setup' or type(someVal) ~= "string" then addContextMenu(doomToken) end
end

function addContextMenu(doomToken)
  if 
    doomToken ~= nil and
    type(doomToken) ~= "string"
  then
    local func = function(player_color) removeDoomToken(player_color, i, doomToken) end
    doomToken.addContextMenuItem('Remove doom', func)  
  end
  
end

function removeDoomToken(player_color, index, token)
  token.destruct()
  broadcastToAll('Doom has been removed!', {0, 1, 0})
end