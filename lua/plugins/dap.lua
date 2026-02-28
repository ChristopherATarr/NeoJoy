-- NeoJoy: DAP — Debug Adapter Protocol

return {

    -- Core DAP client
    {
        "mfussenegger/nvim-dap",
        dependencies = { "nvim-neotest/nvim-nio" },

        -- init runs at startup for all plugins (lazy or not)
        -- Signs are pure vim built-ins — no plugin code needed
        init = function()
            vim.fn.sign_define("DapBreakpoint",          { text = "●", texthl = "DapBreakpoint",          linehl = "",              numhl = "" })
            vim.fn.sign_define("DapBreakpointCondition", { text = "◆", texthl = "DapBreakpointCondition", linehl = "",              numhl = "" })
            vim.fn.sign_define("DapBreakpointRejected",  { text = "●", texthl = "DapBreakpointRejected",  linehl = "",              numhl = "" })
            vim.fn.sign_define("DapLogPoint",            { text = "◎", texthl = "DapLogPoint",            linehl = "",              numhl = "" })
            vim.fn.sign_define("DapStopped",             { text = "▶", texthl = "DapStopped",             linehl = "DapStoppedLine", numhl = "" })
        end,

        keys = {
            -- F-key flow (standard debug conventions)
            { "<F5>",  function() require("dap").continue()    end, desc = "Debug: continue" },
            { "<F10>", function() require("dap").step_over()   end, desc = "Debug: step over" },
            { "<F11>", function() require("dap").step_into()   end, desc = "Debug: step into" },
            { "<F12>", function() require("dap").step_out()    end, desc = "Debug: step out" },

            -- <leader>d namespace (which-key group: "debug")
            { "<leader>db", function() require("dap").toggle_breakpoint() end,                                        desc = "Toggle breakpoint" },
            { "<leader>dB", function() require("dap").set_breakpoint(vim.fn.input("Condition: ")) end,                desc = "Conditional breakpoint" },
            { "<leader>dc", function() require("dap").continue() end,                                                 desc = "Continue" },
            { "<leader>di", function() require("dap").step_into() end,                                                desc = "Step into" },
            { "<leader>do", function() require("dap").step_over() end,                                                desc = "Step over" },
            { "<leader>dO", function() require("dap").step_out() end,                                                 desc = "Step out" },
            { "<leader>dr", function() require("dap").repl.open() end,                                                desc = "Open REPL" },
            { "<leader>dl", function() require("dap").run_last() end,                                                 desc = "Run last" },
            { "<leader>dx", function() require("dap").terminate() end,                                                desc = "Terminate" },

            -- Diagnostics share the namespace (dd/dq to avoid conflict with db/dc/etc.)
            { "<leader>dd", function() vim.diagnostic.open_float() end, desc = "Show diagnostic" },
            { "<leader>dq", function() vim.diagnostic.setloclist() end,  desc = "Diagnostic list" },
        },

        config = function()
            -- highlight groups for the stopped line
            vim.api.nvim_set_hl(0, "DapStoppedLine", { default = true, link = "Visual" })
        end,
    },

    -- DAP UI — side panels for variables, watches, stack, breakpoints
    {
        "rcarriga/nvim-dap-ui",
        dependencies = {
            "mfussenegger/nvim-dap",
            "nvim-neotest/nvim-nio",
        },
        keys = {
            { "<leader>du", function() require("dapui").toggle() end,              desc = "Toggle DAP UI" },
            { "<leader>de", function() require("dapui").eval() end, mode = { "n", "v" }, desc = "Evaluate expression" },
        },
        config = function()
            local dap, dapui = require("dap"), require("dapui")
            dapui.setup()

            -- Auto open/close UI with the debug session
            dap.listeners.after.event_initialized["dapui_config"]  = function() dapui.open() end
            dap.listeners.before.event_terminated["dapui_config"]  = function() dapui.close() end
            dap.listeners.before.event_exited["dapui_config"]      = function() dapui.close() end
        end,
    },

    -- nvim-neotest/nvim-nio — async I/O, required by nvim-dap-ui
    {
        "nvim-neotest/nvim-nio",
        lazy = true,
    },

    -- Mason bridge: installs debug adapters via Mason
    {
        "jay-babu/mason-nvim-dap.nvim",
        dependencies = {
            "williamboman/mason.nvim",
            "mfussenegger/nvim-dap",
        },
        opts = {
            -- Adapters to ensure are installed
            -- Add more here or via lua/config/overrides.lua
            ensure_installed    = { "python" },
            automatic_installation = false,
            handlers            = {},   -- use mason-nvim-dap default configs
        },
    },

    -- Virtual text: show variable values inline during debug session
    {
        "theHamsta/nvim-dap-virtual-text",
        dependencies = {
            "mfussenegger/nvim-dap",
            "nvim-treesitter/nvim-treesitter",
        },
        opts = {},
    },

}
