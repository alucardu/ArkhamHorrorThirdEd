function drawNeighborhoodEncounter(obj)
  eventDeck = getObjectFromGUID('3e1179').getVar('eventDeck')
  eventDeckPos = eventDeck.getPosition()
  neighborhoodDecks = getObjectFromGUID('3e1179').getTable('neighborhoodDecks')

  for i, deck in ipairs(neighborhoodDecks) do
    if obj[3].getTags()[1] == deck.getTags()[1] then
      deckPosition = deck.getPosition()
      encounterCard = deck.takeObject()
      encounterCard.deal(1, obj[1])

      local func = function(player_color) eventSuccess(player_color, i, encounterCard, deck) end
      encounterCard.addContextMenuItem('Event success', func)

      local func = function(player_color) eventFailed(player_color, i, encounterCard, deck) end
      encounterCard.addContextMenuItem('Event failed', func)

      local func = function(player_color) encounter(player_color, i, encounterCard, deck) end
      encounterCard.addContextMenuItem('Encounter', func)

      broadcastToAll('Dealt ' .. deck.getTags()[1] .. ' encounter card to ' .. obj[1], {0,1,0})
    end
  end
end

function drawNeighborhoodAnomaly(obj)
  anomaliesDeck = getObjectFromGUID('3e1179').getVar('anomaliesDeck')
  anomaliesDeckPos = anomaliesDeck.getPosition()
  anomalyCard = anomaliesDeck.takeObject()
  anomalyCard.deal(1, obj[1])

  local func = function(player_color) anomaly(player_color, i, anomalyCard, deck) end
  anomalyCard.addContextMenuItem('Encounter', func)
end

function anomaly(player_color, i, anomalyCard, deck)
  anomalyCard.flip()
  anomalyCard.setPosition({x=anomaliesDeckPos.x, y=anomaliesDeckPos.y, z=anomaliesDeckPos.z - 5})
  anomalyCard.setPositionSmooth({x=anomaliesDeckPos.x, y=anomaliesDeckPos.y - 0.1, z=anomaliesDeckPos.z})
  broadcastToAll('Returned anomaly card to the bottom of the anomaly deck', {1, 1, 1})
end

function eventSuccess(player_color, i, encounterCard, deck)
  discardDeck = getObjectFromGUID('077454').getVar('discardDeck')

  if discardDeck == nil then
    eventDiscardPos = {x = eventDeckPos.x + 4, y = eventDeckPos.y, z = eventDeckPos.z}
    encounterCard.setPosition(eventDiscardPos)
    getObjectFromGUID('077454').setVar('discardDeck', encounterCard)
    else 
      getObjectFromGUID('077454').setVar('discardDeck', discardDeck.putObject(encounterCard))
  end
  broadcastToAll('Returned encounter card to the event discard pile', {1, 1, 1})

end

function eventFailed(player_color, i, encounterCard, deck)
  selection = deck.cut(2)

  selection[2].setPositionSmooth(
    {x = deckPosition.x, y = deckPosition.y, z = deckPosition.z + - 5}
  )
  selection[2].setRotationSmooth(
    {180, 0, 0}
  )
  local shuffle = function() selection[2].putObject(encounterCard) Wait.frames(function() shuffleFn(selection[2]) end, 64) end
  moveWatch = function() return not selection[2].isSmoothMoving() end
  Wait.condition(shuffle, moveWatch)
  broadcastToAll('Returned encounter card to the top of the encounter deck', {1, 1, 1})
end

function encounter(player_color, i, encounterCard, deck)
  encounterCard.flip()
  encounterCard.setPosition({x=deckPosition.x, y=deckPosition.y, z=deckPosition.z - 5})
  encounterCard.setPositionSmooth({x=deckPosition.x, y=deckPosition.y - 0.1, z=deckPosition.z})
  broadcastToAll('Returned encounter card to the bottom of the encounter deck', {1, 1, 1})
end


function shuffleFn(deck) 
  deck.shuffle()

  Wait.frames(
    function()
      deck.shuffle()
    end,
    32
  )

  Wait.frames(
    function()
      deck.shuffle()
    end,
    64
  )

  Wait.frames(
    function()
      selection[2].setPositionSmooth({x = deckPosition.x, y=deckPosition.y + 5, z=deckPosition.z}) 
    end,
    96
  )
end