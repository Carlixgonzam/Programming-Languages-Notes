
def mark(heap, roots):
    color = {obj: 'white' for obj in heap}
    gray = list(roots)
    for r in roots:
        color[r] = 'gray'
    while gray:
        obj = gray.pop()
        for target in heap[obj]:
            if color[target] == 'white':
                color[target] = 'gray'
                gray.append(target)
        color[obj] = 'black'
    return color

def sweep(heap, color):
    return {obj: refs for obj, refs in heap.items() if color[obj] == 'black'}

def cheney(heap, roots):
    to_space = []
    for r in roots:
        if r not in to_space:
            to_space.append(r)
    scan = 0
    while scan < len(to_space):
        for target in heap[to_space[scan]]:
            if target not in to_space:
                to_space.append(target)
        scan += 1
    return to_space

heap = {'root': ['A', 'B'], 'A': [], 'B': [], 'C': ['D'], 'D': ['C']}
color = mark(heap, ['root'])
assert sweep(heap, color) == {'root': ['A', 'B'], 'A': [], 'B': []}
assert color['C'] == color['D'] == 'white'

heap2 = {'root': ['A'], 'A': ['B'], 'B': [], 'C': ['D'], 'D': ['C'], 'E': []}
assert sorted(sweep(heap2, mark(heap2, ['root']))) == ['A', 'B', 'root']

heap3 = {'A': ['B'], 'B': [], 'G': []}
assert cheney(heap3, ['A']) == ['A', 'B']
print("collectors: ok")
