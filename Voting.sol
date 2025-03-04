// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

contract EVoting {
    // Owner of the contract
    address public owner;

    // Struct to store voter details
    struct Voter {
        bool isRegistered;
        bool hasVoted;
        uint256 vote; // Index of the candidate
    }

    // Struct to store candidate details
    struct Candidate {
        string name;
        uint256 voteCount;
    }

    // State variables
    mapping(address => Voter) public voters; // To track voters
    Candidate[] public candidates; // List of candidates
    bool public votingOpen; // Status of voting

    // Events
    event VoterRegistered(address voter);
    event VotingStarted();
    event VotingEnded();
    event VoteCasted(address voter, uint256 candidateIndex);

    // Modifier to restrict access to the contract owner
    modifier onlyOwner() {
        require(msg.sender == owner, "Only owner can call this function");
        _;
    }

    // Modifier to check if voting is open
    modifier whenVotingOpen() {
        require(votingOpen, "Voting is not open");
        _;
    }

    constructor() {
        owner = msg.sender;
    }

    // Function to add candidates
    function addCandidate(string memory _name) public onlyOwner {
        candidates.push(Candidate({name: _name, voteCount: 0}));
    }

    // Function to register voters
    function registerVoter(address _voter) public onlyOwner {
        require(!voters[_voter].isRegistered, "Voter already registered");

        voters[_voter] = Voter({isRegistered: true, hasVoted: false, vote: 0});
        emit VoterRegistered(_voter);
    }

    // Function to start voting
    function startVoting() public onlyOwner {
        require(!votingOpen, "Voting is already open");
        votingOpen = true;
        emit VotingStarted();
    }

    // Function to end voting
    function endVoting() public onlyOwner {
        require(votingOpen, "Voting is not open");
        votingOpen = false;
        emit VotingEnded();
    }

    // Function for voters to cast their vote
    function vote(uint256 candidateIndex) public whenVotingOpen {
        Voter storage sender = voters[msg.sender];
        require(sender.isRegistered, "You are not a registered voter");
        require(!sender.hasVoted, "You have already voted");
        require(candidateIndex < candidates.length, "Invalid candidate index");

        sender.hasVoted = true;
        sender.vote = candidateIndex;

        candidates[candidateIndex].voteCount += 1;
        emit VoteCasted(msg.sender, candidateIndex);
    }

    // Function to get candidate details
    function getCandidate(uint256 candidateIndex)
        public
        view
        returns (string memory name, uint256 voteCount)
    {
        require(candidateIndex < candidates.length, "Invalid candidate index");
        Candidate memory candidate = candidates[candidateIndex];
        return (candidate.name, candidate.voteCount);
    }

    // Function to get total candidates
    function getCandidatesCount() public view returns (uint256) {
        return candidates.length;
    }
}
