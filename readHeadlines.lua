function readHeadline()
  headlinesDeck = getObjectFromGUID('3e1179').getVar('headlinesDeck')
  if headlinesDeck ~= null then headlinesDeckPos = headlinesDeck.getPosition() end

  if headlinesDeck == null then
    if lastCard == nill then
      broadcastToAll("Add Doom", {1,0,0})
      getObjectFromGUID('f807c7').takeObject({
        position={x = headlinesDeckPos.x + 3, y = headlinesDeckPos.y + 5, z = headlinesDeckPos.z }
      })
      return
    end
    lastCard.setPositionSmooth(
      {x = headlinesDeckPos.x + 3, y = headlinesDeckPos.y + 5, z = headlinesDeckPos.z }
    )
    Wait.condition(
      function() lastCard.setRotationSmooth({0, 180, 0}) end,
      || not lastCard.isSmoothMoving()
    )
    return
  end

  if headlinesDeck.remainder == nill then
    headlineCard = headlinesDeck.takeObject({
      position={x = headlinesDeckPos.x + 3, y = headlinesDeckPos.y + 5, z = headlinesDeckPos.z},
    })
    Wait.condition(
      function() headlineCard.setRotationSmooth({0, 180, 0}) end,
      || not headlineCard.isSmoothMoving()
    )
  end

  if headlinesDeck.remainder ~= nill then
    lastCard = headlinesDeck.remainder
  end
  
end