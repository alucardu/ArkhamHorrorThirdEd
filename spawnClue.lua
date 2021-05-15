function spawnClue()
  eventDeck = getObjectFromGUID('3e1179').getVar('eventDeck')
  neighborhoodTiles = getObjectFromGUID('3e1179').getTable('neighborhoodTiles')
  neighborhoodDecks = getObjectFromGUID('3e1179').getTable('neighborhoodDecks')
  
  deckPos = eventDeck.getPosition()
  pos = {x = deckPos.x, y = deckPos.y, z = deckPos.z + - 5}
  
  local takenObject = eventDeck.takeObject({
    position = pos
  })

  for i, deck in ipairs(neighborhoodDecks) do
    if takenObject.getTags()[1] == deck.getTags()[1] then
      neighborhoodDeck = deck
    end
  end

  neighborhoodDeckPos = neighborhoodDeck.getPosition()

  selection = neighborhoodDeck.cut(2)
  Wait.frames(
    function()
      selection[2].setPositionSmooth(
        pos
      )
      selection[2].setRotationSmooth(
        {180, 0, 0}
      )
      local shuffle = function() Wait.frames(function() shuffleFn(selection[2]) end, 64) end
      moveWatch = function() return not selection[2].isSmoothMoving() end
      Wait.condition(shuffle, moveWatch)
    end,
    64
  )

  for i, tile in ipairs(neighborhoodTiles) do
    if takenObject.getTags()[1] == tile.getTags()[1] then
      neighborhoodPosition = tile.getPosition()
    end
  end

   -- cluetoken
   getObjectFromGUID('c896e0').takeObject({
    position={x=neighborhoodPosition.x, y=neighborhoodPosition.y + 5, z=neighborhoodPosition.z}
  })
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
      selection[2].setPositionSmooth({x = neighborhoodDeckPos.x, y=neighborhoodDeckPos.y + 5, z=neighborhoodDeckPos.z}) 
    end,
    96
  )
end