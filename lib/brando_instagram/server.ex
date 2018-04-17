defmodule Brando.Instagram.Server do
  @moduledoc """
  GenServer for polling Instagram's API.

  See Brando.Instagram for instructions
  """
  use GenServer
  require Logger

  alias Brando.Instagram
  alias Brando.Instagram.API
  alias Brando.Instagram.Server.State

  # Public
  @doc false
  def start_link do
    GenServer.start_link(__MODULE__, :ok, name: __MODULE__)
  end

  @doc false
  def init(_) do
    send(self(), :poll)
    {:ok, timer} = :timer.send_interval(Instagram.config(:interval), :poll)

    state =
      %State{}
      |> Map.put(:timer, timer)
      |> Map.put(:query, Instagram.config(:query))

    Logger.info("==> Brando.Instagram.Server initialized")

    {:ok, state}
  end

  @doc false
  def stop() do
    GenServer.call(__MODULE__, :stop)
  end

  @doc false
  def state() do
    GenServer.call(__MODULE__, :state)
  end

  # Private
  @doc false
  def handle_info(:poll, %State{} = state) do
    try do
      :ok = API.query(state)
      {:noreply, state}
    catch
      :exit, err ->
        Logger.error(inspect(err))
        {:noreply, state}
    end
  end

  @doc false
  def handle_info({:EXIT, _, :normal}, state) do
    {:noreply, state}
  end

  @doc false
  def handle_call(:stop, _from, state) do
    {:stop, :normal, :ok, state}
  end

  @doc false
  def handle_call(:state, _from, state) do
    {:reply, state, state}
  end

  @doc false
  def terminate(:shutdown, {timer, _}) do
    :timer.cancel(timer)
    :ok
  end

  @doc false
  def terminate({%HTTPoison.Error{reason: :connect_timeout}, [_|_]}, {_, _}) do
    Logger.error("InstagramServer: connection timed out.")
  end

  @doc false
  def terminate({%HTTPoison.Error{reason: :econnrefused}, [_|_]}, {_, _}) do
    Logger.error("InstagramServer: connection refused.")
  end

  @doc false
  def terminate({%HTTPoison.Error{reason: :nxdomain}, [_|_]}, {_, _}) do
    Logger.error("InstagramServer: dns error, not found")
  end

  @doc false
  def terminate({%Postgrex.Error{message: "tcp connect: econnrefused",
                                 postgres: nil}, _}, _) do
    Logger.error("InstagramServer: postgrex connection refused")
  end

  @doc false
  def terminate(_reason, _state) do
    :ok
  end
end
