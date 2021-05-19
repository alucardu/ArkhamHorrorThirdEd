spawnClueBtn = getObjectFromGUID('98bc78')

function onLoad()
  params = {
    click_function="spawnClue",
    tooltip="Spawn a clue",
    function_owner = self,
    height=1250,
    width=1250,
    color={0, 0, 0, 0},
    position={0, 0.1, 0}
  }
  spawnClueBtn.createButton(params)
end

function spawnClue(amount)
  eventDeck = getObjectFromGUID('3e1179').getVar('eventDeck')
  neighborhoodTiles = getObjectFromGUID('3e1179').getTable('neighborhoodTiles')
  neighborhoodDecks = getObjectFromGUID('3e1179').getTable('neighborhoodDecks')
  deckPos = eventDeck.getPosition()
  pos = {x = deckPos.x, y = deckPos.y, z = deckPos.z + - 5}
  frames = 0

  if type(amount) == 'number' then
    for i = amount, 1, -1 do
      Wait.frames(
        function()
          someFunction()
        end, frames
      )
      frames = frames + 512
    end
    else 
      someFunction()
  end
end

function someFunction()
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

  broadcastToAll('Clue spawned on ' .. neighborhoodDeck.getTags()[1] , {0, 1, 0})
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