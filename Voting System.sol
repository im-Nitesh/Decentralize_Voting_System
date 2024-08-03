// SPDX-License-Identifier: MIT
pragma solidity ^0.8.26;

contract VotingSystem {
    struct Voter {
        bool isRegistered;
        bool hasVoted;
        uint256 vote;
    }

    mapping(address => Voter) public voters;
    mapping(uint256 => uint256) public votesCount;
    address[] public blackList;

    uint256 public registrationDeadline = 1723593600000; // 14th August 2024, in Unix timestamp
    
    // 1720915200 - 14th July 2024, in Unix timestamp

    event VoterRegistered(address indexed voter);
    event VoteCast(address indexed voter, uint256 indexed candidate);
    event VoterBlacklisted(address indexed voter);

    modifier onlyBeforeDeadline() {
        require(block.timestamp <= registrationDeadline, "Registration period is over");
        _;
    }

    modifier onlyRegistered() {
        require(voters[msg.sender].isRegistered, "You are not registered to vote");
        _;
    }

    function register() external onlyBeforeDeadline {
        require(!voters[msg.sender].isRegistered, "You are already registered");

        voters[msg.sender] = Voter({
            isRegistered: true,
            hasVoted: false,
            vote: 0
        });

        emit VoterRegistered(msg.sender);
    }

    function castVote(uint256 candidate) external onlyRegistered {
        Voter storage voter = voters[msg.sender];

        if (voter.hasVoted) {
            // Blacklist the voter if they attempt to vote again
            votesCount[voter.vote]--;
            blackList.push(msg.sender);
            voter.isRegistered = false;
            voter.hasVoted = false;
            voter.vote = 0;
            emit VoterBlacklisted(msg.sender);
        } else {
            // Cast the vote
            voter.hasVoted = true;
            voter.vote = candidate;
            votesCount[candidate]++;
            emit VoteCast(msg.sender, candidate);
        }
    }

    function getVotes(uint256 candidate) external view returns (uint256) {
        return votesCount[candidate];
    }

    function getBlacklist() external view returns (address[] memory) {
        return blackList;
    }

    function isRegistered(address voter) external view returns (bool) {
        return voters[voter].isRegistered;
    }

    function hasVoted(address voter) external view returns (bool) {
        return voters[voter].hasVoted;
    }
}
