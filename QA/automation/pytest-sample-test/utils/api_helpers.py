"""
API helper functions for making requests and handling responses.
"""
import requests
from typing import Dict, Any, Optional, List
import json


class APIResponse:
    """Wrapper for API responses with helper methods."""
    
    def __init__(self, response: requests.Response):
        self.response = response
        self.status_code = response.status_code
        self.headers = response.headers
        
        try:
            self.json_data = response.json()
        except (ValueError, json.JSONDecodeError):
            self.json_data = None
        
        self.text = response.text
    
    def is_success(self) -> bool:
        """Check if response is successful (2xx status)."""
        return 200 <= self.status_code < 300
    
    def is_client_error(self) -> bool:
        """Check if response is a client error (4xx status)."""
        return 400 <= self.status_code < 500
    
    def is_server_error(self) -> bool:
        """Check if response is a server error (5xx status)."""
        return 500 <= self.status_code < 600
    
    def get_data(self) -> Any:
        """Get response data."""
        return self.json_data
    
    def get_error_message(self) -> Optional[str]:
        """Extract error message from response."""
        if self.json_data:
            if isinstance(self.json_data, dict):
                return self.json_data.get("message") or self.json_data.get("error")
        return self.text if self.text else None
    
    def assert_success(self, message: Optional[str] = None):
        """Assert that response is successful."""
        if not self.is_success():
            error_msg = self.get_error_message() or self.text
            raise AssertionError(
                message or f"Expected success status, got {self.status_code}. Error: {error_msg}"
            )
    
    def assert_status_code(self, expected_code: int, message: Optional[str] = None):
        """Assert specific status code."""
        if self.status_code != expected_code:
            error_msg = self.get_error_message() or self.text
            raise AssertionError(
                message or f"Expected status {expected_code}, got {self.status_code}. Error: {error_msg}"
            )


def make_get_request(
    session: requests.Session,
    url: str,
    params: Optional[Dict[str, Any]] = None,
    headers: Optional[Dict[str, str]] = None
) -> APIResponse:
    """Make a GET request."""
    response = session.get(url, params=params, headers=headers)
    return APIResponse(response)


def make_post_request(
    session: requests.Session,
    url: str,
    json_data: Optional[Dict[str, Any]] = None,
    data: Optional[Dict[str, Any]] = None,
    headers: Optional[Dict[str, str]] = None
) -> APIResponse:
    """Make a POST request."""
    response = session.post(url, json=json_data, data=data, headers=headers)
    return APIResponse(response)


def make_put_request(
    session: requests.Session,
    url: str,
    json_data: Optional[Dict[str, Any]] = None,
    data: Optional[Dict[str, Any]] = None,
    headers: Optional[Dict[str, str]] = None
) -> APIResponse:
    """Make a PUT request."""
    response = session.put(url, json=json_data, data=data, headers=headers)
    return APIResponse(response)


def make_delete_request(
    session: requests.Session,
    url: str,
    headers: Optional[Dict[str, str]] = None
) -> APIResponse:
    """Make a DELETE request."""
    response = session.delete(url, headers=headers)
    return APIResponse(response)
