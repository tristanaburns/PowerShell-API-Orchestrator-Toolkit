"""
Minimal Canonical Protocol for Ollama
Condensed version to fit within token limits
"""

def get_minimal_canonical_prompt(task_type: str, work_package: dict) -> str:
    """Generate minimal but effective canonical prompt"""
    
    # Core requirements only
    base_prompt = f"""# TASK: {work_package.get('description', '')}

## MANDATORY REQUIREMENTS:
1. Language: {work_package['context']['language']} ONLY
2. Complete implementation (NO TODOs or stubs)
3. Error handling REQUIRED
4. Type hints REQUIRED (Python)
5. Docstrings REQUIRED

## FORBIDDEN:
- PowerShell, Batch, Shell scripts
- Hard-coded secrets/passwords
- Global variables
- Untested code paths

## YOUR IMPLEMENTATION:
"""
    
    # Add task-specific requirements
    if task_type == "function_implementation":
        base_prompt += """
Create the function with:
- Clear parameters and return types
- error handling
- Thread-safe if applicable
- SOLID principles
"""
    elif task_type == "test_generation":
        base_prompt += """
Write tests that:
- Cover all code paths
- Test edge cases
- Mock external dependencies
- Use descriptive names
"""
    elif task_type == "api_endpoint":
        base_prompt += """
Implement endpoint with:
- Input validation
- Proper HTTP status codes
- Authentication checks
- Error responses
"""
    
    # Add the specific task
    base_prompt += f"\n## SPECIFIC TASK:\n{work_package.get('enhanced_prompt', work_package.get('description', ''))}\n\n"
    
    # Add requirements if present
    if 'requirements' in work_package:
        base_prompt += "## REQUIREMENTS:\n"
        for req in work_package['requirements']:
            base_prompt += f"- {req}\n"
    
    base_prompt += "\nProvide ONLY the code implementation. No explanations."
    
    return base_prompt

def integrate_minimal_protocol(work_package: dict) -> dict:
    """Add minimal canonical protocol to work package"""
    minimal_prompt = get_minimal_canonical_prompt(
        work_package['task_type'],
        work_package
    )
    
    work_package['minimal_canonical_prompt'] = minimal_prompt
    work_package['prompt_size'] = 'minimal'
    
    return work_package