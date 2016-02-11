# Overview

Elixir encoder and decoder for djb's [netstrings](http://cr.yp.to/proto/netstrings.txt)

## Installation

```
# add dependencies in mix.exs
defp deps do
  [
    {:netstrings, "~> 1.1"}
  ]
end

# and fetch
$ mix deps.get
```

## Examples

```
iex> Netstrings.encode(0)
{:error, "Can only encode binaries"}
iex> Netstrings.encode("hello world!")
{:ok, "12:hello world!,"}

iex> Netstrings.decode(0)
{:error, "Can only decode binaries"}
iex> Netstrings.decode("12:hello world!,")
{:ok, ["hello world!"], ""}

iex> {:ok, file} = File.open("net.strings")
{:ok, #PID<0.121.0>}
iex> Netstrings.stream(file)
%Netstrings.Stream{buffer: "", device: #PID<0.121.0>}
```
