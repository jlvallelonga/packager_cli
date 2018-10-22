defmodule FileCase do
  use ExUnit.CaseTemplate

  setup do
    # an 8 character long random directory name probably won't cause conflicts
    directory_name = Faker.Util.format("%8a") <> "/"
    File.mkdir(directory_name)

    on_exit(fn ->
      File.rm_rf(directory_name)
    end)

    {:ok, %{directory_name: directory_name}}
  end
end
