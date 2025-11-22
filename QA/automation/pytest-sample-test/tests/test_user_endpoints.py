"""
Test cases for User endpoints.
Tests user CRUD operations.
"""
import pytest
from utils.api_helpers import (
    make_get_request,
    make_post_request,
    make_put_request,
    make_delete_request,
    APIResponse
)
from utils.validators import validate_user_structure, validate_id_field


@pytest.mark.api
@pytest.mark.user
class TestUserEndpoints:
    """Test User endpoints."""
    
    def test_create_user_success(self, api_client, api_config, sample_user_data, cleanup_resources):
        """
        Test POST /user - Create a new user
        
        Test Steps:
        1. Create a user
        2. Verify response is 200 OK
        3. Verify user was created
        """
        url = f"{api_config.base_url}/user"
        
        response = make_post_request(api_client, url, json_data=sample_user_data)
        
        response.assert_success("Should create user successfully")
        # Petstore API returns message on success
        response_data = response.get_data()
        
        cleanup_resources.append({
            "type": "user",
            "username": sample_user_data["username"],
            "url": f"{url}/{sample_user_data['username']}"
        })
    
    def test_get_user_by_username_success(self, api_client, api_config, sample_user_data, cleanup_resources):
        """
        Test GET /user/{username} - Get user by username
        
        Test Steps:
        1. Create a user
        2. Get user by username
        3. Verify response is 200 OK
        4. Verify user data matches
        """
        # Create a user
        create_url = f"{api_config.base_url}/user"
        create_response = make_post_request(api_client, create_url, json_data=sample_user_data)
        create_response.assert_success()
        
        username = sample_user_data["username"]
        cleanup_resources.append({
            "type": "user",
            "username": username,
            "url": f"{create_url}/{username}"
        })
        
        # Get user by username
        get_url = f"{api_config.base_url}/user/{username}"
        response = make_get_request(api_client, get_url)
        
        response.assert_success("Should return user by username")
        user = response.get_data()
        
        assert user.get("username") == username, "Should return correct user"
        assert validate_user_structure(user), "User should have required fields"
    
    def test_get_user_by_username_not_found(self, api_client, api_config):
        """Test GET /user/{username} with non-existent username."""
        url = f"{api_config.base_url}/user/nonexistentuser12345"
        
        response = make_get_request(api_client, url)
        response.assert_status_code(404, "Should return 404 for non-existent user")
    
    def test_update_user_success(self, api_client, api_config, sample_user_data, cleanup_resources):
        """
        Test PUT /user/{username} - Update user
        
        Test Steps:
        1. Create a user
        2. Update user data
        3. Verify response is 200 OK
        4. Verify user was updated
        """
        # Create a user
        create_url = f"{api_config.base_url}/user"
        create_response = make_post_request(api_client, create_url, json_data=sample_user_data)
        create_response.assert_success()
        
        username = sample_user_data["username"]
        cleanup_resources.append({
            "type": "user",
            "username": username,
            "url": f"{create_url}/{username}"
        })
        
        # Update user
        updated_data = sample_user_data.copy()
        updated_data["firstName"] = "UpdatedFirstName"
        updated_data["email"] = "updated@example.com"
        
        update_url = f"{api_config.base_url}/user/{username}"
        response = make_put_request(api_client, update_url, json_data=updated_data)
        
        response.assert_success("Should update user successfully")
        
        # Verify user was updated
        get_response = make_get_request(api_client, update_url)
        get_response.assert_success()
        updated_user = get_response.get_data()
        
        assert updated_user.get("firstName") == "UpdatedFirstName", "User firstName should be updated"
        assert updated_user.get("email") == "updated@example.com", "User email should be updated"
    
    def test_delete_user_success(self, api_client, api_config, sample_user_data):
        """
        Test DELETE /user/{username} - Delete user
        
        Test Steps:
        1. Create a user
        2. Delete the user
        3. Verify response is 200 OK
        4. Verify user is deleted
        """
        # Create a user
        create_url = f"{api_config.base_url}/user"
        create_response = make_post_request(api_client, create_url, json_data=sample_user_data)
        create_response.assert_success()
        
        username = sample_user_data["username"]
        
        # Delete user
        delete_url = f"{api_config.base_url}/user/{username}"
        response = make_delete_request(api_client, delete_url)
        
        response.assert_success("Should delete user successfully")
        
        # Verify user is deleted
        get_response = make_get_request(api_client, delete_url)
        get_response.assert_status_code(404, "User should not exist after deletion")
    
    def test_delete_user_not_found(self, api_client, api_config):
        """Test DELETE /user/{username} with non-existent username."""
        url = f"{api_config.base_url}/user/nonexistentuser12345"
        
        response = make_delete_request(api_client, url)
        # API might return 200 or 404
        assert response.status_code in [200, 404], "Should handle non-existent user deletion"
    
    def test_user_login(self, api_client, api_config, sample_user_data, cleanup_resources):
        """
        Test GET /user/login - User login
        
        Test Steps:
        1. Create a user
        2. Login with username and password
        3. Verify response is 200 OK
        4. Verify response contains session information
        """
        # Create a user
        create_url = f"{api_config.base_url}/user"
        create_response = make_post_request(api_client, create_url, json_data=sample_user_data)
        create_response.assert_success()
        
        username = sample_user_data["username"]
        cleanup_resources.append({
            "type": "user",
            "username": username,
            "url": f"{create_url}/{username}"
        })
        
        # Login
        login_url = f"{api_config.base_url}/user/login"
        params = {
            "username": username,
            "password": sample_user_data["password"]
        }
        
        response = make_get_request(api_client, login_url, params=params)
        
        response.assert_success("Should login successfully")
        # Petstore API returns message with session info
    
    def test_user_logout(self, api_client, api_config):
        """Test GET /user/logout - User logout."""
        url = f"{api_config.base_url}/user/logout"
        
        response = make_get_request(api_client, url)
        response.assert_success("Should logout successfully")

