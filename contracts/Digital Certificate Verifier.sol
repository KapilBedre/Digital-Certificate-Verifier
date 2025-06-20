// SPDX-License-Identifier: MIT
pragma solidity ^0.8.19;

/**
 * @title Digital Certificate Verifier
 * @dev A smart contract for issuing and verifying digital certificates on blockchain
 * @author Your Name
 */
contract Project {
    
    // Structure to store certificate details
    struct Certificate {
        string recipientName;
        string courseName;
        string issuerName;
        uint256 issueDate;
        bool isValid;
    }
    
    // Mapping from certificate ID to Certificate struct
    mapping(bytes32 => Certificate) public certificates;
    
    // Mapping to track authorized issuers
    mapping(address => bool) public authorizedIssuers;
    
    // Contract owner
    address public owner;
    
    // Events
    event CertificateIssued(
        bytes32 indexed certificateId,
        string recipientName,
        string courseName,
        string issuerName,
        uint256 issueDate
    );
    
    event CertificateRevoked(bytes32 indexed certificateId);
    
    event IssuerAuthorized(address indexed issuer);
    
    event IssuerRevoked(address indexed issuer);
    
    // Modifiers
    modifier onlyOwner() {
        require(msg.sender == owner, "Only owner can perform this action");
        _;
    }
    
    modifier onlyAuthorizedIssuer() {
        require(authorizedIssuers[msg.sender], "Only authorized issuers can issue certificates");
        _;
    }
    
    /**
     * @dev Constructor to set the contract owner
     */
    constructor() {
        owner = msg.sender;
        authorizedIssuers[msg.sender] = true; // Owner is automatically authorized
    }
    
    /**
     * @dev Core Function 1: Issue a new digital certificate
     * @param _recipientName Name of the certificate recipient
     * @param _courseName Name of the course/program
     * @param _issuerName Name of the issuing institution
     * @return certificateId The unique ID of the issued certificate
     */
    function issueCertificate(
        string memory _recipientName,
        string memory _courseName,
        string memory _issuerName
    ) public onlyAuthorizedIssuer returns (bytes32) {
        
        require(bytes(_recipientName).length > 0, "Recipient name cannot be empty");
        require(bytes(_courseName).length > 0, "Course name cannot be empty");
        require(bytes(_issuerName).length > 0, "Issuer name cannot be empty");
        
        // Generate unique certificate ID using hash of parameters and timestamp
        bytes32 certificateId = keccak256(
            abi.encodePacked(
                _recipientName,
                _courseName,
                _issuerName,
                block.timestamp,
                msg.sender
            )
        );
        
        // Ensure certificate ID doesn't already exist
        require(!certificates[certificateId].isValid, "Certificate already exists");
        
        // Create and store the certificate
        certificates[certificateId] = Certificate({
            recipientName: _recipientName,
            courseName: _courseName,
            issuerName: _issuerName,
            issueDate: block.timestamp,
            isValid: true
        });
        
        emit CertificateIssued(
            certificateId,
            _recipientName,
            _courseName,
            _issuerName,
            block.timestamp
        );
        
        return certificateId;
    }
    
    /**
     * @dev Core Function 2: Verify the authenticity of a certificate
     * @param _certificateId The unique ID of the certificate to verify
     * @return isValid Whether the certificate is valid
     * @return recipientName Name of the certificate recipient
     * @return courseName Name of the course/program
     * @return issuerName Name of the issuing institution
     * @return issueDate Timestamp when certificate was issued
     */
    function verifyCertificate(bytes32 _certificateId) 
        public 
        view 
        returns (
            bool isValid,
            string memory recipientName,
            string memory courseName,
            string memory issuerName,
            uint256 issueDate
        ) 
    {
        Certificate memory cert = certificates[_certificateId];
        
        return (
            cert.isValid,
            cert.recipientName,
            cert.courseName,
            cert.issuerName,
            cert.issueDate
        );
    }
    
    /**
     * @dev Core Function 3: Revoke a certificate (invalidate it)
     * @param _certificateId The unique ID of the certificate to revoke
     */
    function revokeCertificate(bytes32 _certificateId) public onlyAuthorizedIssuer {
        require(certificates[_certificateId].isValid, "Certificate does not exist or already revoked");
        
        certificates[_certificateId].isValid = false;
        
        emit CertificateRevoked(_certificateId);
    }
    
    /**
     * @dev Authorize a new issuer (only owner can do this)
     * @param _issuer Address of the issuer to authorize
     */
    function authorizeIssuer(address _issuer) public onlyOwner {
        require(_issuer != address(0), "Invalid issuer address");
        require(!authorizedIssuers[_issuer], "Issuer already authorized");
        
        authorizedIssuers[_issuer] = true;
        
        emit IssuerAuthorized(_issuer);
    }
    
    /**
     * @dev Revoke issuer authorization (only owner can do this)
     * @param _issuer Address of the issuer to revoke
     */
    function revokeIssuerAuthorization(address _issuer) public onlyOwner {
        require(_issuer != owner, "Cannot revoke owner's authorization");
        require(authorizedIssuers[_issuer], "Issuer not authorized");
        
        authorizedIssuers[_issuer] = false;
        
        emit IssuerRevoked(_issuer);
    }
    
    /**
     * @dev Check if an address is an authorized issuer
     * @param _issuer Address to check
     * @return bool Whether the address is authorized to issue certificates
     */
    function isAuthorizedIssuer(address _issuer) public view returns (bool) {
        return authorizedIssuers[_issuer];
    }
}
