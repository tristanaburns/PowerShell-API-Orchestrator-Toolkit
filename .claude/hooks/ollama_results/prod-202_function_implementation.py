def list_models(self) -> List[str]:
    """
    Lists all available models provided by the AI service.

    Returns:
        List[str]: A list of model names.

    Raises:
        ValueError: If the API response is invalid.
        ConnectionError: If there is a network issue connecting to the AI service.
    """
    try:
        response = self._make_api_call("list_models")
        if not isinstance(response, dict) or "models" not in response:
            raise ValueError("Invalid API response")

        models = response["models"]
        if not isinstance(models, list):
            raise ValueError("API response does not contain a valid list of models")

        return [model for model in models if isinstance(model, str)]

    except ConnectionError as e:
        self._log_error(f"Connection error occurred: {e}")
        raise

    except Exception as e:
        self._log_error(f"An unexpected error occurred: {e}")
        raise
