defmodule NetstringsStreamTest do
  use PowerAssert
  doctest Netstrings.Stream


  test "through temp file" do
    {write_stream, path} = TestStreams.write_stream
    test_data = ["hey", "neat"]
    Enum.into(test_data, write_stream)
    File.close(write_stream)
    {read_stream, _} = TestStreams.read_stream(path)
    assert Enum.to_list(read_stream) == test_data, "Into and out of stream data is unmunged."
  end

end
