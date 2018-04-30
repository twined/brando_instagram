defmodule Brando.Instagram.Server.State do
  @moduledoc """
  Struct for Instagram server state.
  """
  defstruct timer: nil,
            filter: nil,
            query: nil
end
