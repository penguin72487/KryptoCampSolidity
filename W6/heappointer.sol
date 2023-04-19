// SPDX-License-Identifier: GPL-3.0
pragma solidity >=0.8.18 <0.9.0;
import "./pointer.sol";
contract maxHeap {
    uint256[] public heap;
    Pointer public pointer;//memory of pointer
    constructor() {
        pointer = new Pointer();
    }
    function _swap(uint256 a, uint256 b) private pure {
        uint256 temp = a;
        a = b;
        b = temp;
    }
    function _conpare(Pointer a, Pointer b) private pure returns (bool) {
        if(a.value == b.value) {
            return a.index < b.index;
        }
        return a.value > b.value;
    }
    function push(uint256 value) public {
        uint256 p = pointer.new_uint256(value);
        heap.push(p);
        uint256 i = heap.length - 1;
        while (i > 0) {
            uint256 cp = (i - 1) >>1;
            if (_conpare(heap[i],heap[cp])) {
                _swap(heap[cp], heap[i]);
                i = cp;
            } else {
                break;
            }
        }
    }

    function print() public view returns (uint256[] memory, uint256[] memory) {
        uint256[] memory result = new uint256[](heap.length);
        uint256[] memory result2 = new uint256[](heap.length);
        for (uint256 i = 0; i < heap.length; i++) {
            result[i] = pointer.pointer(heap[i]);
            result2[i] = heap[i];
        }
        return (result,result2);
    }

}
contract test{
    maxHeap public heap;
    constructor() {
        heap = new maxHeap();
        heap.push(8);
        heap.push(1);
       
        heap.push(9);
        heap.push(3);

        heap.push(5);
        heap.push(6);
        heap.push(4);
        heap.push(10);
        heap.push(2);
        heap.push(7);
    }


    
}