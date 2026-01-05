covered = 0
total = 0

with open("C:/Users/Zosia/projekt-inzynierski/the_basics/coverage/lcov.info", "r", encoding="utf-8") as f:
    for line in f:
        if line.startswith("DA:"):
            total += 1
            if not line.strip().endswith(",0"):
                covered += 1

percent = (covered / total) * 100 if total else 0
print(f"Coverage: {percent:.2f}% ({covered}/{total})")