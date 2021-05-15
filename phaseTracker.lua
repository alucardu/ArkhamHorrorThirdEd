investigator = {}
children = {}
monstersTable = {}
monsters = {}
childrenTableID = ''

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

function updateMonsters()
  if has_value(monstersTable, monsters[1].getName()) then
    table.remove(monstersTable, childrenTableID)
  else
    table.insert(monstersTable, 
      {
        tag = "Button",
        attributes = {
            id=monsters[1].getName(),
            onClick = "69581b/toggleMonsterTurn",
            fontSize = 20,
            interactable=false
        },
        value = monsters[1].getName(),
      }
    )
  end
end

function updateInvestigators()
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
            active=#monstersTable > 0,
            preferredHeight=#monstersTable*35
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

function toggleMonsterTurn(player, value, id)
  if has_value(monstersTable, id) then
    UI.setAttribute(monstersTable[tonumber(childrenTableID)].attributes.id, 'interactable', 'false')
  end

  Wait.frames(
    function()
      if finished(monstersTable, 'true') == true then
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
        UI.setAttribute('ActionPhaseBtn', 'interactable', 'false')
        UI.setAttribute('MonsterPhaseBtn', 'interactable', 'true')

        for i, monster in ipairs(monstersTable) do
          UI.setAttribute(monster.attributes.id, 'interactable', 'true')
        end
      end
    end,
    1
  )
end

function finished(tab, val)
  for index, v in ipairs(tab) do
    if UI.getAttribute(v.attributes.id, "interactable") == val then
      return false
    end
  end

  return true
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