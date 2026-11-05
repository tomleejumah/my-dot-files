local M = {}
--[[ M.current_time = "🅆 N/A " ]]
M.current_time = "󰥔 N/A "
local timer
local fetching = false

local function update_wakatime()
  local token = vim.env.WAKATIME_OAUTH_TOKEN

  if not token or token == "" then
    vim.notify("WakaTime: OAuth token missing", vim.log.levels.ERROR)
    return
  end

  if fetching then return end
  fetching = true

  local date = os.date("!%Y-%m-%d")

  vim.system({
    "curl",
    "-fsS",
    "--max-time", "10",
    "-H", "Authorization: Bearer " .. token,
    "https://wakatime.com/api/v1/users/current/summaries"
      .. "?start=" .. date .. "&end=" .. date,
  }, { text = true }, function(result)
    vim.schedule(function()
      fetching = false

      if result.code ~= 0 then
        vim.notify(
          "WakaTime curl failed: " .. (result.stderr or ""),
          vim.log.levels.ERROR
        )
        return
      end

      local ok, response = pcall(vim.json.decode, result.stdout)

      if not ok or type(response.data) ~= "table" then
        vim.notify("WakaTime: Invalid API response", vim.log.levels.ERROR)
        return
      end

      local day = response.data[1]
      local time = day and day.grand_total and day.grand_total.text

      if not time then
        vim.notify("WakaTime: No coding data returned", vim.log.levels.WARN)
        return
      end

--[[       M.current_time = "🅆 " .. time .. " " ]]
M.current_time = "󰥔 " .. time .. " "
      vim.cmd("redrawstatus")
    end)
  end)
end

M.get_wakatime = function()
  return M.current_time
end

M.refresh = update_wakatime

update_wakatime()

timer = vim.uv.new_timer()
timer:start(300000, 300000, vim.schedule_wrap(update_wakatime))

return M
