#=
#define FMPR_RND_DOWN  0    RoundingMode{:Down}()
#define FMPR_RND_UP    1
#define FMPR_RND_FLOOR 2
#define FMPR_RND_CEIL  3
#define FMPR_RND_NEAR  4
=#

function round{P}(x::ArbFloat{P}, sig::Int=P, base::Int=10)
    sig=abs(sig); base=abs(base)
    sigbits = min(P, ceil(Int, (sig * log(base)/log(2.0))))
    z = initializer(ArbFloat{P})
    ccall(@libarb(arb_set_round), Void,  (Ptr{ArbFloat}, Ptr{ArbFloat}, Int), &z, &x, sigbits)
    return z
end

function ceil{P}(x::ArbFloat{P}, sig::Int=P, base::Int=10)
    sig=abs(sig); base=abs(base)
    sigbits = min(P, ceil(Int, (sig * log(base)/log(2.0))))
    z = initializer(ArbFloat{P})
    ccall(@libarb(arb_ceil), Void,  (Ptr{ArbFloat}, Ptr{ArbFloat}, Int), &z, &x, sigbits)
    return z
end

function floor{P}(x::ArbFloat{P}, sig::Int=P, base::Int=10)
    sig=abs(sig); base=abs(base)
    sigbits = min(P, ceil(Int, (sig * log(base)/log(2.0))))
    z = initializer(ArbFloat{P})
    ccall(@libarb(arb_floor), Void,  (Ptr{ArbFloat}, Ptr{ArbFloat}, Int), &z, &x, sigbits)
    return z
end

function trunc{P}(x::ArbFloat{P}, sig::Int=P, base::Int=10)
    sig=abs(sig); base=abs(base)
    sigbits = min(P, ceil(Int, (sig * log(base)/log(2.0))))
    z = initializer(ArbFloat{P})
    cop = signbit(x) ? @libarb(arb_ceil) : @libarb(arb_floor)
    ccall(cop, Void,  (Ptr{ArbFloat}, Ptr{ArbFloat}, Int), &z, &y, sigbits)
    return z
end

for T in (:Int16, :Int32, :Int64, :Int128,
          :UInt16, :UInt32, :UInt64, :UInt128)
  @eval begin
    function round{P}(::Type{$T}, x::ArbFloat{P}, sig::Int=P, base::Int=10)
        z = round(x, sig, base)
        return convert(($T), z)
    end
    function ceil{P}(::Type{$T}, x::ArbFloat{P}, sig::Int=P, base::Int=10)
        z = ceil(x, sig, base)
        return convert(($T), z)
    end
    function floor{P}(::Type{$T}, x::ArbFloat{P}, sig::Int=P, base::Int=10)
        z = floor(x, sig, base)
        return convert(($T), z)
    end
    function trunc{P}(::Type{$T}, x::ArbFloat{P}, sig::Int=P, base::Int=10)
        z = trunc(x, sig, base)
        return convert(($T), z)
    end
  end
end


fld{P}(x::ArbFloat{P}, y::ArbFloat{P}) = convert(Int, floor(x/y))
cld{P}(x::ArbFloat{P}, y::ArbFloat{P}) = convert(Int, ceil(x/y))
div{P}(x::ArbFloat{P}, y::ArbFloat{P}) = convert(Int, trunc(x/y))

rem{P}(x::ArbFloat{P}, y::ArbFloat{P}) = convert(Int, x - div(x,y)*y)
mod{P}(x::ArbFloat{P}, y::ArbFloat{P}) = convert(Int, x - fld(x,y)*y)

function divrem{P}(x::ArbFloat{P}, y::ArbFloat{P})
   dv = div(x,y)
   r  = x - d*y
   rm = convert(Int, r)
   return dv,rm
end

function fldmod{P}(x::ArbFloat{P}, y::ArbFloat{P})
   fd = fld(x,y)
   m  = x - d*y
   md = convert(Int, m)
   return fd,md
end

