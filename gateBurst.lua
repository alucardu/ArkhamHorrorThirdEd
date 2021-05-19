gateBurstBtn = getObjectFromGUID('151eec')

function onLoad()
  params = {
    click_function="gateBurst",
    tooltip="Resolve a Gate burst",
    function_owner = self,
    height=1250,
    width=1250,
    color={0, 0, 0, 0},
    position={0, 0.1, 0}
  }
  gateBurstBtn.createButton(params)
end

function gateBurst()
  eventDeck = getObjectFromGUID('3e1179').getVar('eventDeck')
  neighborhoodTiles = getObjectFromGUID('3e1179').getTable('neighborhoodTiles')

  eventDeckPos = eventDeck.getPosition()
  doomPos = {x = eventDeckPos.x + 4, y = eventDeckPos.y, z = eventDeckPos.z}

  discardDeck = getObjectFromGUID('077454').getVar('discardDeck')
  
  if discardDeck == nil then
    local takenObject = eventDeck.takeObject({
      position = doomPos
    })
    broadcastToAll('Add doom to ' .. takenObject.getTags()[1], {1,0,0})
    placeDoomTokens(takenObject)
    Wait.frames(
      function()
        eventDeck.putObject(takenObject)
      end, 64
    )
    return
  end
  
  local takenObject = eventDeck.takeObject({
    position = doomPos
  })

  takenObject.flip()
  takenObject.setPositionSmooth({x=doomPos.x, y=doomPos.y + 5, z=doomPos.z})

  local flipCard = function() discardDeck = discardDeck.putObject(takenObject) someFn(discardDeck, 4) end
  moveWatch = function() return not takenObject.isSmoothMoving() end
  Wait.condition(flipCard, moveWatch)

  placeDoomTokens(takenObject)
end

function someFn(discardDeck, shuffleIterations)
  local frames = 32

  -- Wait for decks to be merged then flip the deck
  Wait.frames(
    function()
      discardDeck.flip()

      -- Wait for deck to flip
      Wait.frames(
        function()
          shuffleDeck(discardDeck, shuffleIterations)

          -- Wait for deck to be shuffled
          Wait.frames(
            function()
              eventDeck.putObject(discardDeck)
            end, frames * shuffleIterations
          )
        end, 32
      )
    end, 32
  )
end

function shuffleDeck(deck, iteration)
  local frames = 0
  for i = iteration , 1 ,-1 do
    frames = frames + 32
    Wait.frames(
    function()
      deck.shuffle()
    end,
    frames
  )
  end
end

function placeDoomTokens(takenObject)
  broadcastToAll('Gate burst!', {1,0,0})
  broadcastToAll('Add doom to each part of ' .. takenObject.getTags()[1], {1,0,0})

  for i, deck in ipairs(neighborhoodTiles) do
    if takenObject.getTags()[1] == deck.getTags()[1] then
      neighborhoodPosition = deck.getPosition()
    end
  end

  -- doom token
  for i = 3 , 1, -1 do
    getObjectFromGUID('f807c7').takeObject({
      position={x=neighborhoodPosition.x, y=neighborhoodPosition.y + 5, z=neighborhoodPosition.z}
    })
  end
end