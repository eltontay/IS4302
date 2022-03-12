// SPDX-License-Identifier: MIT
pragma solidity >=0.4.22 <0.9.0;

contract Service {

    enum Status { none, pending, rejected, accepted, started, completd, incomplete}

    struct service {
        string title;
        string description;
        uint256 price;     
        address serviceProvider;
        Status status;
        bool listed;
    }

    event serviceListed(uint256 serviceNumber);
    event serviceDelisted(uint256 serviceNumber);

    mapping (address => address) serviceRequesterList;
    mapping (uint256 => service) serviceProviderList;

    uint256 public numService = 0;
    
    function createService (string memory title, string memory description, uint256 price) public returns (uint256) {
        require(bytes(title).length > 0, "A Service Title is required");
        require(bytes(description).length > 0, "A Service Description is required");
        require(price > 0, "A Service Price must be specified");
        
        service memory newService = service(title,description,price,msg.sender,Status.none,false);
        serviceProviderList[numService] = newService;
        numService = numService++;
        return numService;
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

}