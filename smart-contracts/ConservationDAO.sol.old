// SPDX-License-Identifier: MIT
pragma solidity ^0.8.19;

import "@openzeppelin/contracts/token/ERC20/IERC20.sol";
import "@openzeppelin/contracts/access/AccessControl.sol";
import "@openzeppelin/contracts/security/ReentrancyGuard.sol";
import "./BiodiversityRegistry.sol";

/**
 * @title ConservationDAO
 * @dev Decentralized governance for biodiversity conservation decisions
 * @notice Community-driven conservation funding and decision making
 */
contract ConservationDAO is AccessControl, ReentrancyGuard {
    
    BiodiversityRegistry public biodiversityRegistry;
    IERC20 public governanceToken; // Token for voting
    
    // Roles
    bytes32 public constant CULTURAL_GUARDIAN = keccak256("CULTURAL_GUARDIAN");
    bytes32 public constant PROPOSAL_CREATOR = keccak256("PROPOSAL_CREATOR");
    
    // Proposal structure
    struct ConservationProposal {
        uint256 id;
        string title;
        string description;
        string targetSpeciesId;
        string proposalType; // "habitat_protection", "species_recovery", "research", "community_program"
        uint256 fundingRequested;
        uint256 timelineMonths;
        address proposer;
        uint256 createdAt;
        uint256 votingEndsAt;
        uint256 votesFor;
        uint256 votesAgainst;
        uint256 totalVoters;
        bool executed;
        bool culturalApproval; // Requires cultural guardian approval
        mapping(address => bool) hasVoted;
        mapping(address => uint256) voteWeight;
        string[] deliverables;
        uint256 expectedImpact; // Species protected, habitat restored, etc.
    }
    
    // Impact tracking
    struct ConservationImpact {
        uint256 speciesProtected;
        uint256 habitatRestoredHectares;
        uint256 communityMembersEngaged;
        uint256 totalFundingDeployed;
        uint256 completedProjects;
    }
    
    // Storage
    mapping(uint256 => ConservationProposal) public proposals;
    mapping(address => uint256) public membershipLevel; // 1=member, 2=elder, 3=guardian
    mapping(string => uint256[]) public speciesProposals; // Species ID to proposal IDs
    
    uint256 public proposalCounter;
    uint256 public minimumVotingPeriod = 7 days;
    uint256 public quorumPercentage = 25; // 25% of token holders must vote
    uint256 public approvalThreshold = 60; // 60% approval needed
    
    ConservationImpact public totalImpact;
    
    // Events
    event ProposalCreated(uint256 indexed proposalId, address indexed proposer, string targetSpecies);
    event VoteCast(uint256 indexed proposalId, address indexed voter, bool support, uint256 weight);
    event ProposalExecuted(uint256 indexed proposalId, bool approved);
    event CulturalApprovalGranted(uint256 indexed proposalId, address indexed guardian);
    event FundingDistributed(uint256 indexed proposalId, uint256 amount, address recipient);
    event ImpactRecorded(uint256 indexed proposalId, string impactType, uint256 value);
    
    constructor(
        address _biodiversityRegistry,
        address _governanceToken
    ) {
        _grantRole(DEFAULT_ADMIN_ROLE, msg.sender);
        biodiversityRegistry = BiodiversityRegistry(_biodiversityRegistry);
        governanceToken = IERC20(_governanceToken);
    }
    
    /**
     * @dev Create a new conservation proposal
     */
    function createProposal(
        string memory _title,
        string memory _description,
        string memory _targetSpeciesId,
        string memory _proposalType,
        uint256 _fundingRequested,
        uint256 _timelineMonths,
        string[] memory _deliverables,
        uint256 _expectedImpact
    ) external onlyRole(PROPOSAL_CREATOR) returns (uint256) {
        require(bytes(_title).length > 0, "Title required");
        require(_fundingRequested > 0, "Funding amount required");
        require(_timelineMonths > 0 && _timelineMonths <= 60, "Invalid timeline");
        
        // Verify species exists if specified
        if (bytes(_targetSpeciesId).length > 0) {
            BiodiversityRegistry.Species memory species = biodiversityRegistry.getSpecies(_targetSpeciesId);
            require(bytes(species.speciesId).length > 0, "Species not found");
        }
        
        uint256 proposalId = ++proposalCounter;
        
        ConservationProposal storage proposal = proposals[proposalId];
        proposal.id = proposalId;
        proposal.title = _title;
        proposal.description = _description;
        proposal.targetSpeciesId = _targetSpeciesId;
        proposal.proposalType = _proposalType;
        proposal.fundingRequested = _fundingRequested;
        proposal.timelineMonths = _timelineMonths;
        proposal.proposer = msg.sender;
        proposal.createdAt = block.timestamp;
        proposal.votingEndsAt = block.timestamp + minimumVotingPeriod;
        proposal.deliverables = _deliverables;
        proposal.expectedImpact = _expectedImpact;
        
        // Cultural approval required for certain types
        if (_requiresCulturalApproval(_proposalType, _targetSpeciesId)) {
            proposal.culturalApproval = false;
        } else {
            proposal.culturalApproval = true;
        }
        
        // Track species-specific proposals
        if (bytes(_targetSpeciesId).length > 0) {
            speciesProposals[_targetSpeciesId].push(proposalId);
        }
        
        emit ProposalCreated(proposalId, msg.sender, _targetSpeciesId);
        return proposalId;
    }
    
    /**
     * @dev Vote on a proposal
     */
    function vote(uint256 _proposalId, bool _support) external {
        ConservationProposal storage proposal = proposals[_proposalId];
        require(proposal.id != 0, "Proposal does not exist");
        require(block.timestamp <= proposal.votingEndsAt, "Voting period ended");
        require(!proposal.hasVoted[msg.sender], "Already voted");
        require(proposal.culturalApproval, "Awaiting cultural approval");
        
        uint256 voterWeight = governanceToken.balanceOf(msg.sender);
        require(voterWeight > 0, "No voting power");
        
        proposal.hasVoted[msg.sender] = true;
        proposal.voteWeight[msg.sender] = voterWeight;
        proposal.totalVoters++;
        
        if (_support) {
            proposal.votesFor += voterWeight;
        } else {
            proposal.votesAgainst += voterWeight;
        }
        
        emit VoteCast(_proposalId, msg.sender, _support, voterWeight);
    }
    
    /**
     * @dev Grant cultural approval to a proposal
     */
    function grantCulturalApproval(uint256 _proposalId) external onlyRole(CULTURAL_GUARDIAN) {
        ConservationProposal storage proposal = proposals[_proposalId];
        require(proposal.id != 0, "Proposal does not exist");
        require(!proposal.culturalApproval, "Already approved");
        
        proposal.culturalApproval = true;
        emit CulturalApprovalGranted(_proposalId, msg.sender);
    }
    
    /**
     * @dev Execute a proposal after voting period
     */
    function executeProposal(uint256 _proposalId) external nonReentrant {
        ConservationProposal storage proposal = proposals[_proposalId];
        require(proposal.id != 0, "Proposal does not exist");
        require(block.timestamp > proposal.votingEndsAt, "Voting still active");
        require(!proposal.executed, "Already executed");
        require(proposal.culturalApproval, "No cultural approval");
        
        proposal.executed = true;
        
        // Check quorum
        uint256 totalSupply = governanceToken.totalSupply();
        uint256 totalVotes = proposal.votesFor + proposal.votesAgainst;
        bool quorumMet = (totalVotes * 100 / totalSupply) >= quorumPercentage;
        
        // Check approval threshold
        bool approved = false;
        if (quorumMet && totalVotes > 0) {
            uint256 approvalRate = (proposal.votesFor * 100) / totalVotes;
            approved = approvalRate >= approvalThreshold;
        }
        
        if (approved) {
            _distributeFunding(_proposalId);
        }
        
        emit ProposalExecuted(_proposalId, approved);
    }
    
    /**
     * @dev Distribute funding for approved proposal
     */
    function _distributeFunding(uint256 _proposalId) internal {
        ConservationProposal storage proposal = proposals[_proposalId];
        
        // In a real implementation, this would transfer funds from treasury
        // For now, we'll emit an event to track the funding distribution
        emit FundingDistributed(_proposalId, proposal.fundingRequested, proposal.proposer);
        
        // Update total impact tracking
        if (keccak256(abi.encodePacked(proposal.proposalType)) == keccak256(abi.encodePacked("species_recovery"))) {
            totalImpact.speciesProtected += proposal.expectedImpact;
        } else if (keccak256(abi.encodePacked(proposal.proposalType)) == keccak256(abi.encodePacked("habitat_protection"))) {
            totalImpact.habitatRestoredHectares += proposal.expectedImpact;
        }
        
        totalImpact.totalFundingDeployed += proposal.fundingRequested;
        totalImpact.completedProjects++;
    }
    
    /**
     * @dev Record conservation impact from completed projects
     */
    function recordImpact(
        uint256 _proposalId,
        string memory _impactType,
        uint256 _value
    ) external onlyRole(PROPOSAL_CREATOR) {
        ConservationProposal storage proposal = proposals[_proposalId];
        require(proposal.id != 0, "Proposal does not exist");
        require(proposal.executed, "Proposal not executed");
        require(msg.sender == proposal.proposer, "Only proposer can record impact");
        
        // Update specific impact metrics
        if (keccak256(abi.encodePacked(_impactType)) == keccak256(abi.encodePacked("species_protected"))) {
            totalImpact.speciesProtected += _value;
        } else if (keccak256(abi.encodePacked(_impactType)) == keccak256(abi.encodePacked("habitat_restored"))) {
            totalImpact.habitatRestoredHectares += _value;
        } else if (keccak256(abi.encodePacked(_impactType)) == keccak256(abi.encodePacked("community_engaged"))) {
            totalImpact.communityMembersEngaged += _value;
        }
        
        emit ImpactRecorded(_proposalId, _impactType, _value);
    }
    
    /**
     * @dev Get proposal details
     */
    function getProposal(uint256 _proposalId) external view returns (
        string memory title,
        string memory description,
        string memory targetSpeciesId,
        string memory proposalType,
        uint256 fundingRequested,
        address proposer,
        uint256 votesFor,
        uint256 votesAgainst,
        bool executed,
        bool culturalApproval
    ) {
        ConservationProposal storage proposal = proposals[_proposalId];
        return (
            proposal.title,
            proposal.description,
            proposal.targetSpeciesId,
            proposal.proposalType,
            proposal.fundingRequested,
            proposal.proposer,
            proposal.votesFor,
            proposal.votesAgainst,
            proposal.executed,
            proposal.culturalApproval
        );
    }
    
    /**
     * @dev Get proposals for a specific species
     */
    function getSpeciesProposals(string memory _speciesId) external view returns (uint256[] memory) {
        return speciesProposals[_speciesId];
    }
    
    /**
     * @dev Get total conservation impact
     */
    function getTotalImpact() external view returns (ConservationImpact memory) {
        return totalImpact;
    }
    
    /**
     * @dev Check if proposal requires cultural approval
     */
    function _requiresCulturalApproval(
        string memory _proposalType,
        string memory _targetSpeciesId
    ) internal view returns (bool) {
        // Always require approval for traditional knowledge or sacred species
        if (bytes(_targetSpeciesId).length > 0) {
            BiodiversityRegistry.Species memory species = biodiversityRegistry.getSpecies(_targetSpeciesId);
            if (species.isSacred || 
                keccak256(abi.encodePacked(species.culturalSignificance)) == keccak256(abi.encodePacked("highest"))) {
                return true;
            }
        }
        
        // Require approval for community programs
        if (keccak256(abi.encodePacked(_proposalType)) == keccak256(abi.encodePacked("community_program"))) {
            return true;
        }
        
        return false;
    }
    
    /**
     * @dev Set membership level for community members
     */
    function setMembershipLevel(address _member, uint256 _level) external onlyRole(CULTURAL_GUARDIAN) {
        require(_level >= 1 && _level <= 3, "Invalid membership level");
        membershipLevel[_member] = _level;
        
        if (_level >= 2) {
            grantRole(PROPOSAL_CREATOR, _member);
        }
        if (_level == 3) {
            grantRole(CULTURAL_GUARDIAN, _member);
        }
    }
    
    /**
     * @dev Update governance parameters
     */
    function updateGovernanceParams(
        uint256 _quorumPercentage,
        uint256 _approvalThreshold,
        uint256 _votingPeriod
    ) external onlyRole(DEFAULT_ADMIN_ROLE) {
        require(_quorumPercentage <= 50, "Quorum too high");
        require(_approvalThreshold >= 50 && _approvalThreshold <= 80, "Invalid threshold");
        require(_votingPeriod >= 1 days && _votingPeriod <= 30 days, "Invalid voting period");
        
        quorumPercentage = _quorumPercentage;
        approvalThreshold = _approvalThreshold;
        minimumVotingPeriod = _votingPeriod;
    }
    
    /**
     * @dev Emergency pause function
     */
    function emergencyPause() external onlyRole(CULTURAL_GUARDIAN) {
        // Implementation for emergency pause
        // This would pause proposal creation and voting in case of issues
    }
}