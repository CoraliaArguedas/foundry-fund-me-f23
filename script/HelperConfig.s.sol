//1. Deploy Mocks when we are on a local anvil chain
// 2.keep track of contract address across different chains

//SDPX-License-Identifier: MIT
pragma solidity ^0.8.18;

import {Script} from "forge-std/Script.sol";
import {MockV3Aggregator} from "../test/mocks/MockV3Aggregator.sol";

contract HelperConfig is Script {

    NetworkConfig public activeNetWorkConfig;
    struct NetworkConfig {
        address priceFeed;
    }

    uint8 public constant DECIMALS=8;
    int256 public constant INITIAL_PRICE = 2000e8;


    constructor(){
        if(block.chainid == 11155111){
            activeNetWorkConfig = getSepoliaEthConfig();
        }else if(block.chainid == 1){
             activeNetWorkConfig = getMainnetEthConfig();
        }else {
            activeNetWorkConfig = getOrCreateAnvilEthConfig();
        }
    }

    function getSepoliaEthConfig() public pure  returns(NetworkConfig memory){
        //price feed address
        NetworkConfig memory sepoliaConfig = NetworkConfig({priceFeed:0x694AA1769357215DE4FAC081bf1f309aDC325306});
        return sepoliaConfig;
    }

        function getMainnetEthConfig() public pure  returns(NetworkConfig memory){
        //price feed address
        NetworkConfig memory mainnetConfig = NetworkConfig({priceFeed:0x5147eA642CAEF7BD9c1265AadcA78f997AbB9649});
        return mainnetConfig;
    }

    function getOrCreateAnvilEthConfig() public returns (NetworkConfig memory) {
        //1. Deploy the mocks
        //2.return the mock address
        if(activeNetWorkConfig.priceFeed !=address(0)){
            return activeNetWorkConfig;
        }
        vm.startBroadcast();
        MockV3Aggregator mockPriceFeed = new MockV3Aggregator(DECIMALS, INITIAL_PRICE);
        vm.stopBroadcast();

        NetworkConfig memory anvilConfig = NetworkConfig({priceFeed: address(mockPriceFeed)});
        return anvilConfig;
    }
}