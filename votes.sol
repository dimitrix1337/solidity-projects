// SPDX-License-Identifier: MIT

pragma solidity ^0.8.12;

/// @title VOTES SIMULATOR
/// @author dimitrix1337
/// @notice You can use this contract for everything.
/// @dev I HAVE AN ERROR WHILE THE OWNER DECIDE TO ADD A CANDIDATE, THE TRANSACTION IS REVERT BUT I DON'T FOUNDED THE ERROR, IF SOMEONE HELPS ME, THANKS A LOT.

/// @custom:experimental This is an experimental contract.

contract Votes {

    address owner;
    uint256 i = 0;
    uint256 time_started;
    uint256 days_remaining = 2 days;
    constructor () {

        owner = msg.sender; 
        time_started = block.timestamp;

    }

    struct Person {

        string name;
        uint32 age;
        bool voted;

    }

    struct Candidate {

        string name;
        uint256 votes;
        bool finalized;

    }

    modifier Finalize {
        require(FinalizeVotes(), "Error: is not time to finalize, wait 3 days after time started.");
        _;
    }

    modifier OnlyOwner() {

        require(!(owner != msg.sender), "Error: only owner can do this.");
        _;

    }

    modifier not_voted(uint256 _dni) {

        require(list_person[_dni].voted != true, "Error: this person already voted.");
        _;
    }

    modifier candidate_not_exist(string memory candidate_name) {
        
        require(CandidateExists(candidate_name), "Error: candidate not exists");
        _;
    }

    mapping(uint256 => Person) list_person;
    Candidate[] candidates;

    function FinalizeVotes() private view OnlyOwner() returns(bool) {

        uint256 time_to_finalize = time_started + days_remaining;

        if (time_to_finalize <= block.timestamp) {
            for (uint256 p = 0; p <= candidates.length ; p++) {
                candidates[p].finalized == true;
            }
            return true;
        } else {
            return false;
        }


    }

    function Ready_To_Finalize() public view Finalize() {
        assert(msg.sender == owner);
        FinalizeVotes();
    }


    function CandidateExists(string memory candidate_name) private view returns(bool) {

        for (uint256 h=0;h<=candidates.length;h++) {

            if (keccak256(abi.encodePacked(candidates[h].name)) == keccak256(abi.encodePacked(candidate_name))) {
                return true;
            }

        }
        return false;

    }

    function Vote(string memory candidate_name, uint256 _dni, string memory name, uint32 age) public not_voted(_dni) returns(bool) {
        assert(list_person[_dni].voted != true);
        for (uint256 j=0;j<=candidates.length;j++) {

            if (keccak256(abi.encodePacked(candidates[j].name)) == keccak256(abi.encodePacked(candidate_name)) && candidates[j].finalized != true) {
                
                candidates[j].votes++;
                list_person[_dni].name = name;
                list_person[_dni].age = age;
                list_person[_dni].voted = true;
                return true;
            }
        }
        return false;

    }

    function AddCandidate(string memory _name) payable public {
        uint256 j = i;
            candidates[j].name = _name;
            candidates[j].votes = 0;
            i++;

    }




}