spawnClueBtn = getObjectFromGUID('98bc78')

function onLoad()
  spawnClueOnClick = function() spawnClue(1) end
  local params = {
    click_function="spawnClueOnClick",
    function_owner = self,
    height=1250,
    width=1250,
    color={0, 0, 0, 0},
    position={0, 0.1, 0}
  }
  spawnClueBtn.createButton(params)
end

function spawnClue(amount)
  setData()
  if self.getVar('deck_is_moving') == true then
    broadcastToAll('Clue spawn is queued', {0, 1, 1})
    Wait.condition(
    function() spawnClue(1) end,
      || not neighborhoodCards[2].isSmoothMoving() and neighborhoodCards[2] == nil
    )
    return
  end
  self.setVar('deck_is_moving', true)

  local amount = amount -1

  eventCard = eventDeck.takeObject({position = pos})

  for i, deck in ipairs(neighborhoodDecks) do
    if eventCard.getTags()[1] == deck.getTags()[1] then
      neighborhoodDeck = deck
      neighborhoodDeckPos = neighborhoodDeck.getPosition()
    end
  end

  spawnToken(eventCard)

  neighborhoodCards = neighborhoodDeck.cut(2)
  neighborhoodCards[2].setRotationSmooth({180, 0, 0})
  neighborhoodCards[2].setPositionSmooth(pos)


  Wait.condition(
    function() toDeck(neighborhoodCards[2], amount) end, 
    || not neighborhoodCards[2].isSmoothMoving() and neighborhoodCards[2].getQuantity() == 3
  )
end

function toDeck(neighborhoodCards, amount)
  neighborhoodCards.shuffle()
  neighborhoodCards.setPositionSmooth({x=neighborhoodDeckPos.x, y=neighborhoodDeckPos.y + 5, z=neighborhoodDeckPos.z})
  Wait.condition(
    function() self.setVar('deck_is_moving', false) if amount ~= 0 then spawnClue(amount) end end,
      || not neighborhoodCards.isSmoothMoving() and deck == nil
  )
end
function spawnToken(eventCard)
  for i, neighborhoodTile in ipairs(neighborhoodTiles) do
    if eventCard.getTags()[1] == neighborhoodTile.getTags()[1] then
      neighborhoodPosition = neighborhoodTile.getPosition()
    end
  end
  clueTokenBag.takeObject({
    position={x=neighborhoodPosition.x, y=neighborhoodPosition.y + 5, z=neighborhoodPosition.z}
  })

  broadcastToAll('Clue spawned on ' .. neighborhoodDeck.getTags()[1] , {0, 1, 0})
end

function setData()
  eventDeck = getObjectFromGUID('3e1179').getVar('eventDeck')
  neighborhoodTiles = getObjectFromGUID('3e1179').getTable('neighborhoodTiles')
  neighborhoodDecks = getObjectFromGUID('3e1179').getTable('neighborhoodDecks')
  deckPos = eventDeck.getPosition()
  pos = {x = deckPos.x, y = deckPos.y, z = deckPos.z + - 5}
  clueTokenBag = getObjectFromGUID('c896e0')
end
