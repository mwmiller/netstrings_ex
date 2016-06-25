defmodule NetstringsTest do
  use ExUnit.Case
  import Netstrings
  doctest Netstrings


  test "djb examples" do
    assert encode("") == "0:,", "Encode empty string."
    assert decode("0:,") == {[""],""}, "Decode empty string."
    assert encode("hello world!") == "12:hello world!,",  "Encode hello world!"
    assert decode("12:hello world!,") == {["hello world!"], ""} , "Decode hello world!"
    assert decode("012:hello world!,") == {["hello world!"], ""} , "Spec violation: lax acceptance of leading 0 in decode"
  end

  test "encode" do
    assert encode(0) == {:error, "Can only encode binaries"}, "Can only encode binaries"
    assert encode("√2") == "4:√2,", "UTF-8 string including number"
  end

  test "encode!" do
    assert_raise RuntimeError,  "Can only encode binaries", fn -> encode!(0) end
    assert encode!("√2") == "4:√2,", "UTF-8 string including number"
  end

  test "decode" do
    assert decode(0) == {:error, "Can only decode binaries"}, "Can only decode binaries"
    assert decode("0:,0:,") == {["", ""], ""}, "Pair of empty strings."
    assert decode("4:√3,") == {["√3"], ""}, "UTF-8 string including number"
    assert decode("4:say,,") == {["say,"], ""}, "Including a comma"
    assert decode("4:say:,") == {["say:"], ""}, "Including a colon"
    assert decode("3:say:,") == {[], "3:say:,"}, "Improper netstring left undecoded"
    assert decode("2:hi,5:there,3:") == {["hi", "there"], "3:"}, "Incomplete netstring is left as remainder"
    assert decode("2:hi,4:there,3") == {["hi"], "4:there,3"}, "Stop as soon as improper is hit"
    assert decode("2:hi,:") == {["hi"], ":"}, "Remaining colon is untouched"
  end

  test "decode!" do
    assert_raise RuntimeError,  "Can only decode binaries", fn -> decode!(0) end
    assert decode!("0:,0:,") == {["", ""], ""}, "Pair of empty strings."
    assert decode!("2:hi,5:there,3:") == {["hi", "there"], "3:"}, "Incomplete netstring is left as remainder"
  end

  test "exceptional round trip" do
    assert encode!("Scheiße") |> decode! == {["Scheiße"], ""}, "Garbage in/garbage out"
  end

end
