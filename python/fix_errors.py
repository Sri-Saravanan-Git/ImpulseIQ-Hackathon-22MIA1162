# Fix 1: dashboard_screen.dart line 425
with open('lib/features/dashboard/dashboard_screen.dart', 'r', encoding='utf-8') as f:
    content = f.read()

# The broken line - Container without child:
content = content.replace(
    '''            decoration: BoxDecoration(
              color: AppTheme.surface,
              borderRadius: BorderRadius.circular(12),
            ),
            Text(t.categoryEmoji, style: const TextStyle(fontSize: 20))''',
    '''            decoration: BoxDecoration(
              color: AppTheme.surface,
              borderRadius: BorderRadius.circular(12),
            ),
            child: Center(child: Text(t.categoryEmoji, style: const TextStyle(fontSize: 20)))'''
)

with open('lib/features/dashboard/dashboard_screen.dart', 'w', encoding='utf-8') as f:
    f.write(content)
print("Fix 1 done: dashboard_screen.dart")

# Fix 2: behaviour_screen.dart line 99
with open('lib/features/behaviour/behaviour_screen.dart', 'r', encoding='utf-8') as f:
    content = f.read()

content = content.replace(
    "Text(profile.archetypeEmoji, fontSize: 32)",
    "Text(profile.archetypeEmoji, style: const TextStyle(fontSize: 32))"
)
content = content.replace(
    "Text(profile.archetypeLabel,\n                      style: const TextStyle(\n                          color: AppTheme.textPrimary, fontSize: 18,",
    "Text(profile.archetypeLabel,\n                      style: const TextStyle(\n                          color: AppTheme.textPrimary, fontSize: 18,"
)

with open('lib/features/behaviour/behaviour_screen.dart', 'w', encoding='utf-8') as f:
    f.write(content)
print("Fix 2 done: behaviour_screen.dart")

# Fix 3: nudges_screen.dart line 96 - the \$ escape issue
with open('lib/features/nudges/nudges_screen.dart', 'r', encoding='utf-8') as f:
    content = f.read()

print("Nudges line 90-100:")
lines = content.split('\n')
for i, line in enumerate(lines[88:102], start=89):
    print(f"{i}: {line}")