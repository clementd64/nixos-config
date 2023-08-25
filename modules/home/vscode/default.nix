{ config, lib, pkgs, ... }:

let cfg = config.clement.vscode;
in with lib; {
  options.clement.vscode = {
    enable = mkEnableOption "Enable vscode";
  };

  config = mkIf cfg.enable {
    programs.vscode = {
      enable = true;

      # TODO: don't install pre release

      # Update extensions with
      # $ curl -o /tmp/update_installed_exts.sh https://raw.githubusercontent.com/NixOS/nixpkgs/master/pkgs/applications/editors/vscode/extensions/update_installed_exts.sh
      # $ chmod 775 /tmp/update_installed_exts.sh
      # $ /tmp/update_installed_exts.sh > extensions.nix
      extensions = map
        (extension: pkgs.vscode-utils.buildVscodeMarketplaceExtension {
          mktplcRef = {
            inherit (extension) name publisher version sha256;
          };
        })
        (import ./extensions.nix).extensions;

      keybindings = [
        {
          key = "alt+k";
          command = "workbench.action.nextEditor";
        }
        {
          key = "alt+j";
          command = "workbench.action.previousEditor";
        }
        {
          key = "ctrl+[Backquote]";
          command = "workbench.action.terminal.new";
        }
        {
          key = "ctrl+shift+[Backquote]";
          command = "workbench.action.toggleMaximizedPanel";
        }
      ];

      userSettings = {
        "telemetry.telemetryLevel" = "off";

        "editor.inlineSuggest.enabled" = true;
        "github.copilot.enable" = {
            "*" = true;
            "plaintext" = false;
            "markdown" = false;
            "scminput" = false;
            "terraform" = false;
        };

        "editor.stickyScroll.enabled" = true;
        "editor.unicodeHighlight.invisibleCharacters" = false;
        "githubPullRequests.pullBranch" = "never";
        "workbench.enableExperiments" = false;
        "workbench.settings.enableNaturalLanguageSearch" = false;
        "yaml.customTags" = [ "!vault" ];
        gopls = { "ui.semanticTokens" = true; };

          # Theme
        "editor.fontFamily" = "'Fira Code', 'monospace'";
        "editor.fontLigatures" = true;
        "editor.lineNumbers" = "relative";
        "editor.minimap.enabled" = false;
        "editor.renderWhitespace" = "all";
        "terminal.integrated.fontFamily" = "'Fira Code'";
        "workbench.colorTheme" = "GitHub Dark Default";
        "workbench.iconTheme" = "material-icon-theme";
        "workbench.productIconTheme" = "fluent-icons";
        # Hide status bar. Toggle with alt
        "window.menuBarVisibility" = "toggle";
        # Colorize brackets
        "editor.guides.bracketPairs" = "active";
        "editor.bracketPairColorization.independentColorPoolPerBracketType" = true;

        # Vim
        "vim.leader" = "<space>";
        "vim.easymotion" = true;
        "vim.handleKeys" = {
            "<C-b>" = false;
            "<C-c>" = false;
            "<C-f>" = false;
            "<C-p>" = false;
            "<C-v>" = false;
            "<C-x>" = false;
            "<C-z>" = false;
        };
        "vim.normalModeKeyBindings" = [
            { "before" = ["D"];            "after" = ["\"" "_" "d"]; }
            { "before" = ["D" "D"];        "after" = ["\"" "_" "d" "d"]; }
            { "before" = ["C"];            "after" = ["\"" "_" "c"]; }
            { "before" = ["C" "C"];        "after" = ["\"" "_" "c" "c"]; }
            { "before" = ["<leader>" "y"]; "after" = ["\"" "+" "y"]; }
            { "before" = ["<leader>" "Y"]; "after" = ["\"" "+" "y" "g" "_"]; }
            { "before" = ["<leader>" "p"]; "after" = ["\"" "+" "p"]; }
            { "before" = ["<leader>" "P"]; "after" = ["\"" "+" "P"]; }
        ];
        "vim.visualModeKeyBindings" = [
            { "before" = ["D"];            "after" = ["\"" "_" "d"]; }
            { "before" = ["C"];            "after" = ["\"" "_" "c"]; }
            { "before" = ["<leader>" "y"]; "after" = ["\"" "+" "y"]; }
            { "before" = ["<leader>" "p"]; "after" = ["\"" "+" "p"]; }
            { "before" = ["<leader>" "P"]; "after" = ["\"" "+" "P"]; }
        ];

        # Language specific
        "[terraform]" = {
            "editor.formatOnSave" = true;
        };
        "[terraform-vars]" = {
            "editor.formatOnSave" = true;
        };
        "[json]" = {
            "editor.defaultFormatter" = "vscode.json-language-features";
        };
        "[jsonc]" = {
            "editor.defaultFormatter" = "vscode.json-language-features";
        };
        "[svelte]" = {
            "editor.defaultFormatter" = "svelte.svelte-vscode";
        };

        # C-p
        "search.searchOnType" = false;
        "search.useIgnoreFiles" = false;
        "search.exclude" = {
            "**/.venv" = true;
            "**/.vscode" = true;
            "**/node_modules" = true;
            "**/vendor" = true;
            "**/.direnv" = true;
        };

        # Disable some prompt
        "svelte.ask-to-enable-ts-plugin" = false;
        "svelte.enable-ts-plugin" = true;
        "update.showReleaseNotes" = false;
        "vs-kubernetes" = {
            "vs-kubernetes.ignore-recommendations" = true;
            "disable-linters" = ["resource-limits"];
        };
      };
    };
  };
}
