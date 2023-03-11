// SPDX-License-Identifier: GPL-3.0
pragma solidity >=0.8.4 <0.9.0;

contract TodoList {
    string[] private todos;
    string[] private todoCompleted;
    constructor() {}
    function addTodo(string memory todo) external{
        todos.push(todo);
    }
    function moveTodoTOCompleted(uint256 index) external {
        string storage compeltedTodo = todos[index];
        todoCompleted.push(compeltedTodo);
        todos[index] = todos[todos.length - 1];
        delete todos[todos.length - 1];
        todos.pop();
    }
        function getTodo(uint256 index) external view returns (string memory) {
        return todos[index];
    }

    function deleteTodo(uint256 index) external {
        delete todos[index];
    }

    function getCompleted(uint256 index) external view returns (string memory) {
        return todoCompleted[index];
    }

    function getAllTodo() external view returns (string[] memory) {
        return todos;
    }

    function getAllCompleted() external view returns (string[] memory) {
        return todoCompleted;
    }
    function clearCompleted() external {
        for (uint256 i = 0; i < todoCompleted.length; i++) {
            delete todoCompleted[i];
        }
        for (;todoCompleted.length>0;) {
            todoCompleted.pop();
        }
       
    }

} 