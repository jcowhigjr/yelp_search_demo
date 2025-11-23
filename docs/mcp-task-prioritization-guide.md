# MCP Task Prioritization Tools Guide

This guide explains how to use the MCP Task Prioritization tools for automated T-shirt sizing, work item analysis, and PR status tracking.

## Overview

The MCP Task Prioritization system provides:

1. **T-shirt Sizing**: Automatic estimation of issue complexity (XS, S, M, L, XL)
2. **Work Item Analysis**: Comprehensive backlog analysis and recommendations
3. **PR Status Tracking**: Automated review status updates and risk assessments

## Quick Start

### Prerequisites

- MCP tools installed and configured
- GitHub repository access
- Python 3.7+ with required dependencies

### Installation

```bash
# Install dependencies
pip install pyyaml

# Make scripts executable
chmod +x mcp_task_prioritization.py
chmod +x mcp_integration_wrapper.py

# Ensure project directories exist
mkdir -p .project/data .project/state
```

### Configuration

The tools use `mcp_task_config.yml` for configuration. Key settings:

```yaml
mcp_settings:
  owner: jcowhigjr
  repo: jitter
  
  sizing:
    thresholds:
      XS: 0-4      # 1-2 hours
      S: 5-12      # 2-4 hours  
      M: 13-20     # 4-8 hours
      L: 21-35     # 1-2 days
      XL: 36+      # 2-5 days
```

## Usage Examples

### 1. T-shirt Sizing for Issues

#### Create a sizing comment for a specific issue:

```bash
python mcp_integration_wrapper.py \
    --action create_sizing_comment \
    --issue 123 \
    --context "High priority user story"
```

**Output:**
```
📊 Creating T-shirt sizing comment for issue #123
✅ Successfully created sizing comment
   Issue: #123
   Size: M
   Confidence: high
   Score: 15.2
```

**GitHub Comment Generated:**
```markdown
## 🟡 T-Shirt Size Estimate: **M**

📊 **Complexity Score:** 15.2 (confidence: high)

💭 **Reasoning:** Estimated as M based on complexity analysis. Key factors: Contains 2 code blocks; Has 4 acceptance criteria/tasks

### 📋 Analysis Breakdown:
- **Code Blocks:** 2 found
- **Tasks/Criteria:** 4 identified

⏱️ **Estimated Effort:** 4-8 hours (0.5-1 day)

### 🎯 Recommendation:
🎯 **Standard story size** - Plan for dedicated focus time

---
*Automated sizing by MCP Task Prioritization • 2024-01-15 14:30*
```

### 2. Backlog Analysis

#### Analyze all open issues and PRs:

```bash
python mcp_integration_wrapper.py \
    --action analyze_backlog \
    --project jitter
```

**Output:**
```
🔍 Analyzing backlog for jcowhigjr/jitter

📋 Backlog Analysis Summary:
   📊 Total Issues: 12
   🔄 Total PRs: 3

📏 Size Distribution:
   🟫 XS: 2 items
   🟢 S: 4 items  
   🟡 M: 5 items
   🟠 L: 1 items
   🔴 XL: 0 items

💡 Recommendations:
   • 6 quick wins available (XS/S items)
   • Add T-shirt size estimates to 2 unestimated items
```

### 3. PR Status Updates

#### Add review status comment to a PR:

```bash
python mcp_integration_wrapper.py \
    --action update_pr_review \
    --pr 456 \
    --status-type review
```

**GitHub Comment Generated:**
```markdown
## 👀 PR Review Status Update

### 📊 Change Summary:
- **Files Changed:** 8
- **Lines Added:** +245
- **Lines Removed:** -67
- **Commits:** 4

### 🟡 Risk Assessment: **MEDIUM**

🔍 **Medium Complexity Changes**
- Standard review process recommended
- Verify test coverage
- Consider integration testing

### 📁 File Types Changed:
- `.rb`: 5 files
- `.erb`: 2 files
- `.yml`: 1 files

### 🎯 Review Recommendations:
- [ ] Verify all tests pass
- [ ] Check for proper error handling
- [ ] Confirm documentation updates (if needed)

---
*Automated status by MCP Task Prioritization • 2024-01-15 14:30*
```

