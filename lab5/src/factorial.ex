defmodule Factorial do
  @moduledoc false
  def fac1(n) do
    if n <= 1 do
        1
      else
        n*fac1(n-1)
      end
  end

  def fac2(n) do
    cond do
      n <= 1  -> 1
      true    -> n * fac2(n-1)
    end
  end

  def fac3(n) do
    case n do
      0  -> 1
      _     -> n * fac3(n-1)
    end
  end

  defp fac4(0) do 1 end
  defp fac4(n) do n*fac4(n-1) end

  def fac5(n) do fac4(n) end

  defp fac6(1, acc) do acc end
  defp fac6(n, acc) do fac6(n-1, n*acc) end

  def fac7(0), do: 1
  def fac7(n) do fac6(n, 1) end

  def fac8(n, acc \\ 1)
  def fac8(1, acc) do acc end
  def fac8(n, acc) do fac8(n-1, acc*n) end

end
