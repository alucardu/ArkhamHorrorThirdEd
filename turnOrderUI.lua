investigator = {}
children = {}
childrenTableID = ''

function onLoad()
  -- 
end

function updateChildren()
  if has_value(children, investigator[1]) then
    table.remove(children, childrenTableID)
  else
    table.insert(children, 
      {
        tag = "Button",
        attributes = {
            id=investigator[1],
            onClick = "02bfa6/test",
            fontSize = 20,
            color = investigator[2],
            interactable=true
        },
        value = investigator[1],
      }
    )
  end
end

function updateInvestigators()
  local container = {
    {
      tag="Panel",
      attributes={
        height=#children * 100,
        width=200,
        color="rgba(0,0,0,0.7)",
        rectAlignment="UpperRight",
        offsetXY="-200, 0"
      },
      children={
        {
          tag="VerticalLayout",
          children = children
        }
      }
    }
  }

  UI.setXmlTable(container)
end

function test(player, value, id)
  if has_value(children, id) then
    children[tonumber(childrenTableID)].attributes.interactable = false
    updateInvestigators()
  end
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