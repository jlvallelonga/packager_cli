defmodule PackagrApi do
  def search(query) do
    HTTPoison.start()

    %HTTPoison.Response{body: body} =
      HTTPoison.get!("#{get_base_url()}packages?query=#{query}", get_auth_headers())

    Poison.decode!(body)
  end

  def publish(filepath) do
    HTTPoison.start()

    form =
      {:multipart,
       [
         {:file, filepath,
          {"form-data", [{:name, "package"}, {:filename, Path.basename(filepath)}]}, []}
       ]}

    resp = HTTPoison.post("#{get_base_url()}packages", form, get_auth_headers())

    case resp do
      {:ok, %HTTPoison.Response{status_code: 201}} -> :success
      _ -> :error
    end
  end

  def install(package_name, version) do
    url = "#{get_base_url()}packages/#{package_name}?download=true"

    url =
      if version do
        url <> "&version=#{version}"
      else
        url
      end

    HTTPoison.start()
    %HTTPoison.Response{body: file_gzipped_data} = HTTPoison.get!(url, get_auth_headers())

    file_gzipped_data
  end

  defp get_base_url() do
    Application.get_env(:packagr_cli, :base_url)
  end

  defp get_auth_headers() do
    username = Application.get_env(:packagr_cli, :username)
    password = Application.get_env(:packagr_cli, :password)
    ["x-auth-user": username, "x-auth-password": password]
  end
end

defmodule PackagrApi.InMemory do
  def search(query) do
    %{
      "packages" => [
        %{"id" => 1, "name" => query, "version" => "0.0.1"}
      ]
    }
  end

  def publish(_filepath) do
    :success
  end

  def install(package_name, version) do
    File.mkdir("temp/")

    files = [
      {'example/example.js', "console.log(\"this is an example package\");\n"},
      {'example/packagr.yml', "name: #{package_name}\nversion: #{version}\n"}
    ]

    :erl_tar.create("temp/package.tar.gz", files, [:compressed])

    {:ok, package_gzipped_data} = File.read("temp/package.tar.gz")
    package_gzipped_data
  end
end
