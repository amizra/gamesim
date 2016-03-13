# need to redefine mod to behave correctly with negative numbers
mod = (n, m) ->
	return ((n % m) + m) % m

Strategy =
	cooperate: 0
	defect: 1

class Player
	@strategy = Strategy.cooperate
	@mostRecentScore = -1
	@grid = null
	@i = -1
	@j = -1

	constructor: (grid, i, j, strategy) ->
		@grid = grid
		@i = i
		@j = j
		@strategy = strategy

	# Plays a one-shot Prisoner's Dilemma game.
	# Payoff matrix (C=cooperate, D=defect):
	#
	# 		C 		D
	#	C 	3	|	1
	#	D 	4	|	2
	#
	playAgainst: (neighbor) ->
		payoffMatrix = [[3, 1], [4, 2]]
		return payoffMatrix[@strategy][neighbor.strategy]

	# Returns a list of the 8 Moore neighbors surrounding the player
	getNeighbors: () ->
		return [@grid.get(@i-1, @j-1), @grid.get(@i-1, @j), @grid.get(@i-1, @j+1),
				@grid.get(@i, @j-1), 	@grid.get(@i, @j+1),
				@grid.get(@i+1, @j-1), @grid.get(@i+1, @j), @grid.get(@i+1, @j+1)]

class GameGrid
	@n = 0
	@players = []

	# Creates an nxn grid of players.
	constructor: (n) ->
		@players = []
		@n = n
		for i in [0..@n-1]
			for j in [0..@n-1]
				@players.push(@randomPlayer(i, j))

	# Gets the player in cell (i, j)
	# The game grid is a torus, meaning that the rightmost cells are neighbors with the leftmost cells
	# and the top cells are neighbors with the bottom cells (the game grid "wraps around").
	get: (i, j) ->
		return @players[@n*(mod(i, @n)) + mod(j, @n)]

	# Generates a player at cell (i, j) in the grid with a randomly chosen strategy.
	randomPlayer: (i, j) ->
		r = Math.random()
		strategy = Strategy.cooperate
		if r > 0.5
			strategy = Strategy.defect
		return new Player(@, i, j, strategy)

	# Runs a single iteration of the Prisoner's Dilemma simulation.
	iterate: () ->
		# For each player, play Prisoner's Dilemma with everyone in its Moore neighborhood.
		for player in @players
			player.mostRecentScore = 0
			for neighbor in player.getNeighbors()
				player.mostRecentScore += player.playAgainst(neighbor)

		# Check each player to see if it is the lowest scoring player in its neighborhood.
		# If so, switch player's strategy to that of its highest-scoring neighbor.
		for player in @players
			isLowest = true
			for neighbor in player.getNeighbors()
				if neighbor.mostRecentScore < player.mostRecentScore
					isLowest = false
			if isLowest
				# Get the neighbor with the highest score
				highestNeighborScore = 0
				highestScoringNeighbor = null
				for neighbor in player.getNeighbors()
					if neighbor.mostRecentScore > highestNeighborScore
						highestScoringNeighbor = neighbor
						highestNeighborScore = neighbor.score
				# Set the strategy to the highest scoring neighbor's strategy
				player.strategy = highestScoringNeighbor.strategy

	# Runs k iterations of the simulation.
	simulate: (k) ->
		for i in [0..k]
			@iterate()

printAscii = (grid) ->
	for i in [0..grid.n-1]
		rep = ""
		for j in [0..grid.n-1]
			rep += grid.get(i, j).strategy.toString()
		console.log(rep)
	console.log("\n")

g = new GameGrid(50)
k = 500
for i in [0..k]
	g.iterate()
	printAscii(g)