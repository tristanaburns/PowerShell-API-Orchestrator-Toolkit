import time

class PerformanceProfiler:
    def __init__(self):
        self.start_time = None
        self.end_time = None

    def start(self):
        """Starts the timer."""
        self.start_time = time.time()

    def stop(self):
        """Stops the timer and calculates elapsed time."""
        if self.start_time is not None:
            self.end_time = time.time()
            return self.end_time - self.start_time
        else:
            raise RuntimeError("Timer was not started.")

    def get_last_duration(self):
        """Returns the duration of the last measurement."""
        if self.end_time is not None and self.start_time is not None:
            return self.end_time - self.start_time
        else:
            raise RuntimeError("No measurements available. Ensure the timer has been started and stopped.")