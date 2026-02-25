{
  pkgs,
  lib,
  ...
}: {
  programs.nvf = {
    enable = true;

    settings = {
      vim = {
        augroups = [{name = "UserSetup";}];
        autocmds = [
          {
            event = ["VimEnter"];
            group = "UserSetup";
            desc = "Dim by default";
            callback = lib.generators.mkLuaInline "
              function()
                Snacks.dim.enable()
              end
            ";
          }
        ];

        autocomplete = {
          blink-cmp = {
            enable = true;
            friendly-snippets.enable = true;
          };
        };

        autopairs.nvim-autopairs.enable = true;

        binds = {
          whichKey = {
            enable = true;
            register = {
              "<leader>d" = "+delete";
              "<leader>e" = "+FileBrowser";
              "<leader>g" = "+Git";
              "<leader>l" = "+lsp";
              "<leader>m" = "+modify";
              "<leader>s" = "+Window";
              "<leader>u" = "+ui";
            };
          };
        };

        clipboard.providers.wl-copy.enable = true;

        extraPackages = with pkgs; [
          tree-sitter-bin
          gcc
          ripgrep
          fd
          lazygit
        ];

        keymaps = [
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
          {
            action = ":nohl<CR>";
            key = "<leader>nh";
            mode = "n";
            noremap = true;
            silent = true;
          }
          {
            action = "<C-w>=";
            key = "<leader>se";
            mode = "n";
            noremap = true;
            silent = true;
          }
          {
            action = ":split<CR>";
            key = "<leader>sh";
            mode = "n";
            noremap = true;
            silent = true;
          }
          {
            action = ":vsplit<CR>";
            key = "<leader>sv";
            mode = "n";
            noremap = true;
            silent = true;
          }
          {
            action = "<C-w>c";
            key = "<leader>sx";
            mode = "n";
            noremap = true;
            silent = true;
          }
          {
            action = "<cmd>lua Snacks.explorer.open()<CR>";
            key = "<leader>ee";
            mode = "n";
            noremap = true;
            silent = true;
            desc = "Open explorer [Snacks]";
          }
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
        ];

        languages = {
          enableFormat = true;
          enableTreesitter = true;
          json.enable = true;
          java.enable = true;
          rust.enable = true;
          ts.enable = true;
          yaml.enable = true;

          nix = {
            enable = true;
            lsp.enable = true;
            lsp.servers = ["nil"];
            format.enable = true;
            format.type = ["alejandra"];
          };
        };

        lsp = {
          enable = true;
          formatOnSave = true;
          trouble.enable = true;
        };

        luaConfigPost = ''
          -- Force the legacy Treesitter engine to register the indent module
          local ok, configs = pcall(require, "nvim-treesitter.configs")
          if ok then
            configs.setup({
              indent = {
                enable = true,
              }
            })
          end
        '';

        options = {
          autoindent = true;
          backspace = "indent,eol,start";
          cursorline = true;
          expandtab = true;
          ignorecase = true;
          number = true;
          relativenumber = true;
          shiftwidth = 2;
          smartcase = true;
          splitbelow = true;
          splitright = true;
          tabstop = 2;
          wrap = false;
        };

        statusline.lualine = {
          enable = true;
          activeSection = {
            c = [
              ''
                {
                   function()
                      local status = os.getenv("DIRENV_DIR")
                      if status then
                        return "󱐋 direnv"
                      else
                        return ""
                      end
                    end,
                  color = { fg = "#ebdbb2", gui = "bold" },
                }
              ''
              "filename"
            ];
          };
        };

        tabline = {
          nvimBufferline = {
            enable = true;
            setupOpts = {
              options = {
                mode = "tabs";
                separator_style = "slant";
              };
            };
          };
        };

        telescope = {
          enable = true;
        };

        theme = {
          enable = true;
          name = "catppuccin";
          style = "frappe";
        };

        treesitter = {
          enable = true;
          indent.enable = true;
          addDefaultGrammars = true;
          grammars = with pkgs.vimPlugins.nvim-treesitter-legacy.builtGrammars; [
            lua
            nix
            bash
            python
            java
          ];
        };

        utility = {
          snacks-nvim = {
            enable = true;
            setupOpts = {
              dashboard = {
                enable = true;
                sections = [
                  {section = "header";}
                  {
                    section = "keys";
                    gap = 1;
                    padding = 1;
                  }
                  {
                    section = "terminal";
                    cmd = "ascii-image-converter ~/nixos-config/sin_rostro_2.jpg -C";
                    random = 10;
                    pane = 2;
                    indent = 4;
                    height = 20;
                  }
                ];
              };
              dim.enable = true;
              explorer.enable = true;
              notifier.enable = true;
              # lazygit.enable = true;
            };
          };
        };

        viAlias = true;
        vimAlias = true;

        visuals = {
          indent-blankline = {
            enable = true;
            # This enables the "rainbow" effect for different indent levels
            setupOpts = {
              scope = {
                enabled = true;
              };
            };
          };
        };
      };
    };
  };
}
