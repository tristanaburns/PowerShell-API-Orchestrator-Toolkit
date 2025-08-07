"""
Ollama Feedback Loop Module
Improves Ollama's output quality through iterative feedback
"""

import json
import logging
from pathlib import Path
from typing import Dict, Any, List, Optional
from datetime import datetime
import hashlib

logger = logging.getLogger(__name__)

class OllamaFeedbackLoop:
    """Manages feedback and learning for Ollama models"""
    
    def __init__(self):
        self.feedback_dir = Path(__file__).parent.parent / "ollama_feedback"
        self.feedback_dir.mkdir(exist_ok=True)
        self.patterns_file = self.feedback_dir / "learned_patterns.json"
        self.load_patterns()
    
    def load_patterns(self):
        """Load learned patterns from previous feedback"""
        if self.patterns_file.exists():
            with open(self.patterns_file, 'r') as f:
                self.learned_patterns = json.load(f)
        else:
            self.learned_patterns = {
                "task_improvements": {},
                "common_fixes": {},
                "model_preferences": {},
                "success_patterns": {}
            }
    
    def save_patterns(self):
        """Save learned patterns"""
        with open(self.patterns_file, 'w') as f:
            json.dump(self.learned_patterns, f, indent=2)
    
    def record_feedback(self, work_package: Dict[str, Any], 
                       code_generated: str, 
                       review_result: Dict[str, Any],
                       final_code: Optional[str] = None) -> Dict[str, Any]:
        """Record feedback from a code review"""
        task_type = work_package["task_type"]
        model = work_package["model"]
        
        feedback_entry = {
            "id": self.generate_feedback_id(work_package),
            "timestamp": datetime.now().isoformat(),
            "task_type": task_type,
            "model": model,
            "review_decision": review_result["decision"],
            "issues_found": review_result.get("feedback", ""),
            "improvements_made": []
        }
        
        # If code was improved, analyze the differences
        if final_code and final_code != code_generated:
            improvements = self.analyze_improvements(code_generated, final_code)
            feedback_entry["improvements_made"] = improvements
            
            # Update learned patterns
            self.update_patterns(task_type, model, improvements)
        
        # Save feedback entry
        feedback_file = self.feedback_dir / f"{feedback_entry['id']}.json"
        with open(feedback_file, 'w') as f:
            json.dump(feedback_entry, f, indent=2)
        
        # Update success rate
        self.update_success_metrics(task_type, model, review_result["decision"])
        
        return feedback_entry
    
    def generate_feedback_id(self, work_package: Dict[str, Any]) -> str:
        """Generate unique feedback ID"""
        content = f"{work_package['id']}_{datetime.now().isoformat()}"
        return hashlib.md5(content.encode()).hexdigest()[:12]
    
    def analyze_improvements(self, original: str, improved: str) -> List[str]:
        """Analyze what improvements were made"""
        improvements = []
        
        # Simple heuristics for common improvements
        if '"""' in improved and '"""' not in original:
            improvements.append("Added docstrings")
        
        if "try:" in improved and "try:" not in original:
            improvements.append("Added error handling")
        
        if "import typing" in improved or "from typing import" in improved:
            if "typing" not in original:
                improvements.append("Added type hints")
        
        if improved.count('\n') > original.count('\n') * 1.2:
            improvements.append("Expanded implementation")
        
        if "logger" in improved and "logger" not in original:
            improvements.append("Added logging")
        
        if "validate" in improved.lower() and "validate" not in original.lower():
            improvements.append("Added validation")
        
        return improvements
    
    def update_patterns(self, task_type: str, model: str, improvements: List[str]):
        """Update learned patterns based on improvements"""
        # Track improvements by task type
        if task_type not in self.learned_patterns["task_improvements"]:
            self.learned_patterns["task_improvements"][task_type] = {}
        
        for improvement in improvements:
            if improvement not in self.learned_patterns["task_improvements"][task_type]:
                self.learned_patterns["task_improvements"][task_type][improvement] = 0
            self.learned_patterns["task_improvements"][task_type][improvement] += 1
        
        # Track which model works best for which task
        if task_type not in self.learned_patterns["model_preferences"]:
            self.learned_patterns["model_preferences"][task_type] = {}
        
        if model not in self.learned_patterns["model_preferences"][task_type]:
            self.learned_patterns["model_preferences"][task_type][model] = {
                "attempts": 0,
                "successes": 0
            }
        
        self.save_patterns()
    
    def update_success_metrics(self, task_type: str, model: str, decision: str):
        """Update success metrics for model/task combinations"""
        metrics = self.learned_patterns["model_preferences"].get(task_type, {}).get(model, {
            "attempts": 0,
            "successes": 0
        })
        
        metrics["attempts"] += 1
        if decision == "approved":
            metrics["successes"] += 1
        
        if task_type not in self.learned_patterns["model_preferences"]:
            self.learned_patterns["model_preferences"][task_type] = {}
        
        self.learned_patterns["model_preferences"][task_type][model] = metrics
        self.save_patterns()
    
    def get_enhanced_prompt(self, work_package: Dict[str, Any]) -> str:
        """Generate enhanced prompt based on learned patterns"""
        task_type = work_package["task_type"]
        base_prompt = work_package.get("original_prompt", "")
        
        # Add common improvements for this task type
        if task_type in self.learned_patterns["task_improvements"]:
            common_improvements = self.learned_patterns["task_improvements"][task_type]
            
            # Sort by frequency
            sorted_improvements = sorted(
                common_improvements.items(), 
                key=lambda x: x[1], 
                reverse=True
            )
            
            if sorted_improvements:
                base_prompt += "\n\nBased on previous feedback, make sure to:"
                for improvement, count in sorted_improvements[:5]:
                    base_prompt += f"\n- {improvement}"
        
        # Add success patterns
        if task_type in self.learned_patterns["success_patterns"]:
            patterns = self.learned_patterns["success_patterns"][task_type]
            if patterns:
                base_prompt += "\n\nSuccessful implementations typically include:"
                for pattern in patterns[:3]:
                    base_prompt += f"\n- {pattern}"
        
        return base_prompt
    
    def recommend_model(self, task_type: str) -> Optional[str]:
        """Recommend best model based on success rates"""
        if task_type not in self.learned_patterns["model_preferences"]:
            return None
        
        models = self.learned_patterns["model_preferences"][task_type]
        best_model = None
        best_rate = 0
        
        for model, metrics in models.items():
            if metrics["attempts"] > 0:
                success_rate = metrics["successes"] / metrics["attempts"]
                if success_rate > best_rate:
                    best_rate = success_rate
                    best_model = model
        
        return best_model if best_rate > 0.5 else None
    
    def generate_feedback_report(self) -> str:
        """Generate a report on feedback patterns"""
        report = "# Ollama Feedback Analysis\n\n"
        
        # Model performance
        report += "## Model Performance by Task Type\n\n"
        for task_type, models in self.learned_patterns["model_preferences"].items():
            report += f"### {task_type}\n"
            for model, metrics in models.items():
                if metrics["attempts"] > 0:
                    success_rate = (metrics["successes"] / metrics["attempts"]) * 100
                    report += f"- **{model}**: {success_rate:.1f}% success ({metrics['successes']}/{metrics['attempts']})\n"
            report += "\n"
        
        # Common improvements needed
        report += "## Common Improvements by Task Type\n\n"
        for task_type, improvements in self.learned_patterns["task_improvements"].items():
            if improvements:
                report += f"### {task_type}\n"
                sorted_imp = sorted(improvements.items(), key=lambda x: x[1], reverse=True)
                for imp, count in sorted_imp[:5]:
                    report += f"- {imp}: {count} times\n"
                report += "\n"
        
        return report

