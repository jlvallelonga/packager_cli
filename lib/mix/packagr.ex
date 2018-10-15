defmodule Mix.Tasks.Packagr do
  use Mix.Task

  def run(argv) do
    {[subcommand], %Optimus.ParseResult{args: args}} = PackagrCli.main(argv)

    case subcommand do
      :search -> search(args)
      :publish -> publish(args)
      :install -> install(args)
    end
  end

  def search(%{query: query}) do
    HTTPoison.start()
    %HTTPoison.Response{body: body} = HTTPoison.get!("#{get_base_url()}packages?query=#{query}", get_auth_headers())
    resp = Poison.decode!(body)
    resp |> Map.get("packages")
    |> Enum.each(fn package ->
      IO.puts("#{Map.get(package, "name")} - #{Map.get(package, "version")}")
    end)
  end

  def publish(%{filepath: filepath}) do
    HTTPoison.start()

    form = {:multipart, [{:file, filepath, {"form-data", [{:name, "package"}, {:filename, Path.basename(filepath)}]}, []}]}
    resp = HTTPoison.post("#{get_base_url()}packages", form, get_auth_headers())
    case resp do
      {:ok, %HTTPoison.Response{status_code: 201}} -> IO.puts("success")
      _ -> IO.puts("error")
    end
  end

  def install(%{package: package_name, version: version}) do
    url = "#{get_base_url()}packages/#{package_name}?download=true"
    url = if version do
      url <> "&version=#{version}"
    else
      url
    end
    HTTPoison.start()
    %HTTPoison.Response{body: body} = HTTPoison.get!(url, get_auth_headers())
    File.mkdir("packages/")
    :erl_tar.extract({:binary, body}, [{:cwd, "packages/"}, :compressed])
  end

  defp get_base_url() do
    "http://localhost:4000/api/"
  end

  defp get_auth_headers() do
    ["x-auth-user": "foo", "x-auth-password": "bar"]
  end
end
