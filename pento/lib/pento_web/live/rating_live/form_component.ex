defmodule PentoWeb.RatingLive.FormComponent do
  use PentoWeb, :live_component

  alias Pento.{Survey, Survey.Rating}

  def update(assigns, socket) do
    {
      :ok,
      socket
      |> assign(assigns)
      |> assign_rating()
      |> assign_changeset()
    }
  end

  defp assign_rating(%{assigns: %{user: user, product: product}} = socket) do
    assign(socket, :rating, %Rating{user_id: user.id, product_id: product.id})
  end

  defp assign_changeset(%{assigns: %{rating: rating}} = socket) do
    assign(socket, :changeset, Survey.change_rating(rating))
  end
end
