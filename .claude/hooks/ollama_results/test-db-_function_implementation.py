import threading
from queue import Queue
import time
import logging

# Initialize logging
logging.basicConfig(level=logging.INFO)
logger = logging.getLogger(__name__)

class DatabaseConnectionManager:
    """
    Manages database connections with connection pooling, automatic retry logic, and proper error handling.

    Args:
        pool_size (int): Maximum number of connections in the pool.
        max_retries (int): Maximum number of retries for a failed connection attempt.
        retry_delay (float): Delay between retry attempts in seconds.
        db_config (dict): Configuration dictionary for the database connection.
    """

    def __init__(self, pool_size: int = 5, max_retries: int = 3, retry_delay: float = 1.0, db_config: dict = None):
        self.pool_size = pool_size
        self.max_retries = max_retries
        self.retry_delay = retry_delay
        self.db_config = db_config or {}
        self.connection_pool = Queue(maxsize=pool_size)
        self.lock = threading.Lock()
        self._initialize_connections()

    def _initialize_connections(self):
        """
        Initializes the connection pool with the specified number of connections.
        """
        for _ in range(self.pool_size):
            try:
                connection = self._create_connection()
                self.connection_pool.put(connection)
            except Exception as e:
                logger.error(f"Failed to initialize connection: {e}")

    def _create_connection(self) -> object:
        """
        Creates a new database connection.

        Returns:
            object: Database connection object.
        """
        # Simulate connection creation
        return "DatabaseConnectionObject"

    def get_connection(self) -> object:
        """
        Retrieves a connection from the pool, with retry logic for failed attempts.

        Returns:
            object: Database connection object.
        """
        attempt = 0
        while attempt < self.max_retries:
            try:
                if not self.connection_pool.empty():
                    return self.connection_pool.get()
                else:
                    logger.warning("No available connections in the pool. Attempting to create a new one.")
                    return self._create_connection()
            except Exception as e:
                attempt += 1
                logger.error(f"Failed to get connection (attempt {attempt}): {e}")
                time.sleep(self.retry_delay)
        raise Exception("Failed to obtain database connection after retries.")

    def release_connection(self, connection: object):
        """
        Releases a connection back to the pool.

        Args:
            connection (object): Database connection object.
        """
        with self.lock:
            if not self.connection_pool.full():
                self.connection_pool.put(connection)
            else:
                logger.warning("Connection pool is full. Connection will be discarded.")

    def close_all_connections(self):
        """
        Closes all connections in the pool.
        """
        while not self.connection_pool.empty():
            connection = self.connection_pool.get()
            # Simulate closing a connection
            logger.info(f"Closing connection: {connection}")

# Example usage
if __name__ == "__main__":
    db_config = {
        "host": "localhost",
        "port": 5432,
        "user": "admin",
        "password": "secret"
    }
    manager = DatabaseConnectionManager(pool_size=3, max_retries=2, retry_delay=0.5, db_config=db_config)
    connection = manager.get_connection()
    logger.info(f"Obtained connection: {connection}")
    manager.release_connection(connection)
    manager.close_all_connections()
