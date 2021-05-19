investigator = {}
children = {}
monstersTable = {}
monsters = {}
childrenTableID = ''
frames = 0

function onObjectSearchStart()
  UI.setAttribute('top', 'active', 'false')
end

function onObjectSearchEnd()
  UI.setAttribute('top', 'active', 'true')
end

function onLoad()
  local container = {
    {
      tag="VerticalLayout",
      attributes={
        id="top",
        width=200,
        height=200,
        color="rgba(0,0,0,0.7)",
        rectAlignment="UpperRight",
        offsetXY="-200, 0"
      },
      children={
        {
          tag="Button",
          value="Action phase",
          attributes={
            interactable=false,
            id="ActionPhaseBtn",
            fontSize=20,
            color="white",
            preferredHeight=50
          },
        },
        {
          tag="VerticalLayout",
          attributes={
            id="investigators",
            active=false
          },
          children = children
        },
        {
          tag="Button",
          attributes={
            id="MonsterPhaseBtn",
            fontSize=20,
            color="white",
            interactable=false,
            preferredHeight=50
          },
          value="Monster phase",
        },
        {
          tag="VerticalLayout",
          attributes={
            id="monsterTable",
            active=false
          },
          children = monsterContainer
        },
        {
          tag="Button",
          attributes={
            id="EncounterPhaseBtn",
            onClick = "69581b/finishEncounterPhase",
            fontSize=20,
            color="white",
            interactable=false,
            preferredHeight=50
          },
          value="Encounter phase",
        },
        {
          tag="Button",
          attributes={
            id="MythosPhaseBtn",
            onClick = "69581b/finishMythosPhase",
            fontSize=20,
            color="white",
            interactable=false,
            preferredHeight=50
          },
          value="Mythos phase",
        }
      }
    }
  }
  UI.setXmlTable(container)
end


