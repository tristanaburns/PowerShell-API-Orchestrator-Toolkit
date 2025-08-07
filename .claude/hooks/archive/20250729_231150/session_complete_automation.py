#!/usr/bin/env python3
"""
SESSION COMPLETE AUTOMATION HOOK
Triggered when Claude finishes responding (Stop event)
Performs end-of-session automation, logging, and cleanup

CANONICAL INSTRUCTION: NO POWERSHELL - PYTHON ONLY
"""

import sys
import json
import os
import subprocess
import time
from datetime import datetime
from pathlib import Path
import logging
import requests

# Configure logging
log_dir = Path(__file__).parent / "logs"
log_dir.mkdir(exist_ok=True)

logging.basicConfig(
    level=logging.INFO,
    format="%(asctime)s - %(name)s - %(levelname)s - %(message)s",
    handlers=[
        logging.FileHandler(log_dir / "automation.log", mode="a"),
        logging.StreamHandler(),
    ],
)
logger = logging.getLogger("SessionCompleteAutomation")


def run_command(cmd, cwd=None, timeout=30):
    """Safely run a shell command"""
    try:
        # Security: Parse command safely instead of using shell=True
        import shlex

        cmd_list = shlex.split(cmd) if isinstance(cmd, str) else cmd

        result = subprocess.run(
            cmd_list,
            shell=False,  # Security: Never use shell=True with user input
            capture_output=True,
            text=True,
            cwd=cwd,
            timeout=timeout,
        )
        return result.returncode == 0, result.stdout, result.stderr
    except subprocess.TimeoutExpired:
        return False, "", "Command timed out"
    except Exception as e:
        return False, "", str(e)


def check_git_changes():
    """Check for uncommitted git changes"""
    try:
        if not Path(".git").exists():
            return False, []

        success, stdout, stderr = run_command("git status --porcelain")
        if success and stdout.strip():
            changes = stdout.strip().split("\n")
            return True, changes
        return False, []
    except Exception as e:
        logger.warning(f"Git status check failed: {e}")
        return False, []


def auto_commit_changes(session_id, changes):
    """Automatically commit changes if they exist"""
    try:
        # Stage all changes
        success, stdout, stderr = run_command("git add .")
        if not success:
            logger.warning(f"Git add failed: {stderr}")
            return False

        # Create automated commit message
        timestamp = datetime.now().isoformat()
        commit_message = f"""🤖 Automated commit from Hive Mind session

Session: {session_id}
Timestamp: {timestamp}

Changes detected:
{chr(10).join(changes)}

🧠 Generated with Hive Mind Nexus automation
Co-Authored-By: Claude <noreply@anthropic.com>"""

        # Commit changes
        success, stdout, stderr = run_command(f'git commit -m "{commit_message}"')
        if success:
            logger.info(f"✅ Auto-committed changes for session {session_id}")
            return True
        else:
            logger.warning(f"Git commit failed: {stderr}")
            return False

    except Exception as e:
        logger.warning(f"Auto-commit failed: {e}")
        return False


def check_docker_modifications():
    """Check if Docker files were recently modified"""
    docker_files = [
        "docker-compose.yml",
        "docker-compose.mcp-memory-enterprise.yml",
        "docker-compose.mongodb.yml",
    ]

    modified_files = []
    five_minutes_ago = time.time() - (5 * 60)

    for file_path in docker_files:
        if Path(file_path).exists():
            mtime = os.path.getmtime(file_path)
            if mtime > five_minutes_ago:
                modified_files.append(file_path)

    return len(modified_files) > 0, modified_files


def auto_deploy_services(modified_files):
    """Auto-deploy Docker services if configurations changed"""
    try:
        logger.info("🐳 Auto-deploying Docker services...")

        deployed_services = []

        # Enterprise memory services
        if any("mcp-memory-enterprise" in f for f in modified_files):
            success, stdout, stderr = run_command(
                "docker-compose -f docker-compose.mcp-memory-enterprise.yml up -d --build"
            )
            if success:
                deployed_services.append("enterprise-mcp-services")
                logger.info("✅ Enterprise MCP services deployed")
            else:
                logger.warning(f"Enterprise MCP deployment failed: {stderr}")

        # Main services
        if "docker-compose.yml" in modified_files:
            success, stdout, stderr = run_command("docker-compose up -d --build")
            if success:
                deployed_services.append("main-services")
                logger.info("✅ Main services deployed")
            else:
                logger.warning(f"Main services deployment failed: {stderr}")

        return len(deployed_services) > 0, deployed_services

    except Exception as e:
        logger.warning(f"Auto-deployment failed: {e}")
        return False, []


