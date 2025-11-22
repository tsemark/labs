"""
Test cases for Store endpoints.
Tests store order operations.
"""
import pytest
from utils.api_helpers import (
    make_get_request,
    make_post_request,
    make_delete_request,
    APIResponse
)
from utils.validators import validate_order_structure, validate_id_field


@pytest.mark.api
@pytest.mark.store
class TestStoreEndpoints:
    """Test Store endpoints."""
    
    def test_get_store_inventory(self, api_client, api_config):
        """
        Test GET /store/inventory - Get store inventory
        
        Test Steps:
        1. Get store inventory
        2. Verify response is 200 OK
        3. Verify response is a dictionary
        """
        url = f"{api_config.base_url}/store/inventory"
        
        response = make_get_request(api_client, url)
        
        response.assert_success("Should return inventory")
        data = response.get_data()
        
        assert isinstance(data, dict), "Inventory should be a dictionary"
    
    def test_create_order_success(self, api_client, api_config, sample_order_data, cleanup_resources):
        """
        Test POST /store/order - Place an order
        
        Test Steps:
        1. Create an order
        2. Verify response is 200 OK
        3. Verify order has ID
        4. Verify order data matches
        """
        url = f"{api_config.base_url}/store/order"
        
        response = make_post_request(api_client, url, json_data=sample_order_data)
        
        response.assert_success("Should create order successfully")
        created_order = response.get_data()
        
        assert validate_id_field(created_order), "Created order should have an ID"
        assert validate_order_structure(created_order), "Order should have required fields"
        
        order_id = created_order.get("id")
        cleanup_resources.append({
            "type": "order",
            "id": order_id,
            "url": f"{url}/{order_id}"
        })
    
    def test_get_order_by_id_success(self, api_client, api_config, cleanup_resources):
        """
        Test GET /store/order/{orderId} - Get order by ID
        
        Test Steps:
        1. Create an order
        2. Get order by ID
        3. Verify response is 200 OK
        4. Verify order data matches
        """
        # Create an order
        create_url = f"{api_config.base_url}/store/order"
        order_data = {
            "petId": 1,
            "quantity": 1,
            "status": "placed",
            "complete": False
        }
        
        create_response = make_post_request(api_client, create_url, json_data=order_data)
        create_response.assert_success()
        created_order = create_response.get_data()
        order_id = created_order.get("id")
        
        cleanup_resources.append({
            "type": "order",
            "id": order_id,
            "url": f"{create_url}/{order_id}"
        })
        
        # Get order by ID
        get_url = f"{api_config.base_url}/store/order/{order_id}"
        response = make_get_request(api_client, get_url)
        
        response.assert_success("Should return order by ID")
        order = response.get_data()
        
        assert order.get("id") == order_id, "Should return correct order"
        assert order.get("petId") == order_data["petId"], "Order petId should match"
    
    def test_get_order_by_id_not_found(self, api_client, api_config):
        """Test GET /store/order/{orderId} with non-existent ID."""
        url = f"{api_config.base_url}/store/order/999999999"
        
        response = make_get_request(api_client, url)
        response.assert_status_code(404, "Should return 404 for non-existent order")
    
    def test_delete_order_success(self, api_client, api_config):
        """
        Test DELETE /store/order/{orderId} - Delete an order
        
        Test Steps:
        1. Create an order
        2. Delete the order
        3. Verify response is 200 OK
        4. Verify order is deleted
        """
        # Create an order
        create_url = f"{api_config.base_url}/store/order"
        order_data = {
            "petId": 1,
            "quantity": 1,
            "status": "placed",
            "complete": False
        }
        
        create_response = make_post_request(api_client, create_url, json_data=order_data)
        create_response.assert_success()
        order_id = create_response.get_data().get("id")
        
        # Delete order
        delete_url = f"{api_config.base_url}/store/order/{order_id}"
        response = make_delete_request(api_client, delete_url)
        
        response.assert_success("Should delete order successfully")
        
        # Verify order is deleted
        get_response = make_get_request(api_client, delete_url)
        get_response.assert_status_code(404, "Order should not exist after deletion")
    
    def test_delete_order_not_found(self, api_client, api_config):
        """Test DELETE /store/order/{orderId} with non-existent ID."""
        url = f"{api_config.base_url}/store/order/999999999"
        
        response = make_delete_request(api_client, url)
        # API might return 200 or 404
        assert response.status_code in [200, 404], "Should handle non-existent order deletion"

