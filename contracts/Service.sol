// SPDX-License-Identifier: MIT
pragma solidity >=0.4.22 <0.9.0;
import "./Milestone.sol";

import "@openzeppelin/contracts/utils/Strings.sol";

/*
    1. Service Requester (Project Owner)
    2. Service Providers (Stakeholders)
    Each Service contains milestone(s)
    Each Milestone allows conflict(s) to be raised by the service requester.
*/
contract Service {

    Milestone milestone;

    constructor (Milestone milestoneContract) public {
        milestone = milestoneContract;
    }

    enum Status { none, pending, approved, started, completed, conflict }

    struct service {
        uint256 projectNumber;
        uint256 serviceNumber;
        string title;
        string description;
        uint256 price;
        uint256 currentMilestone; // Defaults to 0 milestone
        address serviceRequester; // msg.sender
        address serviceProvider; // defaults to address(0)
        bool exist; // allowing update such as soft delete of service
        Status status; // Defaults at none
    }

/*
    Events - Service Requester (Project Owner)
*/
    event serviceCreated(uint256 projectNumber, uint256 serviceNumber, string title, string description, uint256 price);
    event serviceUpdated(uint256 projectNumber, uint256 serviceNumber, string title, string description, uint256 price);
    event serviceDeleted(uint256 projectNumber, uint256 serviceNumber);

    mapping (uint256 => service[]) projectServices; // [projectNumber][serviceNumber]

/*
    Modifiers
*/

    modifier requiredString(string memory str) {
        require(bytes(str).length > 0, "A string is required!");
        _;
    }

    modifier activeService(uint256 projectNumber, uint256 serviceNumber) {
        require(projectServices[projectNumber][serviceNumber].exist == true, "This service has been deleted and does not exist anymore");
        _;
    }

    modifier hasServiceStatus(uint256 projectNumber, uint256 serviceNumber, Status state) {
        require(projectServices[projectNumber][serviceNumber].status == state, "The status of this service does not match the intended status.");
        _;
    }

/*
    Service Requester (Project Owner) Functions
*/

    /*
        Service - Create
    */

    function createService(uint256 projectNumber, string memory title, string memory description, uint256 price) public requiredString(title) requiredString(description) {        
        require(price > 0, "A Service Price must be specified");
        uint256 serviceNumber = projectServices[projectNumber].length + 1;     
        service memory newService = service(projectNumber,serviceNumber,title,description,price,0,msg.sender,address(0),true,Status.none);
        projectServices[projectNumber].push(newService);    
        emit serviceCreated(projectNumber, serviceNumber, title, description, price);
    }

    /*
        Service - Read 
    */

    function readService(uint256 projectNumber, uint256 serviceNumber) public view returns (string memory , string memory, uint256 , uint256 ) {
        return (
            projectServices[projectNumber][serviceNumber].title,
            projectServices[projectNumber][serviceNumber].description,
            projectServices[projectNumber][serviceNumber].price,
            projectServices[projectNumber][serviceNumber].currentMilestone
        );
    }

    /*
        Service - Update
    */

    function updateService(uint256 projectNumber, uint256 serviceNumber, string memory title, string memory description, uint256 price) public {
        service memory newService = service(projectNumber,serviceNumber,title,description,price,0,msg.sender,address(0),true,Status.none);
        projectServices[projectNumber][serviceNumber] = newService;

        emit serviceUpdated(projectNumber, serviceNumber, title, description, price);
    }

    /*
        Service - Delete
    */
    function deleteService(uint256 projectNumber, uint256 serviceNumber) public {
        projectServices[projectNumber][serviceNumber].exist = false;
        emit serviceDeleted(projectNumber,serviceNumber);
    }

    /*
        Milestone - Create
    */
    function createMilestone(uint256 projectNumber, uint256 serviceNumber, string memory titleMilestone, string memory descriptionMilestone) public {
        milestone.createMilestone(projectNumber,serviceNumber,titleMilestone,descriptionMilestone);
    }

    /*
        Milestone - Read
    */   
    function readMilestone(uint256 projectNumber, uint256 serviceNumber, uint256 milestoneNumber) public view returns (string memory , string memory ) {
        milestone.readMilestone(projectNumber,serviceNumber,milestoneNumber);
    }
    
    /*
        Milestone - Update
    */
    function updateMilestone(uint256 projectNumber, uint256 serviceNumber, uint256 milestoneNumber, string memory titleMilestone, string memory descriptionMilestone) public {
        milestone.updateMilestone(projectNumber,serviceNumber,milestoneNumber,titleMilestone,descriptionMilestone);
    }

    /*
        Milestone - Delete
    */
    function deleteMilestone(uint256 projectNumber, uint256 serviceNumber, uint256 milestoneNumber) public {        
        milestone.deleteMilestone(projectNumber,serviceNumber,milestoneNumber);
    }

}