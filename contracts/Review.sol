// SPDX-License-Identifier: MIT
pragma solidity >=0.4.22 <0.9.0;

library SafeMath {
    /**
     * @dev Returns the integer division of two unsigned integers. Reverts on
     * division by zero. The result is rounded towards zero.
     *
     * Counterpart to Solidity's `/` operator. Note: this function uses a
     * `revert` opcode (which leaves remaining gas untouched) while Solidity
     * uses an invalid opcode to revert (consuming all remaining gas).
     *
     * Requirements:
     * - The divisor cannot be zero.
     */
    function div(uint256 a, uint256 b) internal pure returns (uint256) {
        return div(a, b);
    }
}

contract Review {
    
    using SafeMath for uint256;

    enum Role {serviceProvider, serviceRequester}    

    struct review {
        address reviewee;
        address reviewer;
        uint256 service_id;
        Role role;
        string review;
        uint256 milestone_completed;
        uint star_rating;
    }

    constructor() public {

    }

    mapping (address => review[]) serviceProviderReviews; // list of reviews received for each profile for each service provided (review id, milestone completed, star rating out of 5)
    mapping (address => review[]) serviceRequesterReviews; // list of reviews received for each profile for each service received (review id, milestone completed, star rating out of 5)

    event reviewCreated(address target, uint256 serviceid, string review, uint star_rating, Role role);

    uint256 public numReview = 0;

    modifier check_role(address target, Role role_input, uint256 service_id) {
        require(serviceContract.doesServiceExist(service_id), "Service does not exist");
        // require(serviceContract.isServiceStatusCompleted(service_id), "Service has not been completed. Please complete the service before reviewing");
        if (role_input == Role.serviceProvider) {
            require(serviceContract.getServiceProvider(service_id) == target, "User you attempted to review is not the  serviceProvider of this service.");
            require(serviceContract.getServiceRequester(service_id) == msg.sender, "You are not the user who requested for this service, hence you are unable to provide reviews on it");
        } else {
            require(serviceContract.getServiceProvider(service_id) == msg.sender, "You are not the user who rendered this service, hence you are unable to provide reviews on the requester");
            require(serviceContract.getServiceRequester(service_id) == target, "User you attempted to review did not requested for your service, hence you are unable to provide reviews the user");
        }
        _;
    }

    modifier check_starrating(uint256 star_rating) {
        require((star_rating >= 1) && (star_rating <= 5), "Star rating must be 1 to 5");
        _;
    }

    
    function createReview(address target, string memory review_inpt, uint256 service_id, Role role, uint star_rating) public check_role(target, role, service_id) check_starrating(star_rating) {
        uint256 milestone = serviceContract.getCurrentMilestone(service_id);
        review memory newReview = review(target, msg.sender, service_id, role, review_inpt, milestone, star_rating);

        if (role == Role.serviceProvider) { // if the review is for a contractor
            serviceProviderReviews[target].push(newReview);
        } else {
            serviceRequesterReviews[target].push(newReview);
        }
        
        numReview++;
        emit reviewCreated(target, service_id, review_inpt, star_rating, role);
    }

    // Get Reviews
    function getserviceProviderReviews(address target) public view returns (review[] memory) {
        return serviceProviderReviews[target];  
    }
    
    function getserviceRequesterReviews(address target) public view returns (review[]  memory) {
        return serviceRequesterReviews[target];
    }

    function getAllReviews(address target) public view returns (review[]  memory) {
        uint256 serviceSize = serviceProviderReviews[target].length;
        uint256 clientSize = serviceRequesterReviews[target].length;
        review[] memory allReviews = new review[](serviceSize + clientSize);

        uint i=0;
        for (;i < serviceSize; i++) {
            allReviews[i] = serviceProviderReviews[target][i];
        }

        uint j=0;
        while (j < clientSize) {
            allReviews[i++] = serviceRequesterReviews[target][j++];
        }

        return allReviews;
    }


    // ! currently assuming 1 service can only be done once
    function getSpecificserviceProviderReviews(address target, uint256 service_id) public view returns (review memory) {
        review memory cur_review;

        for (uint256 i = 0; i < serviceProviderReviews[target].length; i++) {
            cur_review =  serviceProviderReviews[target][i];

            if (cur_review.service_id == service_id) {
                break;
            }
        }
        return cur_review;
    }

    function getSpecificserviceRequesterReviews(address target, uint256 service_id) public view returns (review[] memory) {
        review[] memory specificedReviews;
        review memory cur_review;
        uint256 reviewCnt = 0;

        for (uint256 i = 0; i < serviceRequesterReviews[target].length; i++) {
            cur_review =  serviceRequesterReviews[target][i];

            if (cur_review.service_id == service_id) {
                specificedReviews[i] = cur_review;
                reviewCnt++;
            }
        }
        return specificedReviews;
    }

   // Star Rating getters
    function getAvgServiceStarRating(address target) public view returns (uint256) {
        review[] memory reviews = getserviceProviderReviews(target);
        uint256 sum_star = 0;
        uint256 tot_review = reviews.length;

        for (uint256 i = 0; i < reviews.length; i++) {
            sum_star = sum_star + reviews[i].star_rating;
        }

        return SafeMath.div(sum_star, tot_review);
    }

    function getAvgClientStarRating(address target) public view returns (uint256) {
        review[] memory reviews = getserviceRequesterReviews(target);
        uint256 sum_star = 0;
        uint256 tot_review = reviews.length;

        for (uint256 i = 0; i < reviews.length; i++) {
            sum_star = sum_star + reviews[i].star_rating;
        }

        return SafeMath.div(sum_star, tot_review);
    }

    function getAvgStarRating(address target) public view returns (uint256) {
        uint256 service_stars = getAvgServiceStarRating(target);
        uint256 client_stars = getAvgClientStarRating(target);

        return SafeMath.div(service_stars, client_stars);
    }


    // Milestone getters
    function getAvgServiceMilestone(address target) public view returns (uint256) {
        review[] memory reviews = getserviceProviderReviews(target);
        uint256 sum_milestone = 0;
        uint256 tot_review = reviews.length;

        for (uint256 i = 0; i < reviews.length; i++) {
            sum_milestone = sum_milestone + reviews[i].milestone_completed;
        }

        return SafeMath.div(sum_milestone, tot_review);
    }

    function getAvgClientMilestone(address target) public view returns (uint256) {
        review[] memory reviews = getserviceRequesterReviews(target);
        uint256 sum_milestone = 0;
        uint256 tot_review = reviews.length;

        for (uint256 i = 0; i < reviews.length; i++) {
            sum_milestone = sum_milestone + reviews[i].milestone_completed;
        }

        return SafeMath.div(sum_milestone, tot_review);
    }

    function getAvgMilestone(address target) public view returns (uint256) {
        uint256 service_milestones = getAvgServiceMilestone(target);
        uint256 client_milestones = getAvgClientMilestone(target);

        return SafeMath.div(service_milestones, client_milestones);
    }



}