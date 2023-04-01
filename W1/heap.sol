// SPDX-License-Identifier: MIT

pragma solidity ^0.8.19;

contract MinHeap {
    struct Order {
        address trader;
        uint256 amount;
        uint256 price;
        uint256 timestamp;
    }

    Order[] private heap;

    constructor() {
        heap.push(Order(address(0), type(uint256).max, type(uint256).max, type(uint256).max));
    }
    
    function push (Order memory o) public {
        heap.push(o);
        uint256 i = heap.length - 1;
        while (i > 0) {
            uint256 p = (i - 1) / 2;
            if (_conpare(i,p)) {
                _swap(p, i);
                i = p;
            } else {
                break;
            }
        }
    }

    function pop() public {
        require(heap.length > 0, "heap is empty");
        heap[0] = heap[heap.length - 1];
        delete heap[heap.length - 1];
        heap.pop();
        _heapify(0);
    }
    function top() public view returns (Order memory) {
        require(heap.length > 0, "heap is empty");
        return heap[0];
    }
    function _heapify(uint256 _i) private {
        uint256 l = 2 * _i + 1;
        uint256 r = 2 * _i + 2;
        uint256 smallest = _i;
        if (l < heap.length && _conpare(l ,smallest)) {
            smallest = l;
        }
        if (r < heap.length && _conpare(r ,smallest)) {
            smallest = r;
        }
        if (smallest != _i) {
            _swap(_i, smallest);
            _heapify(smallest);
        }
    } 
    // function _conpare(Order memory a, Order memory b) private pure returns (bool) {
    //     if(a.price == b.price) {
    //         if(a.timestamp == b.timestamp) {
    //             if(a.amount == b.amount) {
    //                 return a.trader < b.trader;
    //             }
    //             return a.amount < b.amount;
    //         }
    //         return a.timestamp < b.timestamp;
    //     }
    //     return a.price < b.price;
    // }
    function _conpare(uint256 i,uint256 j) private view returns (bool) {
        
        if(heap[i].price == heap[j].price) {
            if(heap[i].timestamp == heap[j].timestamp) {
                if(heap[i].amount == heap[j].amount) {
                    return heap[i].trader < heap[j].trader;
                }
                return heap[i].amount < heap[j].amount;
            }
            return heap[i].timestamp < heap[j].timestamp;
        }
        return heap[i].price < heap[j].price;
    }

    function _swap(uint256 a, uint256 b) private  {
        Order memory tmp = heap[a];
        heap[a] = heap[b];
        heap[b] = tmp;
    }
}

contract MaxHeap{
    struct Order {
        address trader;
        uint256 amount;
        uint256 price;
        uint256 timestamp;
    }
    Order[] private heap;
    constructor() {
        heap.push(Order(address(0), type(uint256).max, 1, type(uint256).max));
    }
    function push (Order memory o) public {
        heap.push(o);
        uint256 i = heap.length - 1;
        while (i > 0) {
            uint256 p = (i - 1) / 2;
            if (_conpare(i,p)) {
                _swap(p, i);
                i = p;
            } else {
                break;
            }
        }
    }
    function pop() public {
        require(heap.length > 0, "heap is empty");
        heap[0] = heap[heap.length - 1];
        delete heap[heap.length - 1];
        heap.pop();
        _heapify(0);
    }
    function top() public view returns (Order memory) {
        require(heap.length > 0, "heap is empty");
        return heap[0];
    }
    function _heapify(uint256 _i) private {
        uint256 l = 2 * _i + 1;
        uint256 r = 2 * _i + 2;
        uint256 largest = _i;
        if (l < heap.length && _conpare(l ,largest)) {
            largest = l;
        }
        if (r < heap.length && _conpare(r ,largest)) {
            largest = r;
        }
        if (largest != _i) {
            _swap(_i, largest);
            _heapify(largest);
        }
    }
    // function _conpare(Order memory a, Order memory b) private pure returns (bool) {
    //     if(a.price == b.price) {
    //         if(a.timestamp == b.timestamp) {
    //             if(a.amount == b.amount) {
    //                 return a.trader < b.trader;
    //             }
    //             return a.amount < b.amount;
    //         }
    //         return a.timestamp < b.timestamp;
    //     }
    //     return a.price > b.price;
    // }

    function _conpare(uint256 i,uint256 j) private view returns (bool) {
        
        if(heap[i].price == heap[j].price) {
            if(heap[i].timestamp == heap[j].timestamp) {
                if(heap[i].amount == heap[j].amount) {
                    return heap[i].trader < heap[j].trader;
                }
                return heap[i].amount < heap[j].amount;
            }
            return heap[i].timestamp < heap[j].timestamp;
        }
        return heap[i].price > heap[j].price;
    }
    function _swap(uint256 a, uint256 b) private  {
        Order memory tmp = heap[a];
        heap[a] = heap[b];
        heap[b] = tmp;
    }
    
}



