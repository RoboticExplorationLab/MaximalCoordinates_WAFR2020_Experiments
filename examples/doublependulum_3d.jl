using Rotations
using Plots: RGBA

!(@isdefined FullCordDynamics) && include(joinpath("..", "FullCordDynamics.jl"))
using Main.FullCordDynamics

# Parameters
ex = [1.;0.;0.]

l1 = 1.0
l2 = sqrt(2)/2
x,y = .1,.1
b1 = Box(x,y,l1,l1,color=RGBA(1.,1.,0.))
b2 = Box(x,y,l2,l2,color=RGBA(1.,1.,0.))

vert11 = [0.;0.;l1/2]
vert12 = -vert11

vert21 = [0.;0.;l2/2]

# Initial orientation
phi1, phi2 = pi/4, 0.
q1, q2 = Quaternion(RotX(phi1)), Quaternion(RotX(phi2))

# Links
origin = Origin{Float64}()

link1 = Link(b1)
setInit!(origin,link1,zeros(3),vert11,q=q1)

link2 = Link(b2)
setInit!(link1,link2,vert12,vert21,q=q2,τ=[0.;0.2;0.])

# Constraints
socket0to1 = Constraint(Socket(origin,link1,zeros(3),vert11))
socket1to2 = Constraint(Socket(link1,link2,vert12,vert21))

links = [link1;link2]
constraints = [socket0to1;socket1to2]
shapes = [b1,b2]


bot = Robot(origin,links, constraints)

simulate!(bot,save=true)
FullCordDynamics.visualize(bot,shapes)
