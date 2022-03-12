// SPDX-License-Identifier: MIT
pragma solidity >=0.4.22 <0.9.0;

import "@openzeppelin/contracts/utils/Strings.sol";

contract Service {

    enum Status { none, pending, rejected, accepted, started, completd, incomplete }

    struct service {
        string title;
        string description;
        uint256 price;
        uint256 serviceNumber; // index number of the service
        address serviceProvider; 
        address serviceRequester; // defaults to address(0)
        Status status;
        bool listed;
    }

    event serviceCreated(uint256 serviceNumber);
    event serviceDeleted(uint256 serviceNumber);
    event serviceListed(uint256 serviceNumber);
    event serviceDelisted(uint256 serviceNumber);

    mapping (uint256 => service) serviceProviderList; // indexed mapping of all service providers
    
    uint256 public numService = 0;
    
    // Creation of service
    function createService (string memory title, string memory description, uint256 price) public returns (uint256) {
        require(bytes(title).length > 0, "A Service Title is required");
        require(bytes(description).length > 0, "A Service Description is required");
        require(price > 0, "A Service Price must be specified");
        
        service memory newService = service(title,description,price,numService,msg.sender,address(0),Status.none,false);
        serviceProviderList[numService] = newService;
        emit serviceCreated(numService);
        numService = numService++;
        return numService;
    }

    // Deletion of service 
    function deleteService (uint256 serviceNumber) public {
        require(msg.sender == serviceProviderList[serviceNumber].serviceProvider, "Unauthorised service provider");
        // replacing deleted spot with the last element in the list
        serviceProviderList[serviceNumber] = serviceProviderList[numService-1];
        // deleting the last element in the list
        delete serviceProviderList[numService-1];
        emit serviceDeleted(serviceNumber);
        numService -= 1; 
    }

    // Service provider listing created service
    function listService (uint256 serviceNumber) public {
        require(msg.sender == serviceProviderList[serviceNumber].serviceProvider, "Unauthorised service provider");
        serviceProviderList[serviceNumber].listed = true;
        emit serviceListed(serviceNumber);
    }

    // Service provider delisting created service
    function delistService (uint256 serviceNumber) public {
        require(msg.sender == serviceProviderList[serviceNumber].serviceProvider, "Unauthorised service provider");
        serviceProviderList[serviceNumber].listed = false; 
        emit serviceDelisted(serviceNumber);
    }

    // Service requester requesting of service
    function requestService (uint256 serviceNumber) public {
        
    }

    // Service
    function cancelRequestService (uint256 serviceNumber) public {

    }

    // Getter for services created by service provider
    function viewMyServices() public view returns (string memory) {
        string memory services = "";
        for (uint i = 0; i < numService; i++) {
            if (serviceProviderList[i].serviceProvider == msg.sender) {
                services = string(abi.encodePacked(services, ' ', Strings.toString(numService)));
            }
        }
        return services;
    }

    // Getter for total number of services listed
    function getNumServices() public view returns (uint256) {
        return numService;
    }

    // Getter for service details
    function getServiceDetails(uint256 serviceNumber) public view returns (service memory) {
        return serviceProviderList[serviceNumber];
    }

}