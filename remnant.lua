function onObjectLeaveContainer(container, remnantToken)
  if container == getObjectFromGUID('752ff0') then
    local func = function() destroyObject(remnantToken) end
    remnantToken.addContextMenuItem('Remove remnant', func)
  end
end