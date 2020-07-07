defmodule RoutificTest do
  use ExUnit.Case
  doctest Routific

  defp fixture_json(file) do
    "#{__DIR__}/#{file}"
    |> File.read!()
    |> Jason.decode!()
  end

  setup do
    %{vrp_input: fixture_json("vrp_input.json"), vrp_output: fixture_json("vrp_output.json")}
  end

  test "optimize route", %{vrp_input: vrp_input, vrp_output: vrp_output} do
    assert {:ok, optimized_route} = Routific.optimize_route(vrp_input)
    assert optimized_route["solution"] == vrp_output["solution"]
  end

  test "invalid api key returns error", %{vrp_input: vrp_input} do
    assert {:error, invalid_key_error} = Routific.optimize_route(vrp_input, "bad_key")
  end
end
