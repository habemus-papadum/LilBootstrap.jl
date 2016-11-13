__precompile__()
"""
Based off of keno/ReplExtensions, circa Nov 2016

Provides iterm2 detection, a iterm2 display which provides support for images,
prompt support
"""
module iTerm2
using PackagePrelude
using Compat

import Base: display
immutable InlineDisplay <: Display; end

import Base.Terminals: CSI

function readDCS(io::IO)
    # const DCS = "\eP"
    while nb_available(STDIN) >= 2
        c1 = read(io,UInt8)
        c1 == 0x90 && return true
        if c1 == UInt8('\e')
            read(io,UInt8) == UInt8('P') && return true
        end
    end
    return false
end
function readST(io::IO)
    # const ST  = "\e\\"
    c1 = read(io,UInt8)
    c1 == 0x90 && return true
    c1 != UInt8('\e') && return false
    read(io,UInt8) != UInt8('\\') && return false
    return true
end


## iterm2 escape sequences
"set a nvaigation marker"
function set_mark()
    "\033]50;SetMark\007"
end

"indicate execution output start"
function preexec()
    "\033]133;C\007"
end

function remotehost_and_currentdir()
    return string("\033]1337;RemoteHost=",ENV["USER"],"@",readstring(`hostname -f`),"\007","\033]1337;CurrentDir=",pwd(),"\007")
end

function prompt_prefix(last_success = true)
    return string("\033]133;D;$(convert(Int, last_success))\007",remotehost_and_currentdir(),"\033]133;A\007")
end

function prompt_suffix()
    return "\033]133;B\007"
end

function shell_version_number()
    return "\033]1337;ShellIntegrationVersion=1\007"
end


function prepare_display_file(;filename="Unnamed file", size=nothing, width=nothing, height=nothing, preserveAspectRation::Bool=true, inline::Bool=false)
    q = "\e]1337;File="
    options = String[]
    filename != "Unnamed file" && push!(options,"name=" * base64encode(filename))
    size !== nothing && push!(options,"size=" * dec(size))
    height !== nothing && push!(options,"height=" * height)
    width !== nothing && push!(options,"width=" * width)
    preserveAspectRation !== true && push!(options,"preserveAspectRation=0")
    inline !== false && push!(options,"inline=1")
    q *= join(options,';')
    q *= ":"
    write(STDOUT,q)
end

function display_file(data::Vector{UInt8}; kwargs...)
    prepare_display_file(;kwargs...)
    write(STDOUT,base64encode(data))
    write(STDOUT,'\a')
end

const iterm2_mimes = ["image/png", "image/gif", "image/jpeg", "application/pdf", "application/eps"]

for mime in iterm2_mimes
    @eval begin
        function display(d::InlineDisplay, m::MIME{Symbol($mime)}, x)
            println("displaying $(m)")
            prepare_display_file(;filename="image",inline=true)
            buf = IOBuffer()
            show(Base.Base64EncodePipe(buf),m,x)
            write(STDOUT, takebuf_array(buf))
            write(STDOUT,'\a')
        end
    end
end

function display(d::InlineDisplay,x)
    for m in iterm2_mimes
        if mimewritable(m,x)
            return display(d,m,x)
        end
    end
    throw(MethodError(display, (d,x)))
end



end # module
