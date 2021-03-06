defmodule Brando.Type.InstagramStatus do
  @moduledoc """
  Defines a type for managing status in instagram models.
  """

  @behaviour Ecto.Type
  @ig_status_codes [deleted: 0, rejected: 1, approved: 2, download_failed: 3]

  @doc """
  Returns the internal type representation of our `Role` type for pg
  """
  def type, do: :integer

  @doc """
  Cast should return OUR type no matter what the input.
  """
  def cast(atom) when is_atom(atom), do: {:ok, atom}
  def cast(binary) when is_binary(binary) do
    [atom] = for {k, v} <- @ig_status_codes, v == String.to_integer(binary), do: k
    {:ok, atom}
  end
  def cast(status) when is_integer(status) do
    case status do
      0 -> {:ok, :deleted}
      1 -> {:ok, :rejected}
      2 -> {:ok, :approved}
      3 -> {:ok, :download_failed}
    end
  end

  @doc """
  Cast anything else is a failure
  """
  def cast(_), do: :error

  @doc """
  Integers are never considered blank
  """
  def blank?(_), do: false

  @doc """
  Load from database and convert to our type
  """
  def load(status) when is_integer(status) do
    case status do
      0 -> {:ok, :deleted}
      1 -> {:ok, :rejected}
      2 -> {:ok, :approved}
      3 -> {:ok, :download_failed}
    end
  end

  @doc """
  Dump data to database
  """
  def dump(atom) when is_atom(atom), do: {:ok, @ig_status_codes[atom]}
  def dump(binary) when is_binary(binary), do: {:ok, String.to_integer(binary)}
  def dump(integer) when is_integer(integer), do: {:ok, integer}
  def dump(_) do
    :error
  end
end
