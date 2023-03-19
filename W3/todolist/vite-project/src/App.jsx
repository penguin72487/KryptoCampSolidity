import { useState,useEffect } from 'react'
import './App.css'
import Form from './components/Form'
import TodoList from './components/TodoList'

function App() {
  const [inputText, setInputText] = useState('')
  const [lab, setLab] = useState('all')
  const [filterTodos, setFilterTodos] = useState([])

  const [todos, setTodos] = useState([
    {completed : false, id: 1, text: '吃飯'},
    {completed : false, id: 2, text: '睡覺'},
    {completed : false, id: 3, text: '打咚咚'}
  ])
  const handleFilter = () => {
    switch (lab) {
      case 'completed':
        setFilterTodos(todos.filter(todo => todo.completed === true))
        break
      case 'uncompleted':
        setFilterTodos(todos.filter(todo => todo.completed === false))
        break
      default:
        setFilterTodos(todos)
        break
    }
  }
  useEffect(() => {
    handleFilter()
  }, [todos, lab])
  
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
        />
        <TodoList
          todos={todos}
          setTodos={setTodos}

        />
      </div>

    </div>
  )
}

export default App
