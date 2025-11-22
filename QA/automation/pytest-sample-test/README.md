# Pytest API Testing Framework for Swagger Petstore API

A sample pytest-based API testing framework for testing the Swagger Petstore API. 

This uses https://github.com/swagger-api/swagger-petstore for testing

**Prerequisites:**
- Docker 
- Docker Compose 

## TLD;R
```bash
# Run all
docker-compose up --build

# RUN SPECIFIC TEST SUITE
#  docker-compose run --rm tests pytest -m <TEST_SUITE_NAME> -v
docker-compose run --rm tests pytest -m pet -v

docker-compose run --rm tests pytest -m smoke -v

# RUN SPECIFIC TEST CASE
# docker-compose run --rm tests pytest <PATH_FILE_TESTCASE> -v
docker-compose run --rm tests pytest tests/test_pet_endpoints.py::TestPetEndpoints::test_get_pets_by_status_available -v
```

## Test Reports
- **HTML Report**: `reports/report.html` 
- **JUnit XML**: `test-results/junit.xml` 
- **Coverage Report**: `reports/coverage/index.html` 

### **Best Practices Implemented**
- Page Object Model Pattern: API helpers abstract HTTP calls
- Fixture-based Setup: Reusable test fixtures for common operations
- Test Data Management: Factory pattern for generating test data
- Cleanup: Automatic resource cleanup after tests
- Markers: Test categorization for selective execution
- Validation: Comprehensive response validation
- Error Handling: Proper error message extraction and assertion
- Documentation: Clear test documentation and structure

