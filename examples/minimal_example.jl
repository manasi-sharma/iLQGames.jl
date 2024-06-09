using iLQGames
import iLQGames: dx

# parametes: number of states, number of inputs, sampling time, horizon
nx, nu, ΔT, game_horizon = 4, 2, 0.1, 200

# setup the dynamics
struct Unicycle <: ControlSystem{ΔT,nx,nu} end
# state: (px, py, phi, v)
dx(cs::Unicycle, x, u, t) = SVector(x[4]cos(x[3]), x[4]sin(x[3]), u[1], u[2])
dynamics = Unicycle()
xyindex(::Unicycle) = SVector(1, 2)

# player-1 wants the unicycle to stay close to the origin,
# player-2 wants to keep close to 1 m/s
costs = (FunctionPlayerCost((g, x, u, t) -> (x[1]^2 + x[2]^2 + u[1]^2)),
         FunctionPlayerCost((g, x, u, t) -> ((x[4] - 1)^2 + u[2]^2)))

# indices of inputs that each player controls
player_inputs = (SVector(1), SVector(2))
# the horizon of the game
g = GeneralGame(game_horizon, player_inputs, dynamics, costs)

# get a solver, choose initial conditions and solve (in about 9 ms with AD)
solver = iLQSolver(g)
x0 = SVector(1, 1, 0, 0.5)
converged, trajectory, strategies = solve(g, solver, x0)

# animate the resulting trajectory. Use the `plot_traj` call without @animated to
# get a static plot instead.

# for visualization, we need to state which state indices correspond to px and py
position_indices = tuple(SVector(1,2))
#plot_traj(trajectory, position_indices, [:red, :green], player_inputs)
@animated(plot_traj(trajectory, g, [:red, :green], player_inputs),
          1:game_horizon, "C:\\Users\\MA32631\\OneDrive - MIT Lincoln Laboratory\\Documents\\EDGES\\minimal_example.gif")