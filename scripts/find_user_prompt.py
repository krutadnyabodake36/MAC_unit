import json

with open(r'C:\Users\Krutadnye\.gemini\antigravity\brain\877a232c-55f4-40fd-8055-f04f547c8c82\.system_generated\logs\transcript_full.jsonl', 'r', encoding='utf-8') as f:
    for line in f:
        data = json.loads(line)
        if data.get('source') == 'USER_EXPLICIT':
            content = data.get('content', '')
            print(f"Step {data.get('step_index')}: {content[:120]}...\n")

