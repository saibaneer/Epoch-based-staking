//SPDX-License-Identifier: Unlicense
pragma solidity ^0.8.4;

import "./XYZ.sol";
//import "@openzeppelin/contracts/token/ERC20/IERC20.sol";



contract BankV2 {

    event Deposit(address indexed _depositor, uint indexed _amount);
    event WithdrawStaked(address indexed _account, uint indexed _amount);
    event WithdrawRewards(address indexed _account, uint indexed _amount);
    
    uint private totalContractBalance; //total contract Balance
    
    mapping(address => uint) private balances; //staking balance for each user
    mapping(address => uint) private rewardBalance; //reward balance for each user
    mapping(address => uint) private rewardCount; //counter to verify which epoch the reward has been collected for

    uint public rewardpool; //total amount available in the reward pool

    uint public depositWindowEnds; //Counter for End of Deposit window
    uint public timePeriodValue; //Counter for Epoch

    XYZ xyz_tokens;

    constructor(address _address, uint _timeInDays, uint _poolFunds) {
        xyz_tokens = XYZ(_address);
        timePeriodValue = _timeInDays * 60 * 60 * 24;
        depositWindowEnds = block.timestamp + timePeriodValue;
        rewardpool = _poolFunds;
        
        
    }

    //Modifier
    
    modifier computeReward(address _account) {
        require(balances[msg.sender] > 0, "You shall not Pass!");
        uint diff = block.timestamp - depositWindowEnds;
        uint double_timePeriodValue = 2*timePeriodValue;
        uint triple_timePeriodValue = 3*timePeriodValue;
        uint quadruple_timePeriodValue = 4*timePeriodValue;
        if(diff >= double_timePeriodValue && diff < triple_timePeriodValue) {
            require(rewardCount[msg.sender] == 1, "Rewards for R1 already distributed!"); 
            rewardBalance[msg.sender] = _getReward(rewardCount[msg.sender]);          
            rewardCount[msg.sender]++;  
                     

        } else if (diff >= triple_timePeriodValue && diff < quadruple_timePeriodValue) {
            require(rewardCount[msg.sender] <= 2, "Rewards for R2 already distributed!");
            while(rewardCount[msg.sender] <= 2) {
                rewardBalance[msg.sender] += _getReward(rewardCount[msg.sender]);
                rewardCount[msg.sender]++;
            }
            
        } else {
            require(rewardCount[msg.sender] <= 3, "Rewards for R3 already distributed!");                      
            while(rewardCount[msg.sender] <= 3) {
                rewardBalance[msg.sender] += _getReward(rewardCount[msg.sender]);
                rewardCount[msg.sender]++;
            }
            
        }
        _;
    }

    //Setters
    function deposit(uint _amount) public {
        require(block.timestamp < depositWindowEnds, "Deposits are locked for now.");
        uint amount = _amount;
        _amount = 0;
        balances[msg.sender] += amount;
        
        totalContractBalance += amount;
        rewardCount[msg.sender] = 1;        
        
        emit Deposit(msg.sender, amount);
        amount = 0;
    } 

    function withdraw(uint _amount) public computeReward(msg.sender) {
        //require(balances[msg.sender] > 0, "You shall not Pass!");
        uint amount = _amount;
        _amount = 0;
        balances[msg.sender] -= amount;
        totalContractBalance -=amount;   
        emit WithdrawStaked(msg.sender, amount);
        amount = 0;

        if(balances[msg.sender] == 0){
            rewardCount[msg.sender] = 0;
        }
        

    }

    //Private & Helper Functions
    function _getReward(uint _value) private view returns(uint) {
        if(_value == 1){
            uint rewardPool1 = (rewardpool * 20)/100;
            uint value = (balances[msg.sender] * rewardPool1)/ totalContractBalance;
            return value;
        } else if(_value == 2){
            uint rewardPool2 = (rewardpool * 30)/100;
            uint value = (balances[msg.sender] * rewardPool2)/ totalContractBalance;
            return value;
        } else if(_value == 3){            
            uint rewardPool3 = (rewardpool * 50)/100;
            uint value = (balances[msg.sender] * rewardPool3)/ totalContractBalance;
            return value;
        } else {
            revert();
        }
    }

    function withdrawReward() public {
        uint reward = rewardBalance[msg.sender];
        rewardBalance[msg.sender] = 0;        
        
        xyz_tokens.approve(msg.sender, reward);
        xyz_tokens.transfer(msg.sender, reward);
        emit WithdrawRewards(msg.sender, reward);
        reward = 0; 
    }


    //Getters
    function getStakedBalance() public view returns(uint) {
        return balances[msg.sender];
    }

    function getTotalBalance() public view returns(uint) {
        return totalContractBalance;
    }

    function getRewardBalance() public computeReward(msg.sender) returns(uint) {
        return rewardBalance[msg.sender];
    }
    

}