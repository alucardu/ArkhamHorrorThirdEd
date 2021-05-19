spawnMonsterBtn = getObjectFromGUID('0d44f6')

function onLoad()
  params = {
    click_function="spawnMonster",
    tooltip="Spawn a monster",
    function_owner = self,
    height=1250,
    width=1250,
    color={0, 0, 0, 0},
    position={0, 0.1, 0}
  }
  spawnMonsterBtn.createButton(params)
end

function spawnMonster(spawnedMonster)
  monsterDeck = getObjectFromGUID('3e1179').getVar('monsterDeck')
  monsterDeckPos = monsterDeck.getPosition()
  
  if spawnedMonster == nil or spawnedMonster.getTags()[1] == nil then
    spawnedMonster = monsterDeck.takeObject({
      position = {x = monsterDeckPos.x + 2.5, y = monsterDeckPos.y, z = monsterDeckPos.z},
      index=monsterDeck.getQuantity() - 1
    })
  end
  
  investigatorsObj = getObjectFromGUID('69581b')
  investigatorsObj.setVar('monsters', spawnedMonster)
  investigatorsObj.call('updateMonsters', {'spawned', spawnedMonster})

  local func = function(player_color) defeatMonster(player_color, i, spawnedMonster) end
  spawnedMonster.addContextMenuItem('Defeat Monster', func)
end

function defeatMonster(player_color, i, spawnedMonster)
  investigatorsObj.setVar('monsters', spawnedMonster)
  investigatorsObj.call('updateMonsters', {'defeated', spawnedMonster})
  spawnedMonster.setRotationSmooth({x=180, y=0, z=0})
  spawnedMonster.setPositionSmooth({x=monsterDeckPos.x, y=monsterDeckPos.y + 5, z=monsterDeckPos.z})
  broadcastToAll(player_color .. ' has defeated ' .. spawnedMonster.getName(), {0, 1, 0})
end