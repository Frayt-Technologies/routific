defmodule Routific do
  @moduledoc """
  Documentation for `Routific`.
  """

  @doc """
  Optimize routes by calling routific
  """
  def optimize_route(route, api_key \\ default_api_key()) do
    body = route |> Jason.encode!()

    auth_header = {"Authorization", "bearer #{api_key}"}

    content_type = {"Content-Type", "application/json"}
    {:ok, response} = HTTPoison.post(vrp_url(), body, [auth_header, content_type])
    response |> process_response()
  end

  defp process_response(%HTTPoison.Response{status_code: 200, body: body}),
    do: body |> Jason.decode()

  defp process_response(%HTTPoison.Response{status_code: 401}),
    do: {:error, "Invalid API key"}

  defp vrp_url(), do: "https://api.routific.com/v1/vrp"

  defp default_api_key(),
    do: Application.get_env(:routific, :api_key) || System.get_env("ROUTIFIC_API_KEY")
end
