defmodule NetstringsTest do
  use PowerAssert
  import Netstrings
  doctest Netstrings


  test "djb examples" do
    assert encode("") == {:ok, "0:,"}, "Encode empty string."
    assert decode("0:,") == {:ok, [""],""}, "Decode empty string."
    assert encode("hello world!") == {:ok, "12:hello world!,"},  "Encode hello world!"
    assert decode("12:hello world!,") == {:ok, ["hello world!"], ""} , "Decode hello world!"
    assert decode("012:hello world!,") == {:ok, ["hello world!"], ""} , "Spec violation: lax acceptance of leading 0 in decode"
  end

  test "encode" do
    assert encode(0) == {:error, "Can only encode binaries"}, "Can only encode binaries"
    assert encode("√2") == {:ok, "4:√2,"}, "UTF-8 string including number"
  end

  test "decode" do
    assert decode(0) == {:error, "Can only decode binaries"}, "Can only decode binaries"
    assert decode("0:,0:,") == {:ok, ["", ""], ""}, "Pair of empty strings."
    assert decode("4:√3,") == {:ok, ["√3"], ""}, "UTF-8 string including number"
    assert decode("4:say,,") == {:ok, ["say,"], ""}, "Including a comma"
    assert decode("4:say:,") == {:ok, ["say:"], ""}, "Including a colon"
    assert decode("3:say:,") == {:ok, [], "3:say:,"}, "Improper netstring left undecoded"
    assert decode("2:hi,5:there,3:") == {:ok, ["hi", "there"], "3:"}, "Incomplete netstring is left as remainder"
    assert decode("2:hi,4:there,3") == {:ok, ["hi"], "4:there,3"}, "Stop as soon as improper is hit"
    assert decode("2:hi,:") == {:ok, ["hi"], ":"}, "Remaining colon is untouched"
  end

  test "round trips" do
    ok_encode = fn({:ok, r}) -> r end
    ok_decode = fn({:ok, [r|_],""}) -> r end

    assert encode("Scheiße") |> ok_encode.() |> decode |> ok_decode.() == "Scheiße", "Garbage in/garbage out"
    assert decode("12:2+2=shopping,") |> ok_decode.() |> encode |> ok_encode.() == "12:2+2=shopping,", "Math is hard"

  end

end