class AdaptivePromptGenerator:
    """Generates adaptive prompts based on feedback"""
    
    def __init__(self, feedback_loop: OllamaFeedbackLoop):
        self.feedback_loop = feedback_loop
        self.prompt_templates = {
            "function_implementation": """
You are implementing a {language} function.

Task: {description}

Requirements:
{requirements}

IMPORTANT based on previous feedback:
{feedback_hints}

Provide a complete, production-ready implementation.
""",
            "test_generation": """
Generate tests for: {description}

Test framework: {framework}
Coverage target: {coverage}%

IMPORTANT based on previous feedback:
{feedback_hints}

Include edge cases, error conditions, and meaningful assertions.
""",
            "bug_fix": """
Fix the following bug: {description}

Context:
{context}

IMPORTANT based on previous feedback:
{feedback_hints}

Ensure the fix doesn't introduce new issues.
"""
        }
    
    def generate_adaptive_prompt(self, work_package: Dict[str, Any]) -> str:
        """Generate prompt adapted based on feedback"""
        task_type = work_package["task_type"]
        
        # Get base template
        template = self.prompt_templates.get(
            task_type,
            "Complete the following task: {description}"
        )
        
        # Get feedback hints
        feedback_hints = self.get_feedback_hints(task_type)
        
        # Fill template
        prompt = template.format(
            language=work_package["context"]["language"],
            description=work_package["description"],
            requirements="\n".join(f"- {r}" for r in work_package["requirements"]),
            framework=work_package["context"].get("framework", "default"),
            coverage=work_package["devsecops_checks"].get("coverage_threshold", 80),
            context=json.dumps(work_package["context"], indent=2),
            feedback_hints=feedback_hints
        )
        
        return prompt
    
    def get_feedback_hints(self, task_type: str) -> str:
        """Get hints based on previous feedback"""
        patterns = self.feedback_loop.learned_patterns
        hints = []
        
        # Add common improvements
        if task_type in patterns["task_improvements"]:
            improvements = patterns["task_improvements"][task_type]
            top_improvements = sorted(improvements.items(), key=lambda x: x[1], reverse=True)[:3]
            for imp, _ in top_improvements:
                hints.append(f"- {imp}")
        
        # Add success patterns
        if task_type in patterns["success_patterns"]:
            for pattern in patterns["success_patterns"][task_type][:2]:
                hints.append(f"- {pattern}")
        
        return "\n".join(hints) if hints else "- Follow best practices"

def integrate_feedback_loop(work_package: Dict[str, Any]) -> Dict[str, Any]:
    """Integrate feedback loop into work package"""
    feedback_loop = OllamaFeedbackLoop()
    prompt_generator = AdaptivePromptGenerator(feedback_loop)
    
    # Get recommended model
    recommended_model = feedback_loop.recommend_model(work_package["task_type"])
    if recommended_model:
        work_package["model"] = recommended_model
        logger.info(f"Using recommended model: {recommended_model}")
    
    # Enhance prompt with feedback
    enhanced_prompt = prompt_generator.generate_adaptive_prompt(work_package)
    work_package["enhanced_prompt"] = enhanced_prompt
    
    return work_package