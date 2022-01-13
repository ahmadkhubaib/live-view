defmodule PentoWeb.SurveyResultsLive do
  use PentoWeb, :live_component

  alias Pento.Catalog

  def update(assigns, socket) do
    {
      :ok,
      socket
      |> assign(assigns)
      |> assign_products_with_avg_ratings()
    }
  end

  defp assign_products_with_avg_ratings(socket) do
    socket
    |> assign(:products_with_avg_ratings, Catalog.products_with_average_ratings())
  end
end
