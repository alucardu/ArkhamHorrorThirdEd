
neighborhoodTags = {
  'Rivertown',
  'Downtown',
  'Northside',
  'Easttown',
  'Merchant District',
  'Miskatonic University'
}
discardDeck = nil

function spreadDoom(doomToken)
  someVal = doomToken[2]
  eventDeck = getObjectFromGUID('3e1179').getVar('eventDeck')
  neighborhoodTiles = getObjectFromGUID('3e1179').getTable('neighborhoodTiles')

  eventDeckPos = eventDeck.getPosition()
  doomPos = {x = eventDeckPos.x + 4, y = eventDeckPos.y, z = eventDeckPos.z}
  if 
    doomToken[2] == 'setup' or
    doomToken[2] == 'mythos' or
    doomToken == nil 
  then
    takenObject = eventDeck.takeObject({
      index = eventDeck.getQuantity() - 1,
    })
  
    if discardDeck == nil then
      print('Event discard deck is empty')
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
      if deck.hasTag(returnNeighbordhoodTag(takenObject))then
        neighborhoodPosition = deck.getPosition()
      end
    end
  
    -- doomtoken
    doomBag = getObjectFromGUID('f807c7')
    doomToken = doomBag.takeObject({
      position={x=neighborhoodPosition.x, y=neighborhoodPosition.y + 5, z=neighborhoodPosition.z}
    })

    broadcastToAll('Add doom to ' .. returnNeighbordhoodTag(takenObject), {1,0,0})
  end

  -- when doom tokens come from second setup bag
  if someVal == 'setupBag' then
    addContextMenu({doomToken[1], 'asd'}) 
  end

end

function addContextMenu(doomToken)
  if doomToken ~= nil then
    local func = function(player_color) removeDoomToken(player_color, i, doomToken[1]) end
    doomToken[1].addContextMenuItem('Remove doom', func)  
  end
end

function removeDoomToken(player_color, index, token)
  token.destruct()
  broadcastToAll('Doom has been removed!', {0, 1, 0})
end

function returnNeighbordhoodTag(encounterCard)
  for _, neighborhoodTag in ipairs(neighborhoodTags) do
    if encounterCard.hasTag(neighborhoodTag) then return neighborhoodTag end
  end
end