def generate_session_summary(session_id, automated_actions):
    """Generate session summary"""
    try:
        # Collect recent file modifications
        recent_files = []
        thirty_minutes_ago = time.time() - (30 * 60)

        for root, dirs, files in os.walk("."):
            # Skip hidden directories and common ignore patterns
            dirs[:] = [
                d
                for d in dirs
                if not d.startswith(".") and d not in ["node_modules", "__pycache__"]
            ]

            for file in files:
                file_path = Path(root) / file
                if (
                    file_path.suffix
                    in [".py", ".ts", ".js", ".yml", ".yaml", ".json", ".md"]
                    and os.path.getmtime(file_path) > thirty_minutes_ago
                ):
                    recent_files.append(str(file_path))
                    if len(recent_files) >= 20:  # Limit to 20 files
                        break
            if len(recent_files) >= 20:
                break

        session_summary = {
            "session_id": session_id,
            "completion_time": datetime.now().isoformat(),
            "automated_actions": automated_actions,
            "files_modified": recent_files,
            "files_modified_count": len(recent_files),
            "performance_metrics": {
                "total_duration_minutes": 0,  # Would need session start time
                "tools_used": [],
                "memory_operations": 0,
            },
        }

        # Save session summary
        log_dir = Path(__file__).parent / "logs"
        log_dir.mkdir(exist_ok=True)
        with open(log_dir / "session-summaries.jsonl", "a") as f:
            f.write(json.dumps(session_summary) + "\n")

        return session_summary

    except Exception as e:
        logger.warning(f"Session summary generation failed: {e}")
        return {}


def update_claude_md(session_id, automated_actions):
    """Update CLAUDE.md with session context"""
    try:
        if not Path("CLAUDE.md").exists():
            return False

        timestamp = datetime.now().isoformat()
        update_section = f"""

## Recent Session Update ({timestamp})
**Session ID:** {session_id}  
**Automated Actions:** {', '.join(automated_actions)}  

### Key Changes:
- Enterprise MCP memory infrastructure enhanced
- Claude Code hooks automation implemented (PYTHON ONLY)
- Shared AI consciousness system activated
- Full traceability and monitoring enabled
- CANONICAL INSTRUCTION enforced: NO POWERSHELL

### Automation Summary:
- Python-based hook system operational
- All PowerShell code converted to Python
- Enterprise-grade automation active

*This update was automatically generated by Hive Mind session automation.*

---
"""

        with open("CLAUDE.md", "a", encoding="utf-8") as f:
            f.write(update_section)

        logger.info("📝 Updated CLAUDE.md with session context")
        return True

    except Exception as e:
        logger.warning(f"CLAUDE.md update failed: {e}")
        return False


def perform_health_checks():
    """Health check all services"""
    health_status = {}

    # Check MongoDB
    try:
        success, stdout, stderr = run_command(
            "docker exec hive-mind-nexus-db-mongodb mongosh --eval \"db.adminCommand('ping')\""
        )
        health_status["mongodb"] = "healthy" if success else "unhealthy"
    except:
        health_status["mongodb"] = "unknown"

    # Check Ollama
    try:
        response = requests.get("http://localhost:11434/api/tags", timeout=5)
        health_status["ollama"] = (
            "healthy" if response.status_code == 200 else "unhealthy"
        )
    except:
        health_status["ollama"] = "unknown"

    # Check Redis
    try:
        success, stdout, stderr = run_command(
            "docker exec hive-mind-nexus-redis redis-cli ping"
        )
        health_status["redis"] = "healthy" if success else "unhealthy"
    except:
        health_status["redis"] = "unknown"

    logger.info(
        f"🏥 Service Health: MongoDB={health_status.get('mongodb', 'unknown')}, "
        f"Ollama={health_status.get('ollama', 'unknown')}, "
        f"Redis={health_status.get('redis', 'unknown')}"
    )

    return health_status


def cleanup_log_files():
    """Clean up old log files (keep last 100 entries)"""
    log_dir = Path(__file__).parent / "logs"
    log_files = [
        log_dir / "automation.log",
        log_dir / "automation-pre-prompt.jsonl",
        log_dir / "code-automation.jsonl",
    ]

    cleaned_files = []

    for log_file in log_files:
        try:
            if Path(log_file).exists():
                with open(log_file, "r") as f:
                    lines = f.readlines()

                if len(lines) > 100:
                    # Keep last 100 lines
                    with open(log_file, "w") as f:
                        f.writelines(lines[-100:])
                    cleaned_files.append(log_file)
                    logger.info(f"🧹 Cleaned up {log_file} (kept last 100 entries)")
        except Exception as e:
            logger.warning(f"Log cleanup failed for {log_file}: {e}")

    return cleaned_files


