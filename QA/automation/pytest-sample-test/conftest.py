"""
Pytest configuration and shared fixtures for Petstore API testing.
"""
import os
import pytest
import requests
from typing import Generator, Dict, Any, Optional
from dataclasses import dataclass


@dataclass
class APIConfig:
    """API configuration settings."""
    base_url: str
    timeout: int = 30
    verify_ssl: bool = False


@pytest.fixture(scope="session")
def api_config() -> APIConfig:
    """
    API configuration fixture.
    Reads from environment variables or uses defaults.
    """
    base_url = os.getenv("API_BASE_URL", "http://localhost:8080/api")
    timeout = int(os.getenv("API_TIMEOUT", "30"))
    verify_ssl = os.getenv("API_VERIFY_SSL", "false").lower() == "true"
    
    return APIConfig(
        base_url=base_url,
        timeout=timeout,
        verify_ssl=verify_ssl
    )


@pytest.fixture(scope="session")
def api_client(api_config: APIConfig) -> requests.Session:
    """
    Create a reusable requests session for API calls.
    """
    session = requests.Session()
    session.timeout = api_config.timeout
    session.verify = api_config.verify_ssl
    
    session.headers.update({
        "Content-Type": "application/json",
        "Accept": "application/json"
    })
    
    return session


@pytest.fixture
def cleanup_resources(api_client: requests.Session, api_config: APIConfig) -> Generator:
    """
    Fixture to track and cleanup created resources after tests.
    """
    created_resources = []
    
    yield created_resources
    
    for resource in reversed(created_resources):
        resource_type = resource.get("type")
        resource_id = resource.get("id")
        resource_url = resource.get("url")
        
        if resource_url:
            try:
                api_client.delete(resource_url)
            except requests.RequestException:
                pass 


@pytest.fixture
def sample_pet_data() -> Dict[str, Any]:
    """Generate sample pet data for testing."""
    from faker import Faker
    fake = Faker()
    
    return {
        "name": fake.first_name(),
        "photoUrls": [fake.image_url()],
        "status": "available"
    }


@pytest.fixture
def sample_order_data() -> Dict[str, Any]:
    """Generate sample order data for testing."""
    from faker import Faker
    fake = Faker()
    
    import random
    return {
        "petId": random.randint(1, 1000),
        "quantity": random.randint(1, 10),
        "shipDate": fake.iso8601(),
        "status": "placed",
        "complete": False
    }


@pytest.fixture
def sample_user_data() -> Dict[str, Any]:
    """Generate sample user data for testing."""
    from faker import Faker
    fake = Faker()
    
    return {
        "username": fake.user_name(),
        "firstName": fake.first_name(),
        "lastName": fake.last_name(),
        "email": fake.email(),
        "password": fake.password(),
        "phone": fake.phone_number(),
        "userStatus": 0
    }
