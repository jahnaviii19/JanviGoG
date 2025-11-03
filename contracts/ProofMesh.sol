Enum for proof status
    enum ProofStatus {
        Pending,
        Verified,
        Rejected,
        Revoked
    // SPDX-License-Identifier: MIT
pragma solidity ^0.8.26;

/**
 * @title ProofMesh
 * @notice A decentralized proof-sharing network that allows users to submit,
 *         verify, and connect digital proofs in a trustless environment.
 */
contract Project {
    address public admin;
    uint256 public proofCount;

    struct Proof {
        uint256 id;
        address creator;
        string dataHash;
        string category;
        uint256 timestamp;
        bool verified;
    }

    mapping(uint256 => Proof) public proofs;

    event ProofSubmitted(uint256 indexed id, address indexed creator, string dataHash, string category);
    event ProofVerified(uint256 indexed id, address indexed verifier

    
    Struct to represent a proof in the mesh
    struct Proof {
        bytes32 proofHash;
        address creator;
        ProofType proofType;
        ProofStatus status;
        uint256 createdAt;
        uint256 verifiedAt;
        uint256 expiryTime;
        string metadataURI;
        address[] verifiers;
        bytes32[] linkedProofs;
        bool isActive;
    }
    
    Struct for proof statistics
    struct ProofStats {
        uint256 totalProofs;
        uint256 verifiedProofs;
        uint256 pendingProofs;
        uint256 revokedProofs;
    }
    
    Events
    event ProofCreated(
        bytes32 indexed proofHash,
        address indexed creator,
        ProofType proofType,
        string metadataURI
    );
    
    event ProofVerified(
        bytes32 indexed proofHash,
        address indexed verifier,
        uint256 timestamp
    );
    
    event ProofRevoked(
        bytes32 indexed proofHash,
        address indexed revoker,
        uint256 timestamp
    );
    
    event VerifierAuthorized(
        address indexed verifier,
        uint256 timestamp
    );
    
    event VerifierRemoved(
        address indexed verifier,
        uint256 timestamp
    );
    
    event ProofsLinked(
        bytes32 indexed proof1,
        bytes32 indexed proof2,
        uint256 timestamp
    );
    
    constructor() Ownable(msg.sender) {
        totalProofsCreated = 0;
        minVerificationsRequired = 2;
        verifierReputationThreshold = 50;
    }
    
    /**
     * @dev Creates a new proof in the mesh
     * @param _dataHash Hash of the data being proven
     * @param _proofType Type of proof being created
     * @param _metadataURI URI pointing to additional metadata
     * @param _expiryTime Expiry timestamp (0 for no expiry)
     * @return proofHash The unique hash identifier of the proof
     */
    function createProof(
        bytes32 _dataHash,
        ProofType _proofType,
        string memory _metadataURI,
        uint256 _expiryTime
    ) external whenNotPaused returns (bytes32) {
        require(_dataHash != bytes32(0), "Invalid data hash");
        require(bytes(_metadataURI).length > 0, "Metadata URI required");
        require(_expiryTime == 0 || _expiryTime > block.timestamp, "Invalid expiry time");
        
        Create new proof
        Proof storage newProof = proofs[proofHash];
        newProof.proofHash = proofHash;
        newProof.creator = msg.sender;
        newProof.proofType = _proofType;
        newProof.status = ProofStatus.Pending;
        newProof.createdAt = block.timestamp;
        newProof.expiryTime = _expiryTime;
        newProof.metadataURI = _metadataURI;
        newProof.isActive = true;
        
        Check if proof has expired
        if (proof.expiryTime > 0 && block.timestamp > proof.expiryTime) {
            proof.status = ProofStatus.Rejected;
            revert("Proof has expired");
        }
        
        Update verifier stats
        verifiers[msg.sender].verificationCount++;
        verifiers[msg.sender].reputationScore += 10;
        
        Add bidirectional links
        proofs[_proofHash1].linkedProofs.push(_proofHash2);
        proofs[_proofHash2].linkedProofs.push(_proofHash1);
        
        emit ProofsLinked(_proofHash1, _proofHash2, block.timestamp);
    }
    
    /*
     * @dev Retrieves comprehensive proof information
     * @param _proofHash Hash of the proof
     * @return Proof details including creator, status, type, and timestamps
     */
    function getProofInfo(bytes32 _proofHash) external view returns (
        address creator,
        ProofType proofType,
        ProofStatus status,
        uint256 createdAt,
        uint256 verifiedAt,
        uint256 expiryTime,
        string memory metadataURI,
        uint256 verifierCount,
        uint256 linkedProofCount,
        bool isActive
    ) {
        require(proofs[_proofHash].creator != address(0), "Proof does not exist");
        Proof memory proof = proofs[_proofHash];
        
        return (
            proof.creator,
            proof.proofType,
            proof.status,
            proof.createdAt,
            proof.verifiedAt,
            proof.expiryTime,
            proof.metadataURI,
            proof.verifiers.length,
            proof.linkedProofs.length,
            proof.isActive
        );
    }
    
    /**
     * @dev Gets all verifiers for a specific proof
     */
    function getProofVerifiers(bytes32 _proofHash) external view returns (address[] memory) {
        require(proofs[_proofHash].creator != address(0), "Proof does not exist");
        return proofs[_proofHash].verifiers;
    }
    
    /**
     * @dev Gets all linked proofs for a specific proof
     */
    function getLinkedProofs(bytes32 _proofHash) external view returns (bytes32[] memory) {
        require(proofs[_proofHash].creator != address(0), "Proof does not exist");
        return proofs[_proofHash].linkedProofs;
    }
    
    /**
     * @dev Gets all proofs created by a user
     */
    function getUserProofs(address _user) external view returns (bytes32[] memory) {
        return userProofs[_user];
    }
    
    /**
     * @dev Checks if a proof is verified
     */
    function isProofVerified(bytes32 _proofHash) external view returns (bool) {
        require(proofs[_proofHash].creator != address(0), "Proof does not exist");
        return proofs[_proofHash].status == ProofStatus.Verified;
    }
    
    /**
     * @dev Checks if a proof is still valid (not expired)
     */
    function isProofValid(bytes32 _proofHash) external view returns (bool) {
        require(proofs[_proofHash].creator != address(0), "Proof does not exist");
        Proof memory proof = proofs[_proofHash];
        
        if (!proof.isActive) return false;
        if (proof.status != ProofStatus.Verified) return false;
        if (proof.expiryTime > 0 && block.timestamp > proof.expiryTime) return false;
        
        return true;
    }
    
    /**
     * @dev Revokes a proof (only creator or owner)
     */
    function revokeProof(bytes32 _proofHash) external {
        require(proofs[_proofHash].creator != address(0), "Proof does not exist");
        require(
            proofs[_proofHash].creator == msg.sender || msg.sender == owner(),
            "Not authorized to revoke"
        );
        require(proofs[_proofHash].isActive, "Proof already inactive");
        
        proofs[_proofHash].status = ProofStatus.Revoked;
        proofs[_proofHash].isActive = false;
        
        emit ProofRevoked(_proofHash, msg.sender, block.timestamp);
    }
    
    /**
     * @dev Authorizes a new verifier
     */
    function authorizeVerifier(address _verifier) external onlyOwner {
        require(_verifier != address(0), "Invalid verifier address");
        require(!verifiers[_verifier].isAuthorized, "Already authorized");
        
        verifiers[_verifier] = Verifier({
            isAuthorized: true,
            verificationCount: 0,
            reputationScore: 100,
            registeredAt: block.timestamp
        });
        
        authorizedVerifiers.push(_verifier);
        
        emit VerifierAuthorized(_verifier, block.timestamp);
    }
    
    /**
     * @dev Removes a verifier's authorization
     */
    function removeVerifier(address _verifier) external onlyOwner {
        require(verifiers[_verifier].isAuthorized, "Not an authorized verifier");
        
        verifiers[_verifier].isAuthorized = false;
        
        emit VerifierRemoved(_verifier, block.timestamp);
    }
    
    /**
     * @dev Gets verifier information
     */
    function getVerifierInfo(address _verifier) external view returns (
        bool isAuthorized,
        uint256 verificationCount,
        uint256 reputationScore,
        uint256 registeredAt
    ) {
        Verifier memory verifier = verifiers[_verifier];
        return (
            verifier.isAuthorized,
            verifier.verificationCount,
            verifier.reputationScore,
            verifier.registeredAt
        );
    }
    
    /**
     * @dev Gets all authorized verifiers
     */
    function getAllVerifiers() external view returns (address[] memory) {
        return authorizedVerifiers;
    }
    
    /**
     * @dev Gets statistics about proofs in the system
     */
    function getProofStats() external view returns (
        uint256 totalProofs,
        uint256 verifiedProofs,
        uint256 pendingProofs,
        uint256 revokedProofs
    ) {
        uint256 verified = 0;
        uint256 pending = 0;
        uint256 revoked = 0;
        
        for (uint256 i = 0; i < allProofHashes.length; i++) {
            ProofStatus status = proofs[allProofHashes[i]].status;
            if (status == ProofStatus.Verified) verified++;
            else if (status == ProofStatus.Pending) pending++;
            else if (status == ProofStatus.Revoked) revoked++;
        }
        
        return (totalProofsCreated, verified, pending, revoked);
    }
    
    /**
     * @dev Updates minimum verifications required
     */
    function setMinVerifications(uint256 _minVerifications) external onlyOwner {
        require(_minVerifications > 0, "Must require at least 1 verification");
        minVerificationsRequired = _minVerifications;
    }
    
    /**
     * @dev Pauses the contract
     */
    function pause() external onlyOwner {
        _pause();
    }
    
    /**
     * @dev Unpauses the contract
     */
    function unpause() external onlyOwner {
        _unpause();
    }
    
    /**
     * @dev Gets total number of proofs
     */
    function getTotalProofs() external view returns (uint256) {
        return totalProofsCreated;
    }
    
    /**
     * @dev Gets all proof hashes (paginated for gas efficiency)
     */
    function getAllProofHashes(uint256 _startIndex, uint256 _count) 
        external 
        view 
        returns (bytes32[] memory) 
    {
        require(_startIndex < allProofHashes.length, "Start index out of bounds");
        
        uint256 endIndex = _startIndex + _count;
        if (endIndex > allProofHashes.length) {
            endIndex = allProofHashes.length;
        }
        
        bytes32[] memory result = new bytes32[](endIndex - _startIndex);
        for (uint256 i = _startIndex; i < endIndex; i++) {
            result[i - _startIndex] = allProofHashes[i];
        }
        
        return result;
    }
}
// 
update
// 
