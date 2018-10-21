defmodule Api do
  @typedoc """
  literally either :success or :error
  """
  @type success_or_error :: :success | :error

  @callback search(String.t) :: map()
  @callback publish(String.t) :: success_or_error
  @callback install(String.t, String.t) :: binary()
end
