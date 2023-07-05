{ ... }:
{
  # TODO: remove prefix
  programs.starship = {
    enable = true;
    settings = {
      format = "$all$fill$cmd_duration$kubernetes$time$line_break$jobs$battery$shell$status$sudo$character";

      fill = {
        symbol = " ";
      };

      character = {
        success_symbol = "[\\$](bold green)";
        error_symbol = "[\\$](bold red)";
      };

      directory = {
        format = "[$read_only]($read_only_style)[$path]($style) ";
      };

      kubernetes = {
        disabled = false;
        format = "[$symbol$context](cyan bold)[(/$namespace)](cyan) ";
      };

      time = {
        disabled = false;
      };

      status = {
        disabled = false;
        pipestatus = true;
        format = "[$status( $signal_name)]($style) ";
        pipestatus_separator = "| ";
        pipestatus_format = "$pipestatus"; # do not render the status twice
      };

      sudo = {
        disabled = false;
        format = "[$symbol]($style)";
      };

      shell = {
        disabled = false;
        format = "[$indicator]($style)"; # Remove padding space
        style = "bold bright-black";
        fish_indicator = ""; # Default shell, no need to signal it
        bash_indicator = "bash "; # Must add trailing space
      };

      nix_shell = {
        symbol = "❄️ "; # Fix white space
      };

      git_branch = {
        symbol = " ";
      };

      git_metrics = {
        disabled = false;
      };
    };
  };
}