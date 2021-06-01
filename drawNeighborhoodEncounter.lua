function onLoad()
  neighborhoodTags = getObjectFromGUID('3e1179').getTable('neighborhoodTags')
end

function drawNeighborhoodEncounter(obj)
  eventDeck = getObjectFromGUID('3e1179').getVar('eventDeck')
  eventDeckPos = eventDeck.getPosition()
  neighborhoodDecks = getObjectFromGUID('3e1179').getTable('neighborhoodDecks')

  for i, deck in ipairs(neighborhoodDecks) do
    if deck.hasTag(returnNeighbordhoodTag(obj[3])) then
      deckPosition = deck.getPosition()
      
      encounterCard = deck.takeObject()
      encounterCard.deal(1, obj[1])

      if deck.getTags()[1] ~= 'Street Tile' and encounterCard.hasTag('Event') then
        local func = function(player_color) eventSuccess(player_color, i, encounterCard, deck) end
        encounterCard.addContextMenuItem('Event success', func)

        local func = function(player_color) eventFailed(player_color, i, encounterCard, deck) end
        encounterCard.addContextMenuItem('Event failed', func)
        else
          local func = function(player_color) encounter(player_color, i, encounterCard, deck) end
          encounterCard.addContextMenuItem('Encounter', func)
      end

      broadcastToAll('Dealt ' .. deck.getTags()[1] .. ' encounter card to ' .. obj[1], {0,1,0})
      break
    end
  end
end

function eventSuccess(player_color, i, encounterCard, deck)
  discardDeck = getObjectFromGUID('077454').getVar('discardDeck')

  if discardDeck == nil then
    print('Event discard deck is empty')
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

  selection[2].setPositionSmooth({
    x = deckPosition.x,
    y = deckPosition.y,
    z = deckPosition.z + - 5
  })
  selection[2].setRotationSmooth(
    {180, 0, 0}
  )
  local shuffle = function() selection[2].putObject(encounterCard) Wait.frames(function() shuffleFn(selection[2]) end, 64) end
  moveWatch = function() return not selection[2].isSmoothMoving() end
  Wait.condition(shuffle, moveWatch)
  broadcastToAll('Returned encounter card to the top of the encounter deck', {1, 1, 1})
end

function encounter(player_color, i, encounterCard, deck)
  encounterCard.setPosition({
    x=deckPosition.x,
    y=deckPosition.y,
    z=deckPosition.z - 5
  })
  Wait.condition(
  function() encounterCard.flip() deck.putObject(encounterCard) end
    , || not encounterCard.isSmoothMoving() and encounterCard.resting)
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

function returnNeighbordhoodTag(encounterCard)
  for _, neighborhoodTag in ipairs(neighborhoodTags) do
    if encounterCard.hasTag(neighborhoodTag) then return neighborhoodTag end
  end
end