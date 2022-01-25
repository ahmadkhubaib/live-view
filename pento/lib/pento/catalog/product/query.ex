defmodule Pento.Catalog.Product.Query do
  import Ecto.Query

  alias Pento.Survey.{Rating, Demographic}
  alias Pento.Catalog.Product
  alias Pento.Accounts.User

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

  def filter_by_age_group(query \\ base(), filter) do
    query
    |> apply_age_group_filter(filter)
  end

  def join_users(query \\ base()) do
    query
    |> join(:left, [p, r], u in User, on: r.user_id == u.id)
  end

  def join_demographics(query \\ base()) do
    query
    |> join(:left, [p, r, u, d], d in Demographic, on: d.user_id == u.id)
  end

  defp apply_age_group_filter(query, "18 and under") do
    birth_year = DateTime.utc_now().year - 18

    query
    |> where([p, r, u, d], d.year_of_birth >= ^birth_year)
  end

  defp apply_age_group_filter(query, "18 to 25") do
    max_birth_year = DateTime.utc_now().year - 18
    min_birth_year = DateTime.utc_now().year - 25

    query
    |> where([p, r, u, d], d.year_of_birth >= ^min_birth_year and d.year_of_birth <= ^max_birth_year)
  end

  defp apply_age_group_filter(query, "25 to 35") do
    max_birth_year = DateTime.utc_now().year - 25
    min_birth_year = DateTime.utc_now().year - 35

    query
    |> where([p, r, u, d], d.year_of_birth >= ^min_birth_year and d.year_of_birth <= ^max_birth_year)
  end

  defp apply_age_group_filter(query, "35 and up") do
    birth_year = DateTime.utc_now().year - 35

    query
    |> where([p, r, u, d], d.year_of_birth <= ^birth_year)
  end

  defp apply_age_group_filter(query, _filter) do
    query
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
