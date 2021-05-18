investigator = {}
children = {}
monstersTable = {}
monsters = {}
childrenTableID = ''

function onLoad()
  local container = {
    {
      tag="VerticalLayout",
      attributes={
        id="top",
        width=200,
        height=200,
        color="rgba(0,0,0,0.7)",
        rectAlignment="UpperLeft",
        offsetXY="-0, 0",
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
        -- {
        --   tag="HorizontalLayout",
        --   attributes={
        --     active=#monstersTable > 0,
        --     prefferedHeight=35
        --   },
        --   children = {
        --     {
        --       tag="VerticalLayout",
        --       children=monstersTable
        --     }
        --   }
        -- },
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
  -- make copy of current monster table
  phaseTracker = UI.getXmlTable()
  monsterContainer = phaseTracker[1].children[4].children[1].children

  -- add monster if spawned
  if state[1] == 'spawned' then
    table.insert(monsterContainer,
      {
        tag="Row",
        attributes={
          preferredHeight="20"
        },
        children={
          {
            tag = "Button",
            value = state[2].getName(),
            attributes = {
              id=state[2].getGUID(),
              onClick = "69581b/toggleMonsterTurn",
              fontSize = 20,
              interactable=false
            },
          },
          {
            tag="Button",
            value="X"
          }
        }
      }
    )
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

  if has_value(children, investigator[1].getName()) then
    table.remove(children, childrenTableID)
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
  end
  if (#children > 0) then
    UI.setAttribute('investigators', 'active', 'true')
    UI.setAttribute('ActionPhaseBtn', 'interactable', 'true')
  end
  UI.setAttribute('top', 'height', 200 + #children * 50)
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

function removeInvestigator(player, value, id)
  id = id:sub(7)
  if has_value(children, id) then
    table.remove(children, childrenTableID)
  end
  phaseTracker[1].children[2].children = children
  
  Wait.frames(
    function()
      UI.setAttribute('top', 'height', 200 + #children * 50)
      UI.setXmlTable(phaseTracker)
      if (#children == 0) then
        UI.setAttribute('investigators', 'active', 'false')
        UI.setAttribute('ActionPhaseBtn', 'interactable', 'false')
      end
    end, 8
  )
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
    UI.setAttribute(children[tonumber(childrenTableID)].children[1].attributes.id, 'interactable', 'false')
    UI.setAttribute('remove' .. children[tonumber(childrenTableID)].children[1].attributes.id, 'interactable', 'false')
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
    if value.children[1].value == val then
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