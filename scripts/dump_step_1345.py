import json

with open(r'C:\Users\Krutadnye\.gemini\antigravity\brain\877a232c-55f4-40fd-8055-f04f547c8c82\.system_generated\logs\transcript_full.jsonl', 'r', encoding='utf-8') as f:
    for line in f:
        data = json.loads(line)
        if data.get('step_index') == 1345:
            with open(r'scripts/last_user_prompt.txt', 'w', encoding='utf-8') as out:
                out.write(data.get('content', ''))
            print("Wrote Step 1345 content to scripts/last_user_prompt.txt")
            break

