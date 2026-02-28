with open('lib/features/nudges/nudges_screen.dart', 'r', encoding='utf-8') as f:
    content = f.read()

# Fix the broken string interpolation on line 96
content = content.replace(
    "child: Text('-> \\${nudge['action']}', style: TextStyle(color: color, fontSize: 12, fontWeight: FontWeight.w600)),",
    "child: Text('-> ' + (nudge['action'] as String), style: TextStyle(color: color, fontSize: 12, fontWeight: FontWeight.w600)),"
)

with open('lib/features/nudges/nudges_screen.dart', 'w', encoding='utf-8') as f:
    f.write(content)
print("Nudges fixed!")

# Verify line 96
lines = content.split('\n')
print("Line 96 now:", lines[95])