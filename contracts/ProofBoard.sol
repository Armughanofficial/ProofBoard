
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

        string memory image = Base64.encode(bytes(_badgeSVG(tokenId, c.category, c.title)));

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

        return _badgeSVG(tokenId, contributions[contributionId].category, contributions[contributionId].title);
    }

    function _badgeSVG(
        uint256 tokenId,
        string memory category,
        string memory title
    ) internal pure returns (string memory) {
        string memory a = "#8f7dff";
        string memory b = "#5ff0c0";
        string memory glyph = "{ }";

        if (_equals(category, "Docs")) {
            a = "#5ff0c0"; b = "#7ab8ff"; glyph = "&#182;";
        } else if (_equals(category, "Design")) {
            a = "#ff8fd0"; b = "#8f7dff"; glyph = "&#9670;";
        } else if (_equals(category, "Security")) {
            a = "#ffc46b"; b = "#ff7a90"; glyph = "&#167;";
        }

        bytes memory rings;

        for (uint256 i = 0; i < 14; i++) {
            rings = abi.encodePacked(
                rings,
                '<ellipse rx="72" ry="26" transform="rotate(',
                (i * 12857 / 1000).toString(),
                ')" fill="none" stroke="url(#grad)" stroke-width=".8" opacity=".75"/>'
            );
        }

        // Ten offset circular rings, matching the frontend pattern.
        int256[10] memory xs = [int256(22), 17, 6, -6, -17, -22, -17, -6, 6, 17];
        int256[10] memory ys = [int256(0), 13, 21, 21, 13, 0, -13, -21, -21, -13];

        for (uint256 i = 0; i < 10; i++) {
            rings = abi.encodePacked(
                rings,
                '<ellipse rx="50" ry="50" cx="',
                _signedString(xs[i]),
                '" cy="',
                _signedString(ys[i]),
                '" fill="none" stroke="#ffffff22" stroke-width=".6"/>'
            );
        }

        bytes memory titleBytes = bytes(title);
        if (titleBytes.length > 26) {
            bytes memory shortTitle = new bytes(25);
            for (uint256 i = 0; i < 25; i++) {
                shortTitle[i] = titleBytes[i];
            }
            title = string(abi.encodePacked(shortTitle, "..."));
        }

        bytes memory svg = abi.encodePacked(
            '<svg xmlns="http://www.w3.org/2000/svg" width="800" height="1040" viewBox="0 0 200 260">',
            '<defs><linearGradient id="grad" x1="0" y1="0" x2="1" y2="1">',
            '<stop offset="0" stop-color="', a, '"/>',
            '<stop offset="1" stop-color="', b, '"/>',
            '</linearGradient><radialGradient id="bg" cx=".5" cy=".4" r=".7">',
            '<stop offset="0" stop-color="', a, '" stop-opacity=".28"/>',
            '<stop offset=".7" stop-color="#0d0d14"/>',
            '</radialGradient></defs>'
        );

        svg = abi.encodePacked(
            svg,
            '<rect x="1" y="1" width="198" height="258" rx="19" fill="url(#bg)" stroke="url(#grad)" stroke-width="1.4"/>',
            '<rect x="9" y="9" width="182" height="242" rx="13" fill="none" stroke="#ffffff" stroke-opacity=".08"/>',
            '<text x="20" y="30" fill="', a, '" font-family="monospace" font-size="8.5">proofboard / s1</text>',
            '<text x="180" y="30" text-anchor="end" fill="#ffffff" opacity=".5" font-family="monospace" font-size="8.5">#',
            tokenId.toString(), '</text>'
        );

        svg = abi.encodePacked(
            svg,
            '<g transform="translate(100 120)">',
            rings,
            '<circle r="31" fill="#0b0b11" stroke="url(#grad)" stroke-width="1.5"/>',
            '<text text-anchor="middle" y="9" font-family="serif" font-size="28" fill="', a, '">',
            glyph, '</text></g>'
        );

        svg = abi.encodePacked(
            svg,
            '<line x1="20" x2="180" y1="203" y2="203" stroke="#ffffff" stroke-opacity=".1"/>',
            '<text x="20" y="223" fill="#ecebf3" font-family="serif" font-size="15">',
            _escapeXML(title), '</text>',
            '<text x="20" y="241" fill="', b, '" font-family="monospace" font-size="8.5">',
            _escapeXML(category), ' contributor</text></svg>'
        );

        return string(svg);
    }

    function _signedString(int256 value) private pure returns (string memory) {
        if (value < 0) {
            return string(abi.encodePacked("-", uint256(-value).toString()));
        }
        return uint256(value).toString();
    }

    function _escapeXML(string memory input) private pure returns (string memory) {
        bytes memory source = bytes(input);
        bytes memory output;

        for (uint256 i = 0; i < source.length; i++) {
            bytes1 ch = source[i];

            if (ch == 0x26) output = abi.encodePacked(output, "&amp;");
            else if (ch == 0x3c) output = abi.encodePacked(output, "&lt;");
            else if (ch == 0x3e) output = abi.encodePacked(output, "&gt;");
            else if (ch == 0x22) output = abi.encodePacked(output, "&quot;");
            else if (ch == 0x27) output = abi.encodePacked(output, "&apos;");
            else output = abi.encodePacked(output, ch);
        }

        return string(output);
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
