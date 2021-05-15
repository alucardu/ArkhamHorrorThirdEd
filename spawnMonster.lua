function spawnMonster()
  monsterDeck = getObjectFromGUID('3e1179').getVar('monsterDeck')

  monsterDeckPos = monsterDeck.getPosition()

  spawnedMonster = monsterDeck.takeObject({
    position = {x = monsterDeckPos.x + 2.5, y = monsterDeckPos.y, z = monsterDeckPos.z},
    index=monsterDeck.getQuantity() - 1
  })
  
  investigatorsObj = getObjectFromGUID('69581b')
  investigatorsObj.setTable('monsters', { spawnedMonster })
  investigatorsObj.call('updateMonsters')
  investigatorsObj.call('updateInvestigators')

  for i,o in ipairs(investigatorsObj.getTable('monsters')) do
    local func = function(player_color) defeatMonster(player_color, i, o) end
    o.addContextMenuItem('Defeat Monstes', func)
  end
end

function defeatMonster(player_color, i, o)
  investigatorsObj.call('updateMonsters')
  investigatorsObj.call('updateInvestigators')
  spawnedMonster.setPositionSmooth({x=monsterDeckPos.x, y=monsterDeckPos.y + 5, z=monsterDeckPos.z})
  broadcastToAll(player_color .. ' has defeated ' .. o.getName(), {0, 1, 0})
end