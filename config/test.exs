use Mix.Config

config :packagr_cli,
  base_url: "http://localhost:4000/api/",
  username: "foo",
  password: "bar",
  packagr_api: PackagrApi.InMemory
