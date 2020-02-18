abstract type Component{T} end

#TODO do id differently?
CURRENTID = -1
getGlobalID() = (global CURRENTID-=1; return CURRENTID+1)
resetGlobalID() = (global CURRENTID=-1; return)

Base.show(io::IO, component::Component) = summary(io, component)

@inline Base.foreach(f,itr::Vector{<:Component},arg...) = (for x in itr; f(x,arg...); end; return)
