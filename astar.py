'''
Suppose we have a rectangular grid that has height h and width w.
So the bottom corner is (0,0), top left is (0, h),
top right is (w, h), and bottom right is (w, 0).

Each node of the graph is connected to the other side 
like pacman. Design A-star algorithm for this structure.
'''

from ast import literal_eval


class NodeNotFoundError(Exception):
    pass


class Node(object):
    def __init__(self, x, y):
        self.x = x
        self.y = y
        self.neighbors = []  # references to all neighbors nodes
        self.walkable = True

    def connect(self, node_list):
        for node in node_list:
            self.neighbors.append(node)

    def __repr__(self):
        return "({},{})".format(self.x, self.y)

    def get_name(self):
        return str(self.__str__())


class Graph(object):
    def __init__(self, width, height):
        self.nodes = []
        self.width = width
        self.height = height
        self.initialize()
        self.connect_nodes()

    def initialize(self):
        for x in range(0, self.width):
            for y in range(0, self.height):
                self.nodes.append(Node(x, y))

    def connect_nodes(self):
        '''
        Each node should be connected to 4 nodes
        which are adjacent to it. If the node is "negative"
        connect to the other side of the grid like pacman.
        '''
        for node in self.nodes:
            up_node = self.get_node(node.x, node.y + 1)
            right_node = self.get_node(node.x + 1, node.y)
            left_node = self.get_node(node.x - 1, node.y)
            down_node = self.get_node(node.x, node.y - 1)
            # filter on is walkable
            node.connect([up_node, right_node, left_node, down_node])

    def get_node(self, x, y):
        # should we just put nodes into an array of array? we can index faster
        ''' get a node given its coordinates. '''
        x = x % self.width   # if negative x, wrap around to greatest x
        y = y % self.height  # if negative y, wrap around to greatest y
        for node in self.nodes:
            if node.x == x and node.y == y:
                return node
        raise NodeNotFoundError("Node not found {}, {}", format(x, y))

    def get_node_by_name(self, node_name):
        (x, y) = literal_eval(node_name)
        return self.get_node(x, y)

    def get_neighbors(self, node_name):
        node = self.get_node_by_name(node_name)
        return [neighbor.get_name() for neighbor in node.neighbors]

    def dist_between(self, node_name1, node_name2):
        # total distance in width and height
        a = self.get_node_by_name(node_name1)
        b = self.get_node_by_name(node_name2)
        return abs(a.x - b.x) + abs(a.y - b.y)

    def heuristic_cost_estimate(self, current, goal):
        # distance formula for direct path
        a = self.get_node_by_name(current)
        b = self.get_node_by_name(goal)
        return (a.x - b.x)**2 + (a.y - b.y)**2

    def print_nodes(self):
        for node in self.nodes:
            print "{} Connected: {}".format(node, node.connected)


class AStar(object):
    '''
    A star algorithm with help from wikipedia.

    graph - Graph object that contains our nodes with neighbors
    start - name (str) of a node that we are starting at
    goal - name (str) of the node that we want to reach

    WARNING: nodes used in this algorithms are names/references to nodes
    in the graph. They are not the same data type
    '''

    def __init__(self, graph, start, goal):
        # we refer to each node by it's string name. We use
        # this immutable structure to easily deal with lists and dictionaries
        # to get the node, we ask the graph using graph.get_node_by_name()
        self.graph = graph
        self.start = start
        self.goal = goal
        self.closed_set = []  # the set of nodes already evaluated
        self.open_set = [start]  # the set of tentative nodes to be evaluated, initially containing the start node
        self.came_from = {}  # the map of navigated nodes
        self.cost_from_start = {}  # also known as g(x)
        self.heuristic_cost_from_start = {}  # also known as f(x)
        # the g(x) part of the heuristic is the cost from the starting point, not simply the local cost from the previously expanded node.
        
        self.cost_from_start[start] = 0 # cost from start along best known path
        # estimated total cost from start to goal through y
        self.heuristic_cost_from_start[start] = self._get_heuristic_cost_estimate(start, goal)


    def run(self):     
        while len(self.open_set) > 0:
            current = self._get_min_heuristic_cost_from_start_node()
            if current == self.goal:
                return self._reconstruct_path()
            self.open_set.remove(current)
            self.closed_set.append(current)
            for neighbor in self.graph.get_neighbors(current):
                if neighbor in self.closed_set:
                    continue
                cost = self.cost_from_start[current] + self.graph.dist_between(current, neighbor)
                if neighbor not in self.open_set or cost < self.cost_from_start[neighbor]: 
                    self.came_from[neighbor] = current
                    self.cost_from_start[neighbor] = cost
                    self.heuristic_cost_from_start[neighbor] = self._get_heuristic_cost_estimate(neighbor, self.goal)
                    if neighbor not in self.open_set:
                        self.open_set.append(neighbor)
        raise Exception("Failed!")

    def _get_min_heuristic_cost_from_start_node(self):
        assert len(self.open_set) > 0
        min_heuristic_cost = 99999  # set to arbitrary high number
        return_node = None
        for node in self.open_set:
            if self.heuristic_cost_from_start[node] < min_heuristic_cost:
                min_heuristic_cost = self.heuristic_cost_from_start[node]
                return_node = node
        if return_node is None:
            raise NodeNotFoundError("No node found for min heuristic")
        return return_node        

    def _get_heuristic_cost_estimate(self, start, goal):
        return self.cost_from_start[start] + self.graph.heuristic_cost_estimate(start, goal)
 
    def _reconstruct_path(self):
        current = self.goal
        # this function is trying to make a recursive call
        total_path = [current]
        while current in self.came_from:
            current = self.came_from[current]
            total_path.append(current)
        total_path.reverse()
        return total_path


if __name__ == "__main__":
    x = Graph(9, 9)
    print AStar(x, "(0,0)", "(8,8)").run()
