export default function SearchPhotos() {
  const [query, setQuery] = useState('')
  const [page, setPage] = useState(1)
  const [photos, setPhotos] = useState([])
  const [loading, setLoading] = useState(false)
  const [error, setError] = useState(null)

  useEffect(() => {
    const fetchPhotos = async () => {
      setLoading(true)
      try {
        const data = await fetchPhotosByQuery(query, page)
        setPhotos((prevPhotos) => [...prevPhotos, ...data])
      } catch (error) {
        setError(error)
      } finally {
        setLoading(false)
      }
    }

    if (query) {
      fetchPhotos()
    }
  }, [query, page])

  const handleSearch = (e) => {
    e.preventDefault()
    setPhotos([])
    setPage(1)
    setQuery(e.target.elements.query.value)
  }

  const handleScroll = () => {
    if (
      window.innerHeight + document.documentElement.scrollTop !==
      document.documentElement.offsetHeight
    )
      return

    setPage((prevPage) => prevPage + 1)
  }

  useEffect(() => {
    window.addEventListener('scroll', handleScroll)
    return () => window.removeEventListener('scroll', handleScroll)
  }, [])

  return (
    <div className="container">
      <h1 className="title w-100 text-center">Photo Gallery</h1>
      <form onSubmit={handleSearch} className="form">
        <input
          type="text"
          name="query"
          className="input"
          placeholder="Search Unsplash..."
        />
        <button type="submit" className="button">
          <i className="fas fa-search"></i>
        </button>
      </form>
      <CardList data={photos} />
      {loading && <h2 className="loading">Loading...</h2>}
      {error && <h2 className="error">Something went wrong...</h2>}
    </div>
  )
}