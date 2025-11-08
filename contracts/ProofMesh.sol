Hash or IPFS CID representing the proof content
        string metadataURI;      Block time of creation
        bool verified;           Proof-level credibility (community-weighted)
    }

    mapping(uint256 => Proof) public proofs;
    mapping(address => uint256[]) public userProofs;
    mapping(address => uint256) public userReputation;

    event ProofCreated(uint256 indexed id, address indexed creator, string proofHash, string metadataURI);
    event ProofVerified(uint256 indexed id, address verifier, uint256 reputationAdded);
    event ReputationUpdated(address indexed user, uint256 newReputation);
    event OwnershipTransferred(address indexed previousOwner, address indexed newOwner);

    modifier onlyOwner() {
        require(msg.sender == owner, "Not contract owner");
        _;
    }

    modifier onlyCreator(uint256 _id) {
        require(proofs[_id].creator == msg.sender, "Not proof creator");
        _;
    }

    constructor() {
        owner = msg.sender;
    }

    /**
     * @notice Create a new proof entry
     * @param _proofHash The hash or content ID of the proof
     * @param _metadataURI Optional metadata or reference file URI
     */
    function createProof(string memory _proofHash, string memory _metadataURI) external {
        require(bytes(_proofHash).length > 0, "Invalid proof hash");

        totalProofs++;
        proofs[totalProofs] = Proof({
            id: totalProofs,
            creator: msg.sender,
            proofHash: _proofHash,
            metadataURI: _metadataURI,
            timestamp: block.timestamp,
            verified: false,
            reputationScore: 0
        });

        userProofs[msg.sender].push(totalProofs);

        emit ProofCreated(totalProofs, msg.sender, _proofHash, _metadataURI);
    }

    /**
     * @notice Verify a proof and assign reputation to its creator
     * @param _id Proof ID
     * @param _repScore Reputation points to assign to creator
     */
    function verifyProof(uint256 _id, uint256 _repScore) external onlyOwner {
        Proof storage proof = proofs[_id];
        require(!proof.verified, "Already verified");

        proof.verified = true;
        proof.reputationScore = _repScore;

        userReputation[proof.creator] += _repScore;

        emit ProofVerified(_id, msg.sender, _repScore);
        emit ReputationUpdated(proof.creator, userReputation[proof.creator]);
    }

    /**
     * @notice Retrieve a proof record
     * @param _id Proof ID
     * @return The full Proof struct
     */
    function getProof(uint256 _id) external view returns (Proof memory) {
        require(_id > 0 && _id <= totalProofs, "Invalid proof ID");
        return proofs[_id];
    }

    /**
     * @notice Get all proof IDs created by a specific user
     * @param _user Address of creator
     * @return List of proof IDs
     */
    function getUserProofs(address _user) external view returns (uint256[] memory) {
        return userProofs[_user];
    }

    /**
     * @notice Update contract ownership
     * @param _newOwner Address of new owner
     */
    function transferOwnership(address _newOwner) external onlyOwner {
        require(_newOwner != address(0), "Invalid new owner");
        emit OwnershipTransferred(owner, _newOwner);
        owner = _newOwner;
    }

    /**
     * @notice View total reputation score of a user
     * @param _user Address of user
     * @return Reputation points
     */
    function getUserReputation(address _user) external view returns (uint256) {
        return userReputation[_user];
    }

    /**
     * @notice Get total number of proofs created globally
     */
    function getTotalProofs() external view returns (uint256) {
        return totalProofs;
    }
}
// 
End
// 
