// SPDX-License-Identifier: MIT
pragma solidity ^0.8.26;

import "forge-std/Test.sol";
import {NigeriaElection} from "../src/NigeriaElection.sol";

contract NigeriaElectionTest is Test {
    NigeriaElection election;

    address owner;
    address admin;
    address voter1;
    address voter2;

    function setUp() public {
        owner = address(this);
        admin = address(0x1);
        voter1 = address(0x2);
        voter2 = address(0x3);

        uint256 votingStart = block.timestamp + 1 days;
        uint256 votingEnd = votingStart + 3 days;

        election = new NigeriaElection(votingStart, votingEnd);

        // Owner adds admin
        election.addAdmin(admin);
    }

    function testOnlyOwnerCanAddCandidate() public {
        election.addCandidate("Candidate A");
        (string memory name, uint256 voteCount) = election.candidates(0);
        assertEq(name, "Candidate A");
        assertEq(voteCount, 0);
    }

    function testAdminRegistersVoter() public {
        vm.prank(admin);
        election.registerVoter(
            "Alice",
            25,
            NigeriaElection.Gender.Female,
            true, // cardValid
            voter1
        );

        (, uint8 age,, bool cardValid,) = election.getVoterDetails(voter1);
        assertEq(age, 25);
        assertTrue(cardValid);
    }

    function testVoterCannotBeUnderage() public {
        vm.prank(admin);
        vm.expectRevert("Must be 18+");
        election.registerVoter(
            "Bob",
            17,
            NigeriaElection.Gender.Male,
            true, // cardValid
            voter2
        );
    }

    function testOnlyAdminOrOwnerCanRegister() public {
        vm.prank(voter1); // Not an admin
        vm.expectRevert(NigeriaElection.NotAuthorized.selector);
        election.registerVoter(
            "Eve",
            30,
            NigeriaElection.Gender.Female,
            true, // cardValid
            voter1
        );
    }

    function testVotingSuccess() public {
        // Register voter
        vm.prank(admin);
        election.registerVoter(
            "Tom",
            30,
            NigeriaElection.Gender.Male,
            true, // cardValid
            voter1
        );

        election.addCandidate("Peter Obi");
        election.addCandidate("Atiku Abubakar");

        vm.warp(block.timestamp + 2 days);

        // Vote
        vm.prank(voter1);
        election.vote(0);

        uint256 votes = election.getCandidateVotes(0);
        assertEq(votes, 1);

        bool voted = election.hasVoted(voter1);
        assertTrue(voted);
    }

    function testCannotVoteTwice() public {
        vm.prank(admin);
        election.registerVoter(
            "Jane",
            28,
            NigeriaElection.Gender.Female,
            true, // cardValid
            voter2
        );

        election.addCandidate("Tinubu");

        vm.warp(block.timestamp + 2 days);

        vm.prank(voter2);
        election.vote(0);

        vm.prank(voter2);
        vm.expectRevert(NigeriaElection.AlreadyVoted.selector);
        election.vote(0);
    }

    function testOnlyOwnerCanAddAdmin() public {
        vm.prank(voter1); // not owner
        vm.expectRevert("Only owner can call this");
        election.addAdmin(address(0x99));
    }

    function testOwnerCanRemoveAdmin() public {
        assertTrue(election.admins(admin));
        election.removeAdmin(admin);
        assertFalse(election.admins(admin));
    }
}
