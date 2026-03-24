{...}: {
  programs.nvf.settings.vim.keymaps = [
    # Window navigation
    {
      action = "<C-w>h";
      key = "<C-h>";
      mode = "n";
      noremap = true;
      silent = true;
    }
    {
      action = "<C-w>j";
      key = "<C-j>";
      mode = "n";
      noremap = true;
      silent = true;
    }
    {
      action = "<C-w>k";
      key = "<C-k>";
      mode = "n";
      noremap = true;
      silent = true;
    }
    {
      action = "<C-w>l";
      key = "<C-l>";
      mode = "n";
      noremap = true;
      silent = true;
    }

    # Terminal Navigation and Escape
    {
      action = "<C-\\><C-n><C-w>h";
      key = "<C-h>";
      mode = "t";
      noremap = true;
      silent = true;
    }
    {
      action = "<C-\\><C-n><C-w>j";
      key = "<C-j>";
      mode = "t";
      noremap = true;
      silent = true;
    }
    {
      action = "<C-\\><C-n><C-w>k";
      key = "<C-k>";
      mode = "t";
      noremap = true;
      silent = true;
    }
    {
      action = "<C-\\><C-n><C-w>l";
      key = "<C-l>";
      mode = "t";
      noremap = true;
      silent = true;
    }
    {
      action = "<C-\\><C-n>";
      key = "<Esc>";
      mode = "t";
      noremap = true;
      silent = true;
    }

    # Remove highlights
    {
      action = ":nohl<CR>";
      key = "<leader>nh";
      mode = "n";
      noremap = true;
      silent = true;
      desc = "Remove highlighted text";
    }

    # Window Management
    {
      action = "<C-w>=";
      key = "<leader>we";
      mode = "n";
      noremap = true;
      silent = true;
      desc = "Equalize window sizes";
    }
    {
      action = ":split<CR>";
      key = "<leader>wh";
      mode = "n";
      noremap = true;
      silent = true;
      desc = "Split window horizontally";
    }
    {
      action = ":vsplit<CR>";
      key = "<leader>wv";
      mode = "n";
      noremap = true;
      silent = true;
      desc = "Split window vertically";
    }
    {
      action = "<C-w>c";
      key = "<leader>wx";
      mode = "n";
      noremap = true;
      silent = true;
      desc = "Close current window";
    }

    # Picker and Explorer
    {
      action = "<cmd>lua Snacks.explorer.open()<CR>";
      key = "<leader>ee";
      mode = "n";
      noremap = true;
      silent = true;
      desc = "Open explorer [Snacks]";
    }
    {
      action = "<cmd>lua Snacks.picker.smart()<CR>";
      key = "<leader>e<space>";
      mode = "n";
      noremap = true;
      silent = true;
      desc = "Smart Find Files";
    }
    {
      action = "<cmd>lua Snacks.picker.buffers()<CR>";
      key = "<leader>e,";
      mode = "n";
      noremap = true;
      silent = true;
      desc = "Buffers";
    }
    {
      action = "<cmd>lua Snacks.picker.grep()<CR>";
      key = "<leader>e/";
      mode = "n";
      noremap = true;
      silent = true;
      desc = "Grep";
    }
    {
      action = "<cmd>lua Snacks.picker.command_history()<CR>";
      key = "<leader>e:";
      mode = "n";
      noremap = true;
      silent = true;
      desc = "Command History";
    }
    {
      action = "<cmd>lua Snacks.picker.notifications()<CR>";
      key = "<leader>en";
      mode = "n";
      noremap = true;
      silent = true;
      desc = "Notification History";
    }

    # Dim scope
    {
      action = "<cmd>lua Snacks.dim.enable()<CR>";
      key = "<leader>ud";
      mode = "n";
      noremap = true;
      silent = true;
      desc = "Dim scope";
    }
    {
      action = "<cmd>lua Snacks.dim.disable()<CR>";
      key = "<leader>uD";
      mode = "n";
      noremap = true;
      silent = true;
      desc = "Undim scope";
    }

    # Git
    {
      action = "<cmd>lua Snacks.lazygit()<CR>";
      key = "<leader>gg";
      mode = "n";
      noremap = true;
      silent = true;
      desc = "Open Lazygit";
    }
    {
      action = "<cmd>lua Snacks.git.blame_line()<CR>";
      key = "<leader>gb";
      mode = "n";
      noremap = true;
      silent = true;
      desc = "Git blame";
    }

    # Terminal
    {
      action = "<cmd>lua Snacks.terminal.toggle()<CR>";
      key = "<c-`>";
      mode = "n";
      noremap = true;
      silent = true;
      desc = "Open terminal";
    }

    # Find
    {
      key = "<leader>fb";
      mode = "n";
      action = "<cmd>lua Snacks.picker.buffers()<CR>";
      desc = "Buffers";
    }
    {
      key = "<leader>fc";
      mode = "n";
      action = "<cmd>lua Snacks.picker.files({ cwd = vim.fn.stdpath(\"config\") })<CR>";
      desc = "Find Config File";
    }
    {
      key = "<leader>ff";
      mode = "n";
      action = "<cmd>lua Snacks.picker.files()<CR>";
      desc = "Find Files";
    }
    {
      key = "<leader>fg";
      mode = "n";
      action = "<cmd>lua Snacks.picker.git_files()<CR>";
      desc = "Find Git Files";
    }
    {
      key = "<leader>fp";
      mode = "n";
      action = "<cmd>lua Snacks.picker.projects()<CR>";
      desc = "Projects";
    }
    {
      key = "<leader>fr";
      mode = "n";
      action = "<cmd>lua Snacks.picker.recent()<CR>";
      desc = "Recent";
    }

    # Git
    {
      key = "<leader>gb";
      mode = "n";
      action = "<cmd>lua Snacks.picker.git_branches()<CR>";
      desc = "Git Branches";
    }
    {
      key = "<leader>gl";
      mode = "n";
      action = "<cmd>lua Snacks.picker.git_log()<CR>";
      desc = "Git Log";
    }
    {
      key = "<leader>gL";
      mode = "n";
      action = "<cmd>lua Snacks.picker.git_log_line()<CR>";
      desc = "Git Log Line";
    }
    {
      key = "<leader>gs";
      mode = "n";
      action = "<cmd>lua Snacks.picker.git_status()<CR>";
      desc = "Git Status";
    }
    {
      key = "<leader>gS";
      mode = "n";
      action = "<cmd>lua Snacks.picker.git_stash()<CR>";
      desc = "Git Stash";
    }
    {
      key = "<leader>gd";
      mode = "n";
      action = "<cmd>lua Snacks.picker.git_diff()<CR>";
      desc = "Git Diff (Hunks)";
    }
    {
      key = "<leader>gf";
      mode = "n";
      action = "<cmd>lua Snacks.picker.git_log_file()<CR>";
      desc = "Git Log File";
    }

    # GitHub
    {
      key = "<leader>gi";
      mode = "n";
      action = "<cmd>lua Snacks.picker.gh_issue()<CR>";
      desc = "GitHub Issues (open)";
    }
    {
      key = "<leader>gI";
      mode = "n";
      action = "<cmd>lua Snacks.picker.gh_issue({ state = \"all\" })<CR>";
      desc = "GitHub Issues (all)";
    }
    {
      key = "<leader>gp";
      mode = "n";
      action = "<cmd>lua Snacks.picker.gh_pr()<CR>";
      desc = "GitHub Pull Requests (open)";
    }
    {
      key = "<leader>gP";
      mode = "n";
      action = "<cmd>lua Snacks.picker.gh_pr({ state = \"all\" })<CR>";
      desc = "GitHub Pull Requests (all)";
    }

    # Grep
    {
      key = "<leader>sb";
      mode = "n";
      action = "<cmd>lua Snacks.picker.lines()<CR>";
      desc = "Buffer Lines";
    }
    {
      key = "<leader>sB";
      mode = "n";
      action = "<cmd>lua Snacks.picker.grep_buffers()<CR>";
      desc = "Grep Open Buffers";
    }
    {
      key = "<leader>sg";
      mode = "n";
      action = "<cmd>lua Snacks.picker.grep()<CR>";
      desc = "Grep";
    }
    {
      key = "<leader>sw";
      mode = ["n" "x"];
      action = "<cmd>lua Snacks.picker.grep_word()<CR>";
      desc = "Visual selection or word";
    }

    # Search
    {
      key = "<leader>s\"";
      mode = "n";
      action = "<cmd>lua Snacks.picker.registers()<CR>";
      desc = "Registers";
    }
    {
      key = "<leader>s/";
      mode = "n";
      action = "<cmd>lua Snacks.picker.search_history()<CR>";
      desc = "Search History";
    }
    {
      key = "<leader>sa";
      mode = "n";
      action = "<cmd>lua Snacks.picker.autocmds()<CR>";
      desc = "Autocmds";
    }
    {
      key = "<leader>sc";
      mode = "n";
      action = "<cmd>lua Snacks.picker.command_history()<CR>";
      desc = "Command History";
    }
    {
      key = "<leader>sC";
      mode = "n";
      action = "<cmd>lua Snacks.picker.commands()<CR>";
      desc = "Commands";
    }
    {
      key = "<leader>sd";
      mode = "n";
      action = "<cmd>lua Snacks.picker.diagnostics()<CR>";
      desc = "Diagnostics";
    }
    {
      key = "<leader>sD";
      mode = "n";
      action = "<cmd>lua Snacks.picker.diagnostics_buffer()<CR>";
      desc = "Buffer Diagnostics";
    }
    {
      key = "<leader>sh";
      mode = "n";
      action = "<cmd>lua Snacks.picker.help()<CR>";
      desc = "Help Pages";
    }
    {
      key = "<leader>sH";
      mode = "n";
      action = "<cmd>lua Snacks.picker.highlights()<CR>";
      desc = "Highlights";
    }
    {
      key = "<leader>si";
      mode = "n";
      action = "<cmd>lua Snacks.picker.icons()<CR>";
      desc = "Icons";
    }
    {
      key = "<leader>sj";
      mode = "n";
      action = "<cmd>lua Snacks.picker.jumps()<CR>";
      desc = "Jumps";
    }
    {
      key = "<leader>sk";
      mode = "n";
      action = "<cmd>lua Snacks.picker.keymaps()<CR>";
      desc = "Keymaps";
    }
    {
      key = "<leader>sl";
      mode = "n";
      action = "<cmd>lua Snacks.picker.loclist()<CR>";
      desc = "Location List";
    }
    {
      key = "<leader>sm";
      mode = "n";
      action = "<cmd>lua Snacks.picker.marks()<CR>";
      desc = "Marks";
    }
    {
      key = "<leader>sM";
      mode = "n";
      action = "<cmd>lua Snacks.picker.man()<CR>";
      desc = "Man Pages";
    }
    {
      key = "<leader>sp";
      mode = "n";
      action = "<cmd>lua Snacks.picker.lazy()<CR>";
      desc = "Search for Plugin Spec";
    }
    {
      key = "<leader>sq";
      mode = "n";
      action = "<cmd>lua Snacks.picker.qflist()<CR>";
      desc = "Quickfix List";
    }
    {
      key = "<leader>sR";
      mode = "n";
      action = "<cmd>lua Snacks.picker.resume()<CR>";
      desc = "Resume";
    }
    {
      key = "<leader>su";
      mode = "n";
      action = "<cmd>lua Snacks.picker.undo()<CR>";
      desc = "Undo History";
    }
    {
      key = "<leader>uC";
      mode = "n";
      action = "<cmd>lua Snacks.picker.colorschemes()<CR>";
      desc = "Colorschemes";
    }

    # LSP
    {
      key = "gd";
      mode = "n";
      action = "<cmd>lua Snacks.picker.lsp_definitions()<CR>";
      desc = "Goto Definition";
    }
    {
      key = "gD";
      mode = "n";
      action = "<cmd>lua Snacks.picker.lsp_declarations()<CR>";
      desc = "Goto Declaration";
    }
    {
      key = "gr";
      mode = "n";
      action = "<cmd>lua Snacks.picker.lsp_references()<CR>";
      desc = "References";
    }
    {
      key = "gI";
      mode = "n";
      action = "<cmd>lua Snacks.picker.lsp_implementations()<CR>";
      desc = "Goto Implementation";
    }
    {
      key = "gy";
      mode = "n";
      action = "<cmd>lua Snacks.picker.lsp_type_definitions()<CR>";
      desc = "Goto Type Definition";
    }
    {
      key = "gai";
      mode = "n";
      action = "<cmd>lua Snacks.picker.lsp_incoming_calls()<CR>";
      desc = "Calls Incoming";
    }
    {
      key = "gao";
      mode = "n";
      action = "<cmd>lua Snacks.picker.lsp_outgoing_calls()<CR>";
      desc = "Calls Outgoing";
    }
    {
      key = "<leader>ss";
      mode = "n";
      action = "<cmd>lua Snacks.picker.lsp_symbols()<CR>";
      desc = "LSP Symbols";
    }
    {
      key = "<leader>sS";
      mode = "n";
      action = "<cmd>lua Snacks.picker.lsp_workspace_symbols()<CR>";
      desc = "LSP Workspace Symbols";
    }

    # Other
    {
      key = "<leader>z";
      mode = "n";
      action = "<cmd>lua Snacks.zen()<CR>";
      desc = "Toggle Zen Mode";
    }
    {
      key = "<leader>Z";
      mode = "n";
      action = "<cmd>lua Snacks.zen.zoom()<CR>";
      desc = "Toggle Zoom";
    }
    {
      key = "<leader>.";
      mode = "n";
      action = "<cmd>lua Snacks.scratch()<CR>";
      desc = "Toggle Scratch Buffer";
    }
    {
      key = "<leader>S";
      mode = "n";
      action = "<cmd>lua Snacks.scratch.select()<CR>";
      desc = "Select Scratch Buffer";
    }
    {
      key = "<leader>n";
      mode = "n";
      action = "<cmd>lua Snacks.notifier.show_history()<CR>";
      desc = "Notification History";
    }
    {
      key = "<leader>bd";
      mode = "n";
      action = "<cmd>lua Snacks.bufdelete()<CR>";
      desc = "Delete Buffer";
    }
    {
      key = "<leader>cR";
      mode = "n";
      action = "<cmd>lua Snacks.rename.rename_file()<CR>";
      desc = "Rename File";
    }
    {
      key = "<leader>gB";
      mode = ["n" "v"];
      action = "<cmd>lua Snacks.gitbrowse()<CR>";
      desc = "Git Browse";
    }
    {
      key = "<leader>gg";
      mode = "n";
      action = "<cmd>lua Snacks.lazygit()<CR>";
      desc = "Lazygit";
    }
    {
      key = "<leader>un";
      mode = "n";
      action = "<cmd>lua Snacks.notifier.hide()<CR>";
      desc = "Dismiss All Notifications";
    }
    {
      key = "<c-/>";
      mode = "n";
      action = "<cmd>lua Snacks.terminal()<CR>";
      desc = "Toggle Terminal";
    }
    {
      key = "<c-_>";
      mode = "n";
      action = "<cmd>lua Snacks.terminal()<CR>";
      desc = "which_key_ignore";
    }
    {
      key = "]]";
      mode = ["n" "t"];
      action = "<cmd>lua Snacks.words.jump(vim.v.count1)<CR>";
      desc = "Next Reference";
    }
    {
      key = "[[";
      mode = ["n" "t"];
      action = "<cmd>lua Snacks.words.jump(-vim.v.count1)<CR>";
      desc = "Prev Reference";
    }
    {
      key = "<leader>N";
      mode = "n";
      desc = "Neovim News";
      action = "<cmd>lua Snacks.win({ file = vim.api.nvim_get_runtime_file(\"doc/news.txt\", false)[1], width = 0.6, height = 0.6, wo = { spell = false, wrap = false, signcolumn = \"yes\", statuscolumn = \" \", conceallevel = 3 } })<CR>";
    }
  ];
}
