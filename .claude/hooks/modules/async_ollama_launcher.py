"""
Async Ollama Task Launcher
Handles background execution of Ollama tasks without blocking the main process
"""

import asyncio
import json
import logging
from pathlib import Path
from typing import Dict, Any, List
from collections import deque
from ollama_delegation import OllamaDelegation

logger = logging.getLogger(__name__)

class AsyncOllamaLauncher:
    """Launches Ollama tasks in background with sequential processing queue"""
    
    def __init__(self):
        self.delegation = OllamaDelegation()
        self.status_dir = Path(__file__).parent.parent / "ollama_status"
        self.status_dir.mkdir(exist_ok=True)
        
        # Task queue for sequential processing
        self.task_queue = deque()
        self.processing_task = None
        self.processor_running = False
    
    def launch_task_background(self, work_package: Dict[str, Any]) -> str:
        """Add task to queue for sequential processing"""
        task_id = work_package['id']
        status_file = self.status_dir / f"{task_id}.json"
        
        # Write initial status
        initial_status = {
            "task_id": task_id,
            "status": "queued",
            "timestamp": work_package.get("created_at"),
            "work_package": work_package,
            "queue_position": len(self.task_queue) + 1
        }
        
        with open(status_file, 'w') as f:
            json.dump(initial_status, f, indent=2)
        
        # Add to queue
        self.task_queue.append((work_package, status_file))
        
        # Start processor if not running
        if not self.processor_running:
            import threading
            
            def start_background_loop():
                try:
                    # Create new event loop for background thread
                    loop = asyncio.new_event_loop()
                    asyncio.set_event_loop(loop)
                    
                    # Run the sequential processor
                    loop.run_until_complete(self._start_sequential_processor())
                    
                except Exception as e:
                    logger.error(f"Background processor error: {e}")
                finally:
                    # Clean up loop
                    try:
                        loop.close()
                    except:
                        pass
            
            # Start background thread
            thread = threading.Thread(target=start_background_loop, daemon=True)
            thread.start()
            logger.info("Started background sequential processor thread")
        
        logger.info(f"Task {task_id} queued (position: {len(self.task_queue)})")
        return task_id
    
    async def _start_sequential_processor(self):
        """Start the sequential task processor"""
        if self.processor_running:
            return
            
        self.processor_running = True
        logger.info("Starting sequential Ollama processor...")
        
        try:
            while self.task_queue:
                # Get next task from queue
                work_package, status_file = self.task_queue.popleft()
                self.processing_task = work_package['id']
                
                # Update queue positions for remaining tasks
                self._update_queue_positions()
                
                logger.info(f"Processing task {self.processing_task} (Qwen 14B - {len(self.task_queue)} remaining)")
                
                # Process the task
                await self._process_task_async(work_package, status_file)
                
                self.processing_task = None
                
        finally:
            self.processor_running = False
            logger.info("Sequential Ollama processor stopped")
    
    def _update_queue_positions(self):
        """Update queue positions for all queued tasks"""
        for i, (work_package, status_file) in enumerate(self.task_queue):
            try:
                with open(status_file, 'r') as f:
                    status = json.load(f)
                status['queue_position'] = i + 1
                with open(status_file, 'w') as f:
                    json.dump(status, f, indent=2)
            except Exception:
                continue
    
    async def _process_task_async(self, work_package: Dict[str, Any], status_file: Path):
        """Process task asynchronously and monitor for completion"""
        task_id = work_package['id']
        
        try:
            # Update status to processing
            self._update_status(status_file, {
                "status": "processing",
                "message": "Qwen 14B is generating code..."
            })
            
            # Start Ollama generation and wait for completion
            result = await self._trigger_ollama_generation(work_package)
            
            # Check if Qwen used MCP tools to write file, otherwise extract from response
            if result.get("success"):
                await self._check_mcp_file_output(work_package, result.get("response", ""), status_file)
            else:
                self._update_status(status_file, {
                    "status": "error",
                    "message": f"Generation failed: {result.get('error', 'Unknown error')}"
                })
            
            logger.info(f"Task {task_id} completed - processing next task")
                
        except Exception as e:
            self._update_status(status_file, {
                "status": "error",
                "message": f"Task processing error: {str(e)}"
            })
            logger.error(f"Task {task_id} error: {e}")
    
    async def _trigger_ollama_generation(self, work_package: Dict[str, Any]):
        """Trigger Ollama generation and return result"""
        try:
            task_id = work_package['id']
            logger.info(f"Starting Ollama generation for {task_id}")
            
            # Use the async delegation method and wait for completion
            result = await self.delegation.delegate_to_ollama_async(work_package)
            
            logger.info(f"Ollama generation completed for {task_id}")
            return result
                
        except Exception as e:
            task_id = work_package['id']
            logger.error(f"Error triggering Ollama for {task_id}: {e}")
            return {"success": False, "error": str(e)}
    
    async def _check_mcp_file_output(self, work_package: Dict[str, Any], response: str, status_file: Path):
        """Check if Qwen used MCP tools to write file, otherwise extract from response"""
        task_id = work_package['id']
        
        try:
            # First check if file was written via MCP tools
            results_dir = self.status_dir.parent / "ollama_results"
            results_dir.mkdir(exist_ok=True)
            output_file = results_dir / f"{task_id}_implementation.py"
            
            if output_file.exists():
                # MCP tools were used successfully
                with open(output_file, 'r') as f:
                    code = f.read()
                
                self._update_status(status_file, {
                    "status": "completed",
                    "message": f"Qwen used MCP tools to write {output_file.name}",
                    "output_file": str(output_file),
                    "code_lines": len(code.split('\n')),
                    "code_chars": len(code),
                    "method": "mcp_tools"
                })
                
                logger.info(f"Task {task_id} - Qwen used MCP tools, wrote {len(code)} chars to {output_file}")
                return
            
            # Fallback: extract from response if MCP tools weren't used
            import re
            code_pattern = r"```python\n(.*?)```"
            matches = re.findall(code_pattern, response, re.DOTALL)
            
            if matches:
                code = matches[0].strip()
                
                with open(output_file, 'w') as f:
                    f.write(code)
                
                self._update_status(status_file, {
                    "status": "completed",
                    "message": f"Code extracted from response and saved to {output_file.name}",
                    "output_file": str(output_file),
                    "code_lines": len(code.split('\n')),
                    "code_chars": len(code),
                    "method": "response_extraction"
                })
                
                logger.info(f"Task {task_id} - extracted {len(code)} chars from response to {output_file}")
                
            else:
                # No code found anywhere
                self._update_status(status_file, {
                    "status": "error",
                    "message": "No MCP file output and no code block found in response",
                    "response_preview": response[:200] + "..." if len(response) > 200 else response
                })
                logger.error(f"Task {task_id} - no code found via MCP or response")
                
        except Exception as e:
            self._update_status(status_file, {
                "status": "error",
                "message": f"Error checking output: {str(e)}"
            })
            logger.error(f"Task {task_id} - error checking output: {e}")
    
    async def _monitor_completion(self, work_package: Dict[str, Any], status_file: Path):
        """Monitor and extract code from Qwen response - simplified approach"""
        task_id = work_package['id']
        
        # Since we're using direct prompting, the response should be immediate
        # Just mark as completed after generation
        await asyncio.sleep(2)  # Brief delay for generation
        
        # Check if code was generated in ollama_results
        results_dir = self.status_dir.parent / "ollama_results"
        code_files = list(results_dir.glob(f"{task_id}*.py"))
        
        if code_files:
            self._update_status(status_file, {
                "status": "completed",
                "message": f"Code generated: {code_files[0].name}",
                "output_files": [str(f) for f in code_files]
            })
            logger.info(f"Task {task_id} completed - code generated")
        else:
            self._update_status(status_file, {
                "status": "completed",
                "message": "Generation completed (check response for code)"
            })
            logger.info(f"Task {task_id} completed - response generated")
    
    def _update_status(self, status_file: Path, updates: Dict[str, Any]):
        """Update task status file"""
        try:
            # Read current status
            if status_file.exists():
                with open(status_file, 'r') as f:
                    status = json.load(f)
            else:
                status = {}
            
            # Apply updates
            status.update(updates)
            status['last_updated'] = asyncio.get_event_loop().time()
            
            # Write back
            with open(status_file, 'w') as f:
                json.dump(status, f, indent=2)
                
        except Exception as e:
            logger.error(f"Failed to update status file {status_file}: {e}")
    
    def get_task_status(self, task_id: str) -> Dict[str, Any]:
        """Get current task status"""
        status_file = self.status_dir / f"{task_id}.json"
        
        if not status_file.exists():
            return {"status": "not_found", "message": "Task not found"}
        
        try:
            with open(status_file, 'r') as f:
                return json.load(f)
        except Exception as e:
            return {"status": "error", "message": f"Failed to read status: {e}"}
    
    def list_active_tasks(self) -> list:
        """List all active tasks"""
        active_tasks = []
        
        for status_file in self.status_dir.glob("*.json"):
            try:
                with open(status_file, 'r') as f:
                    status = json.load(f)
                    if status.get("status") in ["queued", "processing"]:
                        active_tasks.append(status)
            except Exception:
                continue
                
        return active_tasks

# Singleton instance
launcher = AsyncOllamaLauncher()

def launch_async_task(work_package: Dict[str, Any]) -> str:
    """Launch async Ollama task and return task ID"""
    return launcher.launch_task_background(work_package)

def get_task_status(task_id: str) -> Dict[str, Any]:
    """Get task status by ID"""
    return launcher.get_task_status(task_id)

def list_active_tasks() -> list:
    """List all active background tasks"""
    return launcher.list_active_tasks()