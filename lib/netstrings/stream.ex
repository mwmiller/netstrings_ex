# This implementation was cribbed from IO.stream.
# It may require some further readjustment or reconsideration
defmodule Netstrings.StreamError do
  defexception [:reason, :message]

  def exception(opts) do
    reason    = opts[:reason]
    formatted = IO.iodata_to_binary(:file.format_error(reason))
    %Netstrings.StreamError{message: "error during streaming: #{formatted}", reason: reason}
  end
end

defmodule Netstrings.Stream do
  @moduledoc """
  Defines an `Netstrings.Stream` struct returned by `Netstrings.stream/1`.

  The following fields are public:
    * `device`        - the IO device
    * `buffer`        - the unhandled strings to this point
  """

  defstruct device: nil, buffer: ""

  @type t :: %__MODULE__{}

  @doc false
  def __build__(device), do: %Netstrings.Stream{device: device, buffer: ""}

  defimpl Collectable do
    def into(%{device: device, buffer: _} = stream) do
      {:ok, into(stream, device)}
    end

    defp into(stream, device) do
      fn
        :ok, {:cont, x} -> Netstrings.encode(x) |> encoded_write(device)
        :ok, _          -> stream
      end
    end

    defp encoded_write(s, d), do:  IO.binwrite(d,s)

  end

  defimpl Enumerable do
    def reduce(stream, acc, fun) do
      start_fun = fn-> stream end
      next_fun = fn(%{device: device, buffer: buffer} = stream) ->
                  case IO.binread(device, 65536) do
                      :eof             -> {:halt, stream}
                      {:error, reason} -> raise Netstrings.StreamError, reason: reason
                      data             -> {strings, remainder} =  buffer <> data |> Netstrings.decode
                                          {strings, %{stream | :buffer => remainder}}
                  end
                end
      Stream.resource(start_fun, next_fun, &(&1)).(acc, fun)
    end

    def count(_stream) do
      {:error, __MODULE__}
    end

    def member?(_stream, _term) do
      {:error, __MODULE__}
    end
  end
end
