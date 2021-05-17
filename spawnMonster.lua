function spawnMonster()
  monsterDeck = getObjectFromGUID('3e1179').getVar('monsterDeck')

  monsterDeckPos = monsterDeck.getPosition()

  local spawnedMonster = monsterDeck.takeObject({
    position = {x = monsterDeckPos.x + 2.5, y = monsterDeckPos.y, z = monsterDeckPos.z},
    index=monsterDeck.getQuantity() - 1
  })
  
  investigatorsObj = getObjectFromGUID('69581b')
  investigatorsObj.setVar('monsters', spawnedMonster)
  investigatorsObj.call('updateMonsters', {'spawned', spawnedMonster})

  local func = function(player_color) defeatMonster(player_color, i, spawnedMonster) end
  spawnedMonster.addContextMenuItem('Defeat Monster', func)
end

function defeatMonster(player_color, i, spawnedMonster)
  investigatorsObj.setVar('monsters', spawnedMonster)
  investigatorsObj.call('updateMonsters', {'defeated', spawnedMonster})
  spawnedMonster.setPositionSmooth({x=monsterDeckPos.x, y=monsterDeckPos.y + 5, z=monsterDeckPos.z})
  broadcastToAll(player_color .. ' has defeated ' .. spawnedMonster.getName(), {0, 1, 0})
end