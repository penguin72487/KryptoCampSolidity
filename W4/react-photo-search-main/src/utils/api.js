const ACCESS_KEY = import.meta.env.VITE_API_KEY
const API = `https://api.unsplash.com`

export const searchPhotoAPI = ({ query = '', page = 1 }) => {
  return `${API}/search/photos?client_id=${ACCESS_KEY}&query=${query}&page=${page}`
}
