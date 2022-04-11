// SPDX-License-Identifier: MIT
pragma solidity >=0.4.22 <0.9.0;

import "./Service.sol";
import "./States.sol";

// library SafeMath {
//     /**
//      * @dev Returns the integer division of two unsigned integers. Reverts on
//      * division by zero. The result is rounded towards zero.
//      *
//      * Counterpart to Solidity's `/` operator. Note: this function uses a
//      * `revert` opcode (which leaves remaining gas untouched) while Solidity
//      * uses an invalid opcode to revert (consuming all remaining gas).
//      *
//      * Requirements:
//      * - The divisor cannot be zero.
//      */
//     function div(uint256 a, uint256 b) internal pure returns (uint256) {
//         return div(a, b);
//     }
// }

contract Review {
    
    // using SafeMath for uint256;

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

    function createReview(uint256 projectNumber, uint256 serviceNumber, uint256 milestoneNumber, address payable _from, address payable _to, string memory review_input, States.Role role, uint star_rating) public
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

        return sum_star/ numberOfReviews;
    }

    // Star Rating getters
    function getAvgServiceRequesterStarRating(uint256 projectNumber, uint256 serviceNumber) public view returns (uint256) {
        uint256 numberOfReviews = serviceRequesterStarRating[projectNumber][serviceNumber];
        uint256 sum_star = 0;
        for (uint256 i = 0; i < numberOfReviews; i++ ) {
            sum_star += serviceRequesterReviews[projectNumber][serviceNumber][i].star_rating;
        }

        return sum_star/ numberOfReviews;
    }

}