defmodule RoutificTest do
  use ExUnit.Case
  doctest Routific

  defp fixture_json(file) do
    "#{__DIR__}/#{file}"
    |> File.read!()
    |> Jason.decode!()
  end

  test "optimize route" do
    vrp_input = fixture_json("vrp_input.json")
    vrp_output = fixture_json("vrp_output.json")

    assert {:ok, optimized_route} = Routific.optimize_route(vrp_input)
    assert optimized_route["solution"] == vrp_output["solution"]
  end
end
