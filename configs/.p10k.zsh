# Powerlevel10k configuration with Nord color theme
# Based on romkatv/powerlevel10k/config/p10k-pure.zsh
# Nord palette: https://www.nordtheme.com/
#
# Type `p10k configure` to generate another config.

# Temporarily change options.
'builtin' 'local' '-a' 'p10k_config_opts'
[[ ! -o 'aliases'         ]] || p10k_config_opts+=('aliases')
[[ ! -o 'sh_glob'         ]] || p10k_config_opts+=('sh_glob')
[[ ! -o 'no_brace_expand' ]] || p10k_config_opts+=('no_brace_expand')
'builtin' 'setopt' 'no_aliases' 'no_sh_glob' 'brace_expand'

() {
  emulate -L zsh -o extended_glob

  # Unset all configuration options.
  unset -m '(POWERLEVEL9K_*|DEFAULT_USER)~POWERLEVEL9K_GITSTATUS_DIR'

  # Zsh >= 5.1 is required.
  [[ $ZSH_VERSION == (5.<1->*|<6->.*) ]] || return

  # ============================================================================
  # Nord Color Palette (using 256-color approximations)
  # ============================================================================
  # Polar Night (dark backgrounds)
  local nord0='236'   # #2E3440 - darkest
  local nord1='238'   # #3B4252
  local nord2='239'   # #434C5E
  local nord3='240'   # #4C566A - lightest dark

  # Snow Storm (light text)
  local nord4='253'   # #D8DEE9 - darkest light
  local nord5='255'   # #E5E9F0
  local nord6='231'   # #ECEFF4 - brightest

  # Frost (cyan/blue accent colors)
  local nord7='109'   # #8FBCBB - teal
  local nord8='110'   # #88C0D0 - cyan (main accent)
  local nord9='110'   # #81A1C1 - light blue
  local nord10='67'   # #5E81AC - blue

  # Aurora (semantic colors)
  local nord11='131'  # #BF616A - red (errors)
  local nord12='173'  # #D08770 - orange (warnings)
  local nord13='222'  # #EBCB8B - yellow (time, duration)
  local nord14='108'  # #A3BE8C - green (success)
  local nord15='139'  # #B48EAD - purple (magenta)

  # Left prompt segments.
  typeset -g POWERLEVEL9K_LEFT_PROMPT_ELEMENTS=(
    # =========================[ Line #1 ]=========================
    context                   # user@host
    dir                       # current directory
    vcs                       # git status
    command_execution_time    # previous command duration
    # =========================[ Line #2 ]=========================
    newline                   # \n
    virtualenv                # python virtual environment
    prompt_char               # prompt symbol
  )

  # Right prompt segments.
  typeset -g POWERLEVEL9K_RIGHT_PROMPT_ELEMENTS=(
    # =========================[ Line #1 ]=========================
    time                      # current time
    # =========================[ Line #2 ]=========================
    newline                   # \n
  )

  # Basic style options that define the overall prompt look.
  typeset -g POWERLEVEL9K_BACKGROUND=                            # transparent background
  typeset -g POWERLEVEL9K_{LEFT,RIGHT}_{LEFT,RIGHT}_WHITESPACE=  # no surrounding whitespace
  typeset -g POWERLEVEL9K_{LEFT,RIGHT}_SUBSEGMENT_SEPARATOR=' '  # separate segments with a space
  typeset -g POWERLEVEL9K_{LEFT,RIGHT}_SEGMENT_SEPARATOR=        # no end-of-line symbol
  typeset -g POWERLEVEL9K_VISUAL_IDENTIFIER_EXPANSION=           # no segment icons

  # Add an empty line before each prompt except the first.
  typeset -g POWERLEVEL9K_PROMPT_ADD_NEWLINE=true

  # ============================================================================
  # Prompt Character (❯)
  # ============================================================================
  # Nord cyan (frost) prompt symbol if the last command succeeded.
  typeset -g POWERLEVEL9K_PROMPT_CHAR_OK_{VIINS,VICMD,VIVIS}_FOREGROUND=$nord8
  # Nord red (aurora) prompt symbol if the last command failed.
  typeset -g POWERLEVEL9K_PROMPT_CHAR_ERROR_{VIINS,VICMD,VIVIS}_FOREGROUND=$nord11
  # Default prompt symbol.
  typeset -g POWERLEVEL9K_PROMPT_CHAR_{OK,ERROR}_VIINS_CONTENT_EXPANSION='❯'
  # Prompt symbol in command vi mode.
  typeset -g POWERLEVEL9K_PROMPT_CHAR_{OK,ERROR}_VICMD_CONTENT_EXPANSION='❮'
  # Prompt symbol in visual vi mode is the same as in command mode.
  typeset -g POWERLEVEL9K_PROMPT_CHAR_{OK,ERROR}_VIVIS_CONTENT_EXPANSION='❮'
  # Prompt symbol in overwrite vi mode is the same as in command mode.
  typeset -g POWERLEVEL9K_PROMPT_CHAR_OVERWRITE_STATE=false

  # ============================================================================
  # Python Virtual Environment
  # ============================================================================
  # Nord purple for virtualenv
  typeset -g POWERLEVEL9K_VIRTUALENV_FOREGROUND=$nord15
  # Don't show Python version.
  typeset -g POWERLEVEL9K_VIRTUALENV_SHOW_PYTHON_VERSION=false
  typeset -g POWERLEVEL9K_VIRTUALENV_{LEFT,RIGHT}_DELIMITER=

  # ============================================================================
  # Current Directory
  # ============================================================================
  # Nord frost blue for directory
  typeset -g POWERLEVEL9K_DIR_FOREGROUND=$nord9

  # ============================================================================
  # Context (user@host)
  # ============================================================================
  # Context format when root: user@host. The first part white (nord6), the rest grey (nord3).
  typeset -g POWERLEVEL9K_CONTEXT_ROOT_TEMPLATE="%F{$nord6}%n%f%F{$nord3}@%m%f"
  # Context format when not root: user@host. The whole thing nord3.
  typeset -g POWERLEVEL9K_CONTEXT_TEMPLATE="%F{$nord3}%n@%m%f"
  # Don't show context unless root or in SSH.
  typeset -g POWERLEVEL9K_CONTEXT_{DEFAULT,SUDO}_CONTENT_EXPANSION=

  # ============================================================================
  # Command Execution Time
  # ============================================================================
  # Show previous command duration only if it's >= 5s.
  typeset -g POWERLEVEL9K_COMMAND_EXECUTION_TIME_THRESHOLD=5
  # Don't show fractional seconds. Thus, 7s rather than 7.3s.
  typeset -g POWERLEVEL9K_COMMAND_EXECUTION_TIME_PRECISION=0
  # Duration format: 1d 2h 3m 4s.
  typeset -g POWERLEVEL9K_COMMAND_EXECUTION_TIME_FORMAT='d h m s'
  # Nord yellow (aurora) for command duration
  typeset -g POWERLEVEL9K_COMMAND_EXECUTION_TIME_FOREGROUND=$nord13

  # ============================================================================
  # Git (VCS)
  # ============================================================================
  # Nord teal (frost) for git info
  typeset -g POWERLEVEL9K_VCS_FOREGROUND=$nord7

  # Disable async loading indicator
  typeset -g POWERLEVEL9K_VCS_LOADING_TEXT=

  # Don't wait for Git status
  typeset -g POWERLEVEL9K_VCS_MAX_SYNC_LATENCY_SECONDS=0

  # Nord cyan (frost) for ahead/behind arrows.
  typeset -g POWERLEVEL9K_VCS_{INCOMING,OUTGOING}_CHANGESFORMAT_FOREGROUND=$nord8
  # Don't show remote branch, current tag or stashes.
  typeset -g POWERLEVEL9K_VCS_GIT_HOOKS=(vcs-detect-changes git-untracked git-aheadbehind)
  # Don't show the branch icon.
  typeset -g POWERLEVEL9K_VCS_BRANCH_ICON=
  # When in detached HEAD state, show @commit where branch normally goes.
  typeset -g POWERLEVEL9K_VCS_COMMIT_ICON='@'
  # Don't show staged, unstaged, untracked indicators.
  typeset -g POWERLEVEL9K_VCS_{STAGED,UNSTAGED,UNTRACKED}_ICON=
  # Show '*' when there are staged, unstaged or untracked files.
  typeset -g POWERLEVEL9K_VCS_DIRTY_ICON='*'
  # Show '⇣' if local branch is behind remote.
  typeset -g POWERLEVEL9K_VCS_INCOMING_CHANGES_ICON=':⇣'
  # Show '⇡' if local branch is ahead of remote.
  typeset -g POWERLEVEL9K_VCS_OUTGOING_CHANGES_ICON=':⇡'
  # Don't show the number of commits next to the ahead/behind arrows.
  typeset -g POWERLEVEL9K_VCS_{COMMITS_AHEAD,COMMITS_BEHIND}_MAX_NUM=1
  # Remove space between '⇣' and '⇡' and all trailing spaces.
  typeset -g POWERLEVEL9K_VCS_CONTENT_EXPANSION='${${${P9K_CONTENT/⇣* :⇡/⇣⇡}// }//:/ }'

  # Git status colors (Nord aurora)
  typeset -g POWERLEVEL9K_VCS_CLEAN_FOREGROUND=$nord14        # green - clean
  typeset -g POWERLEVEL9K_VCS_MODIFIED_FOREGROUND=$nord13     # yellow - modified
  typeset -g POWERLEVEL9K_VCS_UNTRACKED_FOREGROUND=$nord12    # orange - untracked

  # ============================================================================
  # Time
  # ============================================================================
  # Nord light grey (snow storm) for time
  typeset -g POWERLEVEL9K_TIME_FOREGROUND=$nord4
  # Format for the current time: 09:51:02 PM. See `man 3 strftime`.
  typeset -g POWERLEVEL9K_TIME_FORMAT='%D{%I:%M:%S %p}'
  typeset -g POWERLEVEL9K_TIME_UPDATE_ON_COMMAND=false

  # ============================================================================
  # Transient Prompt
  # ============================================================================
  typeset -g POWERLEVEL9K_TRANSIENT_PROMPT=always

  # ============================================================================
  # Instant Prompt
  # ============================================================================
  typeset -g POWERLEVEL9K_INSTANT_PROMPT=verbose

  # ============================================================================
  # Hot Reload (disabled for performance)
  # ============================================================================
  typeset -g POWERLEVEL9K_DISABLE_HOT_RELOAD=true

  # If p10k is already loaded, reload configuration.
  (( ! $+functions[p10k] )) || p10k reload
}

# Tell `p10k configure` which file it should overwrite.
typeset -g POWERLEVEL9K_CONFIG_FILE=${${(%):-%x}:a}

(( ${#p10k_config_opts} )) && setopt ${p10k_config_opts[@]}
'builtin' 'unset' 'p10k_config_opts'
