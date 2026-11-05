
// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

import "@openzeppelin/contracts/token/ERC721/ERC721.sol";
import "@openzeppelin/contracts/access/Ownable.sol";
import "@openzeppelin/contracts/utils/Base64.sol";
import "@openzeppelin/contracts/utils/Strings.sol";

contract ProofBoard is ERC721, Ownable {
    using Strings for uint256;

    enum Status {
        Pending,
        Approved,
        Rejected
    }

    struct Contribution {
        address contributor;
        string title;
        string proofUrl;
        string category;
        Status status;
        uint256 tokenId;
        uint256 submittedAt;
    }

    uint256 private _contributionCount;
    uint256 private _nextTokenId = 1;

    mapping(uint256 => Contribution) private contributions;
    mapping(uint256 => uint256) private tokenContributions;

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

    event ContributionRejected(
        uint256 indexed contributionId,
        address indexed contributor
    );

    constructor() ERC721("ProofBoard Badge", "PB") Ownable(msg.sender) {}

    function submitContribution(
        string calldata title,
        string calldata proofUrl,
        string calldata category
    ) external returns (uint256) {
        require(bytes(title).length > 0 && bytes(title).length <= 100, "Invalid title");
        require(bytes(proofUrl).length > 0 && bytes(proofUrl).length <= 500, "Invalid proof URL");
        require(_validCategory(category), "Invalid category");

        uint256 contributionId = ++_contributionCount;

        contributions[contributionId] = Contribution({
            contributor: msg.sender,
            title: title,
            proofUrl: proofUrl,
            category: category,
            status: Status.Pending,
            tokenId: 0,
            submittedAt: block.timestamp
        });

        emit ContributionSubmitted(contributionId, msg.sender, title, proofUrl);

        return contributionId;
    }

    function approveContribution(uint256 contributionId) external onlyOwner {
        Contribution storage c = contributions[contributionId];

        require(c.contributor != address(0), "Contribution not found");
        require(c.status == Status.Pending, "Already reviewed");

        uint256 tokenId = _nextTokenId++;

        c.status = Status.Approved;
        c.tokenId = tokenId;
        tokenContributions[tokenId] = contributionId;

        _safeMint(c.contributor, tokenId);

        emit ContributionApproved(contributionId, c.contributor, tokenId);
    }

    function rejectContribution(uint256 contributionId) external onlyOwner {
        Contribution storage c = contributions[contributionId];

        require(c.contributor != address(0), "Contribution not found");
        require(c.status == Status.Pending, "Already reviewed");

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

        require(c.contributor != address(0), "Contribution not found");

        return (c.contributor, c.title, c.proofUrl, c.status, c.tokenId);
    }

    function getContributionCategory(uint256 contributionId)
        external
        view
        returns (string memory)
    {
        require(contributions[contributionId].contributor != address(0), "Contribution not found");
        return contributions[contributionId].category;
    }

    function getContributionCount() external view returns (uint256) {
        return _contributionCount;
    }

    function tokenURI(uint256 tokenId) public view override returns (string memory) {
        require(_ownerOf(tokenId) != address(0), "Token does not exist");

        uint256 contributionId = tokenContributions[tokenId];
        Contribution storage c = contributions[contributionId];

        string memory image = Base64.encode(bytes(_badgeSVG(tokenId, c.category)));

        string memory json = string(
            abi.encodePacked(
                '{"name":"',
                _escapeJSON(c.title),
                '","description":"Verified ProofBoard developer contribution.",',
                '"image":"data:image/svg+xml;base64,',
                image,
                '","attributes":[',
                '{"trait_type":"Category","value":"',
                _escapeJSON(c.category),
                '"},',
                '{"trait_type":"Contribution ID","value":"',
                contributionId.toString(),
                '"},',
                '{"trait_type":"Token ID","value":"',
                tokenId.toString(),
                '"}',
                ']}'
            )
        );

        return string(
            abi.encodePacked(
                "data:application/json;base64,",
                Base64.encode(bytes(json))
            )
        );
    }

    function badgeSVG(uint256 tokenId) external view returns (string memory) {
        require(_ownerOf(tokenId) != address(0), "Token does not exist");

        uint256 contributionId = tokenContributions[tokenId];

        return _badgeSVG(tokenId, contributions[contributionId].category);
    }

    function _badgeSVG(uint256 tokenId, string memory category)
        internal
        pure
        returns (string memory)
    {
        string memory accent = "#8B5CF6";

        if (_equals(category, "Code")) accent = "#22D3EE";
        if (_equals(category, "Docs")) accent = "#FBBF24";
        if (_equals(category, "Design")) accent = "#F472B6";
        if (_equals(category, "Security")) accent = "#34D399";

        return string(
            abi.encodePacked(
                '<svg xmlns="http://www.w3.org/2000/svg" width="400" height="520" viewBox="0 0 400 520">',
                '<rect width="400" height="520" rx="24" fill="#0B1020"/>',
                '<rect x="14" y="14" width="372" height="492" rx="18" fill="none" stroke="',
                accent,
                '" stroke-opacity=".55"/>',
                '<text x="200" y="64" text-anchor="middle" fill="#E2E8F0" font-family="monospace" font-size="21" letter-spacing="3">PROOFBOARD</text>',
                '<circle cx="200" cy="235" r="112" fill="none" stroke="',
                accent,
                '" stroke-opacity=".3" stroke-width="2"/>',
                '<ellipse cx="200" cy="235" rx="108" ry="42" fill="none" stroke="',
                accent,
                '" stroke-width="3" transform="rotate(-35 200 235)"/>',
                '<ellipse cx="200" cy="235" rx="108" ry="42" fill="none" stroke="',
                accent,
                '" stroke-width="3" transform="rotate(35 200 235)"/>',
                '<circle cx="200" cy="235" r="33" fill="',
                accent,
                '" fill-opacity=".2" stroke="',
                accent,
                '" stroke-width="3"/>',
                '<text x="200" y="243" text-anchor="middle" fill="#FFFFFF" font-family="monospace" font-size="25">PB</text>',
                '<text x="200" y="390" text-anchor="middle" fill="#FFFFFF" font-family="monospace" font-size="24">',
                category,
                '</text>',
                '<text x="200" y="425" text-anchor="middle" fill="#94A3B8" font-family="monospace" font-size="15">VERIFIED CONTRIBUTION</text>',
                '<text x="200" y="470" text-anchor="middle" fill="',
                accent,
                '" font-family="monospace" font-size="18">TOKEN #',
                tokenId.toString(),
                '</text>',
                '</svg>'
            )
        );
    }

    function _validCategory(string memory category) private pure returns (bool) {
        return _equals(category, "Code")
            || _equals(category, "Docs")
            || _equals(category, "Design")
            || _equals(category, "Security");
    }

    function _equals(string memory a, string memory b) private pure returns (bool) {
        return keccak256(bytes(a)) == keccak256(bytes(b));
    }

    function _escapeJSON(string memory input) private pure returns (string memory) {
        bytes memory source = bytes(input);
        bytes memory output = new bytes(source.length * 6);
        uint256 j;

        for (uint256 i = 0; i < source.length; i++) {
            uint8 ch = uint8(source[i]);

            if (ch == 34 || ch == 92) {
                output[j++] = bytes1(uint8(92));
                output[j++] = source[i];
            } else if (ch < 32) {
                bytes16 hexChars = "0123456789abcdef";
                output[j++] = bytes1(uint8(92));
                output[j++] = bytes1(uint8(117));
                output[j++] = bytes1(uint8(48));
                output[j++] = bytes1(uint8(48));
                output[j++] = hexChars[ch >> 4];
                output[j++] = hexChars[ch & 15];
            } else {
                output[j++] = source[i];
            }
        }

        assembly {
            mstore(output, j)
        }

        return string(output);
    }
}
