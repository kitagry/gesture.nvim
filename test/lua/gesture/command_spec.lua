local helper = require("gesture.lib.testlib.helper")
local gesture = setmetatable({}, {
  __index = function(_, k)
    return require("gesture")[k]
  end,
})
local command = helper.command

describe("gesture.nvim", function()

  before_each(helper.before_each)
  after_each(helper.after_each)

  it("can register and execute a global gesture", function()
    gesture.register({inputs = {gesture.down(), gesture.up()}, action = "normal! gg"})

    helper.set_lines([[
hoge


foo]])
    command("normal! G")

    gesture.draw()
    command("normal! 10j")
    gesture.draw()
    command("normal! 10k")
    gesture.draw()
    gesture.finish()

    assert.window_count(1)
    assert.current_line("hoge")
  end)

  it("can register and execute a buffer local gesture", function()
    gesture.register({
      inputs = {gesture.right(), gesture.left()},
      action = "normal! $",
      buffer = "%",
    })
    gesture.register({inputs = {gesture.right(), gesture.left()}, action = "normal! 0"})

    helper.set_lines([[
hoge         foo
]])

    gesture.draw()
    command("normal! 10l")
    gesture.draw()
    command("normal! 10h")
    gesture.draw()
    gesture.finish()

    assert.window_count(1)
    assert.current_word("foo")
  end)

  it("can use function as action", function()
    gesture.register({
      inputs = {gesture.down(), gesture.up()},
      action = function()
        vim.cmd("normal! gg")
      end,
    })

    helper.set_lines([[
hoge


foo]])
    command("normal! G")

    gesture.draw()
    command("normal! 10j")
    gesture.draw()
    command("normal! 10k")
    gesture.draw()
    gesture.finish()

    assert.window_count(1)
    assert.current_line("hoge")
  end)

  it("can execute a global gesture with matched buffer local gesture", function()
    gesture.register({
      inputs = {gesture.right({min_length = 10})},
      action = "normal! $",
      buffer = "%",
    })
    gesture.register({inputs = {gesture.right()}, action = "normal! G"})

    helper.set_lines([[
hoge         foo
bar]])

    gesture.draw()
    command("normal! 8l")
    gesture.draw()
    gesture.finish()

    assert.window_count(1)
    assert.current_word("bar")
  end)

  it("can register and execute a nowait gesture", function()
    gesture.register({inputs = {gesture.right()}, action = "normal! $", nowait = true})

    helper.set_lines([[
hoge         foo
]])

    gesture.draw()
    command("normal! 10l")
    gesture.draw()

    assert.window_count(1)
    assert.current_word("foo")
  end)

  it("can register and execute a nowait buffer local gesture", function()
    gesture.register({inputs = {gesture.right()}, action = "normal! $", nowait = true, buffer = "%"})
    gesture.register({inputs = {gesture.right()}, action = "normal! 0", nowait = true})
    gesture.register({
      inputs = {gesture.right(), gesture.left()},
      action = "normal! 0",
      buffer = "%",
    })

    helper.set_lines([[
hoge         foo
]])

    gesture.draw()
    command("normal! 10l")
    gesture.draw()

    assert.window_count(1)
    assert.current_word("foo")
  end)

  it("does nothing for non matched gesture", function()
    gesture.register({inputs = {gesture.down(), gesture.up()}, action = "normal! G"})

    helper.set_lines([[
hoge


foo]])

    gesture.draw()
    command("normal! 10j")
    gesture.draw()
    gesture.finish()

    assert.window_count(1)
    assert.current_line("hoge")
  end)

  it("can register a gesture with max length", function()
    gesture.register({inputs = {gesture.right({max_length = 10})}, action = "normal! $"})

    helper.set_lines([[
hoge         foo
]])

    gesture.draw()
    command("normal! 11l")
    gesture.draw()
    gesture.finish()

    assert.window_count(1)
    assert.current_word("hoge")
  end)

  it("can register a gesture with min length", function()
    gesture.register({inputs = {gesture.right({min_length = 10})}, action = "normal! $"})

    helper.set_lines([[
hoge         foo
]])

    gesture.draw()
    command("normal! 9l")
    gesture.draw()
    gesture.finish()

    assert.window_count(1)
    assert.current_word("hoge")
  end)

  it("shows input gestures", function()
    gesture.draw()
    command("normal! 10l")
    gesture.draw()
    command("normal! 10j")
    gesture.draw()
    command("normal! 10h")
    gesture.draw()
    command("normal! 10k")
    gesture.draw()

    assert.shown_in_view("RIGHT")
    assert.shown_in_view("DOWN")
    assert.shown_in_view("LEFT")
    assert.shown_in_view("UP")
  end)

  it("shows matched gesture name", function()
    gesture.register({name = "to bottom", inputs = {gesture.down()}, action = "normal! G"})
    gesture.register({
      name = "to top",
      inputs = {gesture.down(), gesture.up()},
      action = "normal! gg",
    })

    gesture.draw()
    command("normal! 10j")
    gesture.draw()

    assert.shown_in_view("DOWN")
    assert.shown_in_view("to bottom")

    command("normal! 10k")
    gesture.draw()

    assert.shown_in_view("UP")
    assert.shown_in_view("to top")
  end)

  it("raises no error with many gestures", function()
    for _ = 0, 100, 1 do
      gesture.draw()
      command("normal! 10j")
      gesture.draw()
      command("normal! 10k")
    end
    assert.shown_in_view("UP")
  end)

  it("avoid creating multiple gesture state", function()
    command("tabedit")
    gesture.draw()
    command("noautocmd tabprevious")

    gesture.draw()
    command("tabnext")

    assert.window_count(1)
  end)

  it("reset scroll on scrolled", function()
    gesture.draw()
    command("normal! G")
    command("normal! zz")

    -- NOTE: zz may not fire callback in headless mode.
    command("redraw")

    assert.window_first_row(1)
  end)

  it("overwrites the same gesture", function()
    gesture.register({inputs = {gesture.right(), gesture.left()}, action = "normal! w"})
    gesture.register({inputs = {gesture.right(), gesture.left()}, action = "normal! 2w"})

    helper.set_lines([[hoge foo bar]])

    gesture.draw()
    command("normal! 10l")
    gesture.draw()
    command("normal! 10h")
    gesture.draw()
    gesture.finish()

    assert.current_word("bar")
  end)

  it("does not overwrite gesture has the different attribute", function()
    gesture.register({
      inputs = {gesture.right({max_length = 20}), gesture.left()},
      action = "normal! w",
    })
    gesture.register({
      inputs = {gesture.right({min_length = 20}), gesture.left()},
      action = "normal! 2w",
    })

    helper.set_lines([[hoge foo bar]])

    gesture.draw()
    command("normal! 10l")
    gesture.draw()
    command("normal! 10h")
    gesture.draw()
    gesture.finish()

    assert.current_word("foo")
  end)

  it("can cancel gesture", function()
    gesture.register({inputs = {gesture.down(), gesture.up()}, action = "normal! gg"})

    helper.set_lines([[
hoge


foo]])
    command("normal! G")

    gesture.draw()
    command("normal! 10j")
    gesture.draw()
    command("normal! 10k")
    gesture.draw()
    gesture.cancel()

    assert.window_count(1)
    assert.current_line("foo")
  end)

end)