### 4. Bulk Operations

#### Size multiple issues at once:

```bash
python mcp_integration_wrapper.py \
    --action bulk_size \
    --issues 101 102 103 104
```

#### Size all open issues:

```bash
python mcp_integration_wrapper.py \
    --action bulk_size
```

### 5. Priority Reports

#### Generate comprehensive priority report:

```bash
python mcp_integration_wrapper.py \
    --action priority_report
```

**Sample Report Output:**
```json
{
  "timestamp": "2024-01-15T14:30:00",
  "project": "jcowhigjr/jitter",
  "analysis": {
    "summary": {
      "total_issues": 12,
      "total_prs": 3,
      "size_distribution": {
        "XS": 2,
        "S": 4,
        "M": 5,
        "L": 1,
        "XL": 0
      }
    }
  },
  "priority_recommendations": [
    {
      "type": "quick_wins",
      "count": 6,
      "suggestion": "Consider prioritizing 6 quick win items (XS/S) for immediate impact"
    }
  ]
}
```

## Understanding T-shirt Sizes

### Size Mappings

| Size | Score Range | Time Estimate | Description |
|------|-------------|---------------|-------------|
| XS   | 0-4         | 1-2 hours     | Quick fixes, typos, simple updates |
| S    | 5-12        | 2-4 hours     | Small features, bug fixes |
| M    | 13-20       | 4-8 hours     | Standard user stories |
| L    | 21-35       | 1-2 days      | Complex features, may need breakdown |
| XL   | 36+         | 2-5 days      | Epic-sized, requires breakdown |

### Complexity Factors

#### Increases Complexity:
- **Keywords**: refactor, migration, security, authentication, api, database
- **Code blocks**: Each code block adds significant complexity
- **Tasks**: Number of acceptance criteria/checkboxes
- **Content length**: Detailed descriptions suggest complexity

#### Decreases/Maintains Complexity:
- **Simple keywords**: fix, update, bump, add, remove, docs
- **Short descriptions**: Brief, clear issues
- **Documentation tasks**: Usually straightforward

### Confidence Levels

- **High**: Clear indicators, consistent with historical data
- **Medium**: Some ambiguity, mixed signals
- **Low**: Unclear requirements, needs more information

## PR Risk Assessment

### Risk Levels

#### 🟢 Low Risk
- ≤10 files changed
- ≤500 lines changed
- No sensitive files
- Standard review process

#### 🟡 Medium Risk
- 11-20 files changed
- 501-1000 lines changed
- Some complexity
- Enhanced review recommended

#### 🔴 High Risk
- >20 files changed
- >1000 lines changed
- Sensitive files (migrations, config, auth)
- Requires careful review and testing

### Sensitive File Patterns

Files that automatically trigger high risk assessment:
- Database migrations
- Configuration files
- Authentication/security files
- Environment files (.env)
- Schema changes

## Advanced Usage

### Custom Configuration

Create project-specific configs:

```bash
# Use custom config file
python mcp_integration_wrapper.py \
    --action analyze_backlog \
    --config custom_config.yml
```

### Integration with CI/CD

Add to GitHub Actions:

```yaml
name: Task Prioritization
on:
  issues:
    types: [opened, edited]
  pull_request:
    types: [opened, ready_for_review]

jobs:
  prioritize:
    runs-on: ubuntu-latest
    steps:
      - uses: actions/checkout@v3
      - name: Run Task Prioritization
        run: |
          if [[ "${{ github.event_name }}" == "issues" ]]; then
            python mcp_integration_wrapper.py \
              --action create_sizing_comment \
              --issue ${{ github.event.issue.number }}
          elif [[ "${{ github.event_name }}" == "pull_request" ]]; then
            python mcp_integration_wrapper.py \
              --action update_pr_review \
              --pr ${{ github.event.pull_request.number }}
          fi
```

