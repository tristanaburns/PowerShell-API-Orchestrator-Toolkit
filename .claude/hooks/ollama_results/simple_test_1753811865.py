import ast
import os

class CodeMetricsCollector:
    def __init__(self):
        self.total_lines_of_code = 0
        self.total_classes = 0
        self.total_functions = 0
        self.cyclomatic_complexity = 0

    def analyze_file(self, file_path):
        try:
            with open(file_path, 'r', encoding='utf-8') as file:
                source_code = file.read()
                tree = ast.parse(source_code)
                self._analyze_tree(tree)
        except FileNotFoundError:
            print(f"File not found: {file_path}")
        except Exception as e:
            print(f"Error analyzing file {file_path}: {e}")

    def analyze_directory(self, directory_path):
        for root, _, files in os.walk(directory_path):
            for file in files:
                if file.endswith('.py'):
                    self.analyze_file(os.path.join(root, file))

    def _analyze_tree(self, node):
        if isinstance(node, ast.Module):
            self.total_lines_of_code = sum(1 for line in node.body if isinstance(line, (ast.FunctionDef, ast.ClassDef)))
            for child in node.body:
                self._analyze_tree(child)
        elif isinstance(node, ast.FunctionDef):
            self.total_functions += 1
            self.cyclomatic_complexity += self._calculate_cyclomatic_complexity(node)
        elif isinstance(node, ast.ClassDef):
            self.total_classes += 1
            for child in node.body:
                self._analyze_tree(child)

    def _calculate_cyclomatic_complexity(self, node):
        complexity = 1  # Start with 1 for the function entry point
        for child in ast.walk(node):
            if isinstance(child, (ast.If, ast.For, ast.While, ast.With)):
                complexity += 1
            elif isinstance(child, ast.ExceptHandler):
                complexity += 1
        return complexity

    def get_metrics(self):
        return {
            'total_lines_of_code': self.total_lines_of_code,
            'total_classes': self.total_classes,
            'total_functions': self.total_functions,
            'cyclomatic_complexity': self.cyclomatic_complexity
        }

# Example usage:
if __name__ == "__main__":
    collector = CodeMetricsCollector()
    collector.analyze_directory('path/to/your/python/project')
    metrics = collector.get_metrics()
    print(metrics)