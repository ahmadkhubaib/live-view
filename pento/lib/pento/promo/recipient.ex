defmodule Pento.Promo.Recipient do
  defstruct [:first_name, :email]
  @types %{first_name: :string, email: :string}

  alias Pento.Promo.Recipient

  import Ecto.Changeset


  def changeset(%Recipient{} = user, attrs) do
    {user, @types}
    |> cast(attrs, Map.keys(@types))
    |> validate_required(Map.keys(@types))
    |> validate_format(:email, ~r/@/)
  end
end
