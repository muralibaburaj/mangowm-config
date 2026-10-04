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
        "<leader>du",
        function() require("dapui").toggle() end,
        desc = "Debug: Toggle UI",
      },
      {
        "<leader>dS",
        function()
          local dapui = require("dapui")
          dapui.open()
          dapui.elements.stacks.render()
        end,
        desc = "Debug: Refresh call stack",
      },
      {
        "<leader>dF",
        function()
          local widgets = require("dap.ui.widgets")
          widgets.centered_float(widgets.frames)
        end,
        desc = "Debug: Show call stack",
      },
      {
        "<leader>de",
        function() require("dapui").eval() end,
        mode = { "n", "v" },
        desc = "Debug: Evaluate expression",
      },
      {
        "<leader>dh",
        function() require("dap").repl.open() end,
        desc = "Debug: Open REPL",
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
        "<leader>dc",
        function() require("dap").run_to_cursor() end,
        desc = "Debug: Run to cursor",
      },
      {
        "<leader>dC",
        function()
          vim.ui.input({ prompt = "Breakpoint condition: " }, function(condition)
            if condition and condition ~= "" then
              require("dap").set_breakpoint(condition)
            end
          end)
        end,
        desc = "Debug: Conditional breakpoint",
      },
      {
        "<leader>dl",
        function()
          vim.ui.input({ prompt = "Logpoint message: " }, function(message)
            if message and message ~= "" then
              require("dap").set_breakpoint(nil, nil, message)
            end
          end)
        end,
        desc = "Debug: Logpoint",
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
  {
    "rcarriga/nvim-dap-ui",
    dependencies = { "nvim-neotest/nvim-nio", "theHamsta/nvim-dap-virtual-text" },
    opts = {
      icons = { expanded = "▾", collapsed = "▸", current_frame = "▸" },
      controls = { enabled = true },
      layouts = {
        {
          elements = {
            { id = "scopes", size = 0.40 },
            { id = "stacks", size = 0.30 },
            { id = "breakpoints", size = 0.15 },
            { id = "watches", size = 0.15 },
          },
          size = 48,
          position = "left",
        },
        {
          elements = {
            { id = "repl", size = 0.60 },
            { id = "console", size = 0.40 },
          },
          size = 12,
          position = "bottom",
        },
      },
      floating = { border = "rounded", max_height = 0.8, max_width = 0.8 },
    },
    config = function(_, opts)
      local dap, dapui = require("dap"), require("dapui")
      dapui.setup(opts)
      require("nvim-dap-virtual-text").setup({
        enabled = true,
        enabled_commands = true,
        highlight_changed_variables = true,
        show_stop_reason = true,
        commented = false,
      })
      dap.listeners.after.event_initialized["dapui_config"] = function() dapui.open() end
      dap.listeners.after.event_stopped["dapui_stack_refresh"] = function()
        vim.defer_fn(function()
          if dap.session() then
            dapui.open()
            dapui.elements.stacks.render()
          end
        end, 100)
      end
      dap.listeners.before.event_terminated["dapui_config"] = function() dapui.close() end
      dap.listeners.before.event_exited["dapui_config"] = function() dapui.close() end
    end,
  },
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
