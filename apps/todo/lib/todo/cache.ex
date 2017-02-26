defmodule Todo.Cache do
  use GenServer

  # API

  def start, do: GenServer.start(__MODULE__, nil, name: __MODULE__)

  def server_process(todo_list_name) do
    GenServer.call(__MODULE__, {:server_process, todo_list_name})
  end

  # Callbacks

  def init(_), do: {:ok, %{}}

  def handle_call({:server_process, todo_list_name}, _, todo_servers) do
    case Map.fetch(todo_servers, todo_list_name) do
      {:ok, todo_server} ->
        {:reply, todo_server, todo_servers}
      :error ->
        {:ok, new_todo_server} = Todo.Server.start
        new_todo_servers = Map.put(todo_servers, todo_list_name, new_todo_server)
        {:reply, new_todo_server, new_todo_servers}
    end
  end
end