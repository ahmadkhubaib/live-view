defmodule PentoWeb.SurveyLive do
  use PentoWeb, :live_view

  alias Pento.{Catalog, Survey, Accounts}

  @impl true
  def mount(_params, %{"user_token" => user_token} = _session, socket) do
    {
      :ok,
      socket
      |> assign_user(user_token)
      |> assign_demographic()
    }
  end


  defp assign_demographic(%{assigns: %{current_user: current_user}} = socket) do
    assign(socket, :demographic, Survey.get_demographic_by_user(current_user))
  end

  defp assign_user(socket, user_token) do
    assign_new(
      socket,
      :current_user,
      fn -> Accounts.get_user_by_session_token(user_token) end
    )
  end
end
