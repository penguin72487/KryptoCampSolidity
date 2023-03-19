import { BiMessageSquareAdd } from 'react-icons/bi';

const Form = ({ setInputText, inputText, todos, setTodos, setTab }) => {
  // 寫js 的地方

  const inputTextHandler = (event) => {
    setInputText(event.target.value)
  }

  const submitTodo = (event) => {
    // 阻止表單送出，避免瀏覽器重整
    event.preventDefault()

    setTodos([
      // { completed: false, id: 1, text: "寫作業" },
      // { completed: false, id: 2, text: "閱讀" },
      // { completed: false, id: 3, text: "進修" }
      ...todos,
      {
        text: inputText,
        completed: false,
        id: Math.random() * 999
      }
    ])

    setInputText('')
  }

  const handleSelect = (event) => {
    setTab(event.target.value)
  }

  return (
    <form>
      <input
        type="text"
        className='todo-input'
        value={inputText}
        onChange={inputTextHandler}
      />

      <button
        type='submit'
        className='todo-button'
        onClick={submitTodo}
      >
        <BiMessageSquareAdd />
      </button>

      <div className="select">
        <select name="todos" onChange={handleSelect}>
          <option value="all">全部</option>
          <option value="completed">已完成</option>
          <option value="uncompleted">待完成</option>
        </select>
      </div>
    </form>
  )
}


export default Form