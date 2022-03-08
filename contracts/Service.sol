// SPDX-License-Identifier: MIT
pragma solidity >=0.4.22 <0.9.0;

contract Service {

    enum Status { none, pending, rejected, accepted, started, completd, incomplete}

    struct service {
        string title;
        string description;
        uint256 price;     
        address serviceProvider;
        uint256 creationValue;
        Status status;
    }

    mapping (address => address) serviceRequesterList;
    mapping (uint256 => service) serviceProviderList;
    uint256 public numServiceProvider = 0;
    
    function createService (string memory title, string memory description, uint256 price) public payable returns (uint256) {
        require(bytes(title).length > 0, "A Service Title is required");
        require(bytes(description).length > 0, "A Service Description is required");
        require(price > 0, "A Service Price must be specified");
        // require(msg.value > 0.01 ether, "A minimum of 0.01 ETH is needed to create a Service");
        
        service memory newService = service(title,description,price,msg.sender,msg.value,Status.none);
        serviceProviderList[numServiceProvider] = newService;
        numServiceProvider = numServiceProvider++;
        return numServiceProvider;
    }

}