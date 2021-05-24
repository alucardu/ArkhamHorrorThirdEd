function spawnAnomaly(anomalyToken)
  if anomalyToken[3].hasTag('Neighborhood Tile') then
     anomalyToken = getObjectFromGUID('b27518').takeObject({
       position={x=anomalyToken[3].getPosition().x,y=anomalyToken[3].getPosition().y + 2,z=anomalyToken[3].getPosition().z}
     })
  end

  local func = function(player_color) drawAnomalyEncounterCard(player_color, i, anomalyToken) end
  anomalyToken.addContextMenuItem('Anomaly encounter', func)

  local func = function(player_color) removeAnomalyToken(player_color, i, anomalyToken) end
  anomalyToken.addContextMenuItem('Remove anomaly!', func)  
end

function drawAnomalyEncounterCard(player_color, i, anomalyToken)
  anomaliesDeck = getObjectFromGUID('3e1179').getVar('anomaliesDeck')
  anomalyCard = anomaliesDeck.takeObject()
  anomalyCard.deal(1, player_color)

  local func = function(player_color) discardAnomalyEncounterCard(player_color, i, anomalyCard) end
  anomalyCard.addContextMenuItem('Encounter', func)
  
  broadcastToAll('Dealt anomaly encounter card to ' .. player_color, {0,1,0})
end

function removeAnomalyToken(player_color, i, anomalyToken)
  anomaliesDeck = getObjectFromGUID('3e1179').getVar('anomaliesDeck')
  anomalyStackPos = getObjectFromGUID('b27518').getPosition()

  anomalyToken.setPositionSmooth({x=anomalyStackPos.x, y=anomalyStackPos.y+2, z=anomalyStackPos.z})
  broadcastToAll('Anomaly has been removed!', {0, 1, 0})
end

function discardAnomalyEncounterCard(player_color, i, anomalyCard)
  anomaliesDeckPos = anomaliesDeck.getPosition()
  anomalyCard.flip()
  anomalyCard.setPosition({x=anomaliesDeckPos.x, y=anomaliesDeckPos.y, z=anomaliesDeckPos.z - 5})
  anomalyCard.setPositionSmooth({x=anomaliesDeckPos.x, y=anomaliesDeckPos.y - 0.1, z=anomaliesDeckPos.z})
  broadcastToAll('Returned anomaly card to the bottom of the anomaly deck', {1, 1, 1})
end