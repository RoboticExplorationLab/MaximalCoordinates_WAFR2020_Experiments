using Rotations
using Plots: RGBA

!(@isdefined FullCordDynamics) && include(joinpath("..", "FullCordDynamics.jl"))
using Main.FullCordDynamics

# Parameters
ex = [1.;0.;0.]

l1 = 1.0
l2 = 1.0sqrt(2)/2
x,y = .1,.1
b1 = Box(x,y,l1,l1,color=RGBA(1.,1.,0.))
b2 = Box(x,y,l2,l2,color=RGBA(1.,1.,0.))
b3 = Box(x,y,l1,l1,color=RGBA(1.,0.,0.))
b4 = Box(x,y,l2,l2,color=RGBA(1.,0.,0.))

vert11 = [0.;0.;l1/2]
vert12 = -vert11

vert21 = [0.;0.;l2/2]
vert22 = -vert21

# Initial orientation
phi1, phi2, phi3, phi4 = pi/5, 0., 0., pi/5
q1, q2, q3, q4 = Quaternion(RotX(phi1)), Quaternion(RotX(phi2)), Quaternion(RotX(phi3)), Quaternion(RotX(phi4))

phi1, phi2, phi3, phi4 = -pi/5, pi/5, pi/5, -pi/5
q5, q6, q7, q8 = Quaternion(RotX(phi1)), Quaternion(RotX(phi2)), Quaternion(RotX(phi3)), Quaternion(RotX(phi4))

# Links
origin = Origin{Float64}()

link1 = Link(b1)
setInit!(origin,link1,zeros(3),vert11,q=q1)

link2 = Link(b2)
setInit!(link1,link2,vert12,vert21,q=q2)

link3 = Link(b3)
setInit!(link1,link3,vert11,vert11,q=q3)

link4 = Link(b4)
setInit!(link3,link4,vert12,vert21,q=q4)


link5 = Link(b1)
setInit!(link4,link5,zeros(3),vert11,q=q5)

link6 = Link(b2)
setInit!(link5,link6,vert12,vert21,q=q6)

link7 = Link(b3)
setInit!(link5,link7,vert11,vert11,q=q7)

link8 = Link(b4)
setInit!(link7,link8,vert12,vert21,q=q8)

# Constraints
joint0to1 = Constraint(Socket(origin,link1,zeros(3),vert11),Axis(origin,link1,ex))
joint1to23 = Constraint(Socket(link1,link2,vert12,vert21),Axis(link1,link2,ex),SocketYZ(link1,link3,vert11,vert11))
joint3to4 = Constraint(Socket(link3,link4,vert12,vert21),Axis(link3,link4,ex))
joint2to4 = Constraint(Socket(link2,link4,vert22,vert22),Axis(link2,link4,ex))

joint4to5 = Constraint(Socket(link4,link5,zeros(3),vert11),Axis(link4,link5,ex))
joint5to67 = Constraint(Socket(link5,link6,vert12,vert21),Axis(link5,link6,ex),SocketYZ(link5,link7,vert11,vert11))
joint7to8 = Constraint(Socket(link7,link8,vert12,vert21),Axis(link7,link8,ex))
joint6to8 = Constraint(Socket(link6,link8,vert22,vert22),Axis(link6,link8,ex))


links = [link1; link2; link3; link4; link5; link6; link7; link8]
constraints = [joint0to1; joint1to23; joint3to4; joint2to4; joint4to5;joint5to67;joint7to8;joint6to8]
shapes = [b1,b2,b3,b4]

bot = Robot(origin,links, constraints)

simulate!(bot,save=true)
FullCordDynamics.visualize(bot,shapes)
