using Rotations
using Plots: RGBA
using BenchmarkTools

!(@isdefined FullCordDynamics) && include(joinpath("..", "FullCordDynamics.jl"))
using Main.FullCordDynamics

# Parameters
ex = [1.;0.;0.]

l1 = 1.0
l2 = 1.0#sqrt(2)/2
x,y = .1,.1
b1 = Box(x,y,l1,l1,color=RGBA(0.,0.,1.))
b2 = Box(x,y,l2,l2,color=RGBA(0.,0.,1.))
b3 = Box(x,y,l1,l1,color=RGBA(0.,0.,1))
b4 = Box(x,y,l2,l2,color=RGBA(0.,0.,1))

vert11 = [0.;0.;l1/2]
vert12 = -vert11

vert21 = [0.;0.;l2/2]
vert22 = -vert21

# Initial orientation
offset = pi/4
phi1, phi2, phi3, phi4 = pi/8+offset,-pi/8+offset,-pi/8+offset,pi/8+offset#pi/4, -pi/2, -pi/4, pi/2
q1, q2, q3, q4 = Quaternion(RotX(phi1)), Quaternion(RotX(phi2)), Quaternion(RotX(phi3)), Quaternion(RotX(phi4))

offset = pi/2
phi1, phi2, phi3, phi4 = pi/8+offset,-pi/8+offset,-pi/8+offset,pi/8+offset#pi/2, -pi/4, 0., 3*pi/4
q5, q6, q7, q8 = Quaternion(RotX(phi1)), Quaternion(RotX(phi2)), Quaternion(RotX(phi3)), Quaternion(RotX(phi4))

N = 3

# Links
origin = Origin{Float64}()

link1 = Link(b1)
link2 = Link(b2)
link3 = Link(b3)
link4 = Link(b4)
if N>1
    setInit!(origin,link1,zeros(3),vert11,q=q1)
    setInit!(link1,link2,vert12,vert21,q=q2)
    setInit!(link1,link3,vert11,vert11,q=q3)
    setInit!(link3,link4,vert12,vert21,q=q4)
else
    setInit!(origin,link1,zeros(3),vert11,q=q5)
    setInit!(link1,link2,vert12,vert21,q=q6)
    setInit!(link1,link3,vert11,vert11,q=q7)
    setInit!(link3,link4,vert12,vert21,q=q8)
end

links = [link1;link2;link3;link4]

for i=2:N-1
    @eval begin
        $(Symbol("link",(i-1)*4+1)) = Link(b1)
        setInit!($links[($i-1)*4],$(Symbol("link",(i-1)*4+1)),vert22,vert11,q=q1)
        push!($links,$(Symbol("link",(i-1)*4+1)))

        $(Symbol("link",(i-1)*4+2)) = Link(b2)
        setInit!($(Symbol("link",(i-1)*4+1)),$(Symbol("link",(i-1)*4+2)),vert12,vert21,q=q2)
        push!($links,$(Symbol("link",(i-1)*4+2)))

        $(Symbol("link",(i-1)*4+3)) = Link(b3)
        setInit!($(Symbol("link",(i-1)*4+1)),$(Symbol("link",(i-1)*4+3)),vert11,vert11,q=q3)
        push!($links,$(Symbol("link",(i-1)*4+3)))

        $(Symbol("link",(i-1)*4+4)) = Link(b4)
        setInit!($(Symbol("link",(i-1)*4+3)),$(Symbol("link",(i-1)*4+4)),vert12,vert21,q=q4)
        push!($links,$(Symbol("link",(i-1)*4+4)))
    end
end

if N>1
    for i=N
        @eval begin
            $(Symbol("link",(i-1)*4+1)) = Link(b1)
            setInit!($links[($i-1)*4],$(Symbol("link",(i-1)*4+1)),vert22,vert11,q=q5)
            push!($links,$(Symbol("link",(i-1)*4+1)))

            $(Symbol("link",(i-1)*4+2)) = Link(b2)
            setInit!($(Symbol("link",(i-1)*4+1)),$(Symbol("link",(i-1)*4+2)),vert12,vert21,q=q6)
            push!($links,$(Symbol("link",(i-1)*4+2)))

            $(Symbol("link",(i-1)*4+3)) = Link(b3)
            setInit!($(Symbol("link",(i-1)*4+1)),$(Symbol("link",(i-1)*4+3)),vert11,vert11,q=q7)
            push!($links,$(Symbol("link",(i-1)*4+3)))

            $(Symbol("link",(i-1)*4+4)) = Link(b4)
            setInit!($(Symbol("link",(i-1)*4+3)),$(Symbol("link",(i-1)*4+4)),vert12,vert21,q=q8)
            push!($links,$(Symbol("link",(i-1)*4+4)))
        end
    end
end

# Constraints
joint0to1 = Constraint(Socket(origin,link1,zeros(3),vert11),Axis(origin,link1,ex))
joint1to23 = Constraint(Socket(link1,link2,vert12,vert21),Axis(link1,link2,ex),SocketYZ(link1,link3,vert11,vert11))
joint3to4 = Constraint(Socket(link3,link4,vert12,vert21),Axis(link3,link4,ex))
joint2to4 = Constraint(Socket(link2,link4,vert22,vert22),Axis(link2,link4,ex))

constraints = [joint0to1; joint1to23; joint3to4; joint2to4]

for i=2:N
    @eval begin
        $(Symbol("joint",(i-1)*4,"to",(i-1)*4+1)) = Constraint(Socket($links[($i-1)*4],$links[($i-1)*4+1],vert22,vert11),Axis($links[($i-1)*4],$links[($i-1)*4+1],ex))
        push!($constraints,$(Symbol("joint",(i-1)*4,"to",(i-1)*4+1)))

        $(Symbol("joint",(i-1)*4+1,"to",(i-1)*4+2,(i-1)*4+3)) = Constraint(Socket($links[($i-1)*4+1],$links[($i-1)*4+2],vert12,vert21),Axis($links[($i-1)*4+1],$links[($i-1)*4+2],ex),SocketYZ($links[($i-1)*4+1],$links[($i-1)*4+3],vert11,vert11))
        push!($constraints,$(Symbol("joint",(i-1)*4+1,"to",(i-1)*4+2,(i-1)*4+3)))

        $(Symbol("joint",(i-1)*4+3,"to",(i-1)*4+4)) = Constraint(Socket($links[($i-1)*4+3],$links[($i-1)*4+4],vert12,vert21),Axis($links[($i-1)*4+3],$links[($i-1)*4+4],ex))
        push!($constraints,$(Symbol("joint",(i-1)*4+3,"to",(i-1)*4+4)))

        $(Symbol("joint",(i-1)*4+2,"to",(i-1)*4+4)) = Constraint(Socket($links[($i-1)*4+2],$links[($i-1)*4+4],vert22,vert22),Axis($links[($i-1)*4+2],$links[($i-1)*4+4],ex))
        push!($constraints,$(Symbol("joint",(i-1)*4+2,"to",(i-1)*4+4)))
    end
end

shapes = [b1,b2,b3,b4]

bot = Robot(origin,links, constraints)



simulate!(bot,save=true)
FullCordDynamics.visualize(bot,shapes)