function updateMonsters(state)
  -- create copy of UI
  phaseTracker = UI.getXmlTable()

  -- add monster if spawned
  if state[1] == 'spawned' then
    table.insert(monstersTable,
      {
        tag="HorizontalLayout",
        attributes={
          childForceExpandWidth=false,
        },
        children={
          {
            tag = "Button",
            value = state[2].getName(),
            attributes = {
              flexibleWidth='0.8',
              id=state[2].getGUID(),
              onClick = "69581b/toggleMonsterTurn",
              fontSize = 20,
              color = 'White',
              interactable=false,
              preferredHeight=50
            },
          },
          {
            tag="Button",
            value="X",
            attributes={
              flexibleWidth='0.2',
              id='remove' .. state[2].getGUID(),
              onClick = "69581b/toggleRemoveButton",
              interactable=true,
            }
          },
          {
            tag="Button",
            value="Y",
            attributes={
              tooltip="Retire " .. state[2].getGUID(),
              active=false,
              flexibleWidth='0.2',
              id='asdasd' .. state[2].getGUID(),
              onClick = "69581b/removeMonster",
              color="Red"
            }
          }
        }
      }
    )
  end

  -- remove monster if defeated
  if state[1] == 'defeated' then
    monstersTable = phaseTracker[1].children[4].children
    if has_value(monstersTable, state[2].getGUID()) then
      table.remove(monstersTable, childrenTableID)
    end

    -- advance to encounter phase if all monsters are defeated or exausted
    if finished(monstersTable, 'true') == true and UI.getAttribute('MonsterPhaseBtn', 'interactable') == 'true' then
      broadcastToAll('All monsters defeated or exausted', {0, 1, 0})
      UI.setAttribute('MonsterPhaseBtn', 'interactable', 'false')
      UI.setAttribute('EncounterPhaseBtn', 'interactable', 'true')
    end
  end  

  -- update UI
  if (#monstersTable > 0) then
    UI.setAttribute('monsterTable', 'active', 'true')
  end

  if state[1] == 'spawned' then
    frames = frames + 15
    Wait.frames(
      function()
        height = UI.getAttribute('top', 'height')
        height = tonumber(height) + 50
        height = UI.setAttribute('top', 'height', height)
      end, frames
    )
    
    else
      height = UI.getAttribute('top', 'height')
      height = tonumber(height) - 50
      height = UI.setAttribute('top', 'height', height)
  end

  phaseTracker[1].children[4].children = monstersTable
  UI.setXmlTable(phaseTracker)
end

function updateInvestigators()

  if has_value(children, investigator[1].getName()) then
    table.remove(children, childrenTableID)
    height = UI.getAttribute('top', 'height') - 50
  else
    table.insert(children,
      {
        tag="HorizontalLayout",
        attributes={
          childForceExpandWidth=false,
        },
        children={
          {
            tag = "Button",
            value = investigator[1].getName(),
            attributes = {
              flexibleWidth='0.8',
              id=investigator[1].getName(),
              onClick = "69581b/toggleTurn",
              fontSize = 20,
              color = investigator[2],
              interactable=true,
              preferredHeight=50
            },
          },
          {
            tag="Button",
            value="X",
            attributes={
              flexibleWidth='0.2',
              interactable=true,
              id='remove' .. investigator[1].getName(),
              onClick = "69581b/toggleRemoveButton",
            }
          },
          {
            tag="Button",
            value="Y",
            attributes={
              tooltip="Retire " .. investigator[1].getName(),
              active=false,
              flexibleWidth='0.2',
              id='asdasd' .. investigator[1].getName(),
              onClick = "69581b/removeInvestigator",
              color="Red"
            }
          }
        }
      }
    )
    height = UI.getAttribute('top', 'height') + 50
  end

  if (#children > 0) then
    UI.setAttribute('investigators', 'active', 'true')
    UI.setAttribute('ActionPhaseBtn', 'interactable', 'true')
  end

  UI.setAttribute('top', 'height', height)
  phaseTracker = UI.getXmlTable()
  phaseTracker[1].children[2].children = children
  UI.setXmlTable(phaseTracker)
end

function toggleRemoveButton(player, value, id)
  id = id:sub(7)
  UI.setAttribute('asdasd' .. id, 'active', 'true')
  UI.setAttribute('remove' .. id, 'active', 'false')

  Wait.frames(
    function()
      UI.setAttribute('asdasd' .. id, 'active', 'false')
      UI.setAttribute('remove' .. id, 'active', 'true')
    end, 64
  )
end

function removeMonster(player, value, id)
  phaseTracker = UI.getXmlTable()
  monstersTable = phaseTracker[1].children[4].children

  id = id:sub(7)
  if has_value(monstersTable, id) then
    table.remove(monstersTable, childrenTableID)
  end
  
  Wait.frames(
    function()
      height = UI.getAttribute('top', 'height')
      UI.setAttribute('top', 'height', height - 50)
      UI.setXmlTable(phaseTracker)
      if (#monstersTable == 0) then
        UI.setAttribute('monsterTable', 'active', 'false')
        UI.setAttribute('MonsterPhaseBtn', 'interactable', 'false')
        UI.setAttribute('EncounterPhaseBtn', 'interactable', 'true')
      end
    end, 8
  )
end

function removeInvestigator(player, value, id)
  phaseTracker = UI.getXmlTable()
  children = phaseTracker[1].children[2].children

  id = id:sub(7)
  if has_value(children, id) then
    table.remove(children, childrenTableID)
  end
  
  Wait.frames(
    function()
      height = UI.getAttribute('top', 'height') - 50
      UI.setAttribute('top', 'height', height)
      UI.setXmlTable(phaseTracker)
      if (#children == 0) then
        UI.setAttribute('investigators', 'active', 'false')
        UI.setAttribute('ActionPhaseBtn', 'interactable', 'false')
      end
    end, 8
  )
end

function toggleMonsterTurn(player, value, id)
  for i, monster in ipairs(monstersTable) do
    if monster.children[1].attributes.id == id then
      UI.setAttribute(monster.children[1].attributes.id, "interactable", 'false')
    end
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
    UI.setAttribute(children[tonumber(childrenTableID)].children[1].attributes.id, 'interactable', 'false')
  end

  Wait.frames(
    function()
      if finished(children, 'true') == true then

        if monstersTable ~= nil then
          for i, monster in ipairs(monstersTable) do
            UI.setAttribute(monster.children[1].attributes.id, "interactable", 'true')
          end          
        end

        UI.setAttribute('ActionPhaseBtn', 'interactable', 'false')

        if monstersTable ~= nil and #monstersTable > 0 then
          UI.setAttribute('MonsterPhaseBtn', 'interactable', 'true')
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
    if value.children[1].attributes.id == val then
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
    UI.setAttribute(value.children[1].attributes.id, 'interactable', 'true')
    UI.setAttribute('remove' .. value.children[1].attributes.id, 'interactable', 'true')
  end
end

function finished(tab, val)
  if #tab == 0 then
    return true
  end

  for index, v in ipairs(tab) do
    if UI.getAttribute(v.children[1].attributes.id, "interactable") == val then
      return false
    end
  end

  return true
end