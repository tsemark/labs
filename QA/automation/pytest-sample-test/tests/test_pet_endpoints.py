"""
Test cases for Pet endpoints.
Tests CRUD operations for pets.
"""
import pytest
from utils.api_helpers import (
    make_get_request,
    make_post_request,
    make_put_request,
    make_delete_request,
    APIResponse
)
from utils.validators import validate_pet_structure, validate_id_field


@pytest.mark.api
@pytest.mark.pet
@pytest.mark.smoke
class TestPetEndpoints:
    """Test Pet CRUD endpoints."""
    
    def test_get_pets_by_status_available(self, api_client, api_config):
        """
        Test GET /pet/findByStatus with status=available
        
        Test Steps:
        1. Get pets with status=available
        2. Verify response is 200 OK
        3. Verify response is a list
        4. Verify each pet has required fields
        """
        url = f"{api_config.base_url}/pet/findByStatus"
        params = {"status": "available"}
        
        response = make_get_request(api_client, url, params=params)
        
        response.assert_success("Should return 200 for available pets")
        data = response.get_data()
        
        assert isinstance(data, list), "Response should be a list"
        if len(data) > 0:
            assert validate_pet_structure(data[0]), "Pet should have required fields"
    
    def test_get_pets_by_status_pending(self, api_client, api_config):
        """Test GET /pet/findByStatus with status=pending."""
        url = f"{api_config.base_url}/pet/findByStatus"
        params = {"status": "pending"}
        
        response = make_get_request(api_client, url, params=params)
        response.assert_success()
        assert isinstance(response.get_data(), list)
    
    def test_get_pets_by_status_sold(self, api_client, api_config):
        """Test GET /pet/findByStatus with status=sold."""
        url = f"{api_config.base_url}/pet/findByStatus"
        params = {"status": "sold"}
        
        response = make_get_request(api_client, url, params=params)
        response.assert_success()
        assert isinstance(response.get_data(), list)
    
    def test_get_pet_by_id_success(self, api_client, api_config, cleanup_resources):
        """
        Test GET /pet/{petId} - Get pet by ID
        
        Test Steps:
        1. Create a pet
        2. Get pet by ID
        3. Verify response is 200 OK
        4. Verify pet data matches
        """
        # Create a pet first
        create_url = f"{api_config.base_url}/pet"
        pet_data = {
            "name": "TestPet",
            "photoUrls": ["http://example.com/photo.jpg"],
            "status": "available"
        }
        
        create_response = make_post_request(api_client, create_url, json_data=pet_data)
        create_response.assert_success("Should create pet successfully")
        created_pet = create_response.get_data()
        pet_id = created_pet.get("id")
        
        assert pet_id is not None, "Created pet should have an ID"
        cleanup_resources.append({"type": "pet", "id": pet_id, "url": f"{create_url}/{pet_id}"})
        
        # Get pet by ID
        get_url = f"{api_config.base_url}/pet/{pet_id}"
        response = make_get_request(api_client, get_url)
        
        response.assert_success("Should return pet by ID")
        pet = response.get_data()
        
        assert pet.get("id") == pet_id, "Should return correct pet"
        assert pet.get("name") == pet_data["name"], "Pet name should match"
    
    def test_get_pet_by_id_not_found(self, api_client, api_config):
        """Test GET /pet/{petId} with non-existent ID."""
        url = f"{api_config.base_url}/pet/999999999"
        
        response = make_get_request(api_client, url)
        response.assert_status_code(404, "Should return 404 for non-existent pet")
    
    def test_create_pet_success(self, api_client, api_config, sample_pet_data, cleanup_resources):
        """
        Test POST /pet - Create a new pet
        
        Test Steps:
        1. Create a pet with valid data
        2. Verify response is 200 OK
        3. Verify pet has ID
        4. Verify pet data matches request
        """
        url = f"{api_config.base_url}/pet"
        
        response = make_post_request(api_client, url, json_data=sample_pet_data)
        
        response.assert_success("Should create pet successfully")
        created_pet = response.get_data()
        
        assert validate_id_field(created_pet), "Created pet should have an ID"
        assert created_pet.get("name") == sample_pet_data["name"], "Pet name should match"
        
        pet_id = created_pet.get("id")
        cleanup_resources.append({"type": "pet", "id": pet_id, "url": f"{url}/{pet_id}"})
    
    def test_create_pet_with_invalid_data(self, api_client, api_config):
        """Test POST /pet with invalid data."""
        url = f"{api_config.base_url}/pet"
        invalid_data = {"invalid": "data"}
        
        response = make_post_request(api_client, url, json_data=invalid_data)
        # API might return 400 or 500 for invalid data
        assert response.is_client_error() or response.is_server_error(), \
            "Should return error for invalid data"
    
    def test_update_pet_success(self, api_client, api_config, cleanup_resources):
        """
        Test PUT /pet - Update an existing pet
        
        Test Steps:
        1. Create a pet
        2. Update pet data
        3. Verify response is 200 OK
        4. Verify pet was updated
        """
        # Create a pet
        create_url = f"{api_config.base_url}/pet"
        pet_data = {
            "name": "OriginalName",
            "photoUrls": ["http://example.com/photo.jpg"],
            "status": "available"
        }
        
        create_response = make_post_request(api_client, create_url, json_data=pet_data)
        create_response.assert_success()
        created_pet = create_response.get_data()
        pet_id = created_pet.get("id")
        cleanup_resources.append({"type": "pet", "id": pet_id, "url": f"{create_url}/{pet_id}"})
        
        # Update pet
        updated_data = {
            "id": pet_id,
            "name": "UpdatedName",
            "photoUrls": ["http://example.com/photo.jpg"],
            "status": "sold"
        }
        
        update_url = f"{api_config.base_url}/pet"
        response = make_put_request(api_client, update_url, json_data=updated_data)
        
        response.assert_success("Should update pet successfully")
        updated_pet = response.get_data()
        
        assert updated_pet.get("name") == "UpdatedName", "Pet name should be updated"
        assert updated_pet.get("status") == "sold", "Pet status should be updated"
    
    def test_delete_pet_success(self, api_client, api_config):
        """
        Test DELETE /pet/{petId} - Delete a pet
        
        Test Steps:
        1. Create a pet
        2. Delete the pet
        3. Verify response is 200 OK
        4. Verify pet is deleted (GET returns 404)
        """
        # Create a pet
        create_url = f"{api_config.base_url}/pet"
        pet_data = {
            "name": "PetToDelete",
            "photoUrls": ["http://example.com/photo.jpg"],
            "status": "available"
        }
        
        create_response = make_post_request(api_client, create_url, json_data=pet_data)
        create_response.assert_success()
        pet_id = create_response.get_data().get("id")
        
        # Delete pet
        delete_url = f"{api_config.base_url}/pet/{pet_id}"
        response = make_delete_request(api_client, delete_url)
        
        response.assert_success("Should delete pet successfully")
        
        # Verify pet is deleted
        get_response = make_get_request(api_client, delete_url)
        get_response.assert_status_code(404, "Pet should not exist after deletion")
    
    def test_delete_pet_not_found(self, api_client, api_config):
        """Test DELETE /pet/{petId} with non-existent ID."""
        url = f"{api_config.base_url}/pet/999999999"
        
        response = make_delete_request(api_client, url)
        # API might return 200 or 404 for non-existent pet
        assert response.status_code in [200, 404], "Should handle non-existent pet deletion"

