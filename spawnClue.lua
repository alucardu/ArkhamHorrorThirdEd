function onLoad()
  spawnClueBtn = getObjectFromGUID('98bc78')

  local params = {
    click_function="spawnClue",
    function_owner = self,
    height=1250,
    width=1250,
    color={0, 0, 0, 0},
    position={0, 0.1, 0}
  }
  spawnClueBtn.createButton(params)
  
  neighborhoodTags = {
    'Rivertown',
    'Downtown',
    'Northside',
    'Easttown',
    'Merchant District',
    'Miskatonic University'
  }

  iterations = 0

end

function spawnClue()
  iterations = iterations + 1
  setData()

  if self.getVar('deck_is_moving') == true then
    broadcastToAll('Clue spawn is queued', {0, 1, 1})
    Wait.condition(
      function() spawnClue()
      end, || not neighborhoodCards[2].isSmoothMoving() and neighborhoodCards[2] == nil
    )
    return
  end
  self.setVar('deck_is_moving', true)

  eventCard = eventDeck.takeObject({position = eventDeckPos})

  for i, deck in ipairs(neighborhoodDecks) do
    if deck.hasTag(returnNeighbordhoodTag(eventCard)) then
      neighborhoodDeck = deck
      neighborhoodDeckPos = neighborhoodDeck.getPosition()
    end
  end

  spawnToken(eventCard)

  neighborhoodCards = neighborhoodDeck.cut(2)
  neighborhoodCards[2].setRotationSmooth({180, 0, 0})
  neighborhoodCards[2].setPositionSmooth(eventDeckPos)

  Wait.condition(
    function() toDeck(neighborhoodCards[2]) end, 
    || not neighborhoodCards[2].isSmoothMoving() and neighborhoodCards[2].getQuantity() == 3
  )
end

function toDeck(neighborhoodCards)
  neighborhoodCards.shuffle()
  neighborhoodCards.setPositionSmooth({
    x=neighborhoodDeckPos.x,
    y=neighborhoodDeckPos.y + 5,
    z=neighborhoodDeckPos.z
  })

  Wait.condition(
    function() self.setVar('deck_is_moving', false) iterations = iterations - 1
    end, || not neighborhoodCards.isSmoothMoving() and deck == nil
  )
end
function spawnToken(eventCard)
  for i, neighborhoodTile in ipairs(neighborhoodTiles) do
    if neighborhoodTile.hasTag(returnNeighbordhoodTag(eventCard)) then
      neighborhoodPosition = neighborhoodTile.getPosition()
    end
  end
  clueTokenBag.takeObject({
    position={
      x=neighborhoodPosition.x,
      y=neighborhoodPosition.y + 5,
      z=neighborhoodPosition.z}
  })

  broadcastToAll('Clue spawned on ' .. returnNeighbordhoodTag(eventCard) , {0, 1, 0})
end

function setData()
  eventDeck = getObjectFromGUID('3e1179').getVar('eventDeck')
  neighborhoodTiles = getObjectFromGUID('3e1179').getTable('neighborhoodTiles')
  neighborhoodDecks = getObjectFromGUID('3e1179').getTable('neighborhoodDecks')
  eventDeckPos = {
    x=eventDeck.getPosition().x,
    y=eventDeck.getPosition().y,
    z=eventDeck.getPosition().z - 5}
  clueTokenBag = getObjectFromGUID('c896e0')
end

function returnNeighbordhoodTag(encounterCard)
  for _, neighborhoodTag in ipairs(neighborhoodTags) do
    if encounterCard.hasTag(neighborhoodTag) then return neighborhoodTag end
  end
end