import { BiMessageSquareAdd } from 'react-icons/bi';
import DatePicker from 'react-datepicker';
import 'react-datepicker/dist/react-datepicker.css';
import React, { useState } from "react";


const Form = ({ setInputText, inputText, todos, setTodos, setTab }) => {
  const [dueDate, setDueDate] = useState(null);

  const inputTextHandler = (event) => {
    setInputText(event.target.value);
  };

  const submitTodo = (event) => {
    event.preventDefault();

    setTodos([
      // { completed: false, id: 1, text: "寫作業" },
      // { completed: false, id: 2, text: "閱讀" },
      // { completed: false, id: 3, text: "進修" }
      ...todos,
      {
        text: inputText,
        completed: false,
        id: Math.random() * 999,
        dueDate: dueDate,
      },
    ]);

    setInputText('');
    setDueDate(null);
  };

  const handleSelect = (event) => {
    setTab(event.target.value);
  };

  return (
    <form>
      <input
        type="text"
        className="todo-input"
        value={inputText}
        onChange={inputTextHandler}
      />
      <DatePicker selected={dueDate} onChange={setDueDate} />
      <button type="submit" className="todo-button" onClick={submitTodo}>
        <BiMessageSquareAdd />
      </button>
      <div className="select">
      <select name="todos" onChange={handleSelect}>
        <option value="all">全部</option>
        <option value="completed">已完成</option>
        <option value="uncompleted">待完成</option>
        <option value="dueToday">今天到期</option>
        <option value="dueTomorrow">明天到期</option>
      </select>
    </div>

    </form>
  );
};
export default Form