import gc
import sys
import weakref

class Node:
    def __init__(self):
        self.other = None

a = Node()
b = Node()
a.other = b
b.other = a

gc.disable()
alive = weakref.ref(a)
assert sys.getrefcount(a) - 1 == 2
del a
del b
assert alive() is not None
gc.collect()
assert alive() is None
gc.enable()
print("refcount: ok")
