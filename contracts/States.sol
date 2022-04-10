// SPDX-License-Identifier: MIT
pragma solidity >=0.4.22 <0.9.0;

library States {
    
    enum ConflictStatus { created, voting, completed, terminated }

    enum MilestoneStatus { created, pending, approved, started, completed, verified, conflict, terminated}

    enum ServiceStatus { created, pending, accepted, completed, conflict, terminated }

    enum ProjectStatus { active, inactive, terminated } 

    enum Role { serviceProvider, serviceRequester }  

}