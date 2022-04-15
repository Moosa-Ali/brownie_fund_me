//SPDX-License-Identifier: MIT

pragma solidity ^0.6.6;

/*Below inerface is an external ABI which can be used to get data of coversion rate to ETH to USD*/
//We can use this import statement or copy the code as done below in the commented out section
import "@chainlink/contracts/src/v0.6/interfaces/AggregatorV3Interface.sol";

/*
interface AggregatorV3Interface {
  function decimals() external view returns (uint8);

  function description() external view returns (string memory);

  function version() external view returns (uint256);

  // getRoundData and latestRoundData should both raise "No data present"
  // if they do not have data to report, instead of returning unset values
  // which could be misinterpreted as actual reported values.
  function getRoundData(uint80 _roundId)
    external
    view
    returns (
      uint80 roundId,
      int256 answer,
      uint256 startedAt,
      uint256 updatedAt,
      uint80 answeredInRound
    );

  function latestRoundData()
    external
    view
    returns (
      uint80 roundId,
      int256 answer,
      uint256 startedAt,
      uint256 updatedAt,
      uint80 answeredInRound
    );
}

*/

contract FundMe {
    mapping(address => uint256) public addressToAmountFunded;
    address[] public funders;
    address public owner;
    AggregatorV3Interface public priceFeed;

    constructor(address _priceFeed) public {
        //everything in here will be immideatly executed when contract is deployed
        priceFeed = AggregatorV3Interface(_priceFeed);
        owner = msg.sender; //setting ourself as the owner of the smart contract
    }

    //payable fuction can be used to pay for things
    function fund() public payable {
        //set a minimum value that can be sent
        uint256 minimumAmount = (50 * 10**8); //50$ in Gwei

        //Set this amount as required
        require(
            convertToUsd(msg.value) >= minimumAmount,
            "Minimum amount not sent!!"
        );

        addressToAmountFunded[msg.sender] += msg.value;

        funders.push(msg.sender); //keep record of who funded the contract
    }

    function getVersion() public view returns (uint256) {
        return priceFeed.version();
    }

    function getDecimals() public view returns (uint256) {
        return priceFeed.decimals();
    }

    function getPrice() public view returns (uint256) {
        //the latestroundData function returns alot of data, instead of storing them in a variable, we just leave their place blank in a tuple
        // if we don't need that data
        (, int256 answer, , , ) = priceFeed.latestRoundData();
        //The answer returned will be a very large number. This is because solidity does not support decimals.
        //Multiplying it by 10e10 to get answer in Wei.
        //Our already returned answer is in 8 decimals so we further multiply by (10e18/10e8)
        //So this returns price in wei of 1 eth
        return uint256(answer * 10**8);
    }

    //wet to Eth converison value
    //100000000

    function convertToUsd(uint256 ethAmount) public view returns (uint256) {
        uint256 ethPrice = getPrice();
        uint256 ethAmountInUsd = (ethPrice * ethAmount) / 100000000000000000;
        return ethAmountInUsd;
    }

    modifier onlyOwner() {
        require(
            msg.sender == owner,
            "Only owners of the contract can withdraw money"
        );
        _;
    }

    function getEntranceFee() public view returns (uint256) {
        //minimumUSD
        uint256 minimumUSD = 50 * 10**18;
        uint256 price = getPrice();
        uint256 precision = 1 * 10**18;
        return (minimumUSD * precision) / price;
    }

    function withdraw() public payable onlyOwner {
        require(msg.sender == owner); //The address who calls this function must be of the owner
        payable(msg.sender).transfer(address(this).balance);
        /*Keywords in above line
        msg: This refers to who ever called this fucntion externally
        this: refers to the this contract that we are in
        address: returns the address of whatever entity is within the paranthesis*/

        for (
            uint256 funderIndex = 0;
            funderIndex < funders.length;
            funderIndex++
        ) {
            address funder = funders[funderIndex]; //get a funder address
            addressToAmountFunded[funder] = 0; //set that funders given amount to zero
        }

        funders = new address[](0);
    }
}
