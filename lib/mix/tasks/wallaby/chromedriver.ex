defmodule Mix.Tasks.Wallaby.Chromedriver do
  @moduledoc "Compares chrome version with chromedriver version and errors when major, minor and build numbers do not match."
  @shortdoc "Errors when chrome and chromedriver version do not align."

  use Mix.Task

  @impl Mix.Task
  def run(_) do
    chrome_driver =
      case System.find_executable("chromedriver") do
        nil ->
          IO.puts("chromedriver is not in PATH")
          exit({:shutdown, 1})

        path ->
          path
      end

    {chrome_driver_version_string, 0} = System.cmd(chrome_driver, ["--version"])

    chrome_driver_version =
      chrome_driver_version_string
      |> String.split(" ")
      |> Enum.at(1)
      |> String.split(".")
      |> Enum.slice(0..2)
      |> Enum.join(".")

    # TODO: figure out how to find google chrome programmaticaly
    {google_chrome_version_string, 0} =
      case :os.type() do
        {:unix, :darwin} ->
          System.cmd("/Applications/Google\ Chrome.app/Contents/MacOS/Google\ Chrome", [
            "--version"
          ])

        {:unix, :linux} ->
          # this assumes a ubuntu-ish install location for chrome
          System.cmd("/usr/bin/google-chrome", ["--version"])
      end

    google_chrome_version =
      google_chrome_version_string
      |> String.split(" ")
      |> Enum.at(2)
      |> String.split(".")
      |> Enum.slice(0..2)
      |> Enum.join(".")

    case Version.compare(google_chrome_version, chrome_driver_version) do
      :gt ->
        IO.puts("you need to download chromedriver #{google_chrome_version}")
        exit({:shutdown, 1})

      _ ->
        IO.puts("yay chrome and chromedriver match nothing to do here.")
    end
  end
end
