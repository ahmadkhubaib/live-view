defmodule PentoWeb.SurveyResultsLiveTest do
  use Pento.DataCase

  alias PentoWeb.SurveyResultsLive
  alias Pento.{Survey, Accounts, Catalog}

  @create_product_attrs %{
    description: "test description",
    name: "Test Game",
    sku: 42,
    unit_price: 120.5
  }

  @create_user_attrs %{
    email: "test@test.com",
    password: "testtesttest"
  }

  @create_user2_attrs %{
    email: "t@t.com",
    password: "testtesttest"
  }

  @create_demographic_attrs %{
    gender: "male",
    year_of_birth: DateTime.utc_now.year - 15
  }

  @create_demographic_over18 %{
    gender: "female",
    year_of_birth: DateTime.utc_now.year - 30
  }

  def product_fixture do
    {:ok, product} = Catalog.create_product(@create_product_attrs)
    product
  end

  def user_fixture(attrs \\ @create_user_attrs) do
    {:ok, user} = Accounts.register_user(attrs)
    user
  end

  def demographic_fixture(user, attrs \\ @create_demographic_attrs) do
    attrs =
      attrs
      |> Map.merge(%{user_id: user.id})
    {:ok, demographic} = Survey.create_demographic(attrs)
    demographic
  end

  def rating_fixture(stars, user, product) do
    {:ok, rating} = Survey.create_rating(
      %{
        stars: stars,
        user_id: user.id,
        product_id: product.id
      }
    )
    rating
  end

  def create_product(_), do: %{product: product_fixture()}

  def create_user(_), do: %{user: user_fixture()}

  def create_socket(_), do: %{socket: %Phoenix.LiveView.Socket{}}

  def create_demographic(user), do: %{demographic: demographic_fixture(user)}

  def create_rating(stars, user, product), do: %{rating: rating_fixture(stars, user, product)}

  def assert_keys(socket, key, value) do
    assert socket.assigns[key] == value
    socket
  end

  describe "socket state" do
    setup [:create_user, :create_product, :create_socket]

    setup %{user: user} do
      create_demographic(user)
      user2 = user_fixture(@create_user2_attrs)
      demographic_fixture(user2, @create_demographic_over18)
      [user2: user2]
    end

    test "no rating exists", %{socket: socket} do
      socket =
        socket
        |> SurveyResultsLive.assign_age_group_filter()
        |> SurveyResultsLive.assign_products_with_avg_ratings()

      assert socket.assigns.products_with_avg_ratings == [{"Test Game", 0}]
    end

    test "rating exist", %{socket: socket, user: user, product: product} do
      create_rating(2, user, product)
      socket =
        socket
        |> SurveyResultsLive.assign_age_group_filter()
        |> SurveyResultsLive.assign_products_with_avg_ratings()

      assert socket.assigns.products_with_avg_ratings == [{"Test Game", 2}]
    end

    test "ratings by age group", %{socket: socket, user: user, product: product, user2: user2} do
      create_rating(2, user, product)
      create_rating(3, user2, product)

      socket
      |> SurveyResultsLive.assign_age_group_filter()
      |> assert_keys(:age_group_filter, "all")
      |> SurveyResultsLive.assign_age_group_filter("18 and under")
      |> assert_keys(:age_group_filter, "18 and under")
      |> SurveyResultsLive.assign_products_with_avg_ratings()
      |> assert_keys(:products_with_avg_ratings, [{"Test Game", 2.0}])
    end
  end
end
