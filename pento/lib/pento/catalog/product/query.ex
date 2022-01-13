defmodule Pento.Catalog.Product.Query do
  import Ecto.Query

  alias Pento.Survey.Rating
  alias Pento.Catalog.Product

  def base, do: Product

  def with_user_ratings(query \\ base(), user) do
    ratings_query = Rating.Query.preload_user(user)

    query
    |> preload(ratings: ^ratings_query)
  end

  def with_average_rating(query \\ base()) do
    query
    |> join_ratings()
    |> average_rating()
  end

  defp join_ratings(query) do
    query
    |> join(:inner, [p], r in Rating, on: r.product_id == p.id)
  end

  defp average_rating(query) do
    query
    |> group_by([p], p.id)
    |> select([p, r], {p.name, fragment("?::float", avg(r.stars))})
  end
end
