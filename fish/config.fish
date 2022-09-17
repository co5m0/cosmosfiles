
if status is-interactive
    # Commands to run in interactive sessions can go here
    set -g EDITOR nvim
    set -g BROWSER google-chrome-stable
    set -g QT_PLUGIN_PATH /usr/lib/qt/plugins 
    set -g QT_QPA_PLATFORM xcb
    set -gx FZF_DEFAULT_COMMAND  'rg --files --no-ignore-vcs --hidden'
    set -gx LIBVA_DRIVER_NAME nouveau
    set -g WEBKIT_DISABLE_COMPOSITING_MODE 1
    
    alias public-ip 'curl icanhazip.com'
    alias open-ports 'netstat --all --numeric --tcp --programs'usr
    alias code '/usr/bin/code'
    alias reset-audio 'systemctl --user restart pipewire pipewire-pulse'

    # Enable VI keybinding
    fish_vi_key_bindings

    function kp --description "Kill processes"
      set -l __kp__pid (ps -ef | sed 1d | eval "fzf $FZF_DEFAULT_OPTS -m --header='[kill:process]'" | awk '{print $2}')
      set -l __kp__kc $argv[1]

      if test "x$__kp__pid" != "x"
        if test "x$argv[1]" != "x"
          echo $__kp__pid | xargs kill $argv[1]
        else
          echo $__kp__pid | xargs kill -9
        end
        kp
      end
    end


    function extract2 --description "Expand or extract bundled & compressed files"
      set --local ext (echo $argv[1] | awk -F. '{print $NF}')
      switch $ext
        case tar  # non-compressed, just bundled
          tar -xvf $argv[1]
        case gz
          if test (echo $argv[1] | awk -F. '{print $(NF-1)}') = tar  # tar bundle compressed with gzip
            tar -zxvf $argv[1]
          else  # single gzip
            gunzip $argv[1]
          end
        case tgz  # same as tar.gz
          tar -zxvf $argv[1]
        case bz2  # tar compressed with bzip2
          tar -jxvf $argv[1]
        case rar
          unrar x $argv[1]
        case zip
          unzip $argv[1]
        case '*'
          echo "unknown extension"
      end
    end

    # Usage: copy <file>

    function copy --description "Copy the contents of a text file or variable to your clipboard"
      set --local argc (count $argv)
      if test $argc -eq 1
        switch (uname)
          case 'Linux'
            if test -e $argv[1]
              xclip -selection clip < $argv[1]
            else
              printf $argv[1] | xclip -selection clip
            end
          case 'Darwin'
            if test -e $argv[1]
              pbcopy < $argv[1]
            else
              printf $argv[1] | pbcopy
            end
        end
      else
        echo "Well this is embarrassing... I can only copy one file at a time."
      end
    end


    function extract --description "Expand or extract bundled & compressed files"
      for file in $argv
        if test -f $file
          echo -s "Extracting " (set_color --bold blue) $file (set_color normal)
          switch $file
            case "*.tar"
              tar -xvf $file
            case "*.tar.bz2" "*.tbz2"
              tar --bzip2 -xvf $file
            case "*.tar.gz" "*.tgz"
              tar --gzip -xvf $file
            case "*.bz" "*.bz2"
              bunzip2 $file
            case "*.gz"
              gunzip $file
            case "*.rar"
              unrar x $file
            case "*.zip"
              unzip -uo $file -d (basename $file .zip)
            case "*.Z"
              uncompress $file
            case "*.pax"
              pax -r < $file
            case '*'
              echo "Extension not recognized, cannot extract $file"
          end
        else
          echo "$file is not a valid file"
        end
      end
    end

    # Example usage:
    # lsd
    # lsd foo
    # lsd foo/ bar/

    function lsd --description "List all directories under CWD or given paths in a single column"
      set --local argc (count $argv)
      if test $argc -gt 0  # Print dirs under all given paths.
        for dir in $argv
          if test -d $dir
            ls -1d $dir/*/ # | cut -f2
          else
            echo "$dir is not a valid directory"
          end
        end
      else  # Print dirs under CWD.
        ls -1d */ # | cut -f1
      end
    end

    function dirdiff --description "Print the diff output between 2 directories"
      set --local argc (count $argv)
      if test $argc -eq 2  # Print dirs under all given paths.
        diff (tree -a $argv[1] | psub) (tree -a $argv[2] | psub)
      else  # Print dirs under CWD.
          tree -a $argv[1]
      end
    end

    function hfz --description "Fuzzy finding command in history and execute it"
      history | fzf | sh
    end

#FINISH
end
