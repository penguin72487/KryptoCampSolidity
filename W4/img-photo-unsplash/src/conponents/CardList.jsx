export default function CardList({ data }) {
  return (
    <div className="card-list">
      {data.map((item) => (
        <Card key={item.id} item={item} />
      ))}
    </div>
  )
}