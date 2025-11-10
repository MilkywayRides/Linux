#!/usr/bin/env python3
import os
import re
import openai
from github import Github

MAX_RETRIES = 3
RETRY_FILE = ".github/.auto_fix_count"

def get_retry_count():
    if os.path.exists(RETRY_FILE):
        with open(RETRY_FILE) as f:
            return int(f.read().strip())
    return 0

def increment_retry():
    count = get_retry_count() + 1
    with open(RETRY_FILE, 'w') as f:
        f.write(str(count))
    return count

def reset_retry():
    if os.path.exists(RETRY_FILE):
        os.remove(RETRY_FILE)

def main():
    retry_count = get_retry_count()
    if retry_count >= MAX_RETRIES:
        print(f"Max retries ({MAX_RETRIES}) reached. Manual intervention required.")
        reset_retry()
        return

    openai.api_key = os.getenv("OPENAI_API_KEY")
    g = Github(os.getenv("GITHUB_TOKEN"))
    repo = g.get_repo(os.getenv("REPO_NAME"))

    with open("error.log") as f:
        error_log = f.read()[-8000:]

    prompt = f"""You are fixing a Linux From Scratch build error. Analyze and provide ONLY the exact file changes needed.

Error Log:
{error_log}

Respond in this format:
FILE: path/to/file.sh
```bash
# complete fixed file content
```

Be minimal and precise."""

    response = openai.chat.completions.create(
        model="gpt-4o",
        messages=[{"role": "user", "content": prompt}],
        temperature=0.3
    )

    fix_content = response.choices[0].message.content
    
    file_pattern = r'FILE:\s*(.+?)\n```(?:bash|sh)?\n(.*?)```'
    matches = re.findall(file_pattern, fix_content, re.DOTALL)
    
    if not matches:
        print("No fixes parsed from AI response")
        return

    for file_path, content in matches:
        file_path = file_path.strip()
        content = content.strip()
        
        try:
            file = repo.get_contents(file_path, ref="main")
            repo.update_file(
                file_path,
                f"Auto-fix: {file_path} (attempt {retry_count + 1})",
                content,
                file.sha,
                branch="main"
            )
            print(f"Fixed: {file_path}")
        except Exception as e:
            print(f"Error updating {file_path}: {e}")

    increment_retry()
    print(f"Auto-fix applied (attempt {retry_count + 1}/{MAX_RETRIES})")

if __name__ == "__main__":
    main()
