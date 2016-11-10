__precompile__()
"""Customize REPL to support my preferences subject to the constraints
and capabilities of the underlying tty
"""
module REPLSparkle
using iTerm2


##cleanup, make more modular
##todo support configuration
##todo: error indications look incorrent
function configure_REPL()
  if !(isinteractive() && isdefined(Base, :active_repl))
      return
  end
  begin
      term = Base.Terminals.TTYTerminal("xterm",STDIN,STDOUT,STDERR)
      Base.Terminals.raw!(term,true)
      Base.start_reading(STDIN)

      # Detect iTerm support
      println("\e[1337n\e[5n")
      readuntil(STDIN, "\e")
      itermname = ""
      if read(STDIN, Char) != '0'
          itermname = readuntil(STDIN, "\e")[1:end-2]
      end
      # Read the rest of the \e[5n query
      read(STDIN, 3)

      if startswith(itermname, "ITERM2")
          pushdisplay(iTerm2.InlineDisplay())
          repl = Base.active_repl#REPL.LineEditREPL(Terminals.TTYTerminal("xterm",STDIN,STDOUT,STDERR))

          if !isdefined(repl,:interface)
              repl.interface = Base.REPL.setup_interface(repl)
          end

          let waserror = false
              prefix = repl.interface.modes[1].prompt_prefix
              repl.interface.modes[1].prompt_prefix = function ()
                  (iTerm2.prompt_prefix(waserror) * (isa(prefix,Function) ? prefix() : prefix))
              end
              suffix = repl.interface.modes[1].prompt_suffix
              repl.interface.modes[1].prompt_suffix = function ()
                  ((isa(suffix,Function) ? suffix() : suffix) * iTerm2.prompt_suffix())
              end
              for mode in repl.interface.modes
                  if isdefined(mode,:on_done)
                      of = mode.on_done
                      mode.on_done = function (args...)
                          print(STDOUT,iTerm2.preexec())
                          of(args...)
                          waserror = repl.waserror
                      end
                  end
              end
          end
      end
  end
end



end
