
class Duck:
    def quack(self):
        return "Quack!"

class Robot:
    def quack(self):
        return "Beep quack"

class Dog:
    def bark(self):
        return "Woof"

def make_it_quack(thing):
    return thing.quack()

assert make_it_quack(Duck()) == "Quack!"
assert make_it_quack(Robot()) == "Beep quack"
try:
    make_it_quack(Dog())
    assert False, "a Dog does not quack"
except AttributeError:
    pass
