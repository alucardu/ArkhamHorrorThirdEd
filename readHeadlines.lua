function readHeadline()
  headlinesDeck = getObjectFromGUID('3e1179').getVar('headlinesDeck')
  headlinesDeckPos = headlinesDeck.getPosition()

  if getObjectFromGUID('3e1179').getVar('headlinesDeck') == null then
    if lastCard == nill then
      broadcastToAll("Add Doom", {1,0,0})
      getObjectFromGUID('f807c7').takeObject({
        position={x = headlinesDeckPos.x + 3, y = headlinesDeckPos.y, z = headlinesDeckPos.z }
      })
      return
    end
    lastCard.setPositionSmooth(
      {x = headlinesDeckPos.x + 3, y = headlinesDeckPos.y, z = headlinesDeckPos.z }
    )

    local flipCard = function() lastCard.flip() lastCard = nill end
    moveWatch = function() return not lastCard.isSmoothMoving() end
    Wait.condition(flipCard, moveWatch)
    return
  end

  if headlinesDeck.remainder == nill then
    headlineCard = headlinesDeck.takeObject({
      position={x = headlinesDeckPos.x + 3, y = headlinesDeckPos.y, z = headlinesDeckPos.z},
      callback_function = function()
        headlineCard.flip()
      end
    })
  end

  if headlinesDeck.remainder ~= nill then
    lastCard = headlinesDeck.remainder
  end
  
end