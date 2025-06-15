// SPDX-License-Identifier: MIT
pragma solidity ^0.8.26;

contract NigeriaElection {
    enum Gender {
        Male,
        Female
    }

    struct Voter {
        string name;
        uint8 age;
        Gender gender;
        bool cardValid;
        bool hasVoted;
        address wallet;
    }

    struct Candidate {
        string name;
        uint256 voteCount;
    }

    address public owner;

    uint256 public votingStart;
    uint256 public votingEnd;
    uint256 public candidateCount;

    uint256 public maleVoters;
    uint256 public femaleVoters;

    mapping(address => bool) public admins;
    mapping(address => Voter) private voters;
    mapping(address => bool) private validVoters;
    mapping(uint256 => Candidate) public candidates;

    event VoterRegistered(address wallet);
    event Voted(address voter, uint256 candidateId);
    event CandidateAdded(uint256 candidateId, string name);
    event AdminAdded(address indexed admin);
    event AdminRemoved(address indexed admin);

    error Underage();
    error InvalidCard();
    error NotVotingPeriod();
    error AlreadyVoted();
    error InvalidVoter();
    error CandidateDoesNotExist();
    error NotAuthorized();

    constructor(uint256 _start, uint256 _end) {
        require(_start < _end, "Invalid time range");
        owner = msg.sender;
        votingStart = _start;
        votingEnd = _end;
    }

    modifier onlyOwner() {
        require(msg.sender == owner, "Only owner can call this");
        _;
    }

    modifier onlyAdminOrOwner() {
        if (msg.sender != owner && !admins[msg.sender]) {
            revert NotAuthorized();
        }
        _;
    }

    function addAdmin(address _admin) external onlyOwner {
        admins[_admin] = true;
        emit AdminAdded(_admin);
    }

    function removeAdmin(address _admin) external onlyOwner {
        admins[_admin] = false;
        emit AdminRemoved(_admin);
    }

    function addCandidate(string memory _name) external onlyOwner {
        candidates[candidateCount] = Candidate(_name, 0);
        emit CandidateAdded(candidateCount, _name);
        candidateCount++;
    }

    function registerVoter(string memory _name, uint8 _age, Gender _gender, bool _cardValid, address _voterWallet)
        external
        onlyAdminOrOwner
    {
        require(_age >= 18, "Must be 18+");
        require(!validVoters[_voterWallet], "Already registered");

        voters[_voterWallet] = Voter({
            name: _name,
            age: _age,
            gender: _gender,
            cardValid: _cardValid,
            hasVoted: false,
            wallet: _voterWallet
        });

        validVoters[_voterWallet] = true;

        if (_gender == Gender.Male) maleVoters++;
        else femaleVoters++;

        emit VoterRegistered(_voterWallet);
    }

    function vote(uint256 candidateId) external {
        if (!validVoters[msg.sender]) revert InvalidVoter();

        Voter storage voter = voters[msg.sender];

        if (voter.age < 18) revert Underage();
        if (!voter.cardValid) revert InvalidCard();
        if (block.timestamp < votingStart || block.timestamp > votingEnd) revert NotVotingPeriod();
        if (voter.hasVoted) revert AlreadyVoted();
        if (candidateId >= candidateCount) revert CandidateDoesNotExist();

        candidates[candidateId].voteCount += 1;
        voter.hasVoted = true;

        emit Voted(msg.sender, candidateId);
    }

    function getCandidateVotes(uint256 candidateId) external view returns (uint256) {
        require(candidateId < candidateCount, "Invalid candidate");
        return candidates[candidateId].voteCount;
    }

    function getGenderStats() external view returns (uint256 males, uint256 females) {
        return (maleVoters, femaleVoters);
    }

    function hasVoted(address _wallet) external view returns (bool) {
        return voters[_wallet].hasVoted;
    }

    function getVoterDetails(address _wallet)
        external
        view
        returns (string memory name, uint8 age, Gender gender, bool cardValid, bool voted)
    {
        Voter memory voter = voters[_wallet];
        return (voter.name, voter.age, voter.gender, voter.cardValid, voter.hasVoted);
    }

    function updateCardStatus(address _voterWallet, bool _cardValid) external onlyAdminOrOwner {
        require(validVoters[_voterWallet], "Voter not registered");
        voters[_voterWallet].cardValid = _cardValid;
    }
}
