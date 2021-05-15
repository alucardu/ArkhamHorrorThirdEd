function drawNeighborhoodEncounter(obj)
  neighborhoodDecks = getObjectFromGUID('3e1179').getTable('neighborhoodDecks')

  for i, deck in ipairs(neighborhoodDecks) do
    if obj[3].getTags()[1] == deck.getTags()[1] then
      deck.takeObject().deal(1, obj[1])
      broadcastToAll('Dealt ' .. deck.getTags()[1] .. ' encounter card to ' .. obj[1], {0,1,0})
    end
  end
end