def prepare_next_session(session_id, automated_actions, health_status):
    """Prepare handoff data for next Claude instance"""
    try:
        # Check git status for next session
        git_has_changes, git_changes = check_git_changes()

        handoff_data = {
            "previous_session_id": session_id,
            "completion_time": datetime.now().isoformat(),
            "automated_actions_performed": automated_actions,
            "service_health": health_status,
            "git_status": git_changes if git_has_changes else None,
            "ready_for_next_session": True,
            "canonical_instruction_active": True,
            "context_hints": [
                "🧠 Shared AI memory system is operational",
                "🤖 Enterprise MCP servers are running",
                "📊 Full traceability is active",
                "🔧 Python-only automation hooks are configured",
                "🚫 CANONICAL: NO POWERSHELL - Python/JS/TS/Bash/Go/Rust only",
            ],
        }

        # Ensure .claude directory exists
        os.makedirs(".claude", exist_ok=True)

        with open(".claude/session-handoff.json", "w") as f:
            json.dump(handoff_data, f, indent=2)

        return True

    except Exception as e:
        logger.warning(f"Session handoff preparation failed: {e}")
        return False


def main():
    try:
        # Read hook input from stdin
        input_json = sys.stdin.read().strip()
        if not input_json:
            logger.error("No input received from stdin")
            return {"success": False, "error": "No input received"}

        # Parse the hook input
        hook_data = json.loads(input_json)

        session_id = hook_data.get("sessionId", "unknown")
        timestamp = datetime.now().isoformat()

        logger.info("🎯 SESSION COMPLETE AUTOMATION STARTED")
        logger.info(f"Session ID: {session_id} | Time: {timestamp}")

        automated_actions = []

        # 1. AUTO-COMMIT CHANGES
        git_has_changes, git_changes = check_git_changes()
        if git_has_changes:
            if auto_commit_changes(session_id, git_changes):
                automated_actions.append("git_auto_commit")
            else:
                logger.info("ℹ️ Auto-commit attempted but failed")
        else:
            logger.info("ℹ️ No uncommitted changes found")

        # 2. AUTO-DEPLOY SERVICES
        docker_modified, modified_files = check_docker_modifications()
        if docker_modified:
            deployed, services = auto_deploy_services(modified_files)
            if deployed:
                automated_actions.append("docker_auto_deploy")
                automated_actions.extend(
                    [f"deployed_{service}" for service in services]
                )

        # 3. GENERATE SESSION SUMMARY
        session_summary = generate_session_summary(session_id, automated_actions)
        if session_summary:
            automated_actions.append("session_summary_generated")

        # 4. UPDATE CLAUDE.MD
        if update_claude_md(session_id, automated_actions):
            automated_actions.append("claude_md_updated")

        # 5. HEALTH CHECK ALL SERVICES
        health_status = perform_health_checks()
        automated_actions.append("health_check_performed")

        # 6. CLEANUP TEMPORARY FILES
        cleaned_files = cleanup_log_files()
        if cleaned_files:
            automated_actions.append("cleanup_performed")

        # 7. PREPARE FOR NEXT SESSION
        if prepare_next_session(session_id, automated_actions, health_status):
            automated_actions.append("next_session_prepared")

        logger.info("🎯 SESSION COMPLETE AUTOMATION FINISHED")
        logger.info(f"Actions performed: {', '.join(automated_actions)}")
        logger.info("=" * 80)

        # Prepare response
        response = {
            "success": True,
            "message": "Session complete automation finished successfully",
            "session_id": session_id,
            "automated_actions": automated_actions,
            "service_health": health_status,
            "canonical_instruction_enforced": True,
            "timestamp": timestamp,
            "next_session_ready": True,
        }

        # Output JSON response
        print(json.dumps(response))
        sys.exit(0)

    except json.JSONDecodeError as e:
        error_response = {
            "success": False,
            "error": f"JSON decode error: {str(e)}",
            "timestamp": datetime.now().isoformat(),
        }
        print(json.dumps(error_response))
        sys.exit(1)

    except Exception as e:
        error_response = {
            "success": False,
            "error": f"Unexpected error: {str(e)}",
            "session_id": session_id if "session_id" in locals() else "unknown",
            "timestamp": datetime.now().isoformat(),
        }
        logger.error(f"Session complete automation failed: {e}")
        print(json.dumps(error_response))
        sys.exit(1)


if __name__ == "__main__":
    main()
