import { useState, useEffect } from 'react'
// import './App.css'
import './App.scss'
import SearchPhotos from '@/components/SearchPhotos'
import CardList from '@/components/CardList'
import axios from 'axios'
import { searchPhotoAPI } from '@/utils/api'

function App() {
  const [list, setList] = useState([])
  const [query, setQuery] = useState('')
  const [isLoading, setIsLoading] = useState(false)


  // 請求 API try...catch... 包住
  const getPhotos = async () => {
    // https://api.unsplash.com/search/photos?query=dog
    // const res = await axios.get(searchPhotoAPI({ query }))
    setIsLoading(true)

    try {
      const res = await axios.get(searchPhotoAPI({ query }))
      setIsLoading(false)

      if (res.status === 200) {
        setList(res?.data?.results) // Optional chaning
      }

    } catch (error) {
      console.error(error)
      setIsLoading(false)
    }
  }

  useEffect(() => {
    // getPhotos 太頻繁請求了
    const timer = setTimeout(() => {
      getPhotos()
    }, 500)

    return () => clearTimeout(timer)
  }, [query])

  return (
    <div className="App">
      <div className="container">
        <h1 className='title w-100 text-center'>Photo Search</h1>

        <SearchPhotos
          query={query}
          setQuery={setQuery}
        />

        {/* jsx 三元判斷式 */}
        {isLoading ? (
          <div>載入中...</div>
        ) : (
          <CardList
            list={list}
          />
        )}

      </div>
    </div>
  )
}

export default App
