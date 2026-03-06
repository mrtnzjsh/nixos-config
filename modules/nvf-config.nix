{
  pkgs,
  lib,
  ...
}: {
  imports = [
    ./nvf-keymaps.nix
  ];

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
              "<leader>e" = "+Pickers/Explorer";
              "<leader>f" = "+find";
              "<leader>g" = "+Git";
              "<leader>l" = "+lsp";
              "<leader>m" = "+modify";
              "<leader>w" = "+Window";
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

        languages = {
          enableFormat = true;
          enableTreesitter = true;
          json.enable = true;
          java.enable = true;
          rust.enable = true;
          ts.enable = true;
          yaml.enable = true;

          markdown = {
            enable = true;
            extensions.render-markdown-nvim.enable = true;
          };

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
          clipboard = "unnamedplus";
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
              scope.enable = true;
              indent.enable = true;
            };
          };
        };

        viAlias = true;
        vimAlias = true;
      };
    };
  };
}
