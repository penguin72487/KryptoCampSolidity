// SPDX-License-Identifier: GPL-3.0
pragma solidity >=0.8.18 <0.9.0;
import "./pointer.sol";
contract maxHeap {
    uint256[] public heap;
    Pointer public pointer;
    constructor() {
        pointer = new Pointer();
    }
    function _swap(uint256 a, uint256 b) private pure {
        uint256 temp = a;
        a = b;
        b = temp;
    }

    function push(uint256 value) public returns (uint256) {
        uint256 p = pointer.new_uint256(value);
        heap.push(p);
        uint256 i = heap.length - 1;
        while (i > 0) {
            uint256 parent = (i - 1) / 2;
            if (pointer.pointer(heap[parent]) >= pointer.pointer(heap[i])) {
                break;
            }
            _swap(heap[parent], heap[i]);
            i = parent;
        }
        return p;
    }
    function heapify(uint256 i) private {
        uint256 left = 2 * i + 1;
        uint256 right = 2 * i + 2;
        uint256 largest = i;
        if (left < heap.length && pointer.pointer(heap[left]) > pointer.pointer(heap[largest])) {
            largest = left;
        }
        if (right < heap.length && pointer.pointer(heap[right]) > pointer.pointer(heap[largest])) {
            largest = right;
        }
        if (largest != i) {
            _swap(heap[i], heap[largest]);
            heapify(largest);
        }
    }
    function pop() public returns (uint256) {
        require(heap.length > 0, "Heap is empty");
        uint256 top = heap[0];
        heap[0] = heap[heap.length - 1];
        heap.pop();
        heapify(0);
        return top;
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