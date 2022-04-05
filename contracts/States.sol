// SPDX-License-Identifier: MIT
pragma solidity >=0.4.22 <0.9.0;

library States {
    
    enum ConflictStatus { none, pending, completed }

    enum MilestoneStatus { none, pending, approved, started, completed, verified, conflict}

    enum ServiceStatus { none, pending, approved, started, completed, conflict }

    enum ProjectStatus { none, active, inactive, terminated } 

}