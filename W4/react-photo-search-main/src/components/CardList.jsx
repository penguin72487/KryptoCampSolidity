const CardList = ({ list }) => {
  return (
    <div className="grid">
      {list?.map((item, i) => {
        return (
          <div key={item.id}>
            <div className="item">
              <img
                className='img-fluid'
                src={item?.urls?.small}
                alt={item?.alt_description} />
            </div>
          </div>
        )
      })}
    </div>
  )
}

export default CardList
