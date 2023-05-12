// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "@openzeppelin/contracts/token/ERC20/IERC20.sol";
import "@openzeppelin/contracts/token/ERC721/IERC721.sol";
import "@openzeppelin/contracts/token/ERC721/IERC721Receiver.sol";
import "@openzeppelin/contracts/access/Ownable.sol";

contract DVP is IERC721Receiver, Ownable {
    IERC20 public bbcToken;
    IERC721 public mundialToken;

    event Delivery(address indexed sender, address indexed recipient, uint256 amount);
    event Payment(address indexed sender, address indexed recipient, uint256 amount);

    constructor(IERC20 _bbcToken, IERC721 _mundialToken) {
        bbcToken = _bbcToken;
        mundialToken = _mundialToken;
    }

    function sendDelivery(address _recipient, uint256 _amount) public {
        bbcToken.transfer(_recipient, _amount);
        emit Delivery(msg.sender, _recipient, _amount);
    }

    function onERC721Received(address, address _from, uint256 _tokenId, bytes memory) public override returns (bytes4) {
        require(msg.sender == address(mundialToken), "DVP: Tokens received from unauthenticated source");
        bbcToken.transferFrom(_from, address(this), _tokenId);
        emit Payment(address(mundialToken), _from, _tokenId);
        return IERC721Receiver.onERC721Received.selector;
    }
}
