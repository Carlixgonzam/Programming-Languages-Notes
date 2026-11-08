import gc
import sys
import weakref

# <<cycle>>
class Node:
    def __init__(self):
        self.other = None

a = Node()
b = Node()
a.other = b
b.other = a
# <<cycle.end>>

gc.disable()                      # only reference counting from here on
alive = weakref.ref(a)
assert sys.getrefcount(a) - 1 == 2    # the name a and b.other
# <<del>>
del a
del b
# <<del.end>>
assert alive() is not None        # the cycle was not freed
gc.collect()                      # the cycle detector finds it
assert alive() is None
gc.enable()
print("refcount: ok")
