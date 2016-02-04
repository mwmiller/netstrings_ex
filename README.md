# Netstrings

Elixir encoder and decoder for djb's [netstrings](http://cr.yp.to/proto/netstrings.txt)

## Installation

```
# add dependencies in mix.exs
defp deps do
  [
    {:netstrings, "~> 0.2"}
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
```
