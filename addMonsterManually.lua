function onObjectLeaveContainer(container, object)
  if container == self then
    addMonsterToUI(object)
    setContextToMonster(object)
  end
end

function addMonsterToUI(object)
  investigatorsObj = getObjectFromGUID('69581b')
  investigatorsObj.setVar('monsters', object)
  investigatorsObj.call('updateMonsters', {'spawned', object})
end

function defeatMonster(player_color, i, object)
  investigatorsObj = getObjectFromGUID('69581b')
  monsterDeck = getObjectFromGUID('3e1179').getVar('monsterDeck')
  monsterDeckPos = monsterDeck.getPosition()

  investigatorsObj.setVar('monsters', object)
  investigatorsObj.call('updateMonsters', {'defeated', object})
  object.setRotationSmooth({x=180, y=0, z=0})
  object.setPositionSmooth({x=monsterDeckPos.x, y=monsterDeckPos.y + 5, z=monsterDeckPos.z})
  broadcastToAll(player_color .. ' has defeated ' .. object.getName(), {0, 1, 0})
end

function setContextToMonster(object)
  local func = function(player_color) defeatMonster(player_color, i, object) end
  object.addContextMenuItem('Defeat Monster', func)
end