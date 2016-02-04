defmodule Netstrings do

    @moduledoc """
    netstring encoding and decoding

    An implementation of djb's [netstrings](http://cr.yp.to/proto/netstrings.txt).

    Please note that the decoder violates spec by accepting leading zeroes in the `len` part.
    However, the encoder will never generate such leading zeros.
    """
    @doc """
    encode a netstring
    """
    @spec encode(String.t) :: {:ok|:error, String.t}
    def encode(str) when is_binary(str), do: {:ok, (str |> byte_size |> Integer.to_string) <> ":" <> str <> ","}
    def encode(_), do:  {:error, "Can only encode binaries"}

    @doc """
    decode netstrings

    The decoder will stop as soon as it encounters an improper or incomplete netstring.
    Upon success, decoded strings will appear in the second element of the tuple as a list.  Any remaining (undecoded)
    part of the string will appear as the third element.

    There are no gaurantees that the remainder is the start of a proper netstring.  Appending more recieved data
    to the remainder may or may not allow it to be decoded.
    """
    @spec decode(String.t) :: {:ok, [String.t], String.t} | {:error, String.t}
    def decode(ns) when is_binary(ns), do: recur_decode(ns,[],"") # This extra string will be stripped at output
    def decode(_), do: {:error, "Can only decode binaries"}

    @spec recur_decode(String.t, list, any) :: {:ok, list(String.t), String.t}
    defp recur_decode(rest, acc, nil), do: {:ok, (acc |> Enum.reverse |> Enum.drop(1)), rest}
    defp recur_decode(ns, acc, prev) do
      {this_one, rest} = if String.contains?(ns,":") do
        [i|r] = String.split(ns, ":", parts: 2)
        {this_one, rest} = case i |> Integer.parse do
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
        if (binary_part(s,count,1) == ",") do
          f = binary_part(s, 0, count)
          {f, String.replace_prefix(s,f<>",","")}
        else
          bad_path(Integer.to_string(count), s)
        end
    end

    @spec bad_path(String.t|non_neg_integer, String.t|list) :: {nil, String.t}
    defp bad_path(n,s), do: {nil, Enum.join([n,":",s], "")}

end
