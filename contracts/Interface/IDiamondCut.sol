pragma solidity ^0.7.6;
interface IDiamondCut {
    enum FacetCutAction {Add, Replace, Remove}
    // Add=0, Replace=1, Remove=2

    struct FacetCut {
        address facetAddress;
        FacetCutAction action;
        bytes4[] functionSelectors;
    }


    function diamondCut(
        address facetAddress,
        FacetCutAction _action,
        bytes4[] memory functionSelectors
    ) external;

    event DiamondCut(address facetAddress,FacetCutAction action , bytes4[]  functionSelectors);
}