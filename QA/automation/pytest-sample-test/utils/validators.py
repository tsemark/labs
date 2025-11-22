"""
Validation helpers for API responses.
"""
from typing import Dict, Any, List, Optional


def validate_pet_structure(data: Dict[str, Any]) -> bool:
    """Validate pet data structure."""
    required_fields = ["id", "name"]
    return all(field in data for field in required_fields)


def validate_order_structure(data: Dict[str, Any]) -> bool:
    """Validate order data structure."""
    required_fields = ["id", "petId", "quantity", "status"]
    return all(field in data for field in required_fields)


def validate_user_structure(data: Dict[str, Any]) -> bool:
    """Validate user data structure."""
    # User structure is flexible, but should have id or username
    return "id" in data or "username" in data


def validate_list_response(data: Any, min_items: int = 0) -> bool:
    """Validate that response is a list with minimum items."""
    return isinstance(data, list) and len(data) >= min_items


def validate_id_field(data: Dict[str, Any], field_name: str = "id") -> bool:
    """Validate that ID field exists and is valid."""
    return field_name in data and isinstance(data[field_name], (int, str)) and data[field_name] is not None
