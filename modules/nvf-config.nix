{
  pkgs,
  lib,
  ...
}: let
  grammarSource =
    if pkgs.stdenv.isDarwin
    then pkgs.vimPlugins.nvim-treesitter.builtGrammars
    else pkgs.vimPlugins.nvim-treesitter-legacy.builtGrammars;
in {
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

        # Better clipboard handling:
        # OSC 52 is the "gold standard" for headless/SSH.
        # Neovim 0.10+ supports it natively.
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

          -- OSC 52 fallback for headless/SSH
          -- We only use OSC 52 for copying to avoid the "waiting for OSC 52 response" hang on paste.
          -- For pasting, we fall back to internal registers. Use terminal paste for external content.
          if os.getenv('SSH_TTY') or (not os.getenv('WAYLAND_DISPLAY') and not os.getenv('DISPLAY')) then
            vim.g.clipboard = {
              name = 'OSC 52 (Copy only)',
              copy = {
                ['+'] = require('vim.ui.clipboard.osc52').copy('+'),
                ['*'] = require('vim.ui.clipboard.osc52').copy('*'),
              },
              paste = {
                ['+'] = function() return {vim.fn.split(vim.fn.getreg('"'), '\n', 1), vim.fn.getregtype('"')} end,
                ['*'] = function() return {vim.fn.split(vim.fn.getreg('"'), '\n', 1), vim.fn.getregtype('"')} end,
              },
            }
          end
        '';

        extraPackages = with pkgs; [
          (
            if stdenv.isDarwin
            then tree-sitter
            else tree-sitter-bin
          )
          gcc
          ripgrep
          fd
          lazygit
        ];

        extraPlugins = {
          opencode-nvim = {
            package = pkgs.vimPlugins.opencode-nvim;
            setup = ''
              vim.g.opencode_opts = {}
              vim.o.autoread = true -- Required for `opts.events.reload`
              vim.keymap.set({ "n", "x" }, "<C-a>", function() require("opencode").ask("@this: ", { submit = true }) end, { desc = "Ask opencode…" })
              vim.keymap.set({ "n", "x" }, "<C-x>", function() require("opencode").select() end, { desc = "Execute opencode action…" })
              vim.keymap.set({ "n", "t" }, "<C-.>", function() require("opencode").toggle() end, { desc = "Toggle opencode" })
              vim.keymap.set({ "n", "x" }, "go", function() return require("opencode").operator("@this ") end, { desc = "Add range to opencode", expr = true })
              vim.keymap.set("n", "goo", function() return require("opencode").operator("@this ") .. "_" end, { desc = "Add line to opencode", expr = true })
              vim.keymap.set("n", "<S-C-u>", function() require("opencode").command("session.half.page.up") end, { desc = "Scroll opencode up" })
              vim.keymap.set("n", "<S-C-d>", function() require("opencode").command("session.half.page.down") end, { desc = "Scroll opencode down" })

              -- Alternative increment/decrement since opencode uses <C-a> and <C-x>
              vim.keymap.set("n", "+", "<C-a>", { desc = "Increment under cursor", noremap = true })
              vim.keymap.set("n", "-", "<C-x>", { desc = "Decrement under cursor", noremap = true })
            '';
            after = ["snacks-nvim"];
          };
        };

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
          servers.nil.appendConfig = ''
            settings = {
              ["nil"] = {
                nix = {
                  autoArchive = true,
                  autoEvalInputs = true,
                },
              },
            }
          '';
        };

        options = {
          autoindent = true;
          tabstop = 2;
          shiftwidth = 2;
          clipboard = "unnamedplus";
          expandtab = true;
          wrap = false;
          ignorecase = true;
          smartcase = true;
          cursorline = true;
          backspace = "indent,eol,start";
          splitright = true;
          splitbelow = true;
          relativenumber = true;
          number = true;

          foldcolumn = "1";
          foldlevel = 99;
          foldlevelstart = 99;
          foldenable = true;
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
          name = "tokyonight";
          style = "night";
        };

        ui = {
          nvim-ufo = {
            enable = true;
            setupOpts = {
              open_fold_hl_timeout = 150;
              close_fold_kinds_for_ft = {
                default = ["imports" "comment"];
                c = ["comment" "region"];
              };
              close_fold_current_line_for_ft = {
                default = true;
                c = false;
              };
              preview = {
                win_config = {
                  border = ["" "-" "" "" "" "-" "" ""];
                  winhighlight = "Normal:Folded";
                  winblend = 0;
                };
                mappings = {
                  scrollU = "<C-u>";
                  scrollD = "<C-d>";
                  jumpTop = "[";
                  jumpBot = "]";
                };
              };
            };
          };
        };

        treesitter = {
          enable = true;
          indent.enable = true;
          addDefaultGrammars = true;
          grammars = with grammarSource; [
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
                    cmd = "ascii-image-converter ~/.nixos-config/sin_rostro_2.jpg -C";
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
