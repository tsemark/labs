### [Multi tenant ecommerce platform - Data Injection Project]

# Test Data Injection - Technical Documentation

## Overview

The Test Data Injection System is an internal tooling solution designed to prepare and inject test data for both automated and manual testing scenarios. This tool supports a complex ecommerce platform that integrates multiple subsystems including inventory management, point-of-sale (POS), reservation system, checkout/payment processing and more.

## Problem Statement

### Requirements
- Generate test data for automation test suites
- Prepare test data for manual testing activities
- Support a multi-system platform with interconnected components
- Work within blackbox testing constraints with limited direct access to system internals

### Challenges
- Limited developer support and documentation
- Blackbox approach restricts direct database access
- Some API endpoints unavailable or inaccessible
- Need to support various data creation scenarios across different system components
- Edge cases requiring frontend interaction

## Architecture

The system employs a multi-layered approach with three distinct data injection strategies, each serving different use cases and scenarios:

1. **Database Layer (SQL Scripts)** - Direct database manipulation for foundational data
2. **API Layer (Flask Wrapper)** - Programmatic data creation through API endpoints
3. **UI Layer (Selenium Automation)** - Frontend-based data injection for edge cases

## Implementation Approaches

### 1. SQL Script-Based Injection

#### Purpose
Primary method for creating foundational and master data that serves as the base for all testing scenarios.

#### Use Cases
- Master account registration
- Initial account configuration data
- Core reference data required across all systems
- Data that must exist before other components can function

#### Implementation Details
- Collection of SQL scripts organized by data type and system component
- Scripts designed to create data in the correct dependency order
- Handles master account setup and platform initialization
- Limited to scenarios where developers provided SQL access and scripts

#### Limitations
- Requires database access permissions
- Dependent on developer-provided SQL scripts
- Limited flexibility for dynamic data generation
- Cannot handle complex business logic validations

### 2. API-Based Injection (Flask Wrapper)

#### Purpose
Primary method for creating test data through the application's API layer, enabling programmatic data creation that respects business logic and validation rules.

#### Architecture
- Python Flask application serving as an API wrapper
- Encapsulates all necessary API endpoint calls
- Implements API call chaining to handle dependent operations
- Provides abstraction layer for test data creation workflows

#### Implementation Details
- Wraps existing platform API endpoints
- Supports chained API calls to create complex data relationships
- Enables product injection to specific user accounts
- Handles authentication and session management
- Manages API request/response processing and error handling

#### Capabilities
- Create products and associate them with user accounts
- Handle multi-step data creation workflows through call chaining
- Respect application business rules and validations
- Support for various data types across inventory, POS, and reservation systems

#### Limitations
- Limited to available and accessible API endpoints
- Some endpoints may not be exposed or accessible
- Dependent on API stability and versioning
- May not cover all edge cases handled by frontend logic

### 3. Frontend-Based Injection (Selenium)

#### Purpose
Fallback method for data injection scenarios where API endpoints are unavailable or when frontend-specific logic is required.

#### Architecture
- Java-based Selenium automation framework
- Headless browser execution for efficiency
- Reuses existing UI automation infrastructure
- Simulates user interactions through the frontend

#### Implementation Details
- Ported from existing Java Selenium UI automation framework
- Executes in headless mode for performance
- Navigates through frontend workflows to create data
- Handles form submissions, validations, and UI interactions
- Supports edge cases that require frontend-specific processing

#### Use Cases
- Data creation scenarios not supported by API
- Edge cases requiring frontend business logic
- Complex workflows that span multiple UI pages
- Scenarios where API endpoints are restricted or unavailable

#### Limitations
- Slower execution compared to API or SQL methods
- More brittle due to UI element dependencies
- Requires maintenance when UI changes
- Resource-intensive (browser instances)

## Technology Stack

### Backend Services
- **Python Flask** - API wrapper application framework
- Provides RESTful interface for test data injection operations
- Handles API endpoint orchestration and chaining

### Automation Framework
- **Java Selenium** - UI automation and frontend data injection
- Headless browser execution for frontend-based data creation
- Reuses existing automation infrastructure

### Database
- **SQL Scripts** - Direct database manipulation
- Platform-specific database
- Script-based execution for foundational data

## System Integration

### Workflow
1. **Initialization Phase**: SQL scripts execute to create master accounts and foundational data
2. **Primary Data Creation**: Flask API wrapper creates most test data through API endpoints
3. **Edge Case Handling**: Selenium automation handles scenarios not covered by API

### Data Flow
- Master data flows from SQL scripts to API wrapper
- API wrapper creates dependent data using master data references
- Frontend automation supplements data creation for edge cases
- All methods contribute to a comprehensive test data set

## Design Principles

### Blackbox Approach
- Works within constraints of limited system knowledge
- Leverages available interfaces (database, API, UI)
- Adapts to system limitations without requiring deep internal access

### Self-Sufficiency
- Independent automation team solution
- Minimal dependency on application/engineering team support
- Self-contained tooling for test data management

### Flexibility
- Multiple injection methods provide fallback options
- Adapts to different data creation requirements
- Handles various system components and scenarios

## Operational Considerations

### Execution Strategy
- SQL scripts run first to establish foundational data
- API wrapper handles bulk of data creation
- Selenium automation addresses remaining edge cases

### Maintenance
- SQL scripts require updates when database schema changes
- API wrapper must adapt to API version changes
- Selenium automation needs updates for UI changes

### Scalability
- API-based approach provides best performance
- SQL scripts offer fastest execution for bulk foundational data
- Selenium automation is resource-intensive and used sparingly

## Limitations and Constraints

### Technical Limitations
- Blackbox approach limits visibility into system internals
- Dependent on developer-provided SQL scripts (limited scope)
- Some API endpoints unavailable or inaccessible
- Frontend automation is slower and more fragile

### Operational Constraints
- Limited support from application/engineering team
- Must work within existing system interfaces
- No direct access to internal system components
- Dependent on system stability and API availability

## Future Considerations

### Potential Enhancements
- Expand SQL script coverage with more developer collaboration
- Identify and document all available API endpoints
- Optimize Selenium automation for better performance
- Create unified interface for all three injection methods
- Implement data cleanup and reset capabilities
- Add data validation and verification mechanisms

### Integration Opportunities
- Integrate with test execution frameworks
- Provide data injection as a service for other teams
- Create data templates for common test scenarios
- Implement data versioning and rollback capabilities

---

## Summary

The Test Data Injection System provides a comprehensive solution for test data preparation across multiple system layers. By combining SQL scripts, API wrappers, and UI automation, the system addresses various data creation needs while working within blackbox testing constraints. The multi-layered approach ensures flexibility and coverage for both automated and manual testing requirements.
