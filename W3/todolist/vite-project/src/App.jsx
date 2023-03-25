import { useState, useEffect } from 'react'
import './App.css'
import Form from './components/Form'
import TodoList from './components/TodoList'

function App() {
  const [inputText, setInputText] = useState('')
  const [tab, setTab] = useState('all')
  const [filterTodos, setFilterTodos] = useState([])

  const tomorrow = new Date();
  tomorrow.setDate(tomorrow.getDate() + 1);
  const today= new Date();
  today.setDate(today.getDate());
  const yesterday = new Date();
  yesterday.setDate(yesterday.getDate() - 1);
  
  const [todos, setTodos] = useState([
    { text: '寫作業', completed: false, id: 1, dueDate: yesterday },
    { text: '閱讀', completed: false, id: 2, dueDate: today },
    { text: '進修', completed: false, id: 3, dueDate: tomorrow },
  ]);
  
  

  const handleFilter = () => {
    switch (tab) {
      case 'completed':
        setFilterTodos(todos.filter((todo) => todo.completed));
        break;
      case 'uncompleted':
        setFilterTodos(
          todos.filter((todo) => {
            if (todo.completed) return false;
            if (!todo.dueDate) return true;
            const now = new Date();
            const today = new Date(now.getFullYear(), now.getMonth(), now.getDate());
            const dueDate = new Date(todo.dueDate);
            return dueDate >= today;
          })
        );
        break;
      case 'dueToday':
        setFilterTodos(
          todos.filter(
            (todo) =>
              todo.dueDate &&
              todo.dueDate.getDate() === new Date().getDate() &&
              todo.dueDate.getMonth() === new Date().getMonth() &&
              todo.dueDate.getFullYear() === new Date().getFullYear()
          )
        );
        break;
      case 'dueTomorrow':
        const tomorrow = new Date();
        tomorrow.setDate(tomorrow.getDate() + 1);
        setFilterTodos(
          todos.filter(
            (todo) =>
              todo.dueDate &&
              todo.dueDate.getDate() === tomorrow.getDate() &&
              todo.dueDate.getMonth() === tomorrow.getMonth() &&
              todo.dueDate.getFullYear() === tomorrow.getFullYear()
          )
        );
        break;
      default:
        setFilterTodos(todos);
        break;
    }
  };
  

  useEffect(() => {
    handleFilter()
  }, [tab, todos])

  return (
    <div className="App">
      <div className="container">
        <header>
          ToDoList
        </header>
  
        <Form
          inputText={inputText}
          setInputText={setInputText}
          todos={todos}
          setTodos={setTodos}
          setTab={setTab}
        />
  
        <TodoList
          todos={filterTodos}
          setTodos={setTodos}
        />
      </div>
    </div>
  )}

export default App