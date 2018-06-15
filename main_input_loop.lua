local sleep = require('socket').sleep

return function(game_ctx, local_ctx, event_queue, list_processor, command_processor, networking, on_loop)
  local on_loop = on_loop or function() end
  local exit_requested = false

  os.execute('winconsole_vt100.cmd')

  local function handle_line(line)
    local events = command_processor:process(game_ctx, local_ctx, line)
    networking:broadcast_events(game_ctx, local_ctx, events)
  end

  local cached_input = ''
  while not exit_requested do
    local event = event_queue:dequeue()
    while event do
      list_processor:invoke_pre_listeners(game_ctx, local_ctx, networking, event)
      event:process(game_ctx, local_ctx)
      list_processor:invoke_post_listeners(game_ctx, local_ctx, networking, event)
      event = event_queue:dequeue()
    end

    on_loop()
    networking:update(game_ctx, local_ctx, event_queue)

    local handle = io.popen('GetAvailableKeys.exe')
    local new_input = handle:read('*all')
    handle:close()

    for new_key_str in new_input:gmatch('[^\r\n]+') do
      local_ctx.dirty = true
      local first_space = 1
      while new_key_str:sub(first_space, first_space) ~= ' ' do
        first_space = first_space + 1
      end

      local new_key_code = tonumber(new_key_str:sub(1, first_space))
      local new_key_char = new_key_str:sub(first_space + 1)

      if new_key_code == 13 then
        io.write('\27[2K\r')
        handle_line(cached_input)
        cached_input = ''
      elseif new_key_code == 8 then
        if #cached_input > 1 then
          cached_input = cached_input:sub(1, #cached_input - 1)
        else
          cached_input = ''
        end
      else
        cached_input = cached_input .. new_key_char
      end
    end
    if local_ctx.dirty then
      io.write('\27[2K')
      io.write('\r')

      if #cached_input < 100 then
        io.write(cached_input)
      else
        io.write(cached_input:sub(#cached_input - 100))
      end
      local_ctx.dirty = false
    end

    sleep(0.008)
  end
end
