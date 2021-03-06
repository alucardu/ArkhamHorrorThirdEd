function onLoad()
  local params = {
    click_function='spawnMonster',
    tooltip="Spawn a monster",
    function_owner = self,
    height=1250,
    width=1250,
    color={0, 0, 0, 0},
    position={0, 0.1, 0}
  }
  self.createButton(params)
end

function spawnMonster()
  monsterDeck = getObjectFromGUID('3e1179').getVar('monsterDeck')
  monsterDeckPos = monsterDeck.getPosition()
  
  spawnedMonster = monsterDeck.takeObject({
    position = {x = monsterDeckPos.x + 2.5, y = monsterDeckPos.y, z = monsterDeckPos.z},
    index=monsterDeck.getQuantity() - 1
  })

  spawnedMonster.addTag('Monsters')
  addMonster(spawnedMonster)
end

function addMonster(spawnedMonster)
  investigatorsObj = getObjectFromGUID('69581b')
  investigatorsObj.setVar('monsters', spawnedMonster)
  investigatorsObj.call('updateMonsters', {'spawned', spawnedMonster})

  setContextToMonster(spawnedMonster)
end

function defeatMonster(player_color, i, spawnedMonster)
  investigatorsObj = getObjectFromGUID('69581b')
  monsterDeck = getObjectFromGUID('3e1179').getVar('monsterDeck')
  monsterDeckPos = monsterDeck.getPosition()

  investigatorsObj.setVar('monsters', spawnedMonster)
  investigatorsObj.call('updateMonsters', {'defeated', spawnedMonster})
  spawnedMonster.setRotationSmooth({x=180, y=0, z=0})
  spawnedMonster.setPositionSmooth({x=monsterDeckPos.x, y=monsterDeckPos.y + 5, z=monsterDeckPos.z})
  broadcastToAll(player_color .. ' has defeated ' .. spawnedMonster.getName(), {0, 1, 0})
end

function addRemnant(player_color, i, spawnedMonster)
  getObjectFromGUID('752ff0').takeObject({position = spawnedMonster.getPosition() })
end

function setContextToMonster(spawnedMonster)
  local func = function(player_color) defeatMonster(player_color, i, spawnedMonster) end
  spawnedMonster.addContextMenuItem('Defeat Monster', func)

  local func = function(player_color) addRemnant(player_color, i, spawnedMonster) end
  spawnedMonster.addContextMenuItem('Add remnant', func)
end