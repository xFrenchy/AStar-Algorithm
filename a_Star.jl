struct Node
        # Every single entry in the 2D array will be considered a node

        # This is the node of our previous position before reaching our current position
        parent::Union{Node, Nothing}
        position::Tuple{Int, Int}

        # g is the cost of the movement from the our current position to a given point
        g::Int16
        # h is the cost of the movement from the our current position to the final destination
        h::Int16
        # f the sum of g and h
        f::Int16

        Node() = new(nothing,           # no parent(good set up to become a superhero)
                     (1,1),             # start at the top left corner for position in the grid
                     0,                 # g = 0
                     0,                 # h = 0
                     0)                 # f = 0

        Node(cord::Tuple{Int, Int}) = new(nothing,
                                          cord,
                                          0,
                                          0,
                                          0)
end

# Overriding Base isless so that it knows how to compare Node objects. Needed for sort!()
Base.isless(a::Node, b::Node) = isless(a.f, b.f)

function A_Star(grid::Array{Int}, startCord::Tuple{Int, Int}, endCord::Tuple{Int, Int})
        # Set up vars
        open_list = Array{Node}(undef, 0)
        closed_list = Array{Node}(undef, 0)
        starting_node = Node(startCord)
        ending_node = Node(endCord)
        dimension = size(grid)
        length = dimension[1]
        width = dimension[2]

        push!(open_list, starting_node)

        while !isempty(open_list)
                # There are nodes and paths to evaluate, we have to pick the one with the lowest f cost
                sort!(open_list)
                current_node = popfirst!(open_list)
                push!(closed_list, current_node)

                # Let's check if our current node is the end node
                if current_node.position == ending_node.position
                        path = Array{Node}(undef, 0)
                        while current_node.parent != nothing
                                append!(path, current_node)
                                current_node = current_node.parent
                        end # end of while backtracking through path
                        # Path is currently from end->start, let's reverse that
                        reverse!(path)
                        return path
                end # end of if current node is the end goal

                # Let's explore by trying to get in all 4 directions (Up/Down/Left/Right)
                new_nodes = Array{Node}(undef, 0)
                new_nodes = MoveThroughGrid(current_node.position, length, width)


        end # end of while open_list is not empty
        return nothing
end # end of A_Star function

function MoveThroughGrid(current_position::Node, length::Int, width::Int)
        # We have to stay in bounds, that means our indices cannot be < 1 and cannot be > length
        for directions in [(-1,0), (1,0), (0,-1), (0,1)]
                # first index goes up and down, second index goes left and right
                new_position = (current_position[1] + directions[1], current_position[2] + directions[2])
                if new_position[1] < 1 || new_position[1] > length
        end
        return nothing
end

function main()
        println(raw"""
                      _
                   /\| |/\
              __   \ ` ' /
             /""\ |_     _|
            /    \ / , . \
           /' /\  \\/|_|\/
          //  __'  \
         /   /  \\  \
        (___/    \___)
        Welcome to the A* algorithm in Julia made by Anthony Dupont
        """)

        # TODO:
        #       -Place obstacles in this grid to alter the pathing
        #       -Randomly generate these alters
        #       -Place the ending goal somewhere else than just bottom right of the grid
        #       -Make the grid size dependent on the user input, or random
        traversalGrid = zeros(Int, 5, 7)
        println("Here is your current grid that A* will:")
        # TODO:
        #       -Display clearly where the starting goal is and where the ending goal is
        display(traversalGrid)

        # Applying A* algorithm to find the shortest path
        path = A_Star(traversalGrid, (1,1), (5,5))
end

main()
