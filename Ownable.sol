pragma solidity 0.8.0;

contract Ownable {
    mapping(address => bool) owners;
    
    uint approvalsNeeded;
    
    event ownerAdded(address creator, address added);
    
    modifier onlyOwner {
        require(owners[msg.sender], "This function is restricted to wallet owners");
        _; //run the function
    }

    function addOwner(address _newOwner) public onlyOwner {
        owners[_newOwner] = true;
        emit ownerAdded(msg.sender, _newOwner);
    }
    
    constructor(){
        owners[msg.sender] = true;
        approvalsNeeded = 2;
    }
}
