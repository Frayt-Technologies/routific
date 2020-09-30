defmodule Routific do
  @moduledoc """
  Documentation for `Routific`.
  """

  @doc """
  Optimize routes by calling routific
  """
  def optimize_route(route, api_key \\ default_api_key())

  def optimize_route(%{"visits" => visits} = route, api_key) do
    if Enum.count(visits) > 20 do
      optimize_route(route, vrp_url_long(), api_key)
    else
      optimize_route(route, vrp_url(), api_key)
    end
  end

  def optimize_route(route, api_key) do
    optimize_route(route, vrp_url(), api_key)
  end

  def optimize_route(route, url, api_key) do
    body = route |> Jason.encode!()

    auth_header = {"Authorization", "bearer #{api_key}"}

    content_type = {"Content-Type", "application/json"}
    {:ok, response} = HTTPoison.post(url, body, [auth_header, content_type])
    response |> process_response()
  end

  def check_routing_status(job_id) do
    content_type = {"Content-Type", "application/json"}
    {:ok, response} = HTTPoison.get(job_url(job_id), [content_type])
    response |> process_response()
  end

  defp process_response(%HTTPoison.Response{status_code: 200, body: body}),
    do: body |> Jason.decode()

  defp process_response(%HTTPoison.Response{status_code: 202, body: body}),
    do: body |> Jason.decode()

  defp process_response(%HTTPoison.Response{status_code: 401}),
    do: {:error, "Invalid API key"}

  defp process_response(%HTTPoison.Response{status_code: 400, body: body}) do
    {:error, body |> Jason.decode!() |> Map.get("error")}
  end

  defp process_response(%HTTPoison.Response{status_code: 404, body: body}) do
    {:error, body |> Jason.decode!() |> Map.get("error")}
  end

  defp process_response(%HTTPoison.Response{status_code: 408}),
    do: {:error, "Request timeout. Your request was too large."}

  defp process_response(%HTTPoison.Response{status_code: 412}),
    do:
      {:error,
       "No solution could be found. Please check your input. This is usually due to incorrect time-windows."}

  defp process_response(%HTTPoison.Response{status_code: 429}),
    do: {:error, "Exceeded API usage for Routific."}

  defp process_response(%HTTPoison.Response{status_code: 500}),
    do: {:error, "Something is wrong on Routific's end. Contact them at support@routific.com"}

  defp vrp_url(), do: "https://api.routific.com/v1/vrp"

  defp vrp_url_long(), do: "https://api.routific.com/v1/vrp-long"

  defp job_url(job_id), do: "https://api.routific.com/jobs/#{job_id}"

  defp default_api_key(),
    do:
      Application.get_env(:routific, :api_key) ||
        System.get_env("ROUTIFIC_API_KEY")
end
