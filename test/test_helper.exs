ExUnit.start()

defmodule TestStreams do
  def write_stream do
    Temp.track()
    {:ok, pid, path} = Temp.open()
    {Netstrings.stream(pid), path}
  end

  def read_stream(path) do
    {:ok, pid} = File.open(path, [:read])
    {Netstrings.stream(pid), path}
  end
end
