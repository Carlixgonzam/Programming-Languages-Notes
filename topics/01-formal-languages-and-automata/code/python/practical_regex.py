import re

email_pattern = r"^[\w.+-]+@[\w-]+(\.[\w-]+)*\.[a-zA-Z]{2,}$"

log_pattern = r"^(\d{4}-\d{2}-\d{2}) (\d{2}:\d{2}:\d{2}) (\w+) (.+)$"

assert re.match(email_pattern, "ca.gonzalez@uniandes.edu.co")
assert not re.match(email_pattern, "no-at-sign.com")
m = re.match(log_pattern, "2026-07-03 14:02:11 ERROR Connection refused (host=db01)")
assert m.groups() == ("2026-07-03", "14:02:11", "ERROR", "Connection refused (host=db01)")

assert re.search(r"\b(\w+) \1\b", "this is is repeated")
assert not re.search(r"\b(\w+) \1\b", "this is not repeated")
