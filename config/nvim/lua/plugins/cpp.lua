local function project(file)
  local dir = vim.fs.dirname(file)
  local root, config
  while dir do
    local candidate = dir .. "/xmake.lua"
    if vim.fn.filereadable(candidate) == 1 then
      root, config = dir, candidate -- outermost xmake project wins
    end
    local parent = vim.fs.dirname(dir)
    if parent == dir then break end
    dir = parent
  end
  return root, config
end

local function terminal(root, argv)
  vim.cmd("botright 12new")
  vim.fn.termopen(argv, { cwd = root })
  vim.cmd("startinsert")
end

local function target_name(config)
  for _, line in ipairs(vim.fn.readfile(config)) do
    local name = line:match([[target%s*%(%s*["']([^"']+)]])
    if name then return name end
  end
end

local function main_location(root)
  for _, extension in ipairs({ "cpp", "cc", "cxx", "c" }) do
    for _, file in ipairs(vim.fn.globpath(root, "**/*." .. extension, false, true)) do
      if not file:find("/build/", 1, true) then
        for line_number, line in ipairs(vim.fn.readfile(file)) do
          if line:match("^%s*[%w_:<>*& ]+%s+main%s*%(") then
            return file, line_number
          end
        end
      end
    end
  end
end

return {
  {
    "neovim/nvim-lspconfig",
    opts = function(_, opts)
      opts.servers = opts.servers or {}
      opts.servers.clangd = opts.servers.clangd or {}
      local markers = opts.servers.clangd.root_markers or {}
      table.insert(markers, "xmake.lua")
      opts.servers.clangd.root_markers = markers
    end,
  },
  {
    "mfussenegger/nvim-dap",
    keys = {
      {
        "<leader>db",
        function() require("dap").toggle_breakpoint() end,
        desc = "Debug: Toggle breakpoint",
      },
      {
        "<leader>dq",
        function() require("dap").terminate() end,
        desc = "Debug: Stop",
      },
      {
        "<leader>dn",
        function() require("dap").step_over() end,
        desc = "Debug: Step over",
      },
      {
        "<leader>di",
        function() require("dap").step_into() end,
        desc = "Debug: Step into",
      },
      {
        "<leader>do",
        function() require("dap").step_out() end,
        desc = "Debug: Step out",
      },
      {
        "<leader>dr",
        function()
          local dap = require("dap")
          if dap.session() then dap.continue(); return end
          local root, config = project(vim.api.nvim_buf_get_name(0))
          if not root then
            vim.notify("No xmake.lua found above this C++ file", vim.log.levels.ERROR)
            return
          end
          local target = target_name(config)
          if not target then
            vim.notify("No target(\"name\") found in " .. config, vim.log.levels.ERROR)
            return
          end
          -- If the user has not set any breakpoints, stop at their C++ main()
          -- rather than the ELF runtime's low-level _start entry point.
          local all_breakpoints = require("dap.breakpoints").get()
          if not next(all_breakpoints) then
            local file, line = main_location(root)
            if file then
              local buf = vim.fn.bufadd(file)
              vim.fn.bufload(buf)
              require("dap.breakpoints").set({}, buf, line)
            end
          end
          local function fail(result)
            if result.code ~= 0 then
              vim.schedule(function()
                vim.notify((result.stderr or "") .. (result.stdout or ""), vim.log.levels.ERROR)
              end)
              return true
            end
            return false
          end
          vim.notify("Building fresh xmake debug target: " .. target)
          vim.system({ "xmake", "f", "-P", root, "-m", "debug", "-o", root .. "/build" }, { cwd = root }, function(configured)
            if fail(configured) then return end
            vim.system({ "xmake", "build", "-P", root, "-j", "2", target }, { cwd = root }, function(built)
              if fail(built) then return end
              vim.schedule(function()
                local matches = vim.fn.globpath(root .. "/build", "**/debug/" .. target, false, true)
                table.sort(matches)
                local executable
                for _, path in ipairs(matches) do
                  if vim.fn.executable(path) == 1 then executable = path; break end
                end
                if not executable then
                  vim.notify("Built target, but could not locate its debug executable", vim.log.levels.ERROR)
                  return
                end
                dap.defaults.fallback.terminal_win_cmd = "botright 12new"
                dap.run({
                  type = "codelldb",
                  request = "launch",
                  name = "Debug xmake target: " .. target,
                  program = executable,
                  cwd = root,
                  terminal = "integrated",
                  stopOnEntry = false,
                })
              end)
            end)
          end)
        end,
        desc = "Debug: Build and start/continue xmake target",
      },
    },
  },
  -- Keep the editor layout uncluttered: CodeLLDB's integrated terminal is the
  -- only debugger split; no side panels for scopes, stacks, or disassembly.
  { "rcarriga/nvim-dap-ui", enabled = false },
  {
    "nvim-lua/plenary.nvim",
    keys = {
      { "<leader>cb", function()
        local root = project(vim.api.nvim_buf_get_name(0))
        if root then terminal(root, { "xmake", "build", "-j", "2" })
        else vim.notify("No xmake.lua found above this file", vim.log.levels.ERROR) end
      end, desc = "C++: Build xmake project" },
      { "<leader>cr", function()
        local root, config = project(vim.api.nvim_buf_get_name(0))
        if root then
          local argv = { "xmake", "run" }
          local target = target_name(config)
          if target then table.insert(argv, target) end
          terminal(root, argv)
        else vim.notify("No xmake.lua found above this file", vim.log.levels.ERROR) end
      end, desc = "C++: Run xmake target" },
      { "<leader>cc", function()
        local root = project(vim.api.nvim_buf_get_name(0))
        if root then terminal(root, { "xmake", "project", "-k", "compile_commands", "-o", "." })
        else vim.notify("No xmake.lua found above this file", vim.log.levels.ERROR) end
      end, desc = "C++: Generate compile_commands.json" },
      { "<leader>cf", function()
        vim.lsp.buf.format({ async = true })
      end, desc = "C++: Format with clangd" },
    },
  },
}
