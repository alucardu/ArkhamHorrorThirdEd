function selectDifficulty()
  mythosCup = getObjectFromGUID('3e1179').getVar('mythosCup')
  initiateDifficultySelectionUI()
end

function initiateDifficultySelectionUI()
  local difficultyUI = {
    {
      tag='VerticalLayout',
      attributes={
        id='difficultyContainer',
        height=400,
        width=400
      },
      children={
        {
          tag='Button',
          value='Story mode',
          attributes={
            id='story_mode',
            onClick='496863/setGameUI',
          }
        },
        {
          tag='Button',
          value='Normal mode',
          attributes={
            id='normal_mode',
            onClick='496863/setGameUI',
          }
        },
        {
          tag='Button',
          value='Challenge mode',
          attributes={
            id='challenge_mode',
            onClick='496863/setGameUI',
          }
        }
      }
    }
  }
  phaseTracker = UI.getXmlTable()
  UI.setXmlTable(difficultyUI)
end

function setGameUI(player, value, difficuly)
  setDifficulty(difficuly)
  getObjectFromGUID('69581b').call('setGameUI', phaseTracker)
end

function setDifficulty(difficuly)
  broadcastToAll('Good luck!', {0, 1, 0})
  if difficuly == 'story_mode' then 
    for _, mythosToken in ipairs(mythosCup.getObjects()) do
      if mythosToken.name == 'Spread Doom' then local mythosToken = mythosCup.takeObject(mythosToken) destroyObject(mythosToken) break end
    end
    blankToken = getObjectFromGUID('6784ab').takeObject()
    mythosCup.putObject(blankToken)
    broadcastToAll('Replaced a Doom mythos token with a Blank mythos token  in the mythos cup.', {0, 1, 0})
  end

  if difficuly == 'normal_mode' then broadcastToAll('No changes have been made to the mythos cup.', {0, 1, 0}) end

  if difficuly == 'challenge_mode' then 
    for _, mythosToken in ipairs(mythosCup.getObjects()) do
      if mythosToken.name == 'Blank' then local mythosToken = mythosCup.takeObject(mythosToken) destroyObject(mythosToken) break end
    end
    doomToken = getObjectFromGUID('3fd0e5').takeObject()
    mythosCup.putObject(doomToken)
    broadcastToAll('Replaced a Blank mythos token with a Doom mythos token in the mythos cup.', {0, 1, 0})
  end
end