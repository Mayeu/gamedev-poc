defmodule Engine.Util.Performance do
  # TODO: pretty sure we don't need that.
  def parallel_map(collection, func) do
    collection
    |> Enum.map(&Task.async(fn -> func.(&1) end))
    |> Enum.each(&Task.await/1)
  end
end
