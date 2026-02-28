import re

# Fix nudges_screen.dart
with open('lib/features/nudges/nudges_screen.dart', 'r', encoding='utf-8') as f:
    content = f.read()

# Replace all \$ with $ (broken interpolation)
content = content.replace('\\$', '$')

with open('lib/features/nudges/nudges_screen.dart', 'w', encoding='utf-8') as f:
    f.write(content)
print("nudges fixed!")

# Fix simulation_screen.dart
with open('lib/features/simulation/simulation_screen.dart', 'r', encoding='utf-8') as f:
    content = f.read()

content = content.replace('\\$', '$')

with open('lib/features/simulation/simulation_screen.dart', 'w', encoding='utf-8') as f:
    f.write(content)
print("simulation fixed!")

# Fix prediction_screen.dart
with open('lib/features/prediction/prediction_screen.dart', 'r', encoding='utf-8') as f:
    content = f.read()

content = content.replace('\\$', '$')

with open('lib/features/prediction/prediction_screen.dart', 'w', encoding='utf-8') as f:
    f.write(content)
print("prediction fixed!")

print("All interpolation fixed!")