//import { useState } from 'react';
import { MdCheck, MdDeleteOutline } from 'react-icons/md';
import React, { useState, useEffect } from 'react';

const Todo = ({ todos, setTodos, text, todo }) => {
  const [isOverdue, setIsOverdue] = useState(false);

  const completeTodo = () => {
    setTodos(
      todos.map((item) => {
        if (item.id === todo.id) {
          return {
            ...item,
            completed: !todo.completed,
          };
        }
        return item;
      })
    );
  };
  
  

  const deleteTodo = () => {
    setTodos(todos.filter((el) => el.id !== todo.id));
  };

  const checkOverdue = () => {
    const now = new Date();
    const today = new Date(now.getFullYear(), now.getMonth(), now.getDate());
    const dueDate = new Date(todo.dueDate);
    setIsOverdue(dueDate < today);
  };

  useEffect(() => {
    checkOverdue();
  }, [todo]);
  
// Todo.js
  return (
    <div className="todo">
      <li
        className={`todo-item ${
          todo.completed ? 'completed' : ''} ${
          isOverdue && todo.dueDate ? 'overdue' : ''}`}
        style={{ opacity: todo.completed ? 0.5 : 1 }}
      >
        {text}
        {todo.dueDate && (
          <span className="due-date">: {new Date(todo.dueDate).toDateString()}</span>
        )}
      </li>
        <button className="complete-btn" onClick={completeTodo}>
          <MdCheck />
        </button>
        <button className="trash-btn" onClick={deleteTodo}>
          <MdDeleteOutline />
        </button>
    </div>
  );
};
  

const TodoList = ({ todos, setTodos }) => {
  // 對 todos 數組按照時間排序
  const sortedTodos = todos.sort((a, b) => {
    if (!a.dueDate) return 1;
    if (!b.dueDate) return -1;
    return new Date(a.dueDate) - new Date(b.dueDate);
  });
  

  return (
    <div className="todo-container">
      <div className="todo-list">
        {sortedTodos.map((todo) => (
          <Todo
            key={todo.id}
            todos={todos}
            setTodos={setTodos}
            text={todo.text}
            todo={todo}
          />
        ))}
      </div>
    </div>
  );
};

export default TodoList;

