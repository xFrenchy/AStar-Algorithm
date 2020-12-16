const blocking_terrain = 1

mutable struct Node
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
        """Function that traverses the grid using the A* algorithm and returns the
        path to the end goal, if such a path exists. Otherwise it returns nothing"""

        # Set up vars
        open_list = Array{Node}(undef, 0)
        closed_list = Array{Node}(undef, 0)
        starting_node = Node(startCord)
        dimension = size(grid)
        length = dimension[1]
        width = dimension[2]

        push!(open_list, starting_node)

        while !isempty(open_list)
                # There are nodes and paths to evaluate, we have to pick the one with the lowest f cost
                sort!(open_list)
                current_node = popfirst!(open_list)

                # Let's explore by trying to get in all 4 directions (Up/Down/Left/Right)
                new_node = Array{Node}(undef, 0)
                new_node = MoveThroughGrid(grid, current_node, length, width, endCord)

                for node in new_node
                        # Let's check if our node has reached the goal
                        if node.position == endCord
                                path = Array{Node}(undef, 0)
                                current_node = node
                                while current_node != nothing
                                        push!(path, current_node)
                                        current_node = current_node.parent
                                end # end of while backtracking through path
                                # Path is currently from end->start, let's reverse that
                                reverse!(path)
                                return path
                        end # end of if current node is the end goal

                        # check if this node is already in the open list and only add if it's more effecient
                        if CheckToAddOpen(node, open_list)
                                # Check to see if it is in the closed list and only add if it's more effecient
                                if CheckToAddClose(node, closed_list)
                                        push!(open_list, node)
                                end # end of checking if node is in closed list
                        end # end of checking if node is in open list
                end # end of iterating through nodes in the new valid nodes generated

                push!(closed_list, current_node)

        end # end of while open_list is not empty
        return nothing
end # end of A_Star function


function MoveThroughGrid(grid::Array{Int}, current_node::Node, length::Int, width::Int, endCord::Tuple{Int, Int})
        """Function that generates new nodes by applying directions to our current position
        This function also calculates the heuristics of these new generated nodes"""
        # We have to stay in bounds, that means our indices cannot be < 1 and cannot be > length
        valid_nodes = Array{Node}(undef, 0)
        for directions in [(-1,0), (1,0), (0,-1), (0,1)]
                # first index goes up and down, second index goes left and right
                new_position = (current_node.position[1] + directions[1], current_node.position[2] + directions[2])
                # Check that it's in bound
                if new_position[1] >= 1 && new_position[1] <= length && new_position[2] >= 1 && new_position[2] <= width && grid[new_position[1], new_position[2]] != blocking_terrain
                        # This part is where we need a good heuristic. Using Manhattan Distance for this
                        temp_node = Node(new_position)
                        temp_node.g = current_node.g + 1
                        temp_node.h = abs(new_position[1] - endCord[1]) + abs(new_position[2] - endCord[2])
                        temp_node.f = temp_node.g + temp_node.h
                        temp_node.parent = current_node
                        push!(valid_nodes, temp_node)
                end
        end
        return valid_nodes
end


function CheckToAddOpen(current_node::Node, open::Array{Node})
        """Function checks to see if this current node already exists in the open list
        and checks to see if it's a less effecient path than what's currently in the open list
        If the node is less effecient, it returns false, otherwise it returns true"""

        for node in open
                if current_node.position == node.position && current_node.f >= node.f
                        return false
                end
        end
        return true
end


function CheckToAddClose(current_node::Node, close::Array{Node})
        """Function checks to see if this current node already exists in the open list
        and checks to see if it's a less effecient path than what's currently in the open list
        If the node is less effecient, it returns false, otherwise it returns true"""

        for node in close
                if current_node.position == node.position && current_node.f >= node.f
                        return false
                end
        end
        return true
end


function displayPath(path::Array{Node}, length::Int)
        for i = 1:length
                if i == length
                        print(path[i].position)
                else
                        print(path[i].position, "->")
                end
                if i % 5 == 0
                        println()
                end
        end
        println()
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
        traversalGrid[5,6] = blocking_terrain
        traversalGrid[4,6] = blocking_terrain
        traversalGrid[3,6] = blocking_terrain
        traversalGrid[1,6] = blocking_terrain
        println("Here is your current grid that A* will go through:")
        # TODO:
        #       -Display clearly where the starting goal is and where the ending goal is
        display(traversalGrid)

        # Applying A* algorithm to find the shortest path
        path = A_Star(traversalGrid, (1,1), (5,7))
        length = size(path)
        displayPath(path, length[1])
        # we subtract 1 from the length to display the amount of edges instead of amount of nodes
        println("Length of path: ",length[1]-1)
end
#Juno.@enter main()     # <--- Enter debugger
@time main()
