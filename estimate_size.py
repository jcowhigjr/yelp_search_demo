#!/usr/bin/env python3
import json
import sys
import re

def estimate_size(title, body):
    """
    Estimate T-shirt size based on title and body content
    Returns: XS, S, M, L, XL
    """
    
    # Calculate complexity score
    score = 0
    
    # Title analysis
    title_words = len(title.split())
    score += title_words * 0.5
    
    # Body analysis
    body_words = len(body.split()) if body else 0
    score += body_words * 0.1
    
    # Code blocks (```...)
    code_blocks = len(re.findall(r'```', body)) // 2 if body else 0
    score += code_blocks * 5
    
    # Lists and bullet points
    lists = len(re.findall(r'^[-*]\s', body, re.MULTILINE)) if body else 0
    score += lists * 0.5
    
    # Checkboxes/tasks
    checkboxes = len(re.findall(r'- \[[ x]\]', body)) if body else 0
    score += checkboxes * 1
    
    # Keywords that suggest complexity
    complexity_keywords = [
        'refactor', 'migration', 'security', 'authentication', 'authorization',
        'api', 'database', 'performance', 'breaking', 'dependency', 'upgrade'
    ]
    
    text = (title + ' ' + (body or '')).lower()
    for keyword in complexity_keywords:
        if keyword in text:
            score += 3
    
    # Simple keywords suggest smaller tasks
    simple_keywords = ['fix', 'update', 'bump', 'add', 'remove']
    for keyword in simple_keywords:
        if keyword in title.lower():
            score += 1
    
    # Convert score to T-shirt size
    if score <= 3:
        return 'XS'
    elif score <= 8:
        return 'S'
    elif score <= 15:
        return 'M'
    elif score <= 25:
        return 'L'
    else:
        return 'XL'

def main():
    if len(sys.argv) != 3:
        print("Usage: python estimate_size.py <input.json> <output.json>")
        sys.exit(1)
    
    input_file = sys.argv[1]
    output_file = sys.argv[2]
    
    try:
        with open(input_file, 'r') as f:
            items = json.load(f)
        
        # Add size estimates
        for item in items:
            size = estimate_size(item.get('title', ''), item.get('body', ''))
            item['estimated_size'] = size
            
        # Write output
        with open(output_file, 'w') as f:
            json.dump(items, f, indent=2)
            
        print(f"Size estimation complete. Results written to {output_file}")
        
    except Exception as e:
        print(f"Error: {e}")
        sys.exit(1)

if __name__ == '__main__':
    main()
