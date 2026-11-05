// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

import "@openzeppelin/contracts/token/ERC721/ERC721.sol";
import "@openzeppelin/contracts/access/Ownable.sol";
import "@openzeppelin/contracts/utils/Base64.sol";

contract ProofBoard is ERC721, Ownable {
    enum Status {
        Pending,
        Approved,
        Rejected
    }

    struct Contribution {
        address contributor;
        string title;
        string proofUrl;
        Status status;
        uint256 tokenId;
        uint256 submittedAt;
    }

    uint256 private _contributionCount;

    event ContributionSubmitted(
        uint256 indexed contributionId,
        address indexed contributor,
        string title,
        string proofUrl
    );

    event ContributionApproved(
        uint256 indexed contributionId,
        address indexed contributor,
        uint256 indexed tokenId
    );

    event ContributionRejected(uint256 indexed contributionId, address indexed contributor);

    constructor() ERC721("ProofBoard Badge", "PB") Ownable(msg.sender) {}

    function submitContribution(string calldata title, string calldata proofUrl)
        external
        returns (uint256)
    {
        require(bytes(title).length > 0, "ProofBoard: empty title");
        require(bytes(proofUrl).length > 0, "ProofBoard: empty proof URL");

        uint256 contributionId = ++_contributionCount;

        contributions[contributionId] = Contribution({
            contributor: msg.sender,
            title: title,
            proofUrl: proofUrl,
            status: Status.Pending,
            tokenId: 0,
            submittedAt: block.timestamp
        });

        emit ContributionSubmitted(contributionId, msg.sender, title, proofUrl);
        return contributionId;
    }

    function approveContribution(uint256 contributionId) external onlyOwner {
        Contribution storage c = contributions[contributionId];
        require(c.contributor != address(0), "ProofBoard: contribution does not exist");
        require(c.status == Status.Pending, "ProofBoard: already reviewed");

        c.status = Status.Approved;
        c.tokenId = _nextTokenId;
        _mint(c.contributor, c.tokenId);
        _nextTokenId += 1;

        emit ContributionApproved(contributionId, c.contributor, c.tokenId);
    }

    function rejectContribution(uint256 contributionId) external onlyOwner {
        Contribution storage c = contributions[contributionId];
        require(c.contributor != address(0), "ProofBoard: contribution does not exist");
        require(c.status == Status.Pending, "ProofBoard: already reviewed");

        c.status = Status.Rejected;

        emit ContributionRejected(contributionId, c.contributor);
    }

    function getContribution(uint256 contributionId)
        external
        view
        returns (
            address contributor,
            string memory title,
            string memory proofUrl,
            Status status,
            uint256 tokenId
        )
    {
        Contribution storage c = contributions[contributionId];
        require(c.contributor != address(0), "ProofBoard: contribution does not exist");
        return (c.contributor, c.title, c.proofUrl, c.status, c.tokenId);
    }

    function getContributionCount() external view returns (uint256) {
        return _contributionCount;
    }

    mapping(uint256 => Contribution) private contributions;
    uint256 private _nextTokenId = 1;

    function tokenURI(uint256 tokenId) public view override returns (string memory) {
        require(_ownerOf(tokenId) != address(0), "ProofBoard: token does not exist");

        string memory json = string(
            abi.encodePacked(
                '{"name":"ProofBoard Badge #',
                _toString(tokenId),
                '","description":"A ProofBoard contributor badge."}'
            )
        );

        return string(
            abi.encodePacked("data:application/json;base64,", Base64.encode(bytes(json)))
        );
    }

    function _toString(uint256 value) private pure returns (string memory) {
        if (value == 0) return "0";
        uint256 temp = value;
        uint256 digits;
        while (temp != 0) {
            digits++;
            temp /= 10;
        }
        bytes memory buffer = new bytes(digits);
        while (value != 0) {
            digits -= 1;
            buffer[digits] = bytes1(uint8(48 + (value % 10)));
            value /= 10;
        }
        return string(buffer);
    }
}