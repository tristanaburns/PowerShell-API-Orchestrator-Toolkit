# Security Protocol Command

**ALWAYS THINK THEN...** Before executing any action, operation, or command in this instruction set, you MUST use thinking to:
1. Analyze the request and understand what needs to be done
2. Plan your approach and identify potential issues
3. Consider the implications and requirements
4. Only then proceed with the actual execution

**This thinking requirement is MANDATORY and must be followed for every action.**


Apply security analysis and hardening for: $argument

## Security Requirements

### Input Validation
- Validate all input parameters
- Sanitize user-provided data
- Implement proper type checking
- Use parameterized queries for database operations

### Authentication & Authorization
- Implement proper authentication checks
- Follow least privilege principle
- Use secure session management
- Implement rate limiting where appropriate

### Data Protection
- Never log sensitive information
- Use environment variables for secrets
- Implement proper encryption for sensitive data
- Follow OWASP security guidelines

### Code Security
- Prevent injection attacks (SQL, XSS, Command)
- Implement CSRF protection
- Use secure headers
- Validate file uploads and paths

### Error Handling
- Never expose system details in errors
- Log security events appropriately
- Implement proper exception handling
- Use secure defaults

Perform security analysis and implement all necessary protections.