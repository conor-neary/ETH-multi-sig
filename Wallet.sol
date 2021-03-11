pragma solidity 0.8.0;
pragma abicoder v2;
import "./Ownable.sol";


contract MyWallet is Ownable{
    event depositDone(uint amount, address indexed depositor);
    event Received(address indexed sender, uint amount);
    event Requested(address request, address recipient, uint amount, string memo);
    event Approved(address approver,address request, address recipient, uint amount, string memo);
    event Transferred(address recipient, uint amount, string memo);
    
    struct Request {
        address sender;
        address payable recipient;
        uint amount;
        string memo;
        uint approvals;
    }
    
    Request[] requests;
    
    receive() external payable {
        emit Received(msg.sender, msg.value);
    }
    
    function deposit() public payable returns (uint){
        emit depositDone(msg.value, msg.sender);
        return address(this).balance;
    }
    
    function requestTransfer(address payable _to, uint _amount, string memory _memo) public onlyOwner{
        Request memory newRequest = Request(msg.sender, _to, _amount, _memo, 1);
        requests.push(newRequest);
        emit Requested(msg.sender, _to, _amount, _memo);
    }
    
    function approveTransfer(uint _index) public onlyOwner{
        require(msg.sender != requests[_index].sender, "You Can't Approve Your Own Request!");
        requests[_index].approvals++;
        if(requests[_index].approvals >= approvalsNeeded){
            _transfer(_index);
        }
        emit Approved(msg.sender, requests[_index].sender, requests[_index].recipient, requests[_index].amount, requests[_index].memo);
    }
    
    function _transfer(uint _index) internal onlyOwner{
        require(address(this).balance >= requests[_index].amount, "You don't have enough ether for this transfer");
        address payable receiver = requests[_index].recipient;
        receiver.transfer(requests[_index].amount);
        emit Transferred(receiver,requests[_index].amount, requests[_index].memo);
        delete requests[_index];
        
    }
    
    function getBalance() public view onlyOwner returns (uint){
        return address(this).balance;
    }
    
    function getNumRequests() public onlyOwner view returns (uint){
        return requests.length;
    }
    
    function requestLookup(uint _index) public view onlyOwner returns (address, address, uint, string memory, uint){
        return (requests[_index].sender, requests[_index].recipient, requests[_index].amount,requests[_index].memo,requests[_index].approvals);
    }
}
