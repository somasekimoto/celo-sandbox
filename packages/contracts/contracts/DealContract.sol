/**
 *Submitted for verification at polygonscan.com on 2023-03-17
*/

//2023/3/17 @realNuun
// SPDX-License-Identifier: GPL-3.0

pragma solidity >=0.7.0 <0.9.0;

contract DealContract {

    uint executedBalance;

    address public celo; // CELO address mainnet 0x8dd4f800851Db9DC219fdFaEB82F8d69e2B13582 testnet(Alfajores) 0xF194afDf50B03e69Bd7D057c1Aa9e10c9954E4C9
    address public cusd; // cUSD address mainnet 0x765de816845861e75a25fca122bb6898b8b1282a testnet(Alfajores) 0x874069fa1eb16d44d622f2e0ca25eea172369bc1
    address public ceur; // cEUR address mainnet 0xd8763cba276a3738e6de85b4b3bf5fded6d6ca73 testnet(Alfajores) 0x10c892a6ec43a53e45d0b916b4b7d383b1b78c0f
    address public creal; // cREAL address mainnet 0xe8537a3d056DA446677B9E9d6c5dB704EaAb4787 testnet(Alfajores) 0xC5375c73a627105eb4DF00867717F6e301966C32

    struct Deal{
        uint dealId;
        address sellerAddress;
        address    buyerAddress;
        uint    sellerDeposit;
        uint    buyerDeposit;
        uint    amountOfClaim;
        uint    depositReleaseTime;
        uint    grantDeadline;
        uint    executeDeadlineInterval;
    }


    mapping(uint => Deal) dealIdMap;
    uint dealIdMapCount;

    event eventDeal(Deal _deal);

    event eventMsgValue(uint _msgValue);
    
    constructor(address _celo, address _cusd, address _ceur, address _creal) {
        celo = _celo;
        cusd = _cusd;
        ceur = _ceur;
        creal = _creal;
    }

    function claim(uint _grantDeadline,uint _executeDeadlineInterval) public payable returns(Deal memory){

        dealIdMapCount = dealIdMapCount + 1;
        address sellerAddress = msg.sender;
        address buyerAddress;
        uint sellerDeposit = msg.value;
        uint buyerDeposit = 0;
        uint amountOfClaim = msg.value;
        uint depositReleaseTime = block.timestamp + _grantDeadline;

        dealIdMap[dealIdMapCount] = Deal(
            dealIdMapCount,
            sellerAddress,
            buyerAddress,
            sellerDeposit,
            buyerDeposit,
            amountOfClaim,
            depositReleaseTime,
            _grantDeadline,
            _executeDeadlineInterval
        );

        emit eventDeal(dealIdMap[dealIdMapCount]);

        emit eventMsgValue(msg.value);

        return dealIdMap[dealIdMapCount];

    }

    function grant(uint _dealId) public payable returns(Deal memory){
        //Check if msg.value matches the claimAmount of the corresponding deal.
        requireMsgValueEqualClaimAmount(msg.value, dealIdMap[_dealId].amountOfClaim);
        //Check to see if the current time has not exceeded the depositReleaseTime.
        requireDepositReleaseTimeNotPassed(_dealId);

        dealIdMap[_dealId].buyerAddress = msg.sender;
        dealIdMap[_dealId].sellerDeposit += msg.value;
        dealIdMap[_dealId].depositReleaseTime += dealIdMap[_dealId].executeDeadlineInterval;

        emit eventDeal(dealIdMap[_dealId]);

        return dealIdMap[_dealId];
    }

    function buyerExecuteSeller(uint _dealId) public payable{
        //Check if msg.sender is the buyer of the corresponding deal.
        requireMsgSenderEqualbuyer(_dealId,msg.sender);
        //Check if msg.value is exactly twice the claimAmount.
        requireMsgValueEqualDoubleClaimAmount(_dealId,msg.value);
        //Check if dealIdMap[_dealId].sellerDeposit is not empty.
        requiresellerDepositNotEqualZero(_dealId);
        //Check to see if the current time has not exceeded the depositReleaseTime.
        requireDepositReleaseTimeNotPassed(_dealId);

        executedBalance += dealIdMap[_dealId].sellerDeposit;
        dealIdMap[_dealId].sellerDeposit = 0;
        dealIdMap[_dealId].buyerDeposit += msg.value;
        dealIdMap[_dealId].depositReleaseTime += dealIdMap[_dealId].executeDeadlineInterval;

        emit eventDeal(dealIdMap[_dealId]);

    }

    function sellerExecuteBuyer(uint _dealId) public payable{
        //Check if msg.sender is the seller of the corresponding deal.
        requireMsgSenderEqualseller(_dealId,msg.sender);
        //Check if msg.value is exactly twice the claimAmount
        requireMsgValueEqualDoubleClaimAmount(_dealId,msg.value);
        //Check if dealIdMap[_dealId].buyerDeposit is not empty.
        requirebuyerDepositNotEqualZero(_dealId);
        //Check if the current time has not exceeded the depositReleaseTime.
        requireDepositReleaseTimeNotPassed(_dealId);

        executedBalance += dealIdMap[_dealId].buyerDeposit;
        dealIdMap[_dealId].buyerDeposit = 0;
        dealIdMap[_dealId].sellerDeposit += msg.value;
        dealIdMap[_dealId].depositReleaseTime += dealIdMap[_dealId].executeDeadlineInterval;

        emit eventDeal(dealIdMap[_dealId]);
    }

    function releaseDeposits(uint _dealId) public returns(Deal memory,uint,uint){
        //Check if the current time has not exceeded the depositReleaseTime.
        requireDepositReleaseTimePassed(_dealId);

        payable(dealIdMap[_dealId].buyerAddress).transfer(dealIdMap[_dealId].buyerDeposit);
        dealIdMap[_dealId].buyerDeposit = 0;
        
        payable(dealIdMap[_dealId].sellerAddress).transfer(dealIdMap[_dealId].sellerDeposit);
        dealIdMap[_dealId].sellerDeposit = 0;

        emit eventDeal(dealIdMap[_dealId]);

        return (dealIdMap[_dealId],block.timestamp,dealIdMap[_dealId].depositReleaseTime);
    }


    function getDeal(uint _dealId) public view returns(Deal memory){
        return dealIdMap[_dealId];
    }

    function requireDepositReleaseTimeNotPassed(uint _dealId) public view {
        require(
            block.timestamp < dealIdMap[_dealId].depositReleaseTime,
            "DepositReleaseTime already passed."
        );
    }

    function requireDepositReleaseTimePassed(uint _dealId) public view {
        require(
            block.timestamp >= dealIdMap[_dealId].depositReleaseTime,
            "DepositReleaseTime has not yet passed."
        );
    }

    function requireMsgValueEqualDoubleClaimAmount(uint _dealId,uint _msgValue) public view{
        require(
            _msgValue == 2 * dealIdMap[_dealId].amountOfClaim,
            "The amount transferred is not exactly twice the amount of claim."
        );
    }

    function requireMsgValueEqualClaimAmount(uint _msgValue,uint _amountOfClaim) public pure{
        require(
            _msgValue == _amountOfClaim,
            "The amount transferred is not exactly the amount of claim."
        );
    }

    function requireMsgSenderEqualseller(uint _dealId,address _msgSender) public view{
        require(
            _msgSender == dealIdMap[_dealId].sellerAddress,
            "MsgSender does not match the specified deal seller."
        );
    }

    function requireMsgSenderEqualbuyer(uint _dealId,address _msgSender) public view{
        require(
            _msgSender == dealIdMap[_dealId].buyerAddress,
            "MsgSender does not match the specified deal buyer."
        );
    }

    function requiresellerDepositNotEqualZero(uint _dealId) public view{
        require(
            dealIdMap[_dealId].sellerDeposit != 0,
            "seller's deposit is empty."
        );
    }

    function requirebuyerDepositNotEqualZero(uint _dealId) public view{
        require(
            dealIdMap[_dealId].buyerDeposit != 0,
            "buyer's deposit is empty."
        );
    }

}
