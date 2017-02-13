defmodule ElixirInActionTodoList.TodoServer do
  alias ElixirInActionTodoList.{TodoList}
  def start do
    spawn(fn -> loop(TodoList.new) end)
  end

  def add_entry(todo_server, new_entry) do
    send(todo_server, {:add_entry, new_entry})
  end

  def update_entry(todo_server, entry_id, updater_function) do
    send(todo_server, {:update_entry, entry_id, updater_function})
  end

  def delete_entry(todo_server, entry_id) do
    send(todo_server, {:delete_entry, entry_id})
  end

  def entries(todo_server, date) do
    send(todo_server, {:entries, self, date})
    receive do
      {:todo_entries, entries} -> entries
      after 5000 -> {:error, :timeout}
    end
  end

  defp loop(todo_list) do
    new_todo_list = receive do
      {:add_entry, new_entry} ->
        TodoList.add_entry(todo_list, new_entry)
      {:update_entry, entry_id, updater_function} ->
        TodoList.update_entry(todo_list, entry_id, updater_function)
      {:delete_entry, entry_id} ->
        TodoList.delete_entry(todo_list, entry_id)
      {:entries, caller, date} ->
        send(caller, {:todo_entries, TodoList.entries(todo_list, date)})
        todo_list
    end

    loop(new_todo_list)
  end
end