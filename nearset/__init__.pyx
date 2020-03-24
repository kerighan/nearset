from collections import defaultdict
from bisect import bisect_left
from blist import blist


cdef class Node(object):
    cpdef public object value
    cpdef public object key
    cpdef public float order

    def __init__(self, key, value):
        self.key = key
        self.value = value
    
    def __repr__(self):
        return f"<{self.key}>{self.value}"


cdef class NearSet(object):
    cpdef public object cmp
    cpdef public set keys
    cpdef public Node start_value
    cpdef public object nodes
    cpdef public object index_node_order
    cpdef public int max_size

    def __init__(self, cmp, max_size=None):
        self.cmp = cmp
        self.keys = set()
        self.nodes = blist()
        self.index_node_order = blist()
        self.max_size = max_size

    def __len__(self):
        return len(self.keys)
    
    def __setitem__(self, key, value):
        self.add(key, value)

    cpdef add(self, object key, object value=None):
        cpdef Node node

        # if no key is provided, key is the value
        if value is None:
            value = key

        # if element already exists, ignore
        if key in self.keys:
            return

        # create Node element and compute sort value
        node = Node(key, value)
        node.order = self.cmp(node.value)

        if self.max_size is not None \
                and len(self.keys) >= self.max_size \
                and node.order > self.nodes[self.max_size - 1].order:
            return

        # if the node is the first element to be inserted, insert immediately
        if len(self.keys) == 0:
            # add the key for later references
            self.keys.add(key)
            # add the node index to list
            self.nodes.append(node)
            self.index_node_order.append(node.order)
        else:
            # insert node using the standard method
            self.insert(node)
    
    cpdef insert(self, Node node):
        idx = bisect_left(self.index_node_order, node.order)
        self.nodes.insert(idx, node)
        self.index_node_order.insert(idx, node.order)
        self.keys.add(node.key)
        if self.max_size is not None:
            self.index_node_order = self.index_node_order[:self.max_size]
            self.nodes = self.nodes[:self.max_size]

    cpdef pop(self):
        self.index_node_order.pop()
        node = self.nodes.pop()
        self.keys.remove(node.key)
        return node

    cpdef items(self):
        return [(item.key, item.value) for item in self.nodes]

    def __repr__(self):
        return str([item.value for item in self.nodes])

    def __getitem__(self, key):
        if isinstance(key, int):
            return self.nodes[key].value
        elif isinstance(key, slice):
            return [item.value for item in self.nodes[key]]
        raise KeyError(key)
