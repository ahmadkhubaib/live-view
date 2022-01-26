defmodule PentoWeb.SurveyResultsLive do
  use PentoWeb, :live_component

  alias Pento.Catalog

  def update(assigns, socket) do
    {
      :ok,
      socket
      |> assign(assigns)
      |> assign_age_group_filter()
      |> assign_products_with_avg_ratings()
      |> assign_dataset()
      |> assign_chart()
      |> assign_svg_chart()
    }
  end

  def handle_event("age_group_filter", %{"age_group_filter" => age_group_filter}, socket) do
    {
      :noreply,
      socket
      |> assign_age_group_filter(age_group_filter)
      |> assign_products_with_avg_ratings()
      |> assign_dataset()
      |> assign_chart()
      |> assign_svg_chart()
    }
  end

  defp assign_age_group_filter(socket) do
    socket
    |> assign(:age_group_filter, "all")
  end

  defp assign_age_group_filter(socket, age_group_filter) do
    socket
    |> assign(:age_group_filter, age_group_filter)
  end

  defp assign_svg_chart(%{assigns: %{chart: chart}} = socket) do
    socket
    |> assign(:svg_chart, make_svg_chart(chart))
  end

  defp make_svg_chart(chart) do
    Contex.Plot.new(500, 500, chart)
    |> Contex.Plot.titles(title(), subtitle())
    |> Contex.Plot.axis_labels(x_axis(), y_axis())
    |> Contex.Plot.to_svg()
  end

  defp title do
    "Product Ratings"
  end

  defp subtitle do
    "average star ratings per product"
  end

  defp x_axis() do
    "products"
  end

  defp y_axis() do
    "stars"
  end

  defp assign_chart(%{assigns: %{dataset: dataset}} = socket) do
    socket
    |> assign(:chart, make_bar_chart(dataset))
  end

  defp make_bar_chart(dataset) do
    Contex.BarChart.new(dataset)
  end

  defp assign_dataset(%{assigns: %{products_with_avg_ratings: products_with_avg_ratings}} = socket) do
    socket
    |> assign(:dataset, make_bar_chart_dataset(products_with_avg_ratings))
  end

  defp make_bar_chart_dataset([]) do
    Contex.Dataset.new([{"No product found", 0.0}])
  end

  defp make_bar_chart_dataset(dataset) do
    Contex.Dataset.new(dataset)
  end

  defp assign_products_with_avg_ratings(%{assigns: %{age_group_filter: age_group_filter}} = socket) do
    socket
    |> assign(:products_with_avg_ratings, Catalog.products_with_average_ratings(%{age_group_filter: age_group_filter}))
  end
end
