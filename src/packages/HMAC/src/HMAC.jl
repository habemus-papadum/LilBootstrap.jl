##  __precompile__()

module HMAC

using PackagePrelude: ensure_fork, ⇶
#[  (:SHA,       "master")] ⇶ ensure_fork
using SHA



##lifted from Nettle.jl, support only sha256
type HMACState
    outer::Array{UInt8,1}
    inner::Array{UInt8,1}
    state::SHA.SHA2_256_CTX
end



# Constructor for HMACState # support only sha256
function HMACState(key_in)
    key = convert(Array{UInt8,1}, key_in)
    hash_type = SHA.SHA2_256_CTX
    outer = Array(UInt8, SHA.blocklen(SHA2_256_CTX))
    inner = Array(UInt8, SHA.blocklen(SHA2_256_CTX))
    state = SHA.SHA2_256_CTX()

    #digest key if longer then blocklen
    if length(key) > SHA.blocklen(SHA2_256_CTX)
      key = SHA.sha2_256(key)
    else # pad if necessary
      for i=(length(key)+1):SHA.blocklen(SHA2_256_CTX)
        push!(key,0)
      end
    end

    const inner_pad = UInt8(0x36)
    const outer_pad = UInt8(0x5C)
    fill!(inner, inner_pad)
    fill!(outer, outer_pad)
    for i=1:length(key)
      inner[i] $= key[i]
      outer[i] $= key[i]
    end

    return HMACState(outer, inner, state)
end

#how to save memory
function update!(state::HMACState, data_in)
    data = convert(Array{UInt8,1}, data_in)
    SHA.reset!(state.state)
    SHA.update!(state.state, state.inner)
    SHA.update!(state.state, data)

    #make this inplace
    d = SHA.digest!(state.state)
    SHA.reset!(state.state)


    SHA.update!(state.state, state.outer)
    SHA.update!(state.state, d)
    return state
end

function digest!(state::HMACState)
  SHA.digest!(state.state)
end

# Take a digest, and convert it to a printable hex representation
hexdigest!(state::HMACState) = bytes2hex(digest!(state))

# The one-shot functions that makes this whole thing so easy
digest(key, data) = digest!(update!(HMACState(key), data))
hexdigest(key, data) = hexdigest!(update!(HMACState(key), data))

show(io::IO, x::HMACState) = write(io, "$(x.hash_type.name) HMAC state")

end  # module
