#!/usr/bin/env python3
"""
Parse Claude suggestions and post them as GitHub review comments with suggestion format.
"""

import json
import os
import re
import requests
import sys
from typing import List, Dict, Optional

class GitHubAPI:
    def __init__(self, token: str, repo: str):
        self.token = token
        self.repo = repo
        self.headers = {
            'Authorization': f'token {token}',
            'Accept': 'application/vnd.github.v3+json'
        }
        self.base_url = 'https://api.github.com'

    def create_review_with_suggestions(self, pr_number: int, suggestions: List[Dict]) -> bool:
        """Create a PR review with suggestion comments."""
        # Prepare review comments
        comments = []
        for suggestion in suggestions:
            comment = {
                'path': suggestion['file'],
                'line': suggestion['line'],
                'side': 'RIGHT',  # Required by GitHub API - refers to the new version of the file
                'body': self._format_suggestion_comment(
                    suggestion['explanation'], 
                    suggestion['code']
                )
            }
            comments.append(comment)
        
        if not comments:
            print("No valid suggestions found to post")
            return False
            
        # Create review with comments
        review_data = {
            'event': 'COMMENT',
            'body': '🤖 **Claude Code Suggestions**\n\nI\'ve analyzed your changes and added specific suggestions. Click "Apply suggestion" on each one to implement the changes.',
            'comments': comments
        }
        
        url = f'{self.base_url}/repos/{self.repo}/pulls/{pr_number}/reviews'
        response = requests.post(url, headers=self.headers, json=review_data)
        
        if response.status_code == 200:
            print(f"Successfully created review with {len(comments)} suggestions")
            return True
        else:
            print(f"Failed to create review: {response.status_code} {response.text}")
            return False

    def _format_suggestion_comment(self, explanation: str, suggested_code: str) -> str:
        """Format a suggestion comment for GitHub."""
        return f"""**🤖 Claude Suggestion**

{explanation}

```suggestion
{suggested_code}
```"""

class SuggestionParser:
    def __init__(self, suggestions_text: str):
        self.suggestions_text = suggestions_text

    def parse(self) -> List[Dict]:
        """Parse Claude's suggestions into structured format."""
        suggestions = []
        
        # Split by file patterns
        file_pattern = r'\*\*File:\s+([^\s]+)\s+\(Line\s+(\d+)\)\*\*'
        sections = re.split(file_pattern, self.suggestions_text)
        
        # Process sections (skip first empty element)
        for i in range(1, len(sections), 3):
            if i + 2 < len(sections):
                file_path = sections[i]
                line_number = int(sections[i + 1])
                content = sections[i + 2]
                
                # Extract suggestion code block
                suggestion_match = re.search(r'```suggestion\n(.*?)\n```', content, re.DOTALL)
                if not suggestion_match:
                    continue
                    
                suggested_code = suggestion_match.group(1).strip()
                
                # Extract explanation
                explanation_match = re.search(r'\*\*Explanation\*\*:\s*(.*?)(?=\n\n|\n\*\*|$)', content, re.DOTALL)
                explanation = explanation_match.group(1).strip() if explanation_match else "Code improvement suggestion"
                
                suggestions.append({
                    'file': file_path,
                    'line': line_number,
                    'code': suggested_code,
                    'explanation': explanation
                })
                
        print(f"Parsed {len(suggestions)} suggestions from Claude")
        return suggestions

def main():
    # Get environment variables
    github_token = os.environ.get('GITHUB_TOKEN')
    repo = os.environ.get('GITHUB_REPOSITORY')
    pr_number = int(os.environ.get('PR_NUMBER', 0))
    suggestions_file = sys.argv[1] if len(sys.argv) > 1 else 'claude_suggestions.md'
    
    if not all([github_token, repo, pr_number]):
        print("Missing required environment variables: GITHUB_TOKEN, GITHUB_REPOSITORY, PR_NUMBER")
        sys.exit(1)
    
    # Read suggestions
    try:
        with open(suggestions_file, 'r') as f:
            suggestions_text = f.read()
    except FileNotFoundError:
        print(f"Suggestions file {suggestions_file} not found")
        sys.exit(1)
    
    # Parse suggestions
    parser = SuggestionParser(suggestions_text)
    suggestions = parser.parse()
    
    if not suggestions:
        print("No suggestions found to post")
        sys.exit(0)
    
    # Post to GitHub
    github_api = GitHubAPI(github_token, repo)
    success = github_api.create_review_with_suggestions(pr_number, suggestions)
    
    if success:
        print("✅ Successfully posted Claude suggestions as review comments")
    else:
        print("❌ Failed to post suggestions")
        sys.exit(1)

if __name__ == '__main__':
    main()