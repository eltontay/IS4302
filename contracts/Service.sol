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
    }

    mapping (address => address) serviceRequesterList;
    mapping (uint256 => service) serviceProviderList;

    uint256 public numService = 0;
    
    function createService (string memory title, string memory description, uint256 price) public returns (uint256) {
        require(bytes(title).length > 0, "A Service Title is required");
        require(bytes(description).length > 0, "A Service Description is required");
        require(price > 0, "A Service Price must be specified");
        
        service memory newService = service(title,description,price,msg.sender,Status.none);
        serviceProviderList[numService] = newService;
        numService = numService++;
        return numService;
    }

    function listService ()

}