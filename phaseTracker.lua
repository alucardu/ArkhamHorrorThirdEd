investigator = {}
children = {}
monstersTable = {}
monsters = {}
childrenTableID = ''

function onLoad()
  local container = {
    {
      tag="TableLayout",
      attributes={
        autoCalculateHeight=true,
        width=200,
        color="rgba(0,0,0,0.7)",
        rectAlignment="UpperRight",
        offsetXY="-200, 0"
      },
      children={
        {
          tag="Row",
          attributes={
            preferredHeight=50
          },
          children = {
            {
              tag="Cell",
              children={
                tag="Button",
                attributes={
                  id="ActionPhaseBtn",
                  fontSize=20,
                  color="white",
                },
                value="Action phase",
              }
            }
          }
        },
        {
          tag="Row",
          attributes={
            id="investigators",
            active=#children > 0,
            preferredHeight=#children*35
          },
          children = {
            {
              tag="VerticalLayout",
              children=children
            }
          }
        },
        {
          tag="Row",
          attributes={
            preferredHeight=50
          },
          children = {
            {
              tag="Cell",
              children={
                tag="Button",
                attributes={
                  id="MonsterPhaseBtn",
                  fontSize=20,
                  color="white",
                  interactable=false
                },
                value="Monster phase",
              }
            },
          }
        },
        {
          tag="Row",
          attributes={
            id="monsters",
            active=#monstersTable > 0,
            preferredHeight=#monstersTable * 35
          },
          children = {
            {
              tag="VerticalLayout",
              children=monstersTable
            }
          }
        },
        {
          tag="Row",
          attributes={
            preferredHeight=50
          },
          children = {
            {
              tag="Cell",
              children={
                tag="Button",
                attributes={
                  id="EncounterPhaseBtn",
                  onClick = "69581b/finishEncounterPhase",
                  fontSize=20,
                  color="white",
                  interactable=false
                },
                value="Encounter phase",
              }
            },
          }
        },
        {
          tag="Row",
          attributes={
            preferredHeight=50
          },
          children = {
            {
              tag="Cell",
              children={
                tag="Button",
                attributes={
                  id="MythosPhaseBtn",
                  onClick = "69581b/finishMythosPhase",
                  fontSize=20,
                  color="white",
                  interactable=false
                },
                value="Mythos phase",
              }
            },
          }
        }
      }
    }
  }
  UI.setXmlTable(container)
end

function updateChildren()
  if has_value(children, investigator[1]) then
    table.remove(children, childrenTableID)
  else
    table.insert(children, 
      {
        tag = "Button",
        attributes = {
          id=investigator[1].getName(),
          onClick = "69581b/toggleTurn",
          fontSize = 20,
          color = investigator[2],
          interactable=true
        },
        value = investigator[1].getName(),
      }
    )
  end
end

function updateMonsters(state)
  -- make copy of current monster table
  phaseTracker = UI.getXmlTable()
  monsterContainer = phaseTracker[1].children[4].children[1].children

  -- add monster if spawned
  if state[1] == 'spawned' then
    table.insert(monsterContainer,
    {
      tag = "Button",
      attributes = {
        id=state[2].getGUID(),
        onClick = "69581b/toggleMonsterTurn",
        fontSize = 20,
        interactable=false
      },
      value = state[2].getName(),
    })
  end

  -- remove monster if defeated
  if state[1] == 'defeated' then
    for i, monster in ipairs(monsterContainer) do
      if monster.attributes.id == state[2].getGUID() then
        table.remove(monsterContainer, i)
      end
    end

    -- advance to encounter phase if all monsters are defeated or exausted
    if finished(monsterContainer, 'true') == true and UI.getAttribute('MonsterPhaseBtn', 'interactable') == 'true' then
      broadcastToAll('All monsters defeated or exausted', {0, 1, 0})
      UI.setAttribute('MonsterPhaseBtn', 'interactable', 'false')
      UI.setAttribute('EncounterPhaseBtn', 'interactable', 'true')
    end
  end  

  -- update monster attributes
  if #monsterContainer > 0 then
    UI.setAttribute('monsters', 'active', 'true')  
    UI.setAttribute('monsters', 'preferredHeight', #phaseTracker[1].children[4].children[1].children*35)
    else
      UI.setAttribute('monsters', 'active', 'false')
  end

  -- update ui table
  UI.setXmlTable(phaseTracker)
end

function updateInvestigators()
  if (#children > 0) then
    UI.setAttribute('investigators', 'active', 'true')
  end
  UI.setAttribute('investigators', 'preferredHeight', #children*35)
  phaseTracker = UI.getXmlTable()
  phaseTracker[1].children[2].children[1].children = children
  UI.setXmlTable(phaseTracker)
end

function toggleMonsterTurn(player, value, id)
  for i, monster in ipairs(monsterContainer) do
    if monster.attributes.id == id then
      UI.setAttribute(monster.attributes.id, "interactable", 'false')
    end
  end

  Wait.frames(
    function()
      if finished(monsterContainer, 'true') == true then
        UI.setAttribute('MonsterPhaseBtn', 'interactable', 'false')
        UI.setAttribute('EncounterPhaseBtn', 'interactable', 'true')
      end
    end,
    1
  )
end

function toggleTurn(player, value, id)
  if has_value(children, id) then
    UI.setAttribute(children[tonumber(childrenTableID)].attributes.id, 'interactable', 'false')
  end

  Wait.frames(
    function()
      if finished(children, 'true') == true then

        if monsterContainer ~= nil then
          for i, monster in ipairs(monsterContainer) do
            UI.setAttribute(monster.attributes.id, "interactable", 'true')
          end          
        end

        UI.setAttribute('ActionPhaseBtn', 'interactable', 'false')

        if monsterContainer ~= nil and #monsterContainer > 0 then
          UI.setAttribute('MonsterPhaseBtn', 'interactable', 'true')
          for i, monster in ipairs(monstersTable) do
            UI.setAttribute(monster.attributes.id, 'interactable', 'true')
          end
          else
            broadcastToAll('No monsters in play. Going to the encounter phase!', {0, 1, 0})
            finishMonsterPhase()
        end
      end
    end,
    1
  )
end

function has_value (tab, val)
  for index, value in ipairs(tab) do
    if value.value == val then
      childrenTableID = index
      return true
    end
  end

  return false
end

function finishMonsterPhase()
  UI.setAttribute('MonsterPhaseBtn', 'interactable', 'false')
  UI.setAttribute('EncounterPhaseBtn', 'interactable', 'true')
end

function finishEncounterPhase()
  UI.setAttribute('EncounterPhaseBtn', 'interactable', 'false')
  UI.setAttribute('MythosPhaseBtn', 'interactable', 'true')
end

function finishMythosPhase()
  UI.setAttribute('MythosPhaseBtn', 'interactable', 'false')
  UI.setAttribute('ActionPhaseBtn', 'interactable', 'true')

  for index, value in ipairs(children) do
    UI.setAttribute(value.attributes.id, 'interactable', 'true')
  end
end

function finished(tab, val)
  if #tab == 0 then
    return true
  end

  for index, v in ipairs(tab) do
    if UI.getAttribute(v.attributes.id, "interactable") == val then
      return false
    end
  end

  return true
end