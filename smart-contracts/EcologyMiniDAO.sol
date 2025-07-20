// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

/**
 * @title EcologyMiniDAO
 * @dev Simple DAO for portfolio demonstration
 * @author haaz.eth
 */
contract EcologyMiniDAO {
    address public creator;
    address public bakineStudio;
    
    struct Proposal {
        string species;
        string description;
        uint256 votes;
        bool executed;
        uint256 deadline;
        address proposer;
    }
    
    mapping(uint256 => Proposal) public proposals;
    mapping(address => mapping(uint256 => bool)) public hasVoted;
    mapping(address => bool) public isMember;
    uint256 public proposalCount;
    uint256 public memberCount;
    
    event ProposalCreated(uint256 indexed id, string species, address proposer);
    event VoteCast(address indexed voter, uint256 indexed proposalId);
    event MemberAdded(address indexed member);
    event ProposalExecuted(uint256 indexed proposalId);
    
    modifier onlyMembers() {
        require(isMember[msg.sender] || msg.sender == creator, "Not a member");
        _;
    }
    
    modifier onlyCreator() {
        require(msg.sender == creator, "Not authorized");
        _;
    }
    
    constructor() {
        creator = msg.sender;
        bakineStudio = msg.sender; // Set to creator initially
        isMember[msg.sender] = true;
        memberCount = 1;
    }
    
    /**
     * @dev Become a member by paying membership fee
     */
    function becomeMember() external payable {
        require(msg.value >= 0.001 ether, "Membership fee required");
        require(!isMember[msg.sender], "Already a member");
        
        isMember[msg.sender] = true;
        memberCount++;
        
        // Distribute fee
        uint256 creatorShare = (msg.value * 70) / 100;
        uint256 studioShare = msg.value - creatorShare;
        
        payable(creator).transfer(creatorShare);
        payable(bakineStudio).transfer(studioShare);
        
        emit MemberAdded(msg.sender);
    }
    
    /**
     * @dev Create a proposal for adding new species
     */
    function createProposal(string memory _species, string memory _description) external onlyMembers {
        proposals[proposalCount] = Proposal({
            species: _species,
            description: _description,
            votes: 0,
            executed: false,
            deadline: block.timestamp + 7 days,
            proposer: msg.sender
        });
        
        emit ProposalCreated(proposalCount, _species, msg.sender);
        proposalCount++;
    }
    
    /**
     * @dev Vote on a proposal
     */
    function vote(uint256 _proposalId) external onlyMembers {
        require(_proposalId < proposalCount, "Invalid proposal");
        require(!hasVoted[msg.sender][_proposalId], "Already voted");
        require(block.timestamp < proposals[_proposalId].deadline, "Voting ended");
        require(!proposals[_proposalId].executed, "Already executed");
        
        proposals[_proposalId].votes++;
        hasVoted[msg.sender][_proposalId] = true;
        
        emit VoteCast(msg.sender, _proposalId);
    }
    
    /**
     * @dev Execute proposal if it has enough votes
     */
    function executeProposal(uint256 _proposalId) external {
        require(_proposalId < proposalCount, "Invalid proposal");
        require(block.timestamp >= proposals[_proposalId].deadline, "Voting still active");
        require(!proposals[_proposalId].executed, "Already executed");
        require(proposals[_proposalId].votes >= memberCount / 2, "Not enough votes");
        
        proposals[_proposalId].executed = true;
        emit ProposalExecuted(_proposalId);
    }
    
    /**
     * @dev Get proposal details
     */
    function getProposal(uint256 _id) external view returns (Proposal memory) {
        require(_id < proposalCount, "Invalid proposal");
        return proposals[_id];
    }
    
    /**
     * @dev Update bakine studio address
     */
    function setBakineStudio(address _bakineStudio) external onlyCreator {
        bakineStudio = _bakineStudio;
    }
    
    /**
     * @dev Get contract stats
     */
    function getStats() external view returns (uint256, uint256, uint256) {
        return (proposalCount, memberCount, address(this).balance);
    }
}