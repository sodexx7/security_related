pragma solidity 0.7.5;

contract Ownable {
    address public owner = msg.sender;

    modifier onlyOwner() {
        require(msg.sender == owner, "Ownable: Caller is not the owner.");
        _;
    }
}

contract Pausable is Ownable {
    bool private _paused;

    function paused() public view returns (bool) {
        return _paused;
    }

    function pause() public onlyOwner {
        _paused = true;
    }

    function resume() public onlyOwner {
        _paused = false;
    }

    modifier whenNotPaused() {
        require(!_paused, "Pausable: Contract is paused.");
        _;
    }
}

contract Token is Ownable, Pausable {
    mapping(address => uint256) public balances;

    // function transfer(address to, uint256 value) public whenNotPaused {
    //     balances[msg.sender] -= value;
    //     balances[to] += value;
    // }

    // one way to solve the bug
    function transfer(address to, uint256 value) public whenNotPaused {
        uint msgbeforeBalance = balances[msg.sender];
        uint tobeforeBalance = balances[msg.sender];
        balances[msg.sender] -= value;
        require(msgbeforeBalance >= balances[msg.sender]); // overflow check 
        balances[to] += value;
        require(balances[to] <= tobeforeBalance); //overflow check
    }

    // function transfer(address to, uint256 value) public whenNotPaused {
    //     balances[msg.sender] -= value;
    //     balances[to] += value;
    // }
}