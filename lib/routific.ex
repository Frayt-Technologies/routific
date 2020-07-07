defmodule Routific do
  @moduledoc """
  Documentation for `Routific`.
  """

  @doc """
  Optimize routes by calling routific
  """
  def optimize_route(route) do
    body = route |> Jason.encode!()

    auth_header =
      {"Authorization",
       "bearer eyJ0eXAiOiJKV1QiLCJhbGciOiJIUzI1NiJ9.eyJfaWQiOiI1MzEzZDZiYTNiMDBkMzA4MDA2ZTliOGEiLCJpYXQiOjEzOTM4MDkwODJ9.PR5qTHsqPogeIIe0NyH2oheaGR-SJXDsxPTcUQNq90E"}

    content_type = {"Content-Type", "application/json"}
    {:ok, response} = HTTPoison.post(vrp_url(), body, [auth_header, content_type])
    response |> process_response()
  end

  defp process_response(%HTTPoison.Response{status_code: 200, body: body}),
    do: body |> Jason.decode()

  defp vrp_url(), do: "https://api.routific.com/v1/vrp"
end
