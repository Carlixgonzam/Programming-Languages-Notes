import re

# <<internal>>
class TrainingPlan:
    def __init__(self):
        self.days = {}
        self.current = None

    def on(self, day):
        self.current = day
        self.days[day] = []
        return self

    def run(self, km, intensity=None):
        self.days[self.current].append(('run', km * 1000, intensity))
        return self

    def rest(self, minutes):
        self.days[self.current].append(('rest', minutes, None))
        return self

plan = (TrainingPlan()
        .on('Monday')
        .run(10, intensity='threshold')
        .rest(15))
# <<internal.end>>

assert plan.days == {'Monday': [('run', 10000, 'threshold'), ('rest', 15, None)]}

# <<regex>>
pattern = re.compile(r'[A-Z][a-z]+\d{4}')
# <<regex.end>>
assert pattern.fullmatch('Bogota2026')
assert not pattern.fullmatch('bogota2026')
assert not pattern.fullmatch('Bogota26')
print("internal: ok")
