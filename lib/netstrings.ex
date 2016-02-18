defmodule Netstrings do

    @moduledoc """
    netstring encoding and decoding

    An implementation of djb's [netstrings](http://cr.yp.to/proto/netstrings.txt).

    Please note that the decoder violates spec by accepting leading zeros in the `len` part.
    However, the encoder will never generate such leading zeros.
    """
    @doc """
    Encode a netstring
    """
    @spec encode(String.t) :: String.t | {:error, String.t}
    def encode(str) when is_binary(str), do: (str |> byte_size |> Integer.to_string) <> ":" <> str <> ","
    def encode(_), do:  {:error, "Can only encode binaries"}

    @doc """
    Encode a netstring, raise exception on error
    """
    @spec encode!(String.t) :: String.t | no_return
    def encode!(str) do
      case encode(str) do
        {:error, e} -> raise(e)
        s           -> s
      end
    end

    @doc """
    Decode netstrings

    The decoder will stop as soon as it encounters an improper or incomplete netstring.
    Upon success, decoded strings will appear in the second element of the tuple as a list.  Any remaining (undecoded)
    part of the string will appear as the third element.

    There are no guarantees that the remainder is the start of a proper netstring.  Appending more received data
    to the remainder may or may not allow it to be decoded.
    """
    @spec decode(String.t) :: {[String.t], String.t} | {:error, String.t}
    def decode(ns) when is_binary(ns), do: recur_decode(ns,[],"") # This extra string will be stripped at output
    def decode(_), do: {:error, "Can only decode binaries"}


    @doc """
    Decode netstrings, raise exception on error

    Note that the strings must be correct and complete, having any remainder will raise an exception.
    """
    @spec decode!(String.t) :: {[String.t], String.t} | no_return
    def decode!(str) do
      case decode(str) do
        {:error, e} -> raise(e)
        data        -> data
      end
    end

    @spec recur_decode(String.t, list, any) :: {list(String.t), String.t}
    defp recur_decode(rest, acc, nil), do: {(acc |> Enum.reverse |> Enum.drop(1)), rest}
    defp recur_decode(ns, acc, prev) do
      {this_one, rest} = if String.contains?(ns,":") do
        [i|r] = String.split(ns, ":", parts: 2)
        case i |> Integer.parse do
          {n, ""} -> pull_string(n, r)
          _       -> bad_path(i,r)
        end
      else
        {nil, ns}
      end
      recur_decode(rest, [prev|acc], this_one)
    end

    @spec pull_string(non_neg_integer, list) :: tuple
    defp pull_string(count, []), do: bad_path(count, "")
    defp pull_string(count, [s]) do
        if (byte_size(s) > count and binary_part(s,count,1) == ",") do
          f = binary_part(s, 0, count)
          {f, String.replace_prefix(s,f<>",","")}
        else
          bad_path(Integer.to_string(count), s)
        end
    end

    @spec bad_path(String.t|non_neg_integer, String.t|list) :: {nil, String.t}
    defp bad_path(n,s), do: {nil, Enum.join([n,":",s], "")}

    @spec stream(atom | pid) :: Enumerable.t
    @doc """
    Converts an io device into a `Netstrings.Stream`

    Behaves similarly to an `IO.Stream` with the values marshaled into and out of
    netstring format. The device should be opened in raw format for predictability.

    Note that netstrings approaching or above 64kib may not be properly handled.
    """
    def stream(device), do: Netstrings.Stream.__build__(device)

end
