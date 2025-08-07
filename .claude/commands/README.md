# Claude Code Slash Commands

**ALWAYS THINK THEN...** Before executing any action, operation, or command in this instruction set, you MUST use thinking to:
1. Analyze the request and understand what needs to be done
2. Plan your approach and identify potential issues
3. Consider the implications and requirements
4. Only then proceed with the actual execution

**This thinking requirement is MANDATORY and must be followed for every action.**


This directory contains slash commands for Claude Code that can be invoked to execute structured development workflows. These commands follow the patterns described in the Claude Code advanced techniques documentation.

## Usage

Commands can be invoked in Claude Code by typing `/` followed by the command name. Commands support arguments using `$argument` or numbered placeholders like `$1`, `$2`, etc.

### Basic Usage
```
/enforce "implement user authentication"
/epct "shopping cart feature"
/debug "null pointer exception in checkout flow"
```

### Multi-Argument Usage
```
/component React UserProfile "user data display and editing"
/api POST /api/users "user registration"
```

## Command Categories

### [SHIELD] Protocol Commands (`/protocol/*`)

Commands that enforce coding standards and best practices.

- **`/protocol/enforce`** - Apply canonical coding protocols
  - Usage: `/protocol/enforce "feature name"`
  - Enforces SOLID, DRY, KISS principles
  - Ensures atomic commits and testing

- **`/protocol/security`** - Apply security analysis and hardening
  - Usage: `/protocol/security "component or feature"`
  - Implements input validation and authentication
  - Follows OWASP guidelines

###  Planning Commands (`/planning/*`)

Commands for task breakdown and project planning.

- **`/planning/decompose`** - Break down requirements into atomic tasks
  - Usage: `/planning/decompose "high-level requirement"`
  - Creates detailed task structure with dependencies
  - Generates subtasks with clear success criteria

- **`/planning/sprint`** - Create sprint plans
  - Usage: `/planning/sprint "project or feature name"`
  - Organizes tasks into daily/weekly structure
  - Includes capacity planning and risk assessment

### [TOOL] Action Commands (`/actions/*`)

Commands for executing specific development tasks.

- **`/actions/implement`** - Implement a new feature
  - Usage: `/actions/implement "feature description"`
  - Follows TDD approach
  - Includes error handling

- **`/actions/refactor`** - Refactor existing code
  - Usage: `/actions/refactor "component or module"`
  - Preserves functionality while improving quality
  - Incremental changes with testing

- **`/actions/debug`** - Debug and fix issues
  - Usage: `/actions/debug "issue description"`
  - Systematic root cause analysis
  - Includes preventive measures

### [DOCS] Documentation Commands (`/docs/*`)

Commands for creating structured documentation.

- **`/docs/diataxis`** - Create Ditaxis-compliant documentation
  - Usage: `/docs/diataxis "topic or component"`
  - Follows Tutorial/How-to/Reference/Explanation structure
  - Includes examples and diagrams

### [GEAR] Code Quality Commands (`/code/*`)

Commands for maintaining code quality throughout development.

- **`/code/code-lint-and-quality-check`** - Post-implementation quality check
  - Usage: `/code/code-lint-and-quality-check "[directory or file]"`  
  - **Development Workflow Step:** Runs after coding activities
  - Performs linting, type checking, formatting, deduplication analysis
  - Fixes immediate/safe issues, flags complex ones for remediation
  - **Auto-executed** by code-implement command

- **`/code/code-deployment-planning`** - deployment planning and documentation
  - Usage: `/code/code-deployment-planning "[target system]"`
  - **Planning Phase Only:** Creates deployment plans and strategies
  - Analyzes infrastructure requirements and deployment strategies
  - Documents risk assessment and rollback procedures
  - Creates Jupyter notebook documentation
  - **Does NOT perform actual deployment**

- **`/code/code-deploy`** - Execute deployment to specified environment and platform
  - Usage: `/code/code-deploy [environment] [platform] [additional-options]`
  - **Deployment Execution Only:** Builds, deploys, and validates application
  - Examples: `/code-deploy dev docker-desktop`, `/code-deploy prod aws us-east-1`
  - Supports: docker-desktop, kubernetes, aws, azure, gcp, local
  - Performs health checks and functional validation
  - **Does NOT create extensive documentation**

### [TARGET] Composite Commands

Advanced commands with multiple parameters.

- **`/component`** - Create a new component
  - Usage: `/component [framework] [name] [functionality]`
  - Example: `/component React UserProfile "display user data"`
  - Generates component, tests, styles, and types

- **`/api`** - Create an API endpoint
  - Usage: `/api [method] [path] [purpose]`
  - Example: `/api POST /api/users "user registration"`
  - Includes validation, error handling, and tests

### [LAUNCH] Essential Workflow Command

- **`/epct`** - Execute the Explore, Plan, Code, Test workflow
  - Usage: `/epct "feature or task description"`
  - 4-phase development approach
  - Ensures thorough research, planning, implementation, and testing

### [STYLE] Frontend Commands (`/frontend/*`)

- **`/frontend/react`** - Create React implementations
  - Usage: `/frontend/react "component or feature"`
  - Follows React best practices
  - Includes hooks, performance optimization, and testing

###  Backend Commands (`/backend/*`)

- **`/backend/nodejs`** - Create Node.js backend implementations
  - Usage: `/backend/nodejs "API or service"`
  - Clean architecture pattern
  - Includes security, error handling, and testing

### [TEST] Testing Commands (`/testing/*`)

- **`/testing/e2e`** - Create end-to-end tests
  - Usage: `/testing/e2e "user flow or feature"`
  - Page Object Model pattern
  - Includes visual regression and performance tests

## Creating Custom Commands

To create a new slash command:

1. Create a new `.md` file in the appropriate category directory
2. Use `$argument` for single parameter commands
3. Use `$1`, `$2`, `$3` for multi-parameter commands
4. Include clear sections for different phases/aspects
5. Add quality checklists and requirements

### Command Template
```markdown
# Command Name

Brief description of what this command does for: $argument

## Section 1
Detailed instructions...

## Section 2
More instructions...

## Quality Checklist
- [ ] Requirement 1
- [ ] Requirement 2

Execute the task following these guidelines.
```

## Best Practices

1. **Use Specific Commands**: Choose the most specific command for your task
2. **Provide Clear Arguments**: Be descriptive in your arguments
3. **Chain Commands**: Use multiple commands for complex workflows
4. **Follow Protocols**: Commands enforce best practices - follow them
5. **Review Output**: Always review generated code before committing

## Integration with VS Code Toolkit

These commands are designed to work with the VS Code Toolkit deployment system. When deployed to a repository:

1. Commands are available in the project's Claude Code context
2. They follow project-specific conventions from CLAUDE.md
3. They integrate with configured MCP servers
4. They respect project-specific linting and testing requirements

## Troubleshooting

If a command doesn't work as expected:

1. Check the command syntax and arguments
2. Ensure you're in the correct directory
3. Verify CLAUDE.md is properly configured
4. Check for any error messages in the output
5. Try running with more specific arguments

For more information, see the [Claude Code documentation](https://docs.anthropic.com/en/docs/claude-code).