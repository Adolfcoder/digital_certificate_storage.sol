// SPDX-License-Identifier: MIT
pragma solidity ^0.8.19;

contract Project {

    struct Certificate {
        string recipient;
        string course;
        string issuerInstitution;
        uint256 issueDate;
        bool isRevoked;
        address issuedBy;
        bool exists;
    }

    mapping(bytes32 => Certificate) public certificates;
    address public admin;

    event CertificateIssued(bytes32 indexed hash, string recipient, string course);
    event CertificateRevoked(bytes32 indexed hash);

    modifier onlyAdmin() {
        require(msg.sender == admin, "Only admin can perform this action");
        _;
    }

    constructor() {
        admin = msg.sender;
    }

    function issueCertificate(
        string memory recipient,
        string memory course,
        string memory issuerInstitution,
        bytes32 hash
    ) public onlyAdmin {
        require(!certificates[hash].exists, "Certificate already exists");

        certificates[hash] = Certificate({
            recipient: recipient,
            course: course,
            issuerInstitution: issuerInstitution,
            issueDate: block.timestamp,
            isRevoked: false,
            issuedBy: msg.sender,
            exists: true
        });

        emit CertificateIssued(hash, recipient, course);
    }

    function verifyCertificate(bytes32 hash) public view returns (
        bool valid,
        string memory recipient,
        string memory course,
        string memory issuerInstitution,
        uint256 issueDate,
        address issuedBy
    ) {
        Certificate memory cert = certificates[hash];
        if (cert.exists && !cert.isRevoked) {
            return (
                true,
                cert.recipient,
                cert.course,
                cert.issuerInstitution,
                cert.issueDate,
                cert.issuedBy
            );
        } else {
            return (false, "", "", "", 0, address(0));
        }
    }

    function revokeCertificate(bytes32 hash) public onlyAdmin {
        require(certificates[hash].exists, "Certificate does not exist");
        require(!certificates[hash].isRevoked, "Already revoked");

        certificates[hash].isRevoked = true;

        emit CertificateRevoked(hash);
    }
}

