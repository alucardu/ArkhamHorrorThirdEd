itemsInDisplay = {}

function onSave()
  local state = {
    itemsInDisplay = returnItemsInDisplayGuid()
  }
  return JSON.encode(state)
end

function onLoad(script_state)
  setupDone = getObjectFromGUID('3e1179').getVar('setupDone')
  itemDeck = getObjectFromGUID('b69657')
  itemDeck.shuffle()

  spellDeck = getObjectFromGUID('c782d3')
  spellDeck.shuffle()

  allyDeck = getObjectFromGUID('8050a5')
  allyDeck.shuffle()

  itemDeckPos = itemDeck.getPosition()
  if setupDone ~= true then
    placeItems(5)
  end

  state = JSON.decode(script_state)

  if state ~= nil then
    for _, item in ipairs(state.itemsInDisplay) do
      addButtonToItemCard(getObjectFromGUID(item))
      table.insert(itemsInDisplay, getObjectFromGUID(item))
    end
  end

end

function placeItems(iterations)
  for i = iterations, 1, -1 do
    frames = i*32
    posX = 3
    Wait.frames(
      function()
        local itemCard = itemDeck.takeObject({
          position={
            x=itemDeckPos.x + posX,
            y=itemDeckPos.y + 5,
            z=itemDeckPos.z
          }
        })

        table.insert(itemsInDisplay, itemCard)

        Wait.condition(
          function()
            itemCard.flip()
            addButtonToItemCard(itemCard)
          end
        , || not itemCard.isSmoothMoving() and itemCard.resting)
        posX = posX + 3

      end, frames
    )
  end
end

function addButtonToItemCard(itemCard)
  if itemCard ~= nil then
    local params = {
      label="Take item",
      click_function="takeItemCard",
      function_owner=self,
      position={0,1,2},
      font_size=250,
      height=300,
      width=1200,
      color={0,0,0},
      font_color={1,1,1}
    }

    itemCard.createButton(params)
  end
end

function takeItemCard(itemCard, player_color, c)
  replaceItemCard(itemCard.getPosition())
  removeItemCardFromDisplay(itemCard)
  itemCard.clearButtons()
  itemCard.deal(1, player_color)
  broadcastToAll('Dealt ' .. itemCard.getName() .. ' to ' .. player_color, {1,0,0})
end

function replaceItemCard(itemCardPos)
  itemCard = itemDeck.takeObject({
    position=itemCardPos
  })

  table.insert(itemsInDisplay, itemCard)

  Wait.condition(
    function()
      itemCard.flip()
      addButtonToItemCard(itemCard)
    end
  , || not itemCard.isSmoothMoving() and itemCard.resting)
end

function removeItemCardFromDisplay(itemCard)
  for i, item in ipairs(itemsInDisplay) do
    if item == itemCard then
      table.remove(itemsInDisplay, i)
    end
  end
end

function returnItemsInDisplayGuid()
  local t = {}
  for i, item in ipairs(itemsInDisplay) do
    t[i] = item.guid
  end
  return t
end