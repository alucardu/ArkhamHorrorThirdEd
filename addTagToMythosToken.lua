function onObjectLeaveContainer(container, leave_object)
  if container == self then
    tags = {
      container.getName(),
      'Mythos Cup Token'
    }
    leave_object.setTags(tags)
  end
end