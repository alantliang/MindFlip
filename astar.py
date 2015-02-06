'''
Suppose we have a rectangular grid that has height h and width w.
So the bottom corner is (0,0), top left is (0, h),
top right is (w, h), and bottom right is (w, 0).

Each node of the graph is connected to the other side 
like pacman. Design A-star algorithm for this structure.
'''

class NodeNotFoundError(Exception):
	pass

class Node(object):
	def __init__(self, x, y):
		self.x = x
		self.y = y
		self.connected = []  # references to all connected nodes
		self.walkable = True

	def connect(self, node_list):
		for node in node_list:
			self.connected.append(node)

	def __repr__(self):
		return "({}, {})".format(self.x, self.y)


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
		raise NodeNotFoundError("Node not found {}, {}",format(x, y))

	def print_nodes(self):
		for node in self.nodes:
			print "{} Connected: {}".format(node, node.connected)


if __name__ == "__main__":
	x = Graph(3, 3)
	x.print_nodes()