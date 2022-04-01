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
        address payable serviceRequester; // msg.sender
        address payable serviceProvider; // defaults to address(0)
        bool exist; // allowing update such as soft delete of service
        Status status; // Defaults at none
    }

/*
    Events - Service Requester (Project Owner)
*/
    event serviceCreated(uint256 projectNumber, uint256 serviceNumber, string title, string description, uint256 price);
    event serviceUpdated(uint256 projectNumber, uint256 serviceNumber, string title, string description, uint256 price);
    event serviceDeleted(uint256 projectNumber, uint256 serviceNumber);


    uint256 public serviceTotal = 0; // Counts of number of services existing , only true exist bool
    uint256 public serviceNum = 0; // Project Number/ID , value only goes up, includes both true and false exist bool
    mapping (uint256 => mapping (uint256 => service)) projectServices; // [projectNumber][serviceNumber] 


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

    function createService(uint256 projectNumber, string memory title, string memory description, uint256 price, address payable projectOwner) external requiredString(title) requiredString(description) {        
        require(price > 0, "A Service Price must be specified");

        service storage newService = projectServices[projectNumber][serviceNum];
        newService.projectNumber = projectNumber;
        newService.serviceNumber = serviceNum;
        newService.title = title;
        newService.description = description;
        newService.price = price;
        newService.currentMilestone = 0;
        newService.serviceRequester = projectOwner;
        newService.serviceProvider = payable(address(0));
        newService.exist = true;
        newService.status = Status.none;

        emit serviceCreated(projectNumber, serviceNum, title, description, price);

        serviceTotal++;
        serviceNum++;
    }

    /*
        Service - Read 
    */

    function readService(uint256 projectNumber, uint256 serviceNumber) external view returns (string memory , string memory , uint256 , uint256 ) {
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

    function updateService(uint256 projectNumber, uint256 serviceNumber, string memory title, string memory description, uint256 price) external {

        projectServices[projectNumber][serviceNum].title = title;
        projectServices[projectNumber][serviceNum].description = description;
        projectServices[projectNumber][serviceNum].price = price;

        emit serviceUpdated(projectNumber, serviceNumber, title, description, price);
    }

    /*
        Service - Delete
    */
    function deleteService(uint256 projectNumber, uint256 serviceNumber) external {
        projectServices[projectNumber][serviceNumber].exist = false;

        serviceTotal--;
        emit serviceDeleted(projectNumber,serviceNumber);
    }

    /*
        Milestone - Create
    */
    function createMilestone(uint256 projectNumber, uint256 serviceNumber, string memory titleMilestone, string memory descriptionMilestone) external {
        milestone.createMilestone(projectNumber,serviceNumber,titleMilestone,descriptionMilestone);
    }

    /*
        Milestone - Read
    */   
    function readMilestone(uint256 projectNumber, uint256 serviceNumber, uint256 milestoneNumber) external view returns (string memory , string memory ) {
        milestone.readMilestone(projectNumber,serviceNumber,milestoneNumber);
    }
    
    /*
        Milestone - Update
    */
    function updateMilestone(uint256 projectNumber, uint256 serviceNumber, uint256 milestoneNumber, string memory titleMilestone, string memory descriptionMilestone) external {
        milestone.updateMilestone(projectNumber,serviceNumber,milestoneNumber,titleMilestone,descriptionMilestone);
    }

    /*
        Milestone - Delete
    */
    function deleteMilestone(uint256 projectNumber, uint256 serviceNumber, uint256 milestoneNumber) external {        
        milestone.deleteMilestone(projectNumber,serviceNumber,milestoneNumber);
    }

}