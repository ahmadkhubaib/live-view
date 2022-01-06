defmodule PentoWeb.DemographicLive.FormComponent do
  use PentoWeb, :live_component

  alias Pento.Survey
  alias Pento.Survey.Demographic

  @impl true
  def update(assigns, socket) do
    {
      :ok,
      socket
      |> assign(assigns)
      |> assign_demographic()
      |> assign_changeset()
    }
  end

  @impl true
  def handle_event("save", %{"demographic" => demographic}, socket) do
    {:noreply, save_demographic(demographic, socket)}
  end

  @impl true
  def handle_info({:demographic_created, demographic}, socket) do
    {:noreply, handle_demographic_created(demographic, socket)}
  end

  defp handle_demographic_created(demographic, socket) do
    socket
    |> put_flash(:info, "Demographic Created")
    |> assign(:demographic, demographic)
  end

  defp save_demographic(demographic, socket) do
    case Survey.create_demographic(demographic) do
      {:ok, new_demographic} ->
        send(self(), {:demographic_created, new_demographic})
        socket
      {:error, %Ecto.Changeset{} = changeset} ->
        assign(socket, changeset: changeset)
    end
  end

  defp assign_demographic(%{assigns: %{user: user}} = socket) do
    assign(socket, :demographic, %Demographic{user_id: user.id})
  end

  defp assign_changeset(%{assigns: %{demographic: demographic}} = socket) do
    assign(socket, :changeset, Survey.change_demographic(demographic))
  end
end
