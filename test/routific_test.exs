defmodule RoutificTest do
  use ExUnit.Case
  doctest Routific

  defp fixture_json(file) do
    "#{__DIR__}/#{file}"
    |> File.read!()
    |> Jason.decode!()
  end

  @match_stops [
    "127 Calhoun Street, Cincinnati, OH, USA",
    "1455 Dalton Avenue, Cincinnati, OH, USA",
    "1769 Carll Street, Cincinnati, OH, USA",
    "1999 Sutter Avenue, Cincinnati, OH, USA",
    "550 Main Street, Cincinnati, OH, USA",
    "3009 Burnet Avenue, Cincinnati, OH, USA",
    "3050 Mickey Avenue, Cincinnati, OH, USA",
    "98 Glendale Milford Road, Cincinnati, OH, USA",
    "745 Kings Run Drive, Cincinnati, OH, USA",
    "4805 Montgomery Road, Cincinnati, OH, USA",
    "3935 Spring Grove Avenue, Cincinnati, OH, USA",
    "3959 Lowry Avenue, Cincinnati, OH, USA",
    "35 West 5th Street, Cincinnati, OH, USA",
    "400 Oak Street, Cincinnati, OH, USA",
    "222 Senator Place, Cincinnati, OH, USA",
    "660 Erlanger Road, Erlanger, KY, USA",
    "880 Lafayette Avenue, Cincinnati, OH, USA",
    "6507 Hasler Lane, Cincinnati, OH, USA",
    "3301 Colerain Avenue, Cincinnati, OH, USA",
    "2823 Park Avenue, Cincinnati, OH, USA",
    "7050 Links Drive, Cincinnati, OH, USA",
    "3935 Spring Grove Avenue, Cincinnati, OH, USA",
    "412 Central Avenue, Cincinnati, OH, USA",
    "1775 Lexington Avenue, Cincinnati, OH, USA",
    "7935 Reading Road, Cincinnati, OH, USA",
    "794 McPherson Avenue, Cincinnati, OH, USA",
    "7660 School Road, Cincinnati, OH, USA",
    "752 Wayne Street, Cincinnati, OH, USA",
    "7311 Scottwood Avenue, Cincinnati, OH, USA",
    "692 South Fred Shuttlesworth Circle, Cincinnati, OH, USA",
    "6700 Vine Street, Cincinnati, OH, USA",
    "651 Evans Street, Cincinnati, OH, USA",
    "625 Probasco Street, Cincinnati, OH, USA",
    "615 Elsinore Place, Cincinnati, OH, USA",
    "5531 Hamilton Avenue, Cincinnati, OH, USA",
    "3935 Spring Grove Avenue, Cincinnati, OH, USA",
    "2906 Short Vine Street, Cincinnati, OH, USA",
    "2000 Westwood Northern Boulevard, Cincinnati, OH, USA",
    "4777 Kenard Avenue, Cincinnati, OH, USA",
    "220 Findlay Street, Cincinnati, OH, USA"
  ]

  setup do
    %{vrp_input: fixture_json("vrp_input.json"), vrp_output: fixture_json("vrp_output.json")}
  end

  test "optimize route", %{vrp_input: vrp_input, vrp_output: vrp_output} do
    assert {:ok, optimized_route} = Routific.optimize_route(vrp_input)
    assert optimized_route["solution"] == vrp_output["solution"]
  end

  test "optimize route with more than 20 stops uses vrp_long" do
    fleet = %{
      "vehicle_1" => %{
        "start_location" => %{
          "id" => "depot",
          "name" => "800 Kingsway",
          "lat" => 49.2553636,
          "lng" => -123.0873365
        }
      },
      "vehicle_2" => %{
        "start_location" => %{
          "id" => "depot",
          "name" => "800 Kingsway",
          "lat" => 49.2553636,
          "lng" => -123.0873365
        }
      }
    }

    visits =
      @match_stops
      |> Enum.with_index()
      |> Enum.reduce(%{}, fn {address, index}, acc ->
        Map.put(acc, "order_#{index}", %{
          "location" => %{
            "name" => address,
            "address" => address
          }
        })
      end)

    assert {:ok, %{"job_id" => job_id}} =
             Routific.optimize_route(%{
               "fleet" => fleet,
               "visits" => visits
             })

    assert {:ok, %{"status" => _job_status}} = Routific.check_routing_status(job_id)
  end

  test "invalid api key returns error", %{vrp_input: vrp_input} do
    assert {:error, invalid_key_error} = Routific.optimize_route(vrp_input, "bad_key")
    assert String.contains?(invalid_key_error, "Invalid API key")
  end

  test "bad request" do
    assert {:error, invalid_request} = Routific.optimize_route(%{fleet: %{vehicle_1: %{}}})
    assert String.contains?(invalid_request, "Missing 'visits'")
  end
end
