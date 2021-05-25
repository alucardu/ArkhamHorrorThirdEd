function onLoad() 
  setHeadlines(self.getDescription())
end

function setHeadlines(amount)
  headlinesDeck = getObjectFromGUID('f9b203')
  
  headlinesDeckPos = headlinesDeck.getPosition()
  headlinesDeckPos = {
    x=headlinesDeckPos.x - 0.2,
    y=headlinesDeckPos.y,
    z=headlinesDeckPos.z - 15
  }

  headlinesDeck.shuffle()
  headlinesDeck = headlinesDeck.cut(tonumber(amount))
  
  Wait.frames(
    function()
      headlinesDeck = headlinesDeck[2]
      headlinesDeck.setPositionSmooth(
        headlinesDeckPos
      )
      headlinesDeck.setRotationSmooth(
        {180, 0, 0}
      )
      headlinesDeck.shuffle()
    end,
    64
  )
end 

function readHeadline()
  if headlinesDeck == null then
    if lastCard == nill then
      broadcastToAll("Add Doom", {1,0,0})
      getObjectFromGUID('f807c7').takeObject({
        position={
          x=headlinesDeckPos.x + 3,
          y=headlinesDeckPos.y + 5,
          z = headlinesDeckPos.z 
        }
      })
      return
    end
    lastCard.setPositionSmooth(
      {
        x=headlinesDeckPos.x + 3,
        y=headlinesDeckPos.y + 5,
        z=headlinesDeckPos.z }
    )
    Wait.condition(
      function() lastCard.setRotationSmooth({0, 180, 0}) end,
      || not lastCard.isSmoothMoving()
    )
    return
  end

  if headlinesDeck.remainder == nill then
    headlineCard = headlinesDeck.takeObject({
      position={
        x=headlinesDeckPos.x + 3,
        y=headlinesDeckPos.y + 5,
        z=headlinesDeckPos.z
      },
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