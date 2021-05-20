function onLoad()
  local params = {
    label="Shuffle!",
    click_function="shuffle",
    function_owner=self,
    position={-3, 0.2, 0},
    height=1000,
    width=1000,
    color="Red",
    font_size=250
  }
  self.createButton(params)
end

function onObjectLeaveContainer(container, leave_object)
  if container == self then leave_object.setRotation({180, 0, 180}) end
end

function shuffle()
  self.shuffle()
end