### Webhook Integration

For real-time updates, set up webhooks:

```python
# webhook_handler.py
@app.route('/webhook', methods=['POST'])
def handle_webhook():
    event = request.headers.get('X-GitHub-Event')
    payload = request.json
    
    if event == 'issues' and payload['action'] == 'opened':
        issue_number = payload['issue']['number']
        subprocess.run([
            'python', 'mcp_integration_wrapper.py',
            '--action', 'create_sizing_comment',
            '--issue', str(issue_number)
        ])
    
    return '', 200
```

## Troubleshooting

### Common Issues

1. **MCP Tool Not Found**
   ```bash
   # Ensure MCP tools are available
   which call_mcp_tool
   ```

2. **Configuration Errors**
   ```bash
   # Validate YAML syntax
   python -c "import yaml; yaml.safe_load(open('mcp_task_config.yml'))"
   ```

3. **GitHub API Rate Limits**
   ```bash
   # Add delays between bulk operations
   python mcp_integration_wrapper.py --action bulk_size --issues 1 2 3
   # Script automatically adds 1-second delays
   ```

4. **Permission Issues**
   ```bash
   # Ensure GitHub token has proper permissions
   # Needs: repo, issues, pull_requests scopes
   ```

### Debug Mode

Enable verbose logging:

```yaml
# In config file
mcp_settings:
  logging:
    verbose: true
```

### Log Files

Check log files for detailed information:
- `.project/data/sizing_log.jsonl` - T-shirt sizing history
- `.project/data/work_analysis.jsonl` - Backlog analysis history
- `.project/data/pr_status.jsonl` - PR status tracking

## Best Practices

### T-shirt Sizing
1. **Review estimates regularly** - Update thresholds based on team velocity
2. **Break down large items** - XL items should be split into smaller tasks
3. **Use context parameter** - Add specific information for better sizing

### Work Item Analysis
1. **Run weekly analysis** - Track backlog health over time
2. **Address recommendations** - Act on system suggestions
3. **Monitor size distribution** - Aim for balanced task sizes

### PR Status Tracking
1. **Update on status changes** - Re-run when PR status changes
2. **Review high-risk PRs carefully** - Extra attention for complex changes
3. **Use merge readiness checks** - Verify all criteria before merging

## Integration with Project Workflow

### Sprint Planning
1. Run backlog analysis before sprint planning
2. Prioritize quick wins (XS/S) for immediate impact
3. Include variety of sizes for balanced sprints

### Code Review Process
1. Automatic PR risk assessment on creation
2. Enhanced review for high-risk changes
3. Status updates throughout review cycle

### Team Velocity Tracking
1. Track completed sizes over time
2. Adjust estimation thresholds based on actuals
3. Use historical data for better estimates

## API Reference

### Direct Tool Usage

```python
from mcp_task_prioritization import TaskPrioritizationMCP
from mcp_integration_wrapper import MCPIntegration

# Initialize
mcp = MCPIntegration("config.yml")
tool = EnhancedTaskPrioritization("owner", "repo", mcp)

# Create sizing comment
result = tool.create_issue_comment_with_sizing(123)

# Analyze backlog
analysis = tool.analyze_work_items("project_name")

# Update PR status
status = tool.update_pr_status_comment(456, "review")
```

### Configuration Options

See `mcp_task_config.yml` for all available settings:
- Sizing thresholds and keywords
- Risk assessment criteria
- Comment formatting options
- Integration settings
- Automation rules

## Contributing

To extend the tools:

1. **Add new complexity factors** in configuration
2. **Create custom risk assessments** for specific file types
3. **Extend comment templates** for different project types
4. **Add new MCP tool integrations** as needed

For Rails-specific enhancements, see the `project_overrides` section in the config file.
