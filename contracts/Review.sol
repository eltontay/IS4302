// SPDX-License-Identifier: MIT
pragma solidity >=0.4.22 <0.9.0;

import "./Service.sol";
import "./States.sol";
import "./SafeMath.sol";

contract Review {
    
    using SafeMath for uint256;

    struct review {
        uint256 projectNumber;
        uint256 serviceNumber;
        uint256 milestoneNumber;
        address reviewee;
        address reviewer;
        States.Role role;
        string review;
        uint star_rating;
    }


    mapping (uint256 => mapping(uint256 => mapping(uint256 => review))) serviceProviderReviews; // list of reviews received for each profile for each service provided (review id, milestone completed, star rating out of 5)
    mapping (uint256 => mapping(uint256 => mapping(uint256 => review))) serviceRequesterReviews; // list of reviews received for each profile for each service received (review id, milestone completed, star rating out of 5) 
    mapping (uint256 => mapping(uint256 => uint256)) serviceProviderStarRating;
    mapping (uint256 => mapping(uint256 => uint256)) serviceRequesterStarRating;
    event reviewCreated(uint256 projectNumber, uint256 serviceNumber, uint256 milestoneNumber, address reviewee, address reviewer, States.Role role, string review_input, uint star_rating);

    uint256 public numReview = 0;

    modifier check_starrating(uint256 star_rating) {
        require((star_rating >= 1) && (star_rating <= 5), "Star rating must be 1 to 5");
        _;
    }

    /*
        role can be either serviceProvider or serviceRequester

    */

    function createReview(uint256 projectNumber, uint256 serviceNumber, uint256 milestoneNumber, address  _from, address  _to, string memory review_input, States.Role role, uint star_rating) public
        check_starrating(star_rating) 
    {

        review memory newReview = review(projectNumber,serviceNumber,milestoneNumber,_to,_from,role,review_input,star_rating);

        if (role == States.Role.serviceProvider) { 
            serviceProviderReviews[projectNumber][serviceNumber][milestoneNumber] = newReview;
            serviceProviderStarRating[projectNumber][serviceNumber] += 1;
        } else {
            serviceRequesterReviews[projectNumber][serviceNumber][milestoneNumber] = newReview;
            serviceRequesterStarRating[projectNumber][serviceNumber] += 1;
        }
        
        numReview++;
        emit reviewCreated(projectNumber,serviceNumber,milestoneNumber,_to,_from,role,review_input,star_rating);
    }

    // Star Rating getters
    function getAvgServiceProviderStarRating(uint256 projectNumber, uint256 serviceNumber) public view returns (uint256) {
        uint256 numberOfReviews = serviceProviderStarRating[projectNumber][serviceNumber];
        uint256 sum_star = 0;
        for (uint256 i = 0; i < numberOfReviews; i++ ) {
            sum_star += serviceProviderReviews[projectNumber][serviceNumber][i].star_rating;
        }

        return SafeMath.div(sum_star, numberOfReviews);
    }

    // Star Rating getters
    function getAvgServiceRequesterStarRating(uint256 projectNumber, uint256 serviceNumber) public view returns (uint256) {
        uint256 numberOfReviews = serviceRequesterStarRating[projectNumber][serviceNumber];
        uint256 sum_star = 0;
        for (uint256 i = 0; i < numberOfReviews; i++ ) {
            sum_star += serviceRequesterReviews[projectNumber][serviceNumber][i].star_rating;
        }

        return SafeMath.div(sum_star, numberOfReviews);
    }

}