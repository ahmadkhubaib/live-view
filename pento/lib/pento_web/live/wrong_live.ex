defmodule PentoWeb.WrongLive do
  use PentoWeb, :live_view

  @impl true
  def mount(_params, _session, socket) do
    {:ok, assign(socket, message: "", score: 0)}
  end

  @impl true
  def handle_event("guess", %{"number" => number}, socket) do
    {:ok, assign(socket, message: "Your guess: #{number}. Wrong. Guess again. ", score: socket.assigns.score - 1)}
  end

  def time() do
    DateTime.utc_now() |> to_string()
  end